struct GroupingExpression: Expression {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitGrouping(expression: self)
    }
}
