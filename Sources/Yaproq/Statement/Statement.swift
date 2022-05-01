protocol Statement {
    func accept(visitor: StatementVisitor) throws
}

protocol StatementVisitor {
    func visitBlock(statement: BlockStatement) throws
    func visitExpression(statement: ExpressionStatement) throws
    func visitExtend(statement: ExtendStatement) throws
    func visitFor(statement: ForStatement) throws
    func visitIf(statement: IfStatement) throws
    func visitInclude(statement: IncludeStatement) throws
    func visitPrint(statement: PrintStatement) throws
    func visitSuper(statement: SuperStatement) throws
    func visitVariable(statement: VariableStatement) throws
    func visitWhile(statement: WhileStatement) throws
}
