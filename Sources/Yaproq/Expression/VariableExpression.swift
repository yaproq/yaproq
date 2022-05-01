struct VariableExpression: Expression {
    var token: Token
    var key: AnyExpression?

    init(token: Token, key: AnyExpression? = nil) {
        self.token = token
        self.key = key
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitVariable(expression: self)
    }
}
