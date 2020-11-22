protocol Expression {
    func accept(visitor: ExpressionVisitor) throws -> Any?
}

protocol ExpressionVisitor {}
