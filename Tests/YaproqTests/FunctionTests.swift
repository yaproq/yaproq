import XCTest
@testable import Yaproq

final class DateFunctionTests: BaseTests {
    func testInit() {
        // Act
        var function = DateFunction()

        // Assert
        XCTAssertNotNil(function.call() as? Date)

        // Arrange
        let dateString = "14/10/1988"
        let dateFormat = "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        // Act
        function = DateFunction(arity: 2)

        // Assert
        XCTAssertEqual(
            function.call(arguments: [dateFormat, dateString]) as? Date,
            dateFormatter.date(from: dateString)
        )
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