import Foundation

final class Interpreter {
    let templating: Yaproq
    private var output = ""
    private var statements: [Statement]

    init(templating: Yaproq, statements: [Statement] = .init()) {
        self.templating = templating
        self.statements = statements
    }

    func interpret() throws -> String {
        let extendStatements = statements.filter { $0 is ExtendStatement }
        let count = extendStatements.count

        if count > 0 {
            if !(statements.first is ExtendStatement) {
                throw TemplateError(
                    "The '\(Token.Kind.extend.rawValue)' must the first statement in a template file."
                )
            }

            if count > 1 {
                throw TemplateError("Extending multiple templates is not supported.")
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

        return output
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
            return left == right || left.description == right.description
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
        let previousEnvironment = templating.environment
        templating.environment = environment
        defer { templating.environment = previousEnvironment }
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
        } else if let expression = expression.expression as? TernaryExpression {
            return try visitTernary(expression: expression)
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
            try templating.environment.assign(value: value, toVariableWith: expression.identifierToken)
            return value
        case .minusEqual,
             .percentEqual,
             .plusEqual,
             .powerEqual,
             .slashEqual,
             .starEqual:
            guard
                let left = try templating.environment.valueForVariable(with: expression.identifierToken) as? Double,
                let right = try evaluate(expression: expression.value) as? Double else {
                throw RuntimeError(
                    "The operands must be numbers.",
                    filePath: expression.operatorToken.filePath,
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
            } else if expression.operatorToken.kind == .powerEqual {
                value = pow(left, right)
            } else if expression.operatorToken.kind == .slashEqual {
                value = left / right
            } else {
                value = left * right
            }

            try templating.environment.assign(value: value, toVariableWith: expression.identifierToken)

            return value
        default:
            throw RuntimeError(
                "An invalid operator `\(expression.operatorToken.lexeme)`.",
                filePath: expression.operatorToken.filePath,
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
        case .closedRange,
             .halfOpenRange:
            var lowerBound = left as? Double
            var upperBound = right as? Double

            if lowerBound == nil, let expression = left as? VariableExpression {
                lowerBound = try visitVariable(expression: expression) as? Double
            }

            if upperBound == nil, let expression = right as? VariableExpression {
                upperBound = try visitVariable(expression: expression) as? Double
            }

            if let lowerBound = lowerBound, let upperBound = upperBound {
                if expression.token.kind == .closedRange {
                    let range: CountableClosedRange = Int(lowerBound)...Int(upperBound)
                    return range
                } else {
                    let range: CountableRange = Int(lowerBound)..<Int(upperBound)
                    return range
                }
            }

            let token = expression.token
            throw RuntimeError(
                "The operands must be either integers or variables that evaluate to integers.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .equalEqual:
            return isEqual(left, right)
        case .greater:
            if let left = left as? Double, let right = right as? Double { return left > right }
            if let left = left as? String, let right = right as? String { return left > right }
            if let left = left as? Date, let right = right as? Date { return left > right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be comparable.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .greaterOrEqual:
            if let left = left as? Double, let right = right as? Double { return left >= right }
            if let left = left as? String, let right = right as? String { return left >= right }
            if let left = left as? Date, let right = right as? Date { return left >= right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be comparable.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .less:
            if let left = left as? Double, let right = right as? Double { return left < right }
            if let left = left as? String, let right = right as? String { return left < right }
            if let left = left as? Date, let right = right as? Date { return left < right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be comparable.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .lessOrEqual:
            if let left = left as? Double, let right = right as? Double { return left <= right }
            if let left = left as? String, let right = right as? String { return left <= right }
            if let left = left as? Date, let right = right as? Date { return left <= right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be comparable.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .minus:
            if let left = left as? Double, let right = right as? Double { return left - right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be numbers.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .percent:
            if let left = left as? Double, let right = right as? Double {
                return left.truncatingRemainder(dividingBy: right)
            }

            let token = expression.token
            throw RuntimeError(
                "The operands must be numbers.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .plus:
            if let left = left as? Double, let right = right as? Double {
                return left + right
            } else if let left = left as? String, let right = right as? String {
                return left + right
            }

            let token = expression.token
            throw RuntimeError(
                "The operands must be two numbers or strings.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .power:
            if let left = left as? Double, let right = right as? Double {
                return pow(left, right)
            }

            let token = expression.token
            throw RuntimeError(
                "The operands must be numbers.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .questionQuestion:
            return left ?? right
        case .slash:
            if let left = left as? Double, let right = right as? Double { return left / right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be numbers.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        case .star:
            if let left = left as? Double, let right = right as? Double { return left * right }
            let token = expression.token
            throw RuntimeError(
                "The operands must be numbers.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        default:
            let token = expression.token
            throw RuntimeError(
                "An invalid operator `\(token.lexeme)`.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
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

    func visitTernary(expression: TernaryExpression) throws -> Any? {
        let condition = try evaluate(expression: expression.condition)
        let left = try evaluate(expression: expression.left)
        let right = try evaluate(expression: expression.right)

        return isTruthy(condition) ? left : right
    }

    func visitUnary(expression: UnaryExpression) throws -> Any {
        let right = try evaluate(expression: expression.right)

        switch expression.token.kind {
        case .bang:
            return !isTruthy(right)
        case .minus:
            if let right = right as? Double { return -right }
            let token = expression.token
            throw RuntimeError(
                "The operand must be a number.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        default:
            let token = expression.token
            throw RuntimeError(
                "An invalid operator `\(token.lexeme)`.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        }
    }

    func visitVariable(expression: VariableExpression) throws -> Any? {
        let token = expression.token
        let value = try templating.environment.valueForVariable(with: token)

        if let index = expression.index {
            let index = try evaluate(expression: index)

            if let array = value as? Array<Any> {
                if let index = index as? Double { return array[Int(index)] }
                throw RuntimeError(
                    "The index must be an integer.",
                    filePath: token.filePath,
                    line: token.line,
                    column: token.column
                )
            }

            throw RuntimeError(
                "The `\(token.lexeme)` must be an array.",
                filePath: token.filePath,
                line: token.line,
                column: token.column
            )
        }

        return value
    }
}

extension Interpreter {
    private func extendFile(at filePath: String) throws {
        let template: Template

        do {
            template = try templating.loadTemplate(named: filePath)
        } catch is TemplateError {
            template = try templating.loadTemplate(at: filePath)
        }

        let statements = try templating.parseTemplate(template)
        self.statements.removeFirst()
        self.statements = statements + self.statements
        output = try interpret()
    }
}

extension Interpreter: StatementVisitor {
    func visitBlock(statement: BlockStatement) throws {
        let environment = Environment(parent: templating.environment)

        for variable in statement.variables {
            try environment.defineVariable(for: variable.token, with: variable.token.literal)
        }

        try execute(statements: statement.statements, in: environment)
    }

    func visitExpression(statement: ExpressionStatement) throws {
        try evaluate(expression: statement.expression)
    }

    func visitExtend(statement: ExtendStatement) throws {
        if let expression = statement.expression.expression as? LiteralExpression {
            if let filePath = expression.token.literal as? String {
                try extendFile(at: filePath)
            } else {
                let token = expression.token
                throw RuntimeError(
                    "`\(expression.token.literal ?? "")` is not a valid filePath.",
                    filePath: token.filePath,
                    line: token.line,
                    column: token.column
                )
            }
        } else if let expression = statement.expression.expression as? VariableExpression {
            if let filePath = try visitVariable(expression: expression) as? String {
                try extendFile(at: filePath)
            } else {
                let token = expression.token
                throw RuntimeError(
                    "`\(token.literal ?? "")` is not a valid filePath.",
                    filePath: token.filePath,
                    line: token.line,
                    column: token.column
                )
            }
        }
    }

    func visitFor(statement: ForStatement) throws {
        guard let blockStatement = statement.body as? BlockStatement else { return }

        func assign(value: Any, for key: Any) throws {
            blockStatement.variables = .init()

            if let statementKey = statement.key {
                if var statementKey = statementKey.expression as? VariableExpression {
                    statementKey.token.literal = key
                    blockStatement.variables.append(statementKey)
                } else {
                    throw RuntimeError("Expecting a variable.", filePath: nil, line: 0, column: 0)
                }
            }

            if var statementValue = statement.value.expression as? VariableExpression {
                statementValue.token.literal = value
                blockStatement.variables.append(statementValue)
            } else {
                throw RuntimeError("Expecting a variable.", filePath: nil, line: 0, column: 0)
            }

            try visitBlock(statement: blockStatement)
        }

        if let expression = statement.expression.expression as? BinaryExpression {
            let value = try visitBinary(expression: expression)

            if let closedRange = value as? CountableClosedRange<Int> {
                for (key, value) in closedRange.enumerated() {
                    try assign(value: value, for: Double(key))
                }
            } else if let range = value as? CountableRange<Int> {
                for (key, value) in range.enumerated() {
                    try assign(value: value, for: Double(key))
                }
            } else {
                let token = expression.token
                throw RuntimeError(
                    "The `\(token.lexeme)` is not a valid operator.",
                    filePath: token.filePath,
                    line: token.line,
                    column: token.column
                )
            }
        } else if let expression = statement.expression.expression as? VariableExpression {
            let value = try visitVariable(expression: expression)

            if let array = value as? Array<Any> {
                for (key, value) in array.enumerated() {
                    try assign(value: value, for: Double(key))
                }
            } else {
                let token = expression.token
                throw RuntimeError(
                    "The `\(token.lexeme)` must be an array.",
                    filePath: token.filePath,
                    line: token.line,
                    column: token.column
                )
            }
        }
    }

    func visitInclude(statement: IncludeStatement) throws {
        if let expression = statement.expression.expression as? LiteralExpression {
            if let filePath = expression.token.literal as? String {
                do {
                    output += try templating._renderTemplate(named: filePath)
                } catch is TemplateError {
                    output += try templating._renderTemplate(at: filePath)
                }
            } else {
                let token = expression.token
                throw RuntimeError(
                    "`\(expression.token.literal ?? "")` is not a valid filePath.",
                    filePath: token.filePath,
                    line: token.line,
                    column: token.column
                )
            }
        } else if let expression = statement.expression.expression as? VariableExpression {
            if let filePath = try visitVariable(expression: expression) as? String {
                do {
                    output += try templating._renderTemplate(named: filePath)
                } catch is TemplateError {
                    output += try templating._renderTemplate(at: filePath)
                }
            } else {
                let token = expression.token
                throw RuntimeError(
                    "`\(token.literal ?? "")` is not a valid filePath.",
                    filePath: token.filePath, 
                    line: token.line,
                    column: token.column
                )
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
        output += stringify(value)
    }

    func visitSuper(statement: SuperStatement) throws {}

    func visitVariable(statement: VariableStatement) throws {
        var value: Any?
        if let expression = statement.expression { value = try evaluate(expression: expression) }
        try templating.environment.defineVariable(for: statement.token, with: value)
    }

    func visitWhile(statement: WhileStatement) throws {
        while isTruthy(try evaluate(expression: statement.condition)) {
            try execute(statement: statement.body)
        }
    }
}
