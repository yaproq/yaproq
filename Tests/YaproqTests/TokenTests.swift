import XCTest
@testable import Yaproq

final class TokenTests: XCTestCase {
    func testInit() {
        // Arrange
        let kind = Token.Kind.number
        let literal = 1
        let lexeme = String(literal)
        let line = 1
        let column = 3

        // Act
        let token = Token(kind: kind, lexeme: lexeme, literal: literal, line: line, column: column)

        // Assert
        XCTAssertEqual(token.kind, kind)
        XCTAssertEqual(token.lexeme, lexeme)
        XCTAssertEqual(token.literal! as! Int, literal)
        XCTAssertEqual(token.line, line)
        XCTAssertEqual(token.column, column)
    }

    func testKinds() {
        // Assert
        XCTAssertEqual(Token.Kind.carriageReturn.rawValue, "\r")
        XCTAssertEqual(Token.Kind.comma.rawValue, ",")
        XCTAssertEqual(Token.Kind.dot.rawValue, ".")
        XCTAssertEqual(Token.Kind.leftBrace.rawValue, "{")
        XCTAssertEqual(Token.Kind.leftParenthesis.rawValue, "(")
        XCTAssertEqual(Token.Kind.minus.rawValue, "-")
        XCTAssertEqual(Token.Kind.newline.rawValue, "\n")
        XCTAssertEqual(Token.Kind.nullTerminator.rawValue, "\0")
        XCTAssertEqual(Token.Kind.plus.rawValue, "+")
        XCTAssertEqual(Token.Kind.quote.rawValue, "\"")
        XCTAssertEqual(Token.Kind.rightBrace.rawValue, "}")
        XCTAssertEqual(Token.Kind.rightParenthesis.rawValue, ")")
        XCTAssertEqual(Token.Kind.slash.rawValue, "/")
        XCTAssertEqual(Token.Kind.star.rawValue, "*")
        XCTAssertEqual(Token.Kind.tab.rawValue, "\t")
        XCTAssertEqual(Token.Kind.whitespace.rawValue, " ")

        XCTAssertEqual(Token.Kind.bang.rawValue, "!")
        XCTAssertEqual(Token.Kind.bangEqual.rawValue, "!=")
        XCTAssertEqual(Token.Kind.equal.rawValue, "=")
        XCTAssertEqual(Token.Kind.equalEqual.rawValue, "==")
        XCTAssertEqual(Token.Kind.greater.rawValue, ">")
        XCTAssertEqual(Token.Kind.greaterOrEqual.rawValue, ">=")
        XCTAssertEqual(Token.Kind.less.rawValue, "<")
        XCTAssertEqual(Token.Kind.lessOrEqual.rawValue, "<=")

        XCTAssertEqual(Token.Kind.identifier.rawValue, "identifier")
        XCTAssertEqual(Token.Kind.number.rawValue, "number")
        XCTAssertEqual(Token.Kind.string.rawValue, "string")

        XCTAssertEqual(Token.Kind.and.rawValue, "and")
        XCTAssertEqual(Token.Kind.block.rawValue, "block")
        XCTAssertEqual(Token.Kind.else.rawValue, "else")
        XCTAssertEqual(Token.Kind.elseif.rawValue, "elseif")
        XCTAssertEqual(Token.Kind.extend.rawValue, "extend")
        XCTAssertEqual(Token.Kind.false.rawValue, "false")
        XCTAssertEqual(Token.Kind.for.rawValue, "for")
        XCTAssertEqual(Token.Kind.if.rawValue, "if")
        XCTAssertEqual(Token.Kind.include.rawValue, "include")
        XCTAssertEqual(Token.Kind.nil.rawValue, "nil")
        XCTAssertEqual(Token.Kind.or.rawValue, "or")
        XCTAssertEqual(Token.Kind.print.rawValue, "print")
        XCTAssertEqual(Token.Kind.super.rawValue, "@super")
        XCTAssertEqual(Token.Kind.true.rawValue, "true")
        XCTAssertEqual(Token.Kind.var.rawValue, "var")
        XCTAssertEqual(Token.Kind.while.rawValue, "while")

        XCTAssertEqual(Token.Kind.endblock.rawValue, "endblock")
        XCTAssertEqual(Token.Kind.endfor.rawValue, "endfor")
        XCTAssertEqual(Token.Kind.endif.rawValue, "endif")
        XCTAssertEqual(Token.Kind.endwhile.rawValue, "endwhile")

        XCTAssertEqual(Token.Kind.eof.rawValue, "")
    }

    func testKeywords() {
        // Assert
        XCTAssertEqual(Token.Kind.keywords, [
            .and, .block, .else, .elseif, .endblock, .endfor, .endif, .endwhile, .extend,
            .false, .for, .if, .include, .nil, .or, .super, .true, .var, .while
        ])
        XCTAssertEqual(Token.Kind.keywords, [
            .and, .block, .else, .elseif, .endblock, .endfor, .endif, .endwhile, .extend,
            .false, .for, .if, .include, .nil, .or, .super, .true, .var, .while
        ])
        XCTAssertEqual(Token.Kind.blockStartKeywords, [.block, .for, .if, .while])
        XCTAssertEqual(Token.Kind.blockEndKeywords, [.endblock, .endfor, .endif, .endwhile])
    }
}
