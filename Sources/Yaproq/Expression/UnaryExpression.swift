struct UnaryExpression: Expression {
    let token: Token
    let right: AnyExpression

    init(token: Token, right: AnyExpression) {
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitUnary(expression: self)
    }
}
