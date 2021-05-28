final class Environment {
    let parent: Environment?
    var directories: Set<String> = .init(arrayLiteral: "/")
    var templates: [String: Template] = .init()
    private var variables: [String: Any] = .init()
    private var variableNames: Set<String> = .init()

    init(parent: Environment? = nil) {
        self.parent = parent
    }

    func assignVariable(value: Any?, for token: Token) throws {
        let name = token.lexeme

        if hasVariable(named: name) {
            setVariable(value: value, for: name)
        } else if let parent = parent {
            try parent.assignVariable(value: value, for: token)
        } else {
            throw runtimeError(.undefinedVariableOrProperty(name), token: token)
        }
    }

    func defineVariable(value: Any? = nil, for token: Token) throws {
        let name = token.lexeme
        if hasVariable(named: name) { throw runtimeError(.variableExists(name), token: token) }
        setVariable(value: value, for: name)
    }

    func hasVariable(named name: String) -> Bool {
        variableNames.contains(name)
    }

    func setVariable(value: Any?, for name: String) {
        variables[name] = value
        variableNames.insert(name)
    }

    @discardableResult
    func getVariableValue(for token: Token) throws -> Any? {
        var components = token.lexeme.components(separatedBy: Token.Kind.dot.rawValue)

        if let name = components.first {
            if hasVariable(named: name) {
                var value = variables[name]
                components.removeFirst()

                for propertyName in components {
                    if let array = value as? [Encodable] {
                        if let property = Property(rawValue: propertyName) {
                            value = try property.value(from: array, for: token)
                        } else {
                            throw runtimeError(.undefinedVariableOrProperty(propertyName), token: token)
                        }
                    } else if let dictionary = value as? [String: Any] {
                        value = dictionary[propertyName]

                        if value == nil {
                            if let property = Property(rawValue: propertyName) {
                                value = try property.value(from: dictionary, for: token)
                            }
                        }
                    } else if let object = value as? Encodable {
                        value = try object.asDictionary()?[propertyName]

                        if value == nil &&
                            !Mirror(reflecting: object).children.contains(where: { $0.label == propertyName }) {
                            throw runtimeError(.undefinedVariableOrProperty(propertyName), token: token)
                        }
                    } else if let string = value as? String {
                        if let property = Property(rawValue: propertyName) {
                            value = try property.value(from: string, for: token)
                        } else {
                            throw runtimeError(.undefinedVariableOrProperty(propertyName), token: token)
                        }
                    }
                }

                return value
            }

            if let parent = parent { return try parent.getVariableValue(for: token) }
        }

        throw runtimeError(.undefinedVariableOrProperty(token.lexeme), token: token)
    }
}
