final class Environment {
    let parent: Environment?
    private var variables: [String: Any]
    private var variableNames: Set<String>

    init(parent: Environment? = nil) {
        self.parent = parent
        variables = .init()
        variableNames = Set(variables.keys)
    }

    func setVariable(named name: String, with value: Any? = nil) {
        variableNames.insert(name)
        variables[name] = value
    }

    func defineVariable(for token: Token, with value: Any? = nil) throws {
        let name = token.lexeme

        if variableNames.contains(name) {
            throw Yaproq.runtimeError(for: token, with: "A variable '\(name)' already exists.")
        }

        variableNames.insert(name)
        variables[name] = value
    }

    func assign(value: Any?, toVariableWith token: Token) throws {
        let name = token.lexeme

        if variableNames.contains(name) {
            variables[name] = value
        } else if let parent = parent {
            try parent.assign(value: value, toVariableWith: token)
        } else {
            throw Yaproq.runtimeError(for: token, with: "An undefined variable '\(name)'.")
        }
    }

    func valueForVariable(with token: Token) throws -> Any? {
        var components = token.lexeme.components(separatedBy: Token.Kind.dot.rawValue)
        let name = components.first ?? ""

        if variableNames.contains(name) {
            var value = variables[name]

            if components.count > 1 {
                components.removeFirst()

                for component in components {
                    if let array = value as? Array<Encodable> {
                        value = array
                    } else if let object = value as? Encodable {
                        value = try object.asDictionary()?[component]
                    } else if let dictionary = value as? [String: Any] {
                        value = dictionary[component]
                    }
                }
            }

            return value
        }

        if let parent = parent { return try parent.valueForVariable(with: token) }
        throw Yaproq.runtimeError(for: token, with: "An undefined variable '\(name)'.")
    }

    func reset() {
        variables.removeAll()
        variableNames.removeAll()
    }
}
