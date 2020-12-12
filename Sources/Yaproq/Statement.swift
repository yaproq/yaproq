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

final class BlockStatement: Statement {
    let name: String?
    var variables: [VariableExpression]
    var statements: [Statement]

    init(name: String? = nil, variables: [VariableExpression] = .init(), statements: [Statement] = .init()) {
        self.name = name
        self.variables = variables
        self.statements = statements
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitBlock(statement: self)
    }
}

struct ExpressionStatement: Statement {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitExpression(statement: self)
    }
}

struct ExtendStatement: Statement {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitExtend(statement: self)
    }
}

final class ForStatement: Statement {
    var variable: VariableExpression
    let keyword: Token
    let expression: AnyExpression
    let body: Statement

    init(variable: VariableExpression, keyword: Token, expression: AnyExpression, body: Statement) {
        self.variable = variable
        self.keyword = keyword
        self.expression = expression
        self.body = body
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitFor(statement: self)
    }
}

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

struct IncludeStatement: Statement {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitInclude(statement: self)
    }
}

struct PrintStatement: Statement {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrint(statement: self)
    }
}

struct SuperStatement: Statement {
    func accept(visitor: StatementVisitor) throws {
        try visitor.visitSuper(statement: self)
    }
}

struct VariableStatement: Statement {
    let token: Token
    let expression: AnyExpression?

    init(token: Token, expression: AnyExpression? = nil) {
        self.token = token
        self.expression = expression
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitVariable(statement: self)
    }
}

struct WhileStatement: Statement {
    let condition: AnyExpression
    let body: Statement

    init(condition: AnyExpression, body: Statement) {
        self.condition = condition
        self.body = body
    }

    func accept(visitor: StatementVisitor) throws {
        try visitor.visitWhile(statement: self)
    }
}
