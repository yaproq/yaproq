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
