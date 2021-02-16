import XCTest
@testable import Yaproq

final class LexerTests: BaseTests {
    func testSubstringEmptyString() {
        // Arrange
        let template: Template = ""
        let lexer = Lexer(template: template)

        // Act
        let string = lexer.substring(from: template.source.count - 1, to: template.source.count)

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(string, Token.Kind.eof.rawValue)
    }
}

// MARK: - Operators

extension LexerTests {
    func testArithmeticOperators() {
        // Arrange
        let template: Template = "{% var result = 5 * 4 / (3 + 2) - 7 % 2 ^ 2 %}"
        let lexer = Lexer(template: template)

        // Act
        let tokens = try! lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "result", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "5", literal: 5.0, line: 1, column: 17),
            .init(kind: .star, lexeme: Token.Kind.star.rawValue, line: 1, column: 19),
            .init(kind: .number, lexeme: "4", literal: 4.0, line: 1, column: 21),
            .init(kind: .slash, lexeme: Token.Kind.slash.rawValue, line: 1, column: 23),
            .init(kind: .leftParenthesis, lexeme: Token.Kind.leftParenthesis.rawValue, line: 1, column: 25),
            .init(kind: .number, lexeme: "3", literal: 3.0, line: 1, column: 26),
            .init(kind: .plus, lexeme: Token.Kind.plus.rawValue, line: 1, column: 28),
            .init(kind: .number, lexeme: "2", literal: 2.0, line: 1, column: 30),
            .init(kind: .rightParenthesis, lexeme: Token.Kind.rightParenthesis.rawValue, line: 1, column: 31),
            .init(kind: .minus, lexeme: Token.Kind.minus.rawValue, line: 1, column: 33),
            .init(kind: .number, lexeme: "7", literal: 7.0, line: 1, column: 35),
            .init(kind: .percent, lexeme: Token.Kind.percent.rawValue, line: 1, column: 37),
            .init(kind: .number, lexeme: "2", literal: 2.0, line: 1, column: 39),
            .init(kind: .power, lexeme: Token.Kind.power.rawValue, line: 1, column: 41),
            .init(kind: .number, lexeme: "2", literal: 2.0, line: 1, column: 43),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 46)
        ])
    }

    func testComparisonOperators() {
        // Arrange
        let template: Template = """
        {% var result = 2 > 1 %}
        {% result = 4 < 3 %}
        {% result = 2 >= 1 %}
        {% result = 4 <= 3 %}
        {% result = 1 == 2 %}
        {% result = 4 != 3 %}
        """
        let lexer = Lexer(template: template)

        // Act
        let tokens = try! lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "result", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "2", literal: 2.0, line: 1, column: 17),
            .init(kind: .greater, lexeme: Token.Kind.greater.rawValue, line: 1, column: 19),
            .init(kind: .number, lexeme: "1", literal: 1.0, line: 1, column: 21),
            .init(kind: .identifier, lexeme: "result", line: 2, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 2, column: 11),
            .init(kind: .number, lexeme: "4", literal: 4.0, line: 2, column: 13),
            .init(kind: .less, lexeme: Token.Kind.less.rawValue, line: 2, column: 15),
            .init(kind: .number, lexeme: "3", literal: 3.0, line: 2, column: 17),
            .init(kind: .identifier, lexeme: "result", line: 3, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 3, column: 11),
            .init(kind: .number, lexeme: "2", literal: 2.0, line: 3, column: 13),
            .init(kind: .greaterOrEqual, lexeme: Token.Kind.greaterOrEqual.rawValue, line: 3, column: 16),
            .init(kind: .number, lexeme: "1", literal: 1.0, line: 3, column: 18),
            .init(kind: .identifier, lexeme: "result", line: 4, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 4, column: 11),
            .init(kind: .number, lexeme: "4", literal: 4.0, line: 4, column: 13),
            .init(kind: .lessOrEqual, lexeme: Token.Kind.lessOrEqual.rawValue, line: 4, column: 16),
            .init(kind: .number, lexeme: "3", literal: 3.0, line: 4, column: 18),
            .init(kind: .identifier, lexeme: "result", line: 5, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 5, column: 11),
            .init(kind: .number, lexeme: "1", literal: 1.0, line: 5, column: 13),
            .init(kind: .equalEqual, lexeme: Token.Kind.equalEqual.rawValue, line: 5, column: 16),
            .init(kind: .number, lexeme: "2", literal: 2.0, line: 5, column: 18),
            .init(kind: .identifier, lexeme: "result", line: 6, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 6, column: 11),
            .init(kind: .number, lexeme: "4", literal: 4.0, line: 6, column: 13),
            .init(kind: .bangEqual, lexeme: Token.Kind.bangEqual.rawValue, line: 6, column: 16),
            .init(kind: .number, lexeme: "3", literal: 3.0, line: 6, column: 18),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 6, column: 21)
        ])
    }
}
