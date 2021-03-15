protocol Expression: Equatable {
    func accept(visitor: ExpressionVisitor) throws -> Any?
}

protocol ExpressionVisitor {
    func visitAny(expression: AnyExpression) throws -> Any?
    func visitAssignment(expression: AssignmentExpression) throws -> Any?
    func visitBinary(expression: BinaryExpression) throws -> Any?
    func visitGrouping(expression: GroupingExpression) throws -> Any?
    func visitLiteral(expression: LiteralExpression) throws -> Any?
    func visitLogical(expression: LogicalExpression) throws -> Any?
    func visitTernary(expression: TernaryExpression) throws -> Any?
    func visitUnary(expression: UnaryExpression) throws -> Any
    func visitVariable(expression: VariableExpression) throws -> Any?
}

struct AnyExpression: Expression {
    let expression: Any

    init<T: Expression>(_ expression: T) {
        self.expression = expression
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitAny(expression: self)
    }

    static func ==(lhs: AnyExpression, rhs: AnyExpression) -> Bool {
        String(describing: lhs.expression) == String(describing: rhs.expression)
    }
}

struct AssignmentExpression: Expression {
    let identifierToken: Token
    let operatorToken: Token
    let value: AnyExpression

    init(identifierToken: Token, operatorToken: Token, value: AnyExpression) {
        self.identifierToken = identifierToken
        self.operatorToken = operatorToken
        self.value = value
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitAssignment(expression: self)
    }
}

struct BinaryExpression: Expression {
    let left: AnyExpression
    let token: Token
    let right: AnyExpression

    init(left: AnyExpression, token: Token, right: AnyExpression) {
        self.left = left
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitBinary(expression: self)
    }
}

struct GroupingExpression: Expression {
    let expression: AnyExpression

    init(expression: AnyExpression) {
        self.expression = expression
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitGrouping(expression: self)
    }
}

struct LiteralExpression: Expression {
    let token: Token

    init(token: Token) {
        self.token = token
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteral(expression: self)
    }
}

struct LogicalExpression: Expression {
    let left: AnyExpression
    let token: Token
    let right: AnyExpression

    init(left: AnyExpression, token: Token, right: AnyExpression) {
        self.left = left
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLogical(expression: self)
    }
}

struct TernaryExpression: Expression {
    let condition: AnyExpression
    let firstToken: Token
    let first: AnyExpression
    let secondToken: Token
    let second: AnyExpression

    init(
        condition: AnyExpression,
        firstToken: Token,
        first: AnyExpression,
        secondToken: Token,
        second: AnyExpression
    ) {
        self.condition = condition
        self.firstToken = firstToken
        self.first = first
        self.secondToken = secondToken
        self.second = second
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitTernary(expression: self)
    }
}

struct UnaryExpression: Expression {
    let token: Token
    let right: AnyExpression

    init(token: Token, right: AnyExpression) {
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitUnary(expression: self)
    }
}

struct VariableExpression: Expression {
    var token: Token
    var key: AnyExpression?

    init(token: Token, key: AnyExpression? = nil) {
        self.token = token
        self.key = key
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitVariable(expression: self)
    }
}
