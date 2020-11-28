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

final class BinaryExpressionTests: XCTestCase {
    func testInit() {
        // Arrange
        let left = LiteralExpression(
            token: .init(
                kind: .number,
                lexeme: String(1),
                literal: 1,
                line: 1,
                column: 4
            )
        )
        let token = Token(
            kind: .plus,
            lexeme: Token.Kind.plus.rawValue,
            line: 1,
            column: 6
        )
        let right = LiteralExpression(
            token: .init(
                kind: .number,
                lexeme: String(2),
                literal: 2,
                line: 1,
                column: 8
            )
        )

        // Act
        let expression = BinaryExpression(left: left, token: token, right: right)

        // Assert
        XCTAssertEqual(expression.left as! LiteralExpression, left)
        XCTAssertEqual(expression.token, token)
        XCTAssertEqual(expression.right as! LiteralExpression, right)
    }
}

final class GroupingExpressionTests: XCTestCase {
    func testInit() {
        // Arrange
        let left = LiteralExpression(
            token: .init(
                kind: .number,
                lexeme: String(1),
                literal: 1,
                line: 1,
                column: 4
            )
        )
        let token = Token(
            kind: .plus,
            lexeme: Token.Kind.star.rawValue,
            line: 1,
            column: 6
        )
        let right = LiteralExpression(
            token: .init(
                kind: .number,
                lexeme: String(2),
                literal: 2,
                line: 1,
                column: 8
            )
        )

        // Act
        let expression = GroupingExpression(expression: BinaryExpression(left: left, token: token, right: right))

        // Assert
        XCTAssertEqual((expression.expression as! BinaryExpression).left as! LiteralExpression, left)
        XCTAssertEqual((expression.expression as! BinaryExpression).token, token)
        XCTAssertEqual((expression.expression as! BinaryExpression).right as! LiteralExpression, right)
    }
}

final class LiteralExpressionTests: XCTestCase {
    func testInit() {
        // Arrange
        let literal = "Hello World"
        let token = Token(
            kind: .string,
            lexeme: literal,
            literal: literal,
            line: 1,
            column: 16
        )

        // Act
        let expression = LiteralExpression(token: token)

        // Assert
        XCTAssertEqual(expression.token, token)
    }
}
