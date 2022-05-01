final class BlockStatement: Statement {
    let name: String?
    var variables: [VariableExpression]
    var statements: [Statement]

    init(name: String? = nil, variables: [VariableExpression] = .init(), statements: [Statement] = .init()) {
        self.name = name
        self.variables = variables
        self.statements = statements
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitBlock(statement: self)
    }
}
