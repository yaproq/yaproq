import Foundation

final class Interpreter {
    let templating: Yaproq
    var environment: Environment
    lazy var statements: [Statement] = .init()

    init(templating: Yaproq, environment: Environment = .init()) {
        self.templating = templating
        self.environment = environment
    }

    func interpret() throws {
        let extendStatements = statements.filter { $0 is ExtendStatement }
        let count = extendStatements.count

        if count > 0 {
            if !(statements.first is ExtendStatement) {
                throw TemplateError("The 'extend' must the first statement in a template file.")
            }

            if count > 1 {
                throw TemplateError("Extending multiple template files is not supported.")
            }
        }

        if let extendStatement = statements.first as? ExtendStatement {
            try visitExtend(statement: extendStatement)
        } else {
            processBlock(statements: &statements)

            for statement in statements {
                try execute(statement: statement)
            }
        }
    }

    private func processBlock(statements: inout [Statement]) {
        var blockStatements: [String: Int] = .init()
        var indexSet: IndexSet = .init()

        for (index, statement) in statements.enumerated() {
            if let blockStatement = statement as? BlockStatement, let name = blockStatement.name {
                if let firstIndex = blockStatements[name],
                   let parentBlockStatement = statements[firstIndex] as? BlockStatement {
                    var childStatements: [Statement] = .init()

                    for childStatement in blockStatement.statements {
                        if childStatement is SuperStatement {
                            childStatements += parentBlockStatement.statements
                        } else {
                            childStatements.append(childStatement)
                        }
                    }

                    blockStatement.statements = childStatements
                    statements[firstIndex] = blockStatement
                } else {
                    blockStatements[name] = index
                    indexSet.insert(index)
                }

                processBlock(statements: &blockStatement.statements)
            } else {
                indexSet.insert(index)
            }
        }

        statements = indexSet.map { statements[$0] }
    }
}

extension Interpreter {
    private func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        if left == nil && right == nil {
            return true
        } else if let left = left as? AnyHashable, let right = right as? AnyHashable {
            return left == right
        }

        return false
    }

    private func isTruthy(_ value: Any?) -> Bool {
        if let value = value as? Bool { return value }
        return false
    }

    private func stringify(_ value: Any?) -> String {
        guard let value = value else { return "" }

        if let value = value as? Double {
            var text = String(value)

            if text.hasSuffix(".0") {
                let range = text.startIndex..<text.index(text.endIndex, offsetBy: -2)
                text = String(text[range])
            }

            return text
        }

        return String(describing: value)
    }

    @discardableResult
    private func evaluate(expression: AnyExpression) throws -> Any? {
        try expression.accept(visitor: self)
    }

    private func execute(statement: Statement) throws {
        try statement.accept(visitor: self)
    }

    private func execute(statements: [Statement], in environment: Environment) throws {
        let previousEnvironment = self.environment
        self.environment = environment
        defer { self.environment = previousEnvironment }
        for statement in statements { try execute(statement: statement) }
    }
}

extension Interpreter: ExpressionVisitor {
    func visitAny(expression: AnyExpression) throws -> Any? {
        if let expression = expression.expression as? AssignmentExpression {
            return try visitAssignment(expression: expression)
        } else if let expression = expression.expression as? BinaryExpression {
            return try visitBinary(expression: expression)
        } else if let expression = expression.expression as? GroupingExpression {
            return try visitGrouping(expression: expression)
        } else if let expression = expression.expression as? LiteralExpression {
            return try visitLiteral(expression: expression)
        } else if let expression = expression.expression as? LogicalExpression {
            return try visitLogical(expression: expression)
        } else if let expression = expression.expression as? UnaryExpression {
            return try visitUnary(expression: expression)
        } else if let expression = expression.expression as? VariableExpression {
            return try visitVariable(expression: expression)
        }

        return nil
    }

