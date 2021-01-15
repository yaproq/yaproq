final class Environment {
    let parent: Environment?
    var variables: [String: Any] { mutableVariables }
    private var mutableVariables: [String: Any]
    private var variableNames: Set<String>

    init(parent: Environment? = nil, variables: [String: Any] = .init()) {
        self.parent = parent
        self.mutableVariables = variables
        variableNames = Set(variables.keys)
    }

    func setVariable(named name: String, with value: Any? = nil) {
        variableNames.insert(name)
        mutableVariables[name] = value
    }

    func defineVariable(for token: Token, with value: Any? = nil) throws {
        let name = token.lexeme

        if variableNames.contains(name) {
            throw RuntimeError(
                "A variable '\(name)' already exists.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        }

        variableNames.insert(name)
        mutableVariables[name] = value
    }

    func assign(value: Any?, toVariableWith token: Token) throws {
        let name = token.lexeme

        if variableNames.contains(name) {
            mutableVariables[name] = value
        } else if let parent = parent {
            try parent.assign(value: value, toVariableWith: token)
        } else {
            throw RuntimeError(
                "An undefined variable '\(name)'.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        }
    }

    func valueForVariable(with token: Token) throws -> Any? {
        var components = token.lexeme.components(separatedBy: Token.Kind.dot.rawValue)
        let name = components.first!

        if variableNames.contains(name) {
            var value = mutableVariables[name]

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
        throw RuntimeError(
            "An undefined variable '\(name)'.",
            filePath: token.filePath,
            line: token.line,
            column: token.column
        )
    }
}
