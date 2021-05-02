final class Environment {
    let parent: Environment?
    private var variables: [String: Any] = .init()

    init(parent: Environment? = nil) {
        self.parent = parent
    }

    func assignVariable(value: Any?, for token: Token) throws {
        let name = token.lexeme

        if variables.contains(where: { $0.key == name }) {
            variables[name] = value
        } else {
            do {
                try getVariableValue(for: token)
                variables[name] = value
            } catch {
                throw error
            }
        }
    }

    func defineVariable(value: Any? = nil, for token: Token) throws {
        let name = token.lexeme

        if variables.contains(where: { $0.key == name }) {
            throw Yaproq.runtimeError(.variableExists(name: name), token: token)
        }

        variables[name] = value
    }

    func setVariable(value: Any?, for name: String) {
        variables[name] = value
    }

    @discardableResult
    func getVariableValue(for token: Token) throws -> Any? {
        var components = token.lexeme.components(separatedBy: Token.Kind.dot.rawValue)
        let name = components.first ?? ""

        if variables.contains(where: { $0.key == name }) {
            var value = variables[name]

            if components.count > 1 {
                components.removeFirst()

                for component in components {
                    if let array = value as? [Encodable] {
                        value = array
                    } else if let dictionary = value as? [String: Any] {
                        value = dictionary[component]
                    } else if let object = value as? Encodable {
                        value = try object.asDictionary()?[component]
                    }
                }
            }

            return value
        }

        if let parent = parent { return try parent.getVariableValue(for: token) }
        throw Yaproq.runtimeError(.undefinedVariable(name: name), token: token)
    }

    func clear() {
        variables.removeAll()
    }
}
