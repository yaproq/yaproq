import XCTest
@testable import Yaproq

final class BlockStatementTests: XCTestCase {
    func testInit() {
        // Act
        var statement = BlockStatement()

        // Assert
        XCTAssertNil(statement.name)
        XCTAssertTrue(statement.statements.isEmpty)

        // Arrange
        let name = "title"
        let expression = LiteralExpression(token: .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 4))

        // Act
        statement = BlockStatement(name: name, statements: [PrintStatement(expression: expression)])

        // Assert
        XCTAssertEqual(statement.name, name)
        XCTAssertEqual(statement.statements.count, 1)
        XCTAssertEqual((statement.statements.first as! PrintStatement).expression as! LiteralExpression, expression)
    }
}

final class ExpressionStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let expression = LiteralExpression(token: .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 4))

        // Act
        let statement = ExpressionStatement(expression: expression)

        // Assert
        XCTAssertEqual(statement.expression as! LiteralExpression, expression)
    }
}

final class ExtendStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let expression = LiteralExpression(
            token: .init(kind: .string, lexeme: "base.html", literal: "base.html", line: 1, column: 19)
        )

        // Act
        let statement = ExtendStatement(expression: expression)

        // Assert
        XCTAssertEqual(statement.expression as! LiteralExpression, expression)
    }
}

final class IfStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let trueCondition = LiteralExpression(
            token: .init(kind: .true, lexeme: "true", literal: true, line: 1, column: 10)
        )
        let oneExpression = LiteralExpression(
            token: .init(kind: .number, lexeme: "1", literal: 1, line: 2, column: 4)
        )
        let falseCondition = LiteralExpression(
            token: .init(kind: .false, lexeme: "false", literal: false, line: 3, column: 15)
        )
        let twoExpression = LiteralExpression(
            token: .init(kind: .number, lexeme: "2", literal: 2, line: 4, column: 4)
        )
        let threeExpression = LiteralExpression(
            token: .init(kind: .number, lexeme: "3", literal: 3, line: 6, column: 4)
        )

        // Act
        let statement = IfStatement(
            condition: trueCondition,
            thenBranch: BlockStatement(statements: [PrintStatement(expression: oneExpression)]),
            elseIfBranches: [
                IfStatement(
                    condition: falseCondition,
                    thenBranch: BlockStatement(statements: [PrintStatement(expression: twoExpression)])
                )
            ],
            elseBranch: BlockStatement(statements: [PrintStatement(expression: threeExpression)])
        )

        // Assert
        XCTAssertEqual(statement.condition as! LiteralExpression, trueCondition)
        XCTAssertEqual((statement.thenBranch as! BlockStatement).statements.count, 1)
        XCTAssertEqual(
            ((statement.thenBranch as! BlockStatement).statements.first as! PrintStatement).expression as! LiteralExpression,
            oneExpression
        )
        XCTAssertEqual(statement.elseIfBranches.count, 1)
        XCTAssertEqual(statement.elseIfBranches.first?.condition as! LiteralExpression, falseCondition)
        XCTAssertEqual((statement.elseIfBranches.first?.thenBranch as! BlockStatement).statements.count, 1)
        XCTAssertEqual(
            ((statement.elseIfBranches.first?.thenBranch as! BlockStatement).statements.first as! PrintStatement).expression as! LiteralExpression,
            twoExpression
        )
        XCTAssertEqual((statement.elseBranch as! BlockStatement).statements.count, 1)
        XCTAssertEqual(
            ((statement.elseBranch as! BlockStatement).statements.first as! PrintStatement).expression as! LiteralExpression,
            threeExpression
        )
    }
}

final class IncludeStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let expression = LiteralExpression(
            token: .init(kind: .string, lexeme: "header.html", literal: "header.html", line: 1, column: 20)
        )

        // Act
        let statement = IncludeStatement(expression: expression)

        // Assert
        XCTAssertEqual(statement.expression as! LiteralExpression, expression)
    }
}

final class PrintStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let expression = LiteralExpression(token: .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 4))

        // Act
        let statement = PrintStatement(expression: expression)

        // Assert
        XCTAssertEqual(statement.expression as! LiteralExpression, expression)
    }
}

final class VariableStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let token = Token(kind: .identifier, lexeme: "a", line: 1, column: 4)
        let expression = LiteralExpression(token: .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 8))

        // Act
        let statement = VariableStatement(token: token, expression: expression)

        // Assert
        XCTAssertEqual(statement.token, token)
        XCTAssertEqual(statement.expression as! LiteralExpression, expression)
    }
}

final class WhileStatementTests: XCTestCase {
    func testInit() {
        // Arrange
        let condition = LiteralExpression(
            token: .init(kind: .true, lexeme: "true", literal: true, line: 1, column: 16)
        )
        let expression = LiteralExpression(
            token: .init(kind: .string, lexeme: "true", literal: "true", line: 1, column: 7)
        )

        // Act
        let statement = WhileStatement(
            condition: condition,
            body: BlockStatement(statements: [PrintStatement(expression: expression)])
        )

        // Assert
        XCTAssertEqual(statement.condition as! LiteralExpression, condition)
        XCTAssertEqual((statement.body as! BlockStatement).statements.count, 1)
        XCTAssertEqual(
            ((statement.body as! BlockStatement).statements.first as! PrintStatement).expression as! LiteralExpression,
            expression
        )
    }
}
