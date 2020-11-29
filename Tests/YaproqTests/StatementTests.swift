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
