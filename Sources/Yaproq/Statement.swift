protocol Statement {
    func accept(visitor: StatementVisitor) throws
}

protocol StatementVisitor {
    func visitBlock(statement: BlockStatement) throws
    func visitExpression(statement: ExpressionStatement) throws
    func visitExtend(statement: ExtendStatement) throws
    func visitIf(statement: IfStatement) throws
    func visitInclude(statement: IncludeStatement) throws
    func visitPrint(statement: PrintStatement) throws
    func visitSuper(statement: SuperStatement) throws
    func visitVariable(statement: VariableStatement) throws
    func visitWhile(statement: WhileStatement) throws
}

class BlockStatement: Statement {
    let name: String?
    var statements: [Statement]

    init(name: String? = nil, statements: [Statement] = .init()) {
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

class IncludeStatement: Statement {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitInclude(statement: self)
    }
}

class PrintStatement: Statement {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrint(statement: self)
    }
}

class SuperStatement: Statement {
    func accept(visitor: StatementVisitor) throws {
        try visitor.visitSuper(statement: self)
    }
}

class VariableStatement: Statement {
    let token: Token
    let expression: Expression?

    init(token: Token, expression: Expression? = nil) {
        self.token = token
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitVariable(statement: self)
    }
}

class WhileStatement: Statement {
    let condition: Expression
    let body: Statement

    init(condition: Expression, body: Statement) {
        self.condition = condition
        self.body = body
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitWhile(statement: self)
    }
}
