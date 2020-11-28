import XCTest
@testable import Yaproq

final class TemplateErrorTests: XCTestCase {
    func testInit() {
        // Act
        var error = TemplateError()

        // Assert
        XCTAssertEqual(error.message, "Template error: An unknown error.")
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
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
        // Arrange
        let line = 1
        let column = 1

        // Act
        var error = SyntaxError(line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] Syntax error: An unknown error.")
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = "An invalid assignment target."

        // Act
        error = SyntaxError(message, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] Syntax error: \(message)")
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class RuntimeErrorTests: XCTestCase {
    func testInit() {
        // Arrange
        let line = 1
        let column = 1

        // Act
        var error = RuntimeError(line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] Runtime error: An unknown error.")
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = "Operands must be comparable."

        // Act
        error = RuntimeError(message, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] Runtime error: \(message)")
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}
