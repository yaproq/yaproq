protocol Expression: Equatable {
    func accept(visitor: ExpressionVisitor) throws -> Any?
}

protocol ExpressionVisitor {
    func visitAny(expression: AnyExpression) throws -> Any?
    func visitAssignment(expression: AssignmentExpression) throws -> Any?
    func visitBinary(expression: BinaryExpression) throws -> Any?
    func visitFunction(expression: FunctionExpression) throws -> Any?
    func visitGrouping(expression: GroupingExpression) throws -> Any?
    func visitLiteral(expression: LiteralExpression) throws -> Any?
    func visitLogical(expression: LogicalExpression) throws -> Any?
    func visitTernary(expression: TernaryExpression) throws -> Any?
    func visitUnary(expression: UnaryExpression) throws -> Any
    func visitVariable(expression: VariableExpression) throws -> Any?
}
