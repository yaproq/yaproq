struct VariableStatement: Statement {
    let token: Token
    let expression: AnyExpression?

    init(token: Token, expression: AnyExpression? = nil) {
        self.token = token
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitVariable(statement: self)
    }
}
