struct AssignmentExpression: Expression {
    let identifierToken: Token
    let operatorToken: Token
    let value: AnyExpression

    init(identifierToken: Token, operatorToken: Token, value: AnyExpression) {
        self.identifierToken = identifierToken
        self.operatorToken = operatorToken
        self.value = value
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitAssignment(expression: self)
    }
}
