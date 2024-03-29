import Foundation

final class Parser {
    let tokens: [Token]
    var isAtEnd: Bool { peek.kind == .eof }
    var peek: Token { tokens[current] }
    var previous: Token { tokens[current - 1] }
    private var current = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }
}

extension Parser {
    func parse() throws -> [Statement] {
        var statements = [Statement]()

        while !isAtEnd {
            if let statement = try variableDeclarationStatement() {
                statements.append(statement)
            }
        }

        return statements
    }
}

extension Parser {
    @discardableResult
    private func advance() -> Token {
        if !isAtEnd {
            current += 1
        }

        return previous
    }

    private func check(_ kind: Token.Kind) -> Bool {
        isAtEnd ? false : peek.kind == kind
    }

    @discardableResult
    private func consume(_ kind: Token.Kind, elseError error: ErrorType) throws -> Token {
        if check(kind) {
            return advance()
        }

        throw syntaxError(error, token: peek)
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
}

extension Parser {
    private func blockStatement() throws -> Statement {
        var name: String?
        let leftBrace = Token.Kind.leftBrace

        while !check(leftBrace) && !isAtEnd {
            if let expression = try expression().expression as? VariableExpression {
                if name == nil {
                    name = expression.token.lexeme
                } else {
                    break
                }
            } else {
                break
            }
        }

        if name == nil {
            throw syntaxError(.invalidBlockName(name ?? ""), token: previous)
        }

        try consume(leftBrace, elseError: .expectingCharacter(leftBrace.rawValue))

        return BlockStatement(name: name, statements: try blockStatements())
    }

    private func blockStatements() throws -> [Statement] {
        var statements = [Statement]()
        let rightBrace = Token.Kind.rightBrace

        while !check(rightBrace) && !isAtEnd {
            if let statement = try variableDeclarationStatement() {
                statements.append(statement)
            }
        }

        try consume(rightBrace, elseError: .expectingCharacter(rightBrace.rawValue))

        return statements
    }

    private func elseIfStatement() throws -> IfStatement {
        IfStatement(condition: try expression(), thenBranch: try statement())
    }

    private func expressionStatement() throws -> Statement {
        ExpressionStatement(expression: try expression())
    }

    private func extendStatement() throws -> Statement {
        ExtendStatement(expression: try expression())
    }

    private func forStatement() throws -> Statement {
        var key: AnyExpression?
        let element = try expression()
        var value: AnyExpression

        if match(.comma) {
            key = element
            value = try expression()
        } else {
            value = element
        }

        let token = Token.Kind.in
        try consume(token, elseError: .expectingCharacter(token.rawValue))

        return ForStatement(key: key, value: value, expression: try expression(), body: try statement())
    }

    private func ifStatement() throws -> Statement {
        let condition = try expression()
        let thenBranch = try statement()
        var elseIfBranches = [IfStatement]()

        while match(.elseif) {
            elseIfBranches.append(try elseIfStatement())
        }

        let elseBranch = match(.else) ? try statement() : nil

        return IfStatement(
            condition: condition,
            thenBranch: thenBranch,
            elseIfBranches: elseIfBranches,
            elseBranch: elseBranch
        )
    }

    private func includeStatement() throws -> Statement {
        IncludeStatement(expression: try expression())
    }

    private func printStatement() throws -> Statement {
        PrintStatement(expression: try expression())
    }

    private func statement() throws -> Statement {
        if match(.block) {
            return try blockStatement()
        } else if match(.extend) {
            return try extendStatement()
        } else if match(.for) {
            return try forStatement()
        } else if match(.if) {
            return try ifStatement()
        } else if match(.include) {
            return try includeStatement()
        } else if match(.leftBrace) {
            return BlockStatement(statements: try blockStatements())
        } else if match(.print) {
            return try printStatement()
        } else if match(.super) {
            return superStatement()
        } else if match(.while) {
            return try whileStatement()
        }

        return try expressionStatement()
    }

    private func superStatement() -> Statement {
        SuperStatement()
    }

    private func variableDeclarationStatement() throws -> Statement? {
        match(.var) ? try variableStatement() : try statement()
    }

    private func variableStatement() throws -> Statement {
        let token = try consume(.identifier, elseError: .expectingVariable)
        var expression: AnyExpression?

        if match(.equal) {
            expression = try self.expression()
        }

        return VariableStatement(token: token, expression: expression)
    }

    private func whileStatement() throws -> Statement {
        WhileStatement(condition: try expression(), body: try statement())
    }
}

extension Parser {
    private func additionExpression() throws -> AnyExpression {
        var expression = try multiplicationExpression()

        while match(.minus, .plus) {
            expression = AnyExpression(
                BinaryExpression(left: expression, token: previous, right: try multiplicationExpression())
            )
        }

        return expression
    }

    private func andExpression() throws -> AnyExpression {
        var expression = try equalityExpression()

        while match(.and) {
            expression = AnyExpression(
                LogicalExpression(left: expression, token: previous, right: try equalityExpression())
            )
        }

        return expression
    }

