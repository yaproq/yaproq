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
        environment.setVariable(named: name, with: value)

        // Assert
        XCTAssertEqual(try? environment.valueForVariable(with: token) as? String, value)
    }

    func testDefineVariable() {
        // Arrange
        let environment = Environment()

        // Act/Assert
        XCTAssertNoThrow(
            try environment.defineVariable(
                for: .init(kind: .string, lexeme: "title", line: 1, column: 12),
                with: "Home"
            )
        )
        XCTAssertThrowsError(
            try environment.defineVariable(
                for: .init(kind: .string, lexeme: "title", line: 2, column: 12),
                with: "Home"
            )
        )
    }

    func testAssignValueToVariable() {
        // Arrange
        let environment = Environment()

        let token = Token(kind: .string, lexeme: "title", line: 1, column: 12)

        // Act/Assert
        XCTAssertNoThrow(try environment.defineVariable(for: token, with: "Home"))
        XCTAssertNil(environment.parent)
        XCTAssertThrowsError(try environment.defineVariable(for: token, with: "Home"))
    }
}
