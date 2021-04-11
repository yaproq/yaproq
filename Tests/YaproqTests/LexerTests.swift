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
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "result", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "5", literal: 5, line: 1, column: 17),
            .init(kind: .star, lexeme: Token.Kind.star.rawValue, line: 1, column: 19),
            .init(kind: .number, lexeme: "4", literal: 4, line: 1, column: 21),
            .init(kind: .slash, lexeme: Token.Kind.slash.rawValue, line: 1, column: 23),
            .init(kind: .leftParenthesis, lexeme: Token.Kind.leftParenthesis.rawValue, line: 1, column: 25),
            .init(kind: .number, lexeme: "3", literal: 3, line: 1, column: 26),
            .init(kind: .plus, lexeme: Token.Kind.plus.rawValue, line: 1, column: 28),
            .init(kind: .number, lexeme: "2", literal: 2, line: 1, column: 30),
            .init(kind: .rightParenthesis, lexeme: Token.Kind.rightParenthesis.rawValue, line: 1, column: 31),
            .init(kind: .minus, lexeme: Token.Kind.minus.rawValue, line: 1, column: 33),
            .init(kind: .number, lexeme: "7", literal: 7, line: 1, column: 35),
            .init(kind: .percent, lexeme: Token.Kind.percent.rawValue, line: 1, column: 37),
            .init(kind: .number, lexeme: "2", literal: 2, line: 1, column: 39),
            .init(kind: .power, lexeme: Token.Kind.power.rawValue, line: 1, column: 41),
            .init(kind: .number, lexeme: "2", literal: 2, line: 1, column: 43),
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
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "result", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "2", literal: 2, line: 1, column: 17),
            .init(kind: .greater, lexeme: Token.Kind.greater.rawValue, line: 1, column: 19),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 21),
            .init(kind: .identifier, lexeme: "result", line: 2, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 2, column: 11),
            .init(kind: .number, lexeme: "4", literal: 4, line: 2, column: 13),
            .init(kind: .less, lexeme: Token.Kind.less.rawValue, line: 2, column: 15),
            .init(kind: .number, lexeme: "3", literal: 3, line: 2, column: 17),
            .init(kind: .identifier, lexeme: "result", line: 3, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 3, column: 11),
            .init(kind: .number, lexeme: "2", literal: 2, line: 3, column: 13),
            .init(kind: .greaterOrEqual, lexeme: Token.Kind.greaterOrEqual.rawValue, line: 3, column: 16),
            .init(kind: .number, lexeme: "1", literal: 1, line: 3, column: 18),
            .init(kind: .identifier, lexeme: "result", line: 4, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 4, column: 11),
            .init(kind: .number, lexeme: "4", literal: 4, line: 4, column: 13),
            .init(kind: .lessOrEqual, lexeme: Token.Kind.lessOrEqual.rawValue, line: 4, column: 16),
            .init(kind: .number, lexeme: "3", literal: 3, line: 4, column: 18),
            .init(kind: .identifier, lexeme: "result", line: 5, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 5, column: 11),
            .init(kind: .number, lexeme: "1", literal: 1, line: 5, column: 13),
            .init(kind: .equalEqual, lexeme: Token.Kind.equalEqual.rawValue, line: 5, column: 16),
            .init(kind: .number, lexeme: "2", literal: 2, line: 5, column: 18),
            .init(kind: .identifier, lexeme: "result", line: 6, column: 9),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 6, column: 11),
            .init(kind: .number, lexeme: "4", literal: 4, line: 6, column: 13),
            .init(kind: .bangEqual, lexeme: Token.Kind.bangEqual.rawValue, line: 6, column: 16),
            .init(kind: .number, lexeme: "3", literal: 3, line: 6, column: 18),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 6, column: 21)
        ])
    }

    func testCompoundAssignmentOperators() {
        // Arrange
        let template: Template = """
        {% var number = 1 %}
        {% number += 2 %}
        {% number -= 3 %}
        {% number *= 4 %}
        {% number /= 5 %}
        {% number %= 6 %}
        {% number ^= 7 %}
        """
        let lexer = Lexer(template: template)

        // Act
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 17),
            .init(kind: .identifier, lexeme: "number", line: 2, column: 9),
            .init(kind: .plusEqual, lexeme: Token.Kind.plusEqual.rawValue, line: 2, column: 12),
            .init(kind: .number, lexeme: "2", literal: 2, line: 2, column: 14),
            .init(kind: .identifier, lexeme: "number", line: 3, column: 9),
            .init(kind: .minusEqual, lexeme: Token.Kind.minusEqual.rawValue, line: 3, column: 12),
            .init(kind: .number, lexeme: "3", literal: 3, line: 3, column: 14),
            .init(kind: .identifier, lexeme: "number", line: 4, column: 9),
            .init(kind: .starEqual, lexeme: Token.Kind.starEqual.rawValue, line: 4, column: 12),
            .init(kind: .number, lexeme: "4", literal: 4, line: 4, column: 14),
            .init(kind: .identifier, lexeme: "number", line: 5, column: 9),
            .init(kind: .slashEqual, lexeme: Token.Kind.slashEqual.rawValue, line: 5, column: 12),
            .init(kind: .number, lexeme: "5", literal: 5, line: 5, column: 14),
            .init(kind: .identifier, lexeme: "number", line: 6, column: 9),
            .init(kind: .percentEqual, lexeme: Token.Kind.percentEqual.rawValue, line: 6, column: 12),
            .init(kind: .number, lexeme: "6", literal: 6, line: 6, column: 14),
            .init(kind: .identifier, lexeme: "number", line: 7, column: 9),
            .init(kind: .powerEqual, lexeme: Token.Kind.powerEqual.rawValue, line: 7, column: 12),
            .init(kind: .number, lexeme: "7", literal: 7, line: 7, column: 14),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 7, column: 17)
        ])
    }

    func testNilCoalescingOperator() {
        // Arrange
        let message = "The variable `text` is `nil`"
        let template = Template("""
        {% var text %}
        {{ text ?? "\(message)" }}
        """
        )
        let lexer = Lexer(template: template)

        // Act
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "text", line: 1, column: 11),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "text", line: 2, column: 7),
            .init(kind: .questionQuestion, lexeme: Token.Kind.questionQuestion.rawValue, line: 2, column: 10),
            .init(kind: .string, lexeme: "\"\(message)\"", literal: message, line: 2, column: 41),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 2, column: 44)
        ])
    }

    func testRangeOperators() {
        // Arrange
        let template: Template = """
        {% var range = 0..<10 %}
        {% var closedRange = 10...20 %}
        """
        let lexer = Lexer(template: template)

        // Act
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "range", line: 1, column: 12),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 14),
            .init(kind: .number, lexeme: "0", literal: 0, line: 1, column: 16),
            .init(kind: .range, lexeme: Token.Kind.range.rawValue, line: 1, column: 19),
            .init(kind: .number, lexeme: "10", literal: 10, line: 1, column: 21),
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 2, column: 6),
            .init(kind: .identifier, lexeme: "closedRange", line: 2, column: 18),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 2, column: 20),
            .init(kind: .number, lexeme: "10", literal: 10, line: 2, column: 23),
            .init(kind: .closedRange, lexeme: Token.Kind.closedRange.rawValue, line: 2, column: 26),
            .init(kind: .number, lexeme: "20", literal: 20, line: 2, column: 28),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 2, column: 31)
        ])
    }

    func testTernaryOperator() {
        // Arrange
        let template: Template = """
        {% var number = 1 %}
        {{ number == 1 ? "One" : "Not one" }}
        """
        let lexer = Lexer(template: template)

        // Act
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 17),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 2, column: 9),
            .init(kind: .equalEqual, lexeme: Token.Kind.equalEqual.rawValue, line: 2, column: 12),
            .init(kind: .number, lexeme: "1", literal: 1, line: 2, column: 14),
            .init(kind: .question, lexeme: Token.Kind.question.rawValue, line: 2, column: 16),
            .init(kind: .string, lexeme: "\"One\"", literal: "One", line: 2, column: 22),
            .init(kind: .colon, lexeme: Token.Kind.colon.rawValue, line: 2, column: 24),
            .init(kind: .string, lexeme: "\"Not one\"", literal: "Not one", line: 2, column: 34),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 2, column: 37)
        ])
    }

    func testUnaryOperators() {
        // Arrange
        var template: Template = "{% var number = 1 %}{% number = -number %}"
        var lexer = Lexer(template: template)

        // Act
        var tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 17),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 29),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 31),
            .init(kind: .minus, lexeme: Token.Kind.minus.rawValue, line: 1, column: 33),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 39),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 42)
        ])

        // Arrange
        template = "{% var bool = true %}{% bool = !bool %}"
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "bool", line: 1, column: 11),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 13),
            .init(kind: .true, lexeme: Token.Kind.true.rawValue, literal: true, line: 1, column: 18),
            .init(kind: .identifier, lexeme: "bool", line: 1, column: 28),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 30),
            .init(kind: .bang, lexeme: Token.Kind.bang.rawValue, line: 1, column: 32),
            .init(kind: .identifier, lexeme: "bool", line: 1, column: 36),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 39)
        ])
    }
}

