final class Environment {
    let parent: Environment?
    private var variables: [String: Any]

    init(parent: Environment? = nil) {
        self.parent = parent
        variables = .init()
    }

    func setVariable(named name: String, with value: Any? = nil) {
        variables[name] = value
    }

    func defineVariable(for token: Token, with value: Any? = nil) throws {
        let name = token.lexeme

        if variables.contains(where: { $0.key == name }) {
            throw Yaproq.runtimeError("A variable '\(name)' already exists.", token: token)
        }

        variables[name] = value
    }

    func assign(value: Any?, toVariableWith token: Token) throws {
        let name = token.lexeme

        if variables.contains(where: { $0.key == name }) {
            variables[name] = value
        } else if let parent = parent {
            try parent.assign(value: value, toVariableWith: token)
        } else {
            throw Yaproq.runtimeError("An undefined variable '\(name)'.", token: token)
        }
    }

    func valueForVariable(with token: Token) throws -> Any? {
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

        if let parent = parent { return try parent.valueForVariable(with: token) }
        throw Yaproq.runtimeError("An undefined variable '\(name)'.", token: token)
    }

    func reset() {
        variables.removeAll()
    }
}
