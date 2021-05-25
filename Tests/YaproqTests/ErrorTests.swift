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
        let message = ErrorType.invalidTemplateFile.message

        // Act
        error = TemplateError(message, filePath: filePath)

        // Assert
        XCTAssertEqual(error.message, """
        [Template: "\(filePath)"] \(String(describing: TemplateError.self)): \(message)
        """
        )
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
        [Template: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: SyntaxError.self)): \(message)
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
        [Template: "\(filePath)", Line: \(line), Column: \(column)] \(String(describing: RuntimeError.self)): \(message)
        """
        )
        XCTAssertEqual(error.filePath, filePath)
        XCTAssertEqual(error.line, line)
        XCTAssertEqual(error.column, column)
        XCTAssertEqual(error.errorDescription, error.message)
    }
}

final class ErrorTypeTests: BaseTests {
    func testTypes() {
        // Arrange
        let blockName = ""
        let delimiterEnd = "%}"
        let index = "index"
        let key = "key"
        let operatorName = "**"
        let rightBrace = Token.Kind.rightBrace.rawValue
        let semicolon = ";"
        let variableName = "result"

        // Assert
        XCTAssertEqual(ErrorType.unknownedError.message, "An unknown error.")

        // YaproqError
        XCTAssertEqual(ErrorType.delimitersMustBeUnique.message, "The delimiters must be unique.")

        // TemplateError
        XCTAssertEqual(
            ErrorType.extendingMultipleTemplatesNotSupported.message,
            "Extending multiple templates is not supported."
        )
        XCTAssertEqual(
            ErrorType.extendMustBeFirstStatement.message,
            "The `\(Token.Kind.extend.rawValue)` must be the first statement."
        )
        XCTAssertEqual(ErrorType.invalidTemplateFile.message, "An invalid template file.")
        XCTAssertEqual(
            ErrorType.templateFileMustBeUTF8Encodable.message,
            "The template file must be UTF8 encodable."
        )

        // SyntaxError
        XCTAssertEqual(ErrorType.expectingCharacter(rightBrace).message, "Expecting `\(rightBrace)`.")
        XCTAssertEqual(ErrorType.expectingExpression.message, "Expecting an expression.")
        XCTAssertEqual(ErrorType.expectingVariable.message, "Expecting a variable.")
        XCTAssertEqual(ErrorType.invalidAssignmentTarget.message, "An invalid assignment target.")
        XCTAssertEqual(ErrorType.invalidBlockName(blockName).message, "An invalid block name `\(blockName).")
        XCTAssertEqual(ErrorType.invalidCharacter(semicolon).message, "An invalid character `\(semicolon)`.")
        XCTAssertEqual(
            ErrorType.invalidDelimiterEnd(delimiterEnd).message,
            "An invalid closing delimiter `\(delimiterEnd)`."
        )
        XCTAssertEqual(ErrorType.invalidOperator(operatorName).message, "An invalid operator `\(operatorName)`.")
        XCTAssertEqual(ErrorType.unterminatedString.message, "An unterminated string.")

        // RuntimeError
        XCTAssertEqual(ErrorType.indexMustBeInteger(index).message, "The index `\(index)` must be an integer.")
        XCTAssertEqual(ErrorType.keyMustBeHashable(key).message, "The key `\(key)` must be hashable.")
        XCTAssertEqual(ErrorType.operandMustBeBoolean.message, "The operand must be a boolean.")
        XCTAssertEqual(ErrorType.operandMustBeNumber.message, "The operand must be a number.")
        XCTAssertEqual(ErrorType.operandsMustBeComparable.message, "The operands must be comparable.")
        XCTAssertEqual(
            ErrorType.operandsMustBeEitherIntegersOrDoubles.message,
            "The operands must be either integers or doubles."
        )
        XCTAssertEqual(
            ErrorType.operandsMustBeEitherNumbersOrStrings.message,
            "The operands must be either numbers or strings."
        )
        XCTAssertEqual(ErrorType.operandsMustBeNumbers.message, "The operands must be numbers.")
        XCTAssertEqual(
            ErrorType.variableExists(variableName).message,
            "The variable `\(variableName)` already exists."
        )
        XCTAssertEqual(
            ErrorType.variableMustBeEitherArrayOrDictionary(variableName).message,
            "The `\(variableName)` must be either an array or dictionary."
        )
        XCTAssertEqual(ErrorType.undefinedVariable(variableName).message, "An undefined variable `\(variableName)`.")
    }
}
