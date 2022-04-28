import XCTest
@testable import Yaproq

final class DateFunctionTests: BaseTests {
    func testInit() {
        // Act
        let function = DateFunction()

        // Assert
        XCTAssertNotNil(function.call() as? Date)
    }
}
