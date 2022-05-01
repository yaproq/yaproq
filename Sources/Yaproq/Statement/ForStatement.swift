final class ForStatement: Statement {
    var key: AnyExpression?
    var value: AnyExpression
    let expression: AnyExpression
    let body: Statement

    init(
        key: AnyExpression? = nil,
        value: AnyExpression,
        expression: AnyExpression,
        body: Statement
    ) {
        self.key = key
        self.value = value
        self.expression = expression
        self.body = body
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitFor(statement: self)
    }
}
