struct FunctionExpression: Expression {
    let callee: AnyExpression
    let arguments: [AnyExpression]
    let rightParenthesis: Token

    init(callee: AnyExpression, arguments: [AnyExpression] = .init(), rightParenthesis: Token) {
        self.callee = callee
        self.arguments = arguments
        self.rightParenthesis = rightParenthesis
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitFunction(expression: self)
    }
}
