import Foundation

class Parser {
    let tokens: [Token]
    private var current = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    private func match(_ kinds: Token.Kind...) -> Bool {
        for kind in kinds {
            if check(kind) {
                advance()
                return true
            }
        }

        return false
    }

    private func check(_ kind: Token.Kind) -> Bool {
        if isAtEnd() { return false }
        return peek().kind == kind
    }

    @discardableResult
    private func advance() -> Token {
        if !isAtEnd() { current += 1 }
        return previous()
    }

    private func isAtEnd() -> Bool {
        peek().kind == .eof
    }

    private func peek() -> Token {
        tokens[current]
    }

    private func previous() -> Token {
        tokens[current - 1]
    }

    @discardableResult
    private func consume(_ kind: Token.Kind, elseErrorMessage message: String) throws -> Token {
        if check(kind) { return advance() }
        let token = peek()
        throw SyntaxError(message, line: token.line, column: token.column)
    }

    private func synchronize() {
        advance()

        while !isAtEnd() {
            if previous().kind == .newline { return }

            switch peek().kind {
            case .block,
                 .extend,
                 .for,
                 .if,
                 .include,
                 .print,
                 .super,
                 .var,
                 .while:
                return
            default:
                advance()
            }
        }
    }

    func parse() throws -> [Statement] {
        var statements: [Statement] = .init()

        while !isAtEnd() {
            if let statement = declarationStatement() {
                statements.append(statement)
            }
        }

        return statements
    }
}

// MARK: - Statement

extension Parser {
    private func statement() throws -> Statement {
        if match(.block) { return try blockStatement() }
        if match(.extend) { return try extendStatement() }
        if match(.if) { return try ifStatement() }
        if match(.include) { return try includeStatement() }
        if match(.print) { return try printStatement() }
        if match(.super) { return try superStatement() }
        if match(.while) { return try whileStatement() }
        if match(.leftBrace) { return BlockStatement(statements: try blockStatements()) }
        return try expressionStatement()
    }

    private func blockStatement() throws -> Statement {
        var name: String?

        while !check(.leftBrace) && !isAtEnd() {
            if let expression = try self.expression() as? VariableExpression {
                if name == nil {
                    name = expression.token.lexeme
                } else {
                    let token = previous()
                    throw SyntaxError("Invalid name for `block`.", line: token.line, column: token.column)
                }
            } else {
                let token = previous()
                throw SyntaxError("Invalid name for `block`.", line: token.line, column: token.column)
            }
        }

        if name == nil {
            let token = previous()
            throw SyntaxError("Invalid name for `block`.", line: token.line, column: token.column)
        }

        try consume(.leftBrace, elseErrorMessage: "Expect '{' after block name.")

        return BlockStatement(name: name, statements: try blockStatements())
    }

    private func blockStatements() throws -> [Statement] {
        var statements: [Statement] = .init()

        while !check(.rightBrace) && !isAtEnd() {
            if let statement = declarationStatement() { statements.append(statement) }
        }

        try consume(.rightBrace, elseErrorMessage: "Expect '}' after block.")

        return statements
    }

    private func declarationStatement() -> Statement? {
        do {
            if match(.var) { return try variableDeclarationStatement() }
            return try statement()
        } catch {
            synchronize()
            return nil
        }
    }

    private func elseIfStatement() throws -> IfStatement {
        IfStatement(condition: try expression(), thenBranch: try statement())
    }

    private func expressionStatement() throws -> Statement {
        ExpressionStatement(expression: try self.expression())
    }

    private func extendStatement() throws -> Statement {
        ExtendStatement(expression: try self.expression())
    }

    private func ifStatement() throws -> Statement {
        let condition = try expression()
        let thenBranch = try statement()
        var elseIfBranches: [IfStatement] = .init()
        while match(.elseif) { elseIfBranches.append(try elseIfStatement()) }
        let elseBranch = match(.else) ? try statement() : nil

        return IfStatement(
            condition: condition,
            thenBranch: thenBranch,
            elseIfBranches: elseIfBranches,
            elseBranch: elseBranch
        )
    }

    private func includeStatement() throws -> Statement {
        IncludeStatement(expression: try self.expression())
    }

    private func printStatement() throws -> Statement {
        PrintStatement(expression: try self.expression())
    }

    private func superStatement() throws -> Statement {
        SuperStatement()
    }

    private func variableDeclarationStatement() throws -> Statement {
        let token = try consume(.identifier, elseErrorMessage: "Expect variable name.")
        var expression: Expression?
        if match(.equal) { expression = try self.expression() }

        return VariableStatement(token: token, expression: expression)
    }

    private func whileStatement() throws -> Statement {
        WhileStatement(condition: try expression(), body: try statement())
    }
}

// MARK: - Expression

extension Parser {
    private func expression() throws -> Expression {
        try assignmentExpression()
    }

    private func assignmentExpression() throws -> Expression {
        let expression = try orExpression()

        if match(.equal) {
            let token = previous()
            let value = try assignmentExpression()

            if let variableExpression = expression as? VariableExpression {
                return AssignmentExpression(token: variableExpression.token, value: value)
            }

            throw SyntaxError("Invalid assignment target.", line: token.line, column: token.column)
        }

        return expression
    }

    private func orExpression() throws -> Expression {
        var expression = try andExpression()

        while match(.or) {
            expression = LogicalExpression(left: expression, token: previous(), right: try andExpression())
        }

        return expression
    }

    private func andExpression() throws -> Expression {
        var expression = try equalityExpression()

        while match(.and) {
            expression = LogicalExpression(left: expression, token: previous(), right: try equalityExpression())
        }

        return expression
    }

    private func equalityExpression() throws -> Expression {
        var expression = try comparisonExpression()

        while match(.bangEqual, .equalEqual) {
            expression = BinaryExpression(left: expression, token: previous(), right: try comparisonExpression())
        }

        return expression
    }

    private func comparisonExpression() throws -> Expression {
        var expression = try additionExpression()

        while match(.greater, .greaterOrEqual, .less, .lessOrEqual) {
            expression = BinaryExpression(left: expression, token: previous(), right: try additionExpression())
        }

        return expression
    }

    private func additionExpression() throws -> Expression {
        var expression = try multiplicationExpression()

        while match(.minus, .plus) {
            expression = BinaryExpression(left: expression, token: previous(), right: try multiplicationExpression())
        }

        return expression
    }

    private func multiplicationExpression() throws -> Expression {
        var expression = try unaryExpression()

        while match(.slash, .star) {
            expression = BinaryExpression(left: expression, token: previous(), right: try unaryExpression())
        }

        return expression
    }

    private func unaryExpression() throws -> Expression {
        if match(.bang, .minus) {
            return UnaryExpression(token: previous(), right: try unaryExpression())
        }

        return try primaryExpression()
    }

    private func primaryExpression() throws -> Expression {
        if match(.false) { return LiteralExpression(token: previous()) }
        if match(.true) { return LiteralExpression(token: previous()) }
        if match(.nil) { return LiteralExpression(token: previous()) }
        if match(.number, .string) { return LiteralExpression(token: previous()) }
        if match(.identifier) { return VariableExpression(token: previous()) }

        if match(.leftParenthesis) {
            let expression = try self.expression()
            try consume(.rightParenthesis, elseErrorMessage: "Expect ')' after expression.")
            return GroupingExpression(expression: expression)
        }

        let token = peek()
        throw SyntaxError("Expect expression.", line: token.line, column: token.column)
    }
}
