import XCTest
@testable import Yaproq

final class AssignmentExpressionTests: XCTestCase {
    func testInit() {
        // Arrange
        let token = Token(
            kind: .equal,
            lexeme: Token.Kind.equal.rawValue,
            line: 1,
            column: 6
        )
        let value = LiteralExpression(
            token: .init(
                kind: .true,
                lexeme: Token.Kind.true.rawValue,
                literal: true,
                line: 1,
                column: 11
            )
        )

        // Act
        let expression = AssignmentExpression(token: token, value: value)

        // Assert
        XCTAssertEqual(expression.token, token)
        XCTAssertEqual(expression.value as! LiteralExpression, value)
    }
}
