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
