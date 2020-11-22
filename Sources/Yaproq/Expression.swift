protocol Expression {
    func accept(visitor: ExpressionVisitor) throws -> Any?
}

protocol ExpressionVisitor {
    func visitAssignment(expression: AssignmentExpression) throws -> Any?
}

class AssignmentExpression: Expression {
    let token: Token
    let value: Expression

    init(token: Token, value: Expression) {
        self.token = token
        self.value = value
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitAssignment(expression: self)
    }
}
