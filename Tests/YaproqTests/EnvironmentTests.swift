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
}
