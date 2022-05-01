struct LiteralExpression: Expression {
    let token: Token

    init(token: Token) {
        self.token = token
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteral(expression: self)
    }
}
