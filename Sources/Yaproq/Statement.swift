protocol Statement {
    func accept(visitor: StatementVisitor) throws
}

protocol StatementVisitor {}
