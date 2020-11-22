protocol Expression {
    func accept(visitor: ExpressionVisitor) throws -> Any?
}

protocol ExpressionVisitor {
    func visitAssignment(expression: AssignmentExpression) throws -> Any?
    func visitBinary(expression: BinaryExpression) throws -> Any
    func visitGrouping(expression: GroupingExpression) throws -> Any?
    func visitLiteral(expression: LiteralExpression) throws -> Any?
    func visitLogical(expression: LogicalExpression) throws -> Any?
    func visitUnary(expression: UnaryExpression) throws -> Any
    func visitVariable(expression: VariableExpression) throws -> Any?
}

class AssignmentExpression: Expression {
    let token: Token
    let value: Expression

    init(token: Token, value: Expression) {
        self.token = token
        self.value = value
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitAssignment(expression: self)
    }
}

class BinaryExpression: Expression {
    let left: Expression
    let token: Token
    let right: Expression

    init(left: Expression, token: Token, right: Expression) {
        self.left = left
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitBinary(expression: self)
    }
}

class GroupingExpression: Expression {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitGrouping(expression: self)
    }
}

class LiteralExpression: Expression {
    let token: Token

    init(token: Token) {
        self.token = token
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLiteral(expression: self)
    }
}

class LogicalExpression: Expression {
    let left: Expression
    let token: Token
    let right: Expression

    init(left: Expression, token: Token, right: Expression) {
        self.left = left
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitLogical(expression: self)
    }
}

class UnaryExpression: Expression {
    let token: Token
    let right: Expression

    init(token: Token, right: Expression) {
        self.token = token
        self.right = right
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitUnary(expression: self)
    }
}

class VariableExpression: Expression {
    let token: Token
    let value: Expression?

    init(token: Token, value: Expression? = nil) {
        self.token = token
        self.value = value
    }

    func accept(visitor: ExpressionVisitor) throws -> Any? {
        try visitor.visitVariable(expression: self)
    }
}
