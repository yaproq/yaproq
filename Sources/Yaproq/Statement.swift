protocol Statement {
    func accept(visitor: StatementVisitor) throws
}

protocol StatementVisitor {
    func visitBlock(statement: BlockStatement) throws
    func visitExpression(statement: ExpressionStatement) throws
    func visitExtend(statement: ExtendStatement) throws
    func visitIf(statement: IfStatement) throws
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

class ExtendStatement: Statement {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitExtend(statement: self)
    }
}

class IfStatement: Statement {
    let condition: Expression
    let thenBranch: Statement
    let elseIfBranches: [IfStatement]?
    let elseBranch: Statement?

    init(
        condition: Expression,
        thenBranch: Statement,
        elseIfBranches: [IfStatement]? = nil,
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
