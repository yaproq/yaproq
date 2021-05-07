import Foundation

final class Interpreter {
    let templating: Yaproq
    private var result = ""
    private var statements: [Statement]

    init(templating: Yaproq, statements: [Statement] = .init()) {
        self.templating = templating
        self.statements = statements
    }

    func interpret() throws -> String {
        let extendStatements = statements.filter { $0 is ExtendStatement }
        let count = extendStatements.count

        if count > 0 {
            if !(statements.first is ExtendStatement) { throw Yaproq.templateError(.extendMustBeFirstStatement) }
            if count > 1 { throw Yaproq.templateError(.extendingMultipleTemplatesNotSupported) }
        }

        if let extendStatement = statements.first as? ExtendStatement {
            try extendStatement.accept(visitor: self)
        } else {
            try processBlock(statements: &statements)

            for statement in statements {
                try execute(statement: statement)
            }
        }

        return result
    }

    private func processBlock(statements: inout [Statement]) throws {
        var blockStatements: [String: Int] = .init()
        var indexSet: IndexSet = .init()

        for (index, statement) in statements.enumerated() {
            if let blockStatement = statement as? BlockStatement, let name = blockStatement.name {
                if let firstIndex = blockStatements[name],
                   let parentBlockStatement = statements[firstIndex] as? BlockStatement {
                    var childStatements: [Statement] = .init()

                    for childStatement in blockStatement.statements {
                        if let superStatement = childStatement as? SuperStatement {
                            childStatements += parentBlockStatement.statements
                            try superStatement.accept(visitor: self)
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

                try processBlock(statements: &blockStatement.statements)
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

    private func isTruthy(_ value: Any?, for token: Token? = nil) throws -> Bool {
        if let value = value as? Bool { return value }
        if let token = token { throw Yaproq.runtimeError(.operandMustBeBoolean, token: token) }

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
        let previousEnvironment = templating.currentEnvironment
        templating.currentEnvironment = environment
        defer { templating.currentEnvironment = previousEnvironment }
        for statement in statements { try execute(statement: statement) }
    }
}

extension Interpreter: ExpressionVisitor {
    func visitAny(expression: AnyExpression) throws -> Any? {
        if let expression = expression.expression as? AssignmentExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? BinaryExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? GroupingExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? LiteralExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? LogicalExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? TernaryExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? UnaryExpression {
            return try expression.accept(visitor: self)
        } else if let expression = expression.expression as? VariableExpression {
            return try expression.accept(visitor: self)
        }

        return nil
    }

    func visitAssignment(expression: AssignmentExpression) throws -> Any? {
        let currentEnvironment = templating.currentEnvironment

        switch expression.operatorToken.kind {
        case .equal:
            let value = try evaluate(expression: expression.value)
            try currentEnvironment.assignVariable(value: value, for: expression.identifierToken)
            return value
        case .minusEqual,
             .percentEqual,
             .plusEqual,
             .powerEqual,
             .slashEqual,
             .starEqual:
            if let left = try currentEnvironment.getVariableValue(for: expression.identifierToken) as? Double,
               let right = try evaluate(expression: expression.value) as? Double {
                let value: Any

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

                try currentEnvironment.assignVariable(value: value, for: expression.identifierToken)

                return value
            } else if let left = try currentEnvironment.getVariableValue(for: expression.identifierToken) as? Int,
                      let right = try evaluate(expression: expression.value) as? Int {
                let value: Any

                if expression.operatorToken.kind == .minusEqual {
                    value = left - right
                } else if expression.operatorToken.kind == .percentEqual {
                    value = left % right
                } else if expression.operatorToken.kind == .plusEqual {
                    value = left + right
                } else if expression.operatorToken.kind == .powerEqual {
                    value = pow(Decimal(left), right)
                } else if expression.operatorToken.kind == .slashEqual {
                    value = left / right
                } else {
                    value = left * right
                }

                try currentEnvironment.assignVariable(value: value, for: expression.identifierToken)

                return value
            } else if let left = try currentEnvironment.getVariableValue(for: expression.identifierToken) as? Double,
                      let right = try evaluate(expression: expression.value) as? Int {
                let value: Any

                if expression.operatorToken.kind == .minusEqual {
                    value = left - Double(right)
                } else if expression.operatorToken.kind == .percentEqual {
                    value = left.truncatingRemainder(dividingBy: Double(right))
                } else if expression.operatorToken.kind == .plusEqual {
                    value = left + Double(right)
                } else if expression.operatorToken.kind == .powerEqual {
                    value = pow(left, Double(right))
                } else if expression.operatorToken.kind == .slashEqual {
                    value = left / Double(right)
                } else {
                    value = left * Double(right)
                }

                try currentEnvironment.assignVariable(value: value, for: expression.identifierToken)

                return value
            } else if let left = try currentEnvironment.getVariableValue(for: expression.identifierToken) as? Int,
                      let right = try evaluate(expression: expression.value) as? Double {
                let value: Any

                if expression.operatorToken.kind == .minusEqual {
                    value = Double(left) - right
                } else if expression.operatorToken.kind == .percentEqual {
                    value = Double(left).truncatingRemainder(dividingBy: right)
                } else if expression.operatorToken.kind == .plusEqual {
                    value = Double(left) + right
                } else if expression.operatorToken.kind == .powerEqual {
                    value = pow(Double(left), right)
                } else if expression.operatorToken.kind == .slashEqual {
                    value = Double(left) / right
                } else {
                    value = Double(left) * right
                }

                try currentEnvironment.assignVariable(value: value, for: expression.identifierToken)

                return value
            }

            throw Yaproq.runtimeError(.operandsMustBeNumbers, token: expression.operatorToken)
        default:
            throw Yaproq.syntaxError(
                .invalidOperator(expression.operatorToken.lexeme),
                token: expression.operatorToken
            )
        }
    }

    func visitBinary(expression: BinaryExpression) throws -> Any? {
        let left = try evaluate(expression: expression.left)
        let token = expression.token
        let right = try evaluate(expression: expression.right)

        switch token.kind {
        case .bangEqual:
            return !isEqual(left, right)
        case .closedRange,
             .range:
            if let lowerBound = left as? Double, let upperBound = right as? Double {
                return expression.token.kind == .closedRange ? lowerBound...upperBound : lowerBound..<upperBound
            } else if let lowerBound = left as? Int, let upperBound = right as? Int {
                return expression.token.kind == .closedRange ? lowerBound...upperBound : lowerBound..<upperBound
            }

            throw Yaproq.runtimeError(.operandsMustBeEitherIntegersOrDoubles, token: token)
        case .equalEqual:
            return isEqual(left, right)
        case .greater:
            if let left = left as? Double, let right = right as? Double { return left > right }
            if let left = left as? Int, let right = right as? Int { return left > right }
            if let left = left as? Double, let right = right as? Int { return left > Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) > right }
            if let left = left as? String, let right = right as? String { return left > right }
            if let left = left as? Date, let right = right as? Date { return left > right }
            throw Yaproq.runtimeError(.operandsMustBeComparable, token: token)
        case .greaterOrEqual:
            if let left = left as? Double, let right = right as? Double { return left >= right }
            if let left = left as? Int, let right = right as? Int { return left >= right }
            if let left = left as? Double, let right = right as? Int { return left >= Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) >= right }
            if let left = left as? String, let right = right as? String { return left >= right }
            if let left = left as? Date, let right = right as? Date { return left >= right }
            throw Yaproq.runtimeError(.operandsMustBeComparable, token: token)
        case .less:
            if let left = left as? Double, let right = right as? Double { return left < right }
            if let left = left as? Int, let right = right as? Int { return left < right }
            if let left = left as? Double, let right = right as? Int { return left < Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) < right }
            if let left = left as? String, let right = right as? String { return left < right }
            if let left = left as? Date, let right = right as? Date { return left < right }
            throw Yaproq.runtimeError(.operandsMustBeComparable, token: token)
        case .lessOrEqual:
            if let left = left as? Double, let right = right as? Double { return left <= right }
            if let left = left as? Int, let right = right as? Int { return left <= right }
            if let left = left as? Double, let right = right as? Int { return left <= Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) <= right }
            if let left = left as? String, let right = right as? String { return left <= right }
            if let left = left as? Date, let right = right as? Date { return left <= right }
            throw Yaproq.runtimeError(.operandsMustBeComparable, token: token)
        case .minus:
            if let left = left as? Double, let right = right as? Double { return left - right }
            if let left = left as? Int, let right = right as? Int { return left - right }
            if let left = left as? Double, let right = right as? Int { return left - Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) - right }
            throw Yaproq.runtimeError(.operandsMustBeNumbers, token: token)
        case .percent:
            if let left = left as? Double, let right = right as? Double {
                return left.truncatingRemainder(dividingBy: right)
            } else if let left = left as? Int, let right = right as? Int {
                return left % right
            } else if let left = left as? Double, let right = right as? Int {
                return left.truncatingRemainder(dividingBy: Double(right))
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left).truncatingRemainder(dividingBy: right)
            }

            throw Yaproq.runtimeError(.operandsMustBeNumbers, token: token)
        case .plus:
            if let left = left as? Double, let right = right as? Double {
                return left + right
            } else if let left = left as? Int, let right = right as? Int {
                return left + right
            } else if let left = left as? Double, let right = right as? Int {
                return left + Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) + right
            } else if let left = left as? String, let right = right as? String {
                return left + right
            }

            throw Yaproq.runtimeError(.operandsMustBeEitherNumbersOrStrings, token: token)
        case .power:
            if let left = left as? Double, let right = right as? Double {
                return pow(left, right)
            } else if let left = left as? Int, let right = right as? Int {
                return Double(truncating: pow(Decimal(left), right) as NSNumber)
            } else if let left = left as? Double, let right = right as? Int {
                return pow(left, Double(right))
            } else if let left = left as? Int, let right = right as? Double {
                return pow(Double(left), right)
            }

            throw Yaproq.runtimeError(.operandsMustBeNumbers, token: token)
        case .questionQuestion:
            return left ?? right
        case .slash:
            if let left = left as? Double, let right = right as? Double { return left / right }
            if let left = left as? Int, let right = right as? Int { return Double(left) / Double(right) }
            if let left = left as? Double, let right = right as? Int { return left / Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) / right }
            throw Yaproq.runtimeError(.operandsMustBeNumbers, token: token)
        case .star:
            if let left = left as? Double, let right = right as? Double { return left * right }
            if let left = left as? Int, let right = right as? Int { return left * right }
            if let left = left as? Double, let right = right as? Int { return left * Double(right) }
            if let left = left as? Int, let right = right as? Double { return Double(left) * right }
            throw Yaproq.runtimeError(.operandsMustBeNumbers, token: token)
        default:
            throw Yaproq.runtimeError(.invalidOperator(token.lexeme), token: token)
        }
    }

    func visitGrouping(expression: GroupingExpression) throws -> Any? {
        try evaluate(expression: expression.expression)
    }

    func visitLiteral(expression: LiteralExpression) throws -> Any? {
        expression.token.literal
    }

    func visitLogical(expression: LogicalExpression) throws -> Any? {
        let token = expression.token
        let left = try isTruthy(try evaluate(expression: expression.left), for: token)
        let right = try isTruthy(try evaluate(expression: expression.right), for: token)

        return token.kind == .and ? left && right : left || right
    }

    func visitTernary(expression: TernaryExpression) throws -> Any? {
        let condition = try evaluate(expression: expression.condition)
        let first = try evaluate(expression: expression.first)
        let second = try evaluate(expression: expression.second)

        return try isTruthy(condition) ? first : second
    }

    func visitUnary(expression: UnaryExpression) throws -> Any {
        let token = expression.token
        let right = try evaluate(expression: expression.right)

        switch token.kind {
        case .bang:
            return try !isTruthy(right, for: token)
        case .minus:
            if let right = right as? Double { return -right }
            if let right = right as? Int { return -right }
            throw Yaproq.runtimeError(.operandMustBeNumber, token: token)
        default:
            throw Yaproq.syntaxError(.invalidOperator(token.lexeme), token: token)
        }
    }

    func visitVariable(expression: VariableExpression) throws -> Any? {
        let token = expression.token
        let value = try templating.currentEnvironment.getVariableValue(for: token)

        if let key = expression.key {
            let key = try evaluate(expression: key)

            if let array = value as? [Any] {
                if let index = key as? Int { return array[index] }
                throw Yaproq.runtimeError(.indexMustBeInteger("\(key ?? "")"), token: token)
            } else if let dictionary = value as? [AnyHashable: Any] {
                if let key = key as? AnyHashable { return dictionary[key] }
                throw Yaproq.runtimeError(.keyMustBeHashable("\(key ?? "")"), token: token)
            }

            throw Yaproq.runtimeError(.variableMustBeEitherArrayOrDictionary(token.lexeme), token: token)
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
        result = try interpret()
    }
}

