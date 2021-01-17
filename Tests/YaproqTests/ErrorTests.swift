import XCTest
@testable import Yaproq

final class TemplateErrorTests: BaseTests {
    func testInit() {
        // Act
        var error = TemplateError()

        // Assert
        XCTAssertEqual(error.message, "\(String(describing: TemplateError.self)): An unknown error.")
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = "An invalid template."
        let filePath = "/"

        // Act
        error = TemplateError(message, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, "\(String(describing: TemplateError.self)): \(message)")
        XCTAssertEqual(error.filePath, error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class SyntaxErrorTests: BaseTests {
    func testInit() {
        // Arrange
        let line = 1
        let column = 1

        // Act
        var error = SyntaxError(line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] \(String(describing: SyntaxError.self)): An unknown error.")
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = "An invalid assignment target."
        let filePath = "/"

        // Act
        error = SyntaxError(message, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] \(String(describing: SyntaxError.self)): \(message)")
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class RuntimeErrorTests: BaseTests {
    func testInit() {
        // Arrange
        let line = 1
        let column = 1

        // Act
        var error = RuntimeError(line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] \(String(describing: RuntimeError.self)): An unknown error.")
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = "Operands must be comparable."
        let filePath = "/"

        // Act
        error = RuntimeError(message, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, "[\(line):\(column)] \(String(describing: RuntimeError.self)): \(message)")
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}
