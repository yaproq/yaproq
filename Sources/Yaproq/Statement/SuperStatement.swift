struct SuperStatement: Statement {
    func accept(visitor: StatementVisitor) throws {
        try visitor.visitSuper(statement: self)
    }
}
