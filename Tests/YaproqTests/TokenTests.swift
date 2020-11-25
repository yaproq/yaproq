@testable import Yaproq
import XCTest

final class TokenTests: XCTestCase {
    func testInit() {
        // Arrange
        let kind = Token.Kind.and
        let line = 1
        let column = 3

        // Act
        let token = Token(kind: kind, lexeme: kind.rawValue, line: line, column: column)

        // Assert
        XCTAssertEqual(token.kind, kind)
        XCTAssertEqual(token.lexeme, kind.rawValue)
        XCTAssertEqual(token.line, line)
        XCTAssertEqual(token.column, column)
    }
}
