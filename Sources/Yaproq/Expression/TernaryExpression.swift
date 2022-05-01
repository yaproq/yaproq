struct TernaryExpression: Expression {
    let condition: AnyExpression
    let firstToken: Token
    let first: AnyExpression
    let secondToken: Token
    let second: AnyExpression

    init(
        condition: AnyExpression,
        firstToken: Token,
        first: AnyExpression,
        secondToken: Token,
        second: AnyExpression
    ) {
        self.condition = condition
        self.firstToken = firstToken
        self.first = first
        self.secondToken = secondToken
        self.second = second
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitTernary(expression: self)
    }
}
