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

    func defineVariable(named name: String, with value: Any? = nil) throws {
        if variableNames.contains(name) {
            throw RuntimeError("A variable '\(name)' already exists.", line: 0, column: 0)
        }

        variableNames.insert(name)
        mutableVariables[name] = value
    }

    func defineVariable(for token: Token, with value: Any? = nil) throws {
        let name = token.lexeme

        if variableNames.contains(name) {
            throw RuntimeError("A variable '\(name)' already exists.", line: token.line, column: token.column)
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
            throw RuntimeError("An undefined variable '\(name)'.", line: token.line, column: token.column)
        }
    }

    func valueForVariable(with token: Token) throws -> Any? {
        let name = token.lexeme
        if variableNames.contains(name) { return mutableVariables[name] }
        if let parent = parent { return try parent.valueForVariable(with: token) }
        throw RuntimeError("An undefined variable '\(name)'.", line: token.line, column: token.column)
    }
}
