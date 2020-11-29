import XCTest
@testable import Yaproq

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
