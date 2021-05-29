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
            \(String(describing: RuntimeError.self)): \(ErrorType.undefinedVariableOrProperty(token.lexeme))
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
            \(String(describing: RuntimeError.self)): \(ErrorType.variableExists(token.lexeme))
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

    func testSetAndGetVariable() {
        // Arrange
        let data: [(String, Any?, String, Any?)] = [
            ("", "text", "invalidProperty", nil),
            ("string", "text", "string.count", 4),
            ("string", "text", "string.invalidProperty", nil),
            ("array", [1, 2], "array.count", 2),
            ("array", [1, 2], "array.invalidProperty", nil),
            ("dictionary", ["3": 3], "dictionary.count", 1),
            ("dictionary", ["3": 3], "dictionary.invalidProperty", nil),
            ("object", Page(title: "Blog", url: URL(string: "/blog")!), "object.title", "Blog"),
            ("object", Page(title: "Blog", url: URL(string: "/blog")!), "object.title.count", 4),
            ("object", Page(title: "Blog", url: URL(string: "/blog")!), "object.invalidProperty", nil),
            ("object", Page(title: "Blog", url: URL(string: "/blog")!), "object.invalidProperty.count", nil)
        ]

        for tokenData in data {
            // Arrange
            let variableToken = Token(kind: .identifier, lexeme: tokenData.0, line: -1, column: -1)
            let propertyToken = Token(kind: .identifier, lexeme: tokenData.2, line: -1, column: -1)
            let environment = Environment()

            // Act
            environment.setVariable(value: tokenData.1, for: variableToken.lexeme)

            // Assert
            XCTAssertEqual(
                String(describing: try? environment.getVariableValue(for: variableToken)),
                String(describing: tokenData.1)
            )

            if tokenData.3 == nil {
                XCTAssertThrowsError(try environment.getVariableValue(for: propertyToken)) { error in
                    guard let error = error as? RuntimeError else {
                        XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                        return
                    }

                    XCTAssertNil(error.filePath)
                    XCTAssertEqual(error.line, -1)
                    XCTAssertEqual(error.column, -1)
                    XCTAssertEqual(error.errorDescription, """
                    [Line: \(error.line), Column: \(error.column)] \
                    \(String(describing: RuntimeError.self)): \
                    \(ErrorType.undefinedVariableOrProperty("invalidProperty"))
                    """
                    )
                }
            } else {
                XCTAssertEqual(
                    String(describing: try! environment.getVariableValue(for: propertyToken)!),
                    String(describing: tokenData.3!)
                )
            }
        }
    }
}
