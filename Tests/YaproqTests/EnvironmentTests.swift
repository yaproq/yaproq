import XCTest
@testable import Yaproq

final class EnvironmentTests: BaseTests {
    func testInit() {
        // Act
        let parentEnvironment = Environment()

        // Assert
        XCTAssertNil(parentEnvironment.parent)

        // Act
        let childEnvironment = Environment(parent: parentEnvironment)

        // Assert
        XCTAssertTrue(childEnvironment.parent === parentEnvironment)
    }

    func testAssignAndDefineVariable() {
        // Arrange
        let value1 = "value1"
        let value2 = "value2"
        let value3 = "value3"
        let token = Token(kind: .identifier, lexeme: "name", literal: value1, line: -1, column: -1)
        let parentEnvironment = Environment()
        let childEnvironment = Environment(parent: parentEnvironment)

        // Act/Assert
        XCTAssertThrowsError(try parentEnvironment.assignVariable(value: token.literal, for: token)) { error in
            guard let error = error as? RuntimeError else {
                XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, -1)
            XCTAssertEqual(error.column, -1)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            \(String(describing: RuntimeError.self)): \(ErrorType.undefinedVariable(name: token.lexeme))
            """
            )
        }
        XCTAssertNoThrow(try parentEnvironment.defineVariable(value: token.literal, for: token))
        XCTAssertThrowsError(try parentEnvironment.defineVariable(value: token.literal, for: token)) { error in
            guard let error = error as? RuntimeError else {
                XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, -1)
            XCTAssertEqual(error.column, -1)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            \(String(describing: RuntimeError.self)): \(ErrorType.variableExists(name: token.lexeme))
            """
            )
        }
        XCTAssertEqual(try? parentEnvironment.getVariableValue(for: token) as? String, value1)
        XCTAssertEqual(try? childEnvironment.getVariableValue(for: token) as? String, value1)
        XCTAssertNoThrow(try childEnvironment.assignVariable(value: value2, for: token))
        XCTAssertEqual(try? parentEnvironment.getVariableValue(for: token) as? String, value2)
        XCTAssertEqual(try? childEnvironment.getVariableValue(for: token) as? String, value2)
        XCTAssertNoThrow(try childEnvironment.assignVariable(value: value3, for: token))
        XCTAssertEqual(try? parentEnvironment.getVariableValue(for: token) as? String, value3)
        XCTAssertEqual(try? childEnvironment.getVariableValue(for: token) as? String, value3)
    }

    func testSetVariableAndClear() {
        // Arrange
        let token1 = Token(kind: .identifier, lexeme: "name1", literal: "value1", line: -1, column: -1)
        let token2 = Token(kind: .identifier, lexeme: "name2", literal: "value2", line: -1, column: -1)
        let environment = Environment()

        // Act
        environment.setVariable(value: token1.literal, for: token1.lexeme)
        environment.setVariable(value: token2.literal, for: token2.lexeme)

        // Assert
        XCTAssertEqual(try? environment.getVariableValue(for: token1) as? String, token1.literal as? String)
        XCTAssertEqual(try? environment.getVariableValue(for: token2) as? String, token2.literal as? String)

        // Act
        environment.clear()

        // Assert
        XCTAssertNil(try? environment.getVariableValue(for: token1) as? String)
        XCTAssertNil(try? environment.getVariableValue(for: token2) as? String)
    }
}
