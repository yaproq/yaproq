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

final class DateFormatFunctionTests: BaseTests {
    func testInit() {
        // Arrange
        let date = Date()
        let dateFormat = "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        // Act
        let function = DateFormatFunction(date: date)

        // Assert
        XCTAssertEqual(function.call(arguments: [dateFormat]) as? String, dateFormatter.string(from: date))
    }
}