extension Interpreter: StatementVisitor {
    func visitBlock(statement: BlockStatement) throws {
        let environment = Environment(parent: templating.currentEnvironment)

        for variable in statement.variables {
            try environment.defineVariable(value: variable.token.literal, for: variable.token)
        }

        try execute(statements: statement.statements, in: environment)
    }

    func visitExpression(statement: ExpressionStatement) throws {
        try evaluate(expression: statement.expression)
    }

    func visitExtend(statement: ExtendStatement) throws {
        guard let value = try evaluate(expression: statement.expression) else { return }

        if let filePath = value as? String {
            try extendFile(at: filePath)
        } else {
            throw Yaproq.templateError(.invalidTemplateFile, filePath: "\(value)")
        }
    }

    func visitFor(statement: ForStatement) throws {
        guard let blockStatement = statement.body as? BlockStatement else { return }

        func assign(value: Any, for key: Any, on token: Token) throws {
            blockStatement.variables = .init()

            if let statementKey = statement.key {
                if var statementKey = statementKey.expression as? VariableExpression {
                    statementKey.token.literal = key
                    blockStatement.variables.append(statementKey)
                } else {
                    throw Yaproq.runtimeError(.expectingVariable, token: token)
                }
            }

            if var statementValue = statement.value.expression as? VariableExpression {
                statementValue.token.literal = value
                blockStatement.variables.append(statementValue)
            } else {
                throw Yaproq.runtimeError(.expectingVariable, token: token)
            }

            try blockStatement.accept(visitor: self)
        }

        if let expression = statement.expression.expression as? BinaryExpression {
            let value = try expression.accept(visitor: self)
            let token = expression.token

            if let closedRange = value as? ClosedRange<Int> {
                for (key, value) in closedRange.enumerated() {
                    try assign(value: value, for: key, on: token)
                }
            } else if let range = value as? Range<Int> {
                for (key, value) in range.enumerated() {
                    try assign(value: value, for: key, on: token)
                }
            } else {
                throw Yaproq.syntaxError(.invalidOperator(token.lexeme), token: token)
            }
        } else if let expression = statement.expression.expression as? VariableExpression {
            let value = try expression.accept(visitor: self)
            let token = expression.token

            if let array = value as? [Any] {
                for (key, value) in array.enumerated() {
                    try assign(value: value, for: key, on: token)
                }
            } else if let dictionary = value as? [AnyHashable: Any] {
                for (key, value) in dictionary {
                    try assign(value: value, for: key, on: token)
                }
            } else {
                throw Yaproq.runtimeError(.variableMustBeEitherArrayOrDictionary(token.lexeme), token: token)
            }
        }
    }

    func visitInclude(statement: IncludeStatement) throws {
        guard let value = try evaluate(expression: statement.expression) else { return }

        if let filePath = value as? String {
            do {
                result += try templating.doRenderTemplate(named: filePath)
            } catch is TemplateError {
                result += try templating.doRenderTemplate(at: filePath)
            }
        } else {
            throw Yaproq.templateError(.invalidTemplateFile, filePath: "\(value)")
        }
    }

    func visitIf(statement: IfStatement) throws {
        if try isTruthy(try evaluate(expression: statement.condition)) {
            try execute(statement: statement.thenBranch)
        } else {
            var isTruthy = false

            for elseIfBranch in statement.elseIfBranches {
                if try self.isTruthy(try evaluate(expression: elseIfBranch.condition)) {
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
        result += stringify(value)
    }

    func visitSuper(statement: SuperStatement) throws {}

    func visitVariable(statement: VariableStatement) throws {
        var value: Any?
        if let expression = statement.expression { value = try evaluate(expression: expression) }
        try templating.currentEnvironment.defineVariable(value: value, for: statement.token)
    }

    func visitWhile(statement: WhileStatement) throws {
        while try isTruthy(try evaluate(expression: statement.condition)) {
            try execute(statement: statement.body)
        }
    }
}
