final class Environment {
    let parent: Environment?
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
            throw Yaproq.runtimeError(.undefinedVariable(name: name), token: token)
        }
    }

    func defineVariable(value: Any? = nil, for token: Token) throws {
        let name = token.lexeme

        if hasVariable(named: name) {
            throw Yaproq.runtimeError(.variableExists(name: name), token: token)
        }

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

                for property in components {
                    if let object = value as? Encodable {
                        value = try object.asDictionary()?[property]
                    }
                }

                return value
            }

            if let parent = parent { return try parent.getVariableValue(for: token) }
        }

        throw Yaproq.runtimeError(.undefinedVariable(name: token.lexeme), token: token)
    }

    func clear() {
        variables.removeAll()
        variableNames.removeAll()
    }
}
