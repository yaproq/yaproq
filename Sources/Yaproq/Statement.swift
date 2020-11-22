protocol Statement {
    func accept(visitor: StatementVisitor) throws
}

protocol StatementVisitor {
    func visitBlock(statement: BlockStatement) throws
    func visitExpression(statement: ExpressionStatement) throws
}

class BlockStatement: Statement {
    let name: String?
    var statements: [Statement]

    init(name: String? = nil, statements: [Statement]) {
        self.name = name
        self.statements = statements
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitBlock(statement: self)
    }
}

class ExpressionStatement: Statement {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitExpression(statement: self)
    }
}