// MARK: - Statements

extension LexerTests {
    func testBlockStatement() {
        // Arrange
        let template: Template = """
        {% extend "base.html" %}

        {% block title %}
        {% super %}
        {% endblock %}
        """
        let lexer = Lexer(template: template)

        // Act
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .extend, lexeme: Token.Kind.extend.rawValue, line: 1, column: 9),
            .init(kind: .string, lexeme: "\"base.html\"", literal: "base.html", line: 1, column: 21),
            .init(kind: .block, lexeme: Token.Kind.block.rawValue, line: 3, column: 8),
            .init(kind: .identifier, lexeme: "title", line: 3, column: 14),
            .init(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue, line: -1, column: -1),
            .init(kind: .super, lexeme: Token.Kind.super.rawValue, line: 4, column: 8),
            .init(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue, line: -1, column: -1),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 5, column: 14)
        ])
    }

    func testCommentStatement() {
        // Arrange
        var template: Template = "{# A single-line comment #}"
        var lexer = Lexer(template: template)

        // Act
        var tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 27)
        ])

        // Arrange
        template = """
        {#
            A multi-line
            comment
        #}
        """
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 4, column: 2)
        ])
    }

    func testForStatement() {
        // Arrange
        var template: Template = """
        {% for number in numbers %}
        {{ number }}
        {% endfor %}
        """
        var lexer = Lexer(template: template)

        // Act
        var tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .for, lexeme: Token.Kind.for.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .in, lexeme: Token.Kind.in.rawValue, line: 1, column: 16),
            .init(kind: .identifier, lexeme: "numbers", line: 1, column: 24),
            .init(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue, line: -1, column: -1),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 2, column: 9),
            .init(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue, line: -1, column: -1),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 3, column: 12)
        ])

        // Arrange
        template = """
        {% for index, number in numbers %}
        {{ index }}{{ number }}
        {% endfor %}
        """
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .for, lexeme: Token.Kind.for.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "index", line: 1, column: 12),
            .init(kind: .comma, lexeme: Token.Kind.comma.rawValue, line: 1, column: 13),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 20),
            .init(kind: .in, lexeme: Token.Kind.in.rawValue, line: 1, column: 23),
            .init(kind: .identifier, lexeme: "numbers", line: 1, column: 31),
            .init(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue, line: -1, column: -1),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "index", line: 2, column: 8),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 2, column: 20),
            .init(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue, line: -1, column: -1),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 3, column: 12)
        ])
    }

    func testIfStatement() {
        // Arrange
        let template: Template = """
        {% var number = 1 %}
        {% if number > 1 %}
        More than
        {{ number }}
        {% elseif number < 1 %}
        Less than {{ number }}
        {% else %}
        {{ number }}
        {% endif %}
        """
        let lexer = Lexer(template: template)

        // Act
        let tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 17),
            .init(kind: .if, lexeme: Token.Kind.if.rawValue, line: 2, column: 5),
            .init(kind: .identifier, lexeme: "number", line: 2, column: 12),
            .init(kind: .greater, lexeme: Token.Kind.greater.rawValue, line: 2, column: 14),
            .init(kind: .number, lexeme: "1", literal: 1, line: 2, column: 16),
            .init(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue, line: -1, column: -1),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .string, lexeme: "More than", literal: "More than", line: 4, column: 0),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 4, column: 9),
            .init(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue, line: -1, column: -1),
            .init(kind: .elseif, lexeme: Token.Kind.elseif.rawValue, line: 5, column: 9),
            .init(kind: .identifier, lexeme: "number", line: 5, column: 16),
            .init(kind: .less, lexeme: Token.Kind.less.rawValue, line: 5, column: 18),
            .init(kind: .number, lexeme: "1", literal: 1, line: 5, column: 20),
            .init(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue, line: -1, column: -1),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .string, lexeme: "Less than ", literal: "Less than ", line: 6, column: 10),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 6, column: 19),
            .init(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue, line: -1, column: -1),
            .init(kind: .else, lexeme: Token.Kind.else.rawValue, line: 7, column: 7),
            .init(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue, line: -1, column: -1),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 8, column: 9),
            .init(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue, line: -1, column: -1),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 9, column: 11)
        ])
    }

    func testOutputStatement() {
        // Arrange
        var template: Template = "{{ 1 }}"
        var lexer = Lexer(template: template)

        // Act
        var tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 4),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 7)
        ])

        // Arrange
        template = """
        {% var number = 1 %}
        {{
            number
        }}
        """
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 17),
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "number", line: 3, column: 10),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 4, column: 2)
        ])

        // Arrange
        template = "{{ array[0] }}"
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "array", line: 1, column: 8),
            .init(kind: .leftBracket, lexeme: Token.Kind.leftBracket.rawValue, line: 1, column: 9),
            .init(kind: .number, lexeme: "0", literal: 0, line: 1, column: 10),
            .init(kind: .rightBracket, lexeme: Token.Kind.rightBracket.rawValue, line: 1, column: 11),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 14)
        ])

        // Arrange
        template = "{{ object.property }}"
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .print, lexeme: Token.Kind.print.rawValue, line: -1, column: -1),
            .init(kind: .identifier, lexeme: "object.property", line: 1, column: 18),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 21)
        ])

        // Arrange
        template = "{{ object. }}"
        lexer = Lexer(template: template)

        // Act/Assert
        XCTAssertThrowsError(try lexer.scan()) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 10)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            SyntaxError: An unexpected character `\(Token.Kind.dot.rawValue)`.
            """
            )
        }

        // Arrange
        template = "{{ object.. }}"
        lexer = Lexer(template: template)

        // Act/Assert
        XCTAssertThrowsError(try lexer.scan()) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 11)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            SyntaxError: An unexpected character `\(Token.Kind.dot.rawValue)`.
            """
            )
        }
    }

    func testVariableStatement() {
        // Arrange
        var template: Template = "{% var number = 1 %}{% number = 20.0 %}"
        var lexer = Lexer(template: template)

        // Act
        var tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .number, lexeme: "1", literal: 1, line: 1, column: 17),
            .init(kind: .identifier, lexeme: "number", line: 1, column: 29),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 31),
            .init(kind: .number, lexeme: "20.0", literal: 20.0, line: 1, column: 36),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 39)
        ])

        // Arrange
        template = "{% var bool = true %}{% bool = false %}"
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "bool", line: 1, column: 11),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 13),
            .init(kind: .true, lexeme: Token.Kind.true.rawValue, literal: true, line: 1, column: 18),
            .init(kind: .identifier, lexeme: "bool", line: 1, column: 28),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 30),
            .init(kind: .false, lexeme: Token.Kind.false.rawValue, literal: false, line: 1, column: 36),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 39)
        ])

        // Arrange
        template = "{% var string = \"Hello World\" %}"
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 1, column: 6),
            .init(kind: .identifier, lexeme: "string", line: 1, column: 13),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 1, column: 15),
            .init(kind: .string, lexeme: "\"Hello World\"", literal: "Hello World", line: 1, column: 29),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 1, column: 32)
        ])

        // Arrange
        template = "{% var unterminatedString = \"Hello World %}"
        lexer = Lexer(template: template)

        // Act/Assert
        XCTAssertThrowsError(try lexer.scan()) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 43)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            SyntaxError: An unterminated string.
            """
            )
        }

        // Arrange
        template = "{% var unclosedDelimiter = \"Hello World\""
        lexer = Lexer(template: template)

        // Act/Assert
        XCTAssertThrowsError(try lexer.scan()) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 40)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            SyntaxError: No matching closing delimiter `%}` is found.
            """
            )
        }

        // Arrange
        template = "{% var numberWithTrailingDotAndUnclosedDelimiter = 12."
        lexer = Lexer(template: template)

        // Act/Assert
        XCTAssertThrowsError(try lexer.scan()) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 54)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            SyntaxError: An unexpected character `.`.
            """
            )
        }

        // Arrange
        template = """
        {%
            var whitespaceAndNewlines = false
        %}
        """
        lexer = Lexer(template: template)

        // Act
        tokens = try? lexer.scan()

        // Assert
        XCTAssertEqual(lexer.template, template)
        XCTAssertEqual(tokens, [
            .init(kind: .var, lexeme: Token.Kind.var.rawValue, line: 2, column: 7),
            .init(kind: .identifier, lexeme: "whitespaceAndNewlines", line: 2, column: 29),
            .init(kind: .equal, lexeme: Token.Kind.equal.rawValue, line: 2, column: 31),
            .init(kind: .false, lexeme: Token.Kind.false.rawValue, literal: false, line: 2, column: 37),
            .init(kind: .eof, lexeme: Token.Kind.eof.rawValue, line: 3, column: 2)
        ])
    }
}
