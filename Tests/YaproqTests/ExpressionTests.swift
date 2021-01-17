import XCTest
@testable import Yaproq

final class AssignmentExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let identifierToken = Token(kind: .identifier, lexeme: "bool", line: 1, column: 7)
        let operatorToken = Token(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 9)
        let value = AnyExpression(
            LiteralExpression(
                token: .init(kind: .true, lexeme: Token.Kind.true.rawValue, literal: true, line: 1, column: 14)
            )
        )

        // Act
        let expression = AssignmentExpression(
            identifierToken: identifierToken,
            operatorToken: operatorToken,
            value: value
        )

        // Assert
        XCTAssertEqual(expression.identifierToken, identifierToken)
        XCTAssertEqual(expression.operatorToken, operatorToken)
        XCTAssertEqual(expression.value, value)
    }
}

final class BinaryExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let left = AnyExpression(
            LiteralExpression(token: .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 4))
        )
        let token = Token(
            kind: .plus,
            lexeme: Token.Kind.plus.rawValue,
            line: 1,
            column: 6
        )
        let right = AnyExpression(
            LiteralExpression(token: .init(kind: .number, lexeme: "2", literal: 2, line: 1, column: 8))
        )

        // Act
        let expression = BinaryExpression(left: left, token: token, right: right)

        // Assert
        XCTAssertEqual(expression.left, left)
        XCTAssertEqual(expression.token, token)
        XCTAssertEqual(expression.right, right)
    }
}

final class GroupingExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let left = AnyExpression(
            LiteralExpression(token: .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 4))
        )
        let token = Token(
            kind: .star,
            lexeme: Token.Kind.star.rawValue,
            line: 1,
            column: 6
        )
        let right = AnyExpression(
            LiteralExpression(token: .init(kind: .number, lexeme: "2", literal: 2, line: 1, column: 8))
        )
        let binaryExpression = AnyExpression(BinaryExpression(left: left, token: token, right: right))

        // Act
        let expression = GroupingExpression(expression: binaryExpression)

        // Assert
        XCTAssertEqual(expression.expression, binaryExpression)
    }
}

final class LiteralExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let literal = "Hello World"
        let token = Token(kind: .string, lexeme: literal, literal: literal, line: 1, column: 16)

        // Act
        let expression = LiteralExpression(token: token)

        // Assert
        XCTAssertEqual(expression.token, token)
    }
}

final class LogicalExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let left = AnyExpression(
            LiteralExpression(
                token: .init(kind: .true, lexeme: Token.Kind.true.rawValue, literal: true, line: 1, column: 7)
            )
        )
        let token = Token(kind: .or, lexeme: Token.Kind.or.rawValue, line: 1, column: 10)
        let right = AnyExpression(
            LiteralExpression(
                token: .init(kind: .false, lexeme: Token.Kind.false.rawValue, literal: false, line: 1, column: 16)
            )
        )

        // Act
        let expression = LogicalExpression(left: left, token: token, right: right)

        // Assert
        XCTAssertEqual(expression.left, left)
        XCTAssertEqual(expression.token, token)
        XCTAssertEqual(expression.right, right)
    }
}

final class UnaryExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let token = Token(
            kind: .minus,
            lexeme: Token.Kind.minus.rawValue,
            line: 1,
            column: 4
        )
        let literal = 1
        let right = AnyExpression(
            LiteralExpression(
                token: .init(kind: .number, lexeme: String(literal), literal: literal, line: 1, column: 5)
            )
        )

        // Act
        let expression = UnaryExpression(token: token, right: right)

        // Assert
        XCTAssertEqual(expression.token, token)
        XCTAssertEqual(expression.right, right)
    }
}

final class VariableExpressionTests: BaseTests {
    func testInit() {
        // Arrange
        let token = Token(
            kind: .var,
            lexeme: Token.Kind.var.rawValue,
            literal: 1,
            line: 1,
            column: 6
        )

        // Act
        let expression = VariableExpression(token: token)

        // Assert
        XCTAssertEqual(expression.token, token)
    }
}