    func visitAssignment(expression: AssignmentExpression) throws -> Any? {
        switch expression.operatorToken.kind {
        case .equal:
            let value = try evaluate(expression: expression.value)
            try environment.assign(value: value, toVariableWith: expression.identifierToken)
            return value
        case .minusEqual,
             .percentEqual,
             .plusEqual,
             .slashEqual,
             .starEqual:
            guard
                let left = try environment.valueForVariable(with: expression.identifierToken) as? Double,
                let right = try evaluate(expression: expression.value) as? Double else {
                throw RuntimeError(
                    "Operands must be numbers.",
                    line: expression.operatorToken.line,
                    column: expression.operatorToken.column
                )
            }

            let value: Double

            if expression.operatorToken.kind == .minusEqual {
                value = left - right
            } else if expression.operatorToken.kind == .percentEqual {
                value = left.truncatingRemainder(dividingBy: right)
            } else if expression.operatorToken.kind == .plusEqual {
                value = left + right
            } else if expression.operatorToken.kind == .slashEqual {
                value = left / right
            } else {
                value = left * right
            }

            try environment.assign(value: value, toVariableWith: expression.identifierToken)

            return value
        default:
            throw RuntimeError(
                "An invalid operator `\(expression.operatorToken.kind.rawValue)`.",
                line: expression.operatorToken.line,
                column: expression.operatorToken.column
            )
        }
    }

    func visitBinary(expression: BinaryExpression) throws -> Any? {
        let left = try evaluate(expression: expression.left)
        let right = try evaluate(expression: expression.right)

        switch expression.token.kind {
        case .bangEqual:
            return !isEqual(left, right)
        case .equalEqual:
            return isEqual(left, right)
        case .greater:
            if let left = left as? Double, let right = right as? Double { return left > right }
            if let left = left as? String, let right = right as? String { return left > right }
            if let left = left as? Date, let right = right as? Date { return left > right }
            let token = expression.token
            throw RuntimeError("Operands must be comparable.", line: token.line, column: token.column)
        case .greaterOrEqual:
            if let left = left as? Double, let right = right as? Double { return left >= right }
            if let left = left as? String, let right = right as? String { return left >= right }
            if let left = left as? Date, let right = right as? Date { return left >= right }
            let token = expression.token
            throw RuntimeError("Operands must be comparable.", line: token.line, column: token.column)
        case .less:
            if let left = left as? Double, let right = right as? Double { return left < right }
            if let left = left as? String, let right = right as? String { return left < right }
            if let left = left as? Date, let right = right as? Date { return left < right }
            let token = expression.token
            throw RuntimeError("Operands must be comparable.", line: token.line, column: token.column)
        case .lessOrEqual:
            if let left = left as? Double, let right = right as? Double { return left <= right }
            if let left = left as? String, let right = right as? String { return left <= right }
            if let left = left as? Date, let right = right as? Date { return left <= right }
            let token = expression.token
            throw RuntimeError("Operands must be comparable.", line: token.line, column: token.column)
        case .minus:
            if let left = left as? Double, let right = right as? Double { return left - right }
            let token = expression.token
            throw RuntimeError("Operands must be numbers.", line: token.line, column: token.column)
        case .percent:
            if let left = left as? Double, let right = right as? Double {
                return left.truncatingRemainder(dividingBy: right)
            }

            let token = expression.token
            throw RuntimeError("Operands must be numbers.", line: token.line, column: token.column)
        case .plus:
            if let left = left as? Double, let right = right as? Double {
                return left + right
            } else if let left = left as? String, let right = right as? String {
                return left + right
            }

            let token = expression.token
            throw RuntimeError("Operands must be two numbers or strings.", line: token.line, column: token.column)
        case .questionQuestion:
            return left ?? right
        case .slash:
            if let left = left as? Double, let right = right as? Double { return left / right }
            let token = expression.token
            throw RuntimeError("Operands must be numbers.", line: token.line, column: token.column)
        case .star:
            if let left = left as? Double, let right = right as? Double { return left * right }
            let token = expression.token
            throw RuntimeError("Operands must be numbers.", line: token.line, column: token.column)
        default:
            let token = expression.token
            throw RuntimeError("Invalid operator.", line: token.line, column: token.column)
        }
    }

    func visitGrouping(expression: GroupingExpression) throws -> Any? {
        try evaluate(expression: expression.expression)
    }

    func visitLiteral(expression: LiteralExpression) throws -> Any? {
        expression.token.literal
    }

