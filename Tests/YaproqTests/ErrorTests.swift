import XCTest
@testable import Yaproq

final class YaproqErrorTests: BaseTests {
    func testInit() {
        // Act
        var error = YaproqError()

        // Assert
        XCTAssertEqual(error.message, "\(String(describing: YaproqError.self)): \(ErrorType.unknownedError)")
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = ErrorType.delimitersMustBeUnique.message

        // Act
        error = YaproqError(message)

        // Assert
        XCTAssertEqual(error.message, "\(String(describing: YaproqError.self)): \(message)")
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class TemplateErrorTests: BaseTests {
    func testInit() {
        // Act
        var error = TemplateError()

        // Assert
        XCTAssertEqual(
            error.message,
            "\(String(describing: TemplateError.self)): \(ErrorType.unknownedError)"
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let filePath = "/"
        let message = ErrorType.invalidTemplateFilePath(filePath: filePath).message

        // Act
        error = TemplateError(message, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, "[Template: \(filePath)] \(String(describing: TemplateError.self)): \(message)")
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
        XCTAssertEqual(error.message, """
        [Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \
        \(ErrorType.unknownedError)
        """
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = ErrorType.invalidAssignmentTarget.message
        let filePath = "/"

        // Act
        error = SyntaxError(message, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [Template: \(filePath), Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \(message)
        """
        )
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
        XCTAssertEqual(error.message, """
        [Line: \(line), Column: \(column)] \(String(describing: RuntimeError.self)): \
        \(ErrorType.unknownedError)
        """
        )
        XCTAssertNil(error.filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)

        // Arrange
        let message = ErrorType.operandsMustBeComparable.message
        let filePath = "/"

        // Act
        error = RuntimeError(message, filePath: filePath, line: line, column: column)

        // Assert
        XCTAssertEqual(error.message, """
        [Template: \(filePath), Line: \(line), Column: \(column)] \(String(describing: RuntimeError.self)): \(message)
        """
        )
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}
