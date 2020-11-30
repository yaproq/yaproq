final class Environment {
    let parent: Environment?
    var variables: [String: Any] { didSet { variableNames = Set(variables.keys) } }
    private var variableNames: Set<String>

    init(parent: Environment? = nil, variables: [String: Any] = .init()) {
        self.parent = parent
        self.variables = variables
        variableNames = Set(variables.keys)
    }

    func defineVariable(for token: Token, with value: Any? = nil) throws {
        let name = token.lexeme

        if variableNames.contains(name) {
            throw RuntimeError("A variable '\(name)' already exists.", line: token.line, column: token.column)
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
            throw RuntimeError("An undefined variable '\(name)'.", line: token.line, column: token.column)
        }
    }

    func valueForVariable(with token: Token) throws -> Any? {
        let name = token.lexeme
        if variableNames.contains(name) { return variables[name] }
        if let parent = parent { return try parent.valueForVariable(with: token) }
        throw RuntimeError("An undefined variable '\(name)'.", line: token.line, column: token.column)
    }
}