    func visitLogical(expression: LogicalExpression) throws -> Any? {
        let left = try evaluate(expression: expression.left)

        if expression.token.kind == .or {
            if isTruthy(left) { return left }
        } else {
            if !isTruthy(left) { return left }
        }

        return try evaluate(expression: expression.right)
    }

    func visitUnary(expression: UnaryExpression) throws -> Any {
        let right = try evaluate(expression: expression.right)

        switch expression.token.kind {
        case .bang:
            return !isTruthy(right)
        case .minus:
            if let right = right as? Double { return -right }
            let token = expression.token
            throw RuntimeError("Operand must be a number.", line: token.line, column: token.column)
        default:
            let token = expression.token
            throw RuntimeError("Invalid operator.", line: token.line, column: token.column)
        }
    }

    func visitVariable(expression: VariableExpression) throws -> Any? {
        try environment.valueForVariable(with: expression.token)
    }
}

extension Interpreter: StatementVisitor {
    func visitBlock(statement: BlockStatement) throws {
        try execute(statements: statement.statements, in: Environment(parent: environment))
    }

    func visitExpression(statement: ExpressionStatement) throws {
        try evaluate(expression: statement.expression)
    }

    func visitExtend(statement: ExtendStatement) throws {
        if let expression = statement.expression.expression as? LiteralExpression {
            if let path = expression.token.literal as? String {
                try extendFile(at: path)
            } else {
                let token = expression.token
                throw RuntimeError(
                    "`\(expression.token.literal ?? "")` is not a valid path.",
                    line: token.line,
                    column: token.column
                )
            }
        } else if let expression = statement.expression.expression as? VariableExpression {
            if let path = try visitVariable(expression: expression) as? String {
                try extendFile(at: path)
            } else {
                let token = expression.token
                throw RuntimeError("This is not a valid path.", line: token.line, column: token.column)
            }
        }
    }

    private func extendFile(at path: String) throws {
        let source: String

        do {
            source = try templating.loadTemplate(named: path)
        } catch {
            source = try templating.loadTemplate(at: path)
        }

        let statements = try templating.parse(source)
        self.statements.removeFirst()
        self.statements = statements + self.statements
        try interpret()
    }

    func visitInclude(statement: IncludeStatement) throws {
        if let expression = statement.expression.expression as? LiteralExpression {
            if let path = expression.token.literal as? String {
                do {
                    try templating.renderTemplate(named: path)
                } catch {
                    try templating.renderTemplate(at: path)
                }
            } else {
                let token = expression.token
                throw RuntimeError(
                    "`\(expression.token.literal ?? "")` is not a valid path.",
                    line: token.line,
                    column: token.column
                )
            }
        } else if let expression = statement.expression.expression as? VariableExpression {
            if let path = try visitVariable(expression: expression) as? String {
                do {
                    try templating.renderTemplate(named: path)
                } catch {
                    try templating.renderTemplate(at: path)
                }
            } else {
                let token = expression.token
                throw RuntimeError("This is not a valid path.", line: token.line, column: token.column)
            }
        }
    }

    func visitIf(statement: IfStatement) throws {
        if isTruthy(try evaluate(expression: statement.condition)) {
            try execute(statement: statement.thenBranch)
        } else {
            var isTruthy = false

            for elseIfBranch in statement.elseIfBranches {
                if self.isTruthy(try evaluate(expression: elseIfBranch.condition)) {
                    isTruthy = true
                    try execute(statement: elseIfBranch.thenBranch)
                    break
                }
            }

            if !isTruthy, let elseBranch = statement.elseBranch {
                try execute(statement: elseBranch)
            }
        }
    }

    func visitPrint(statement: PrintStatement) throws {
        let value = try evaluate(expression: statement.expression)
        print(stringify(value), terminator: "")
    }

    func visitSuper(statement: SuperStatement) throws {}

    func visitVariable(statement: VariableStatement) throws {
        var value: Any?
        if let expression = statement.expression { value = try evaluate(expression: expression) }
        try environment.defineVariable(for: statement.token, with: value)
    }

    func visitWhile(statement: WhileStatement) throws {
        while isTruthy(try evaluate(expression: statement.condition)) {
            try execute(statement: statement.body)
        }
    }
}
