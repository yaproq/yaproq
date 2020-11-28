import XCTest
@testable import Yaproq

final class TemplateErrorTests: XCTestCase {
    func testInit() {
        // Act
        var error = TemplateError()

        // Assert
        XCTAssertEqual(error.message, "Template error: An unknown error.")
        XCTAssertEqual(error.errorDescription, error.message)

        let message = "An invalid source."

        // Act
        error = TemplateError(message)

        // Assert
        XCTAssertEqual(error.message, "Template error: \(message)")
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class SyntaxErrorTests: XCTestCase {
    func testInit() {
        // Act
        var error = SyntaxError(line: 1, column: 1)

        // Assert
        XCTAssertEqual(error.message, "[\(error.line):\(error.column)] Syntax error: An unknown error.")
        XCTAssertEqual(error.errorDescription, error.message)

        let message = "An invalid assignment target."

        // Act
        error = SyntaxError(message, line: 1, column: 1)

        // Assert
        XCTAssertEqual(error.message, "[\(error.line):\(error.column)] Syntax error: \(message)")
        XCTAssertEqual(error.errorDescription, error.message)
    }
}
