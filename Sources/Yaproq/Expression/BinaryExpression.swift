struct BinaryExpression: Expression {
    let left: AnyExpression
    let token: Token
    let right: AnyExpression

    init(left: AnyExpression, token: Token, right: AnyExpression) {
        self.left = left
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitBinary(expression: self)
    }
}
