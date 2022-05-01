struct IfStatement: Statement {
    let condition: AnyExpression
    let thenBranch: Statement
    let elseIfBranches: [IfStatement]
    let elseBranch: Statement?

    init(
        condition: AnyExpression,
        thenBranch: Statement,
        elseIfBranches: [IfStatement] = .init(),
        elseBranch: Statement? = nil
    ) {
        self.condition = condition
        self.thenBranch = thenBranch
        self.elseIfBranches = elseIfBranches
        self.elseBranch = elseBranch
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitIf(statement: self)
    }
}
