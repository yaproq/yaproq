struct AnyExpression: Expression {
    let expression: Any

    init<T: Expression>(_ expression: T) {
        self.expression = expression
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitAny(expression: self)
    }

    static func == (lhs: AnyExpression, rhs: AnyExpression) -> Bool {
        String(describing: lhs.expression) == String(describing: rhs.expression)
    }
}
