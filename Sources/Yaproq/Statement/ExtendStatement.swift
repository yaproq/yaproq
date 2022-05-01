struct ExtendStatement: Statement {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitExtend(statement: self)
    }
}
