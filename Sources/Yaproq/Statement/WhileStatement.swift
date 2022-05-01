struct WhileStatement: Statement {
    let condition: AnyExpression
    let body: Statement

    init(condition: AnyExpression, body: Statement) {
        self.condition = condition
        self.body = body
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitWhile(statement: self)
    }
}