    private func assignmentExpression() throws -> AnyExpression {
        let expression = try ternaryExpression()

        if match(.equal, .minusEqual, .percentEqual, .plusEqual, .powerEqual, .slashEqual, .starEqual) {
            let operatorToken = previous
            let value = try assignmentExpression()

            if let expression = expression.expression as? VariableExpression {
                return AnyExpression(
                    AssignmentExpression(identifierToken: expression.token, operatorToken: operatorToken, value: value)
                )
            }

            throw syntaxError(.invalidAssignmentTarget, token: previous)
        }

        return expression
    }

    private func comparisonExpression() throws -> AnyExpression {
        var expression = try additionExpression()

        while match(.greater, .greaterOrEqual, .less, .lessOrEqual) {
            expression = AnyExpression(
                BinaryExpression(left: expression, token: previous, right: try additionExpression())
            )
        }

        return expression
    }

    private func equalityExpression() throws -> AnyExpression {
        var expression = try comparisonExpression()

        while match(.bangEqual, .equalEqual, .questionQuestion) {
            expression = AnyExpression(
                BinaryExpression(left: expression, token: previous, right: try comparisonExpression())
            )
        }

        return expression
    }

    private func expression() throws -> AnyExpression {
        try assignmentExpression()
    }

    private func functionExpression() throws -> AnyExpression {
        let token = previous

        if match(.leftParenthesis) {
            var arguments = [AnyExpression]()

            if !check(.rightParenthesis) {
                repeat {
                    arguments.append(try self.expression())
                } while match(.comma)
            }

            let kind = Token.Kind.rightParenthesis
            let rightParenthesis = try consume(kind, elseError: .expectingCharacter(kind.rawValue))

            return AnyExpression(
                FunctionExpression(
                    callee: AnyExpression(VariableExpression(token: token)),
                    arguments: arguments,
                    rightParenthesis: rightParenthesis
                )
            )
        }

        return try variableExpression()
    }

    private func groupingExpression() throws -> AnyExpression {
        let expression = try self.expression()
        let rightParenthesis = Token.Kind.rightParenthesis
        try consume(rightParenthesis, elseError: .expectingCharacter(rightParenthesis.rawValue))

        return AnyExpression(GroupingExpression(expression: expression))
    }

    private func literalExpression() -> AnyExpression {
        AnyExpression(LiteralExpression(token: previous))
    }

    private func multiplicationExpression() throws -> AnyExpression {
        var expression = try rangeExpression()

        while match(.percent, .slash, .star) {
            expression = AnyExpression(
                BinaryExpression(left: expression, token: previous, right: try rangeExpression())
            )
        }

        return expression
    }

    private func orExpression() throws -> AnyExpression {
        var expression = try andExpression()

        while match(.or) {
            expression = AnyExpression(
                LogicalExpression(left: expression, token: previous, right: try andExpression())
            )
        }

        return expression
    }

    private func powerExpression() throws -> AnyExpression {
        var expression = try unaryExpression()

        while match(.power) {
            expression = AnyExpression(
                BinaryExpression(left: expression, token: previous, right: try unaryExpression())
            )
        }

        return expression
    }

    private func primaryExpression() throws -> AnyExpression {
        if match(.false, .nil, .number, .string, .true) {
            return literalExpression()
        } else if match(.identifier) {
            return try functionExpression()
        } else if match(.leftParenthesis) {
            return try groupingExpression()
        }

        throw syntaxError(.expectingExpression, token: peek)
    }

    private func rangeExpression() throws -> AnyExpression {
        var expression = try powerExpression()

        while match(.closedRange, .range) {
            expression = AnyExpression(
                BinaryExpression(left: expression, token: previous, right: try powerExpression())
            )
        }

        return expression
    }

    private func ternaryExpression() throws -> AnyExpression {
        var expression = try orExpression()

        while match(.question) {
            let firstToken = previous
            let first = try orExpression()
            var isTernary = false

            while match(.colon) {
                isTernary = true
                let secondToken = previous
                let second = try orExpression()
                expression = AnyExpression(
                    TernaryExpression(
                        condition: expression,
                        firstToken: firstToken,
                        first: first,
                        secondToken: secondToken,
                        second: second
                    )
                )
            }

            if !isTernary {
                throw syntaxError(.invalidCharacter(firstToken.kind.rawValue), token: firstToken)
            }
        }

        return expression
    }

    private func unaryExpression() throws -> AnyExpression {
        match(.bang, .minus)
            ? AnyExpression(UnaryExpression(token: previous, right: try unaryExpression()))
            : try primaryExpression()
    }

    private func variableExpression() throws -> AnyExpression {
        let token = previous

        if match(.leftBracket) {
            let key = try expression()
            let rightBracket = Token.Kind.rightBracket
            try consume(rightBracket, elseError: .expectingCharacter(rightBracket.rawValue))

            return AnyExpression(VariableExpression(token: token, key: key))
        }

        return AnyExpression(VariableExpression(token: token))
    }
}
