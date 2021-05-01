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

    func testSetVariable() {
        // Arrange
        let environment = Environment()
        let name = "title"
        let value = "Home"
        let token = Token(kind: .identifier, lexeme: name, literal: value, line: 1, column: 8)

        // Act
        environment.setVariable(value: value, for: name)

        // Assert
        XCTAssertEqual(try? environment.getVariableValue(for: token) as? String, value)
    }

    func testDefineVariable() {
        // Arrange
        let environment = Environment()

        // Act/Assert
        XCTAssertNoThrow(
            try environment.defineVariable(
                value: "Home",
                for: .init(kind: .string, lexeme: "title", line: 1, column: 12)
            )
        )
        XCTAssertThrowsError(
            try environment.defineVariable(
                value: "Home",
                for: .init(kind: .string, lexeme: "title", line: 2, column: 12)
            )
        )
    }

    func testAssignValueToVariable() {
        // Arrange
        let environment = Environment()

        let token = Token(kind: .string, lexeme: "title", line: 1, column: 12)

        // Act/Assert
        XCTAssertNoThrow(try environment.defineVariable(value: "Home", for: token))
        XCTAssertNil(environment.parent)
        XCTAssertThrowsError(try environment.defineVariable(value: "Home", for: token))
    }
}
