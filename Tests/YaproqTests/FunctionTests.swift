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
            function.call(arguments: [dateString, dateFormat]) as? Date,
            dateFormatter.date(from: dateString)
        )
    }
}

final class DateFormatFunctionTests: BaseTests {
    func testInit() {
        // Arrange
        let date = Date()

        // Act
        var function = DateFormatFunction(date: date)

        // Assert
        XCTAssertEqual(function.arity, DateFormatFunction.arity)
        XCTAssertEqual(function.date, date)
        XCTAssertNil(function.call())

        // Arrange
        let dateFormat = "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        // Act
        function = DateFormatFunction(date: date)

        // Assert
        XCTAssertEqual(function.arity, DateFormatFunction.arity)
        XCTAssertEqual(function.date, date)
        XCTAssertNotNil(function.call(arguments: [dateFormat]) as? String)
        XCTAssertEqual(function.call(arguments: [dateFormat]) as? String, dateFormatter.string(from: date))

        // Arrange
        let arity = 2
        var timeZone = "UTC"
        dateFormatter.timeZone = TimeZone(abbreviation: timeZone)

        // Act
        function = DateFormatFunction(arity: arity, date: date)

        // Assert
        XCTAssertEqual(function.arity, arity)
        XCTAssertEqual(function.date, date)
        XCTAssertNotNil(function.call(arguments: [dateFormat, timeZone]) as? String)
        XCTAssertEqual(function.call(arguments: [dateFormat, timeZone]) as? String, dateFormatter.string(from: date))

        // Arrange
        timeZone = "Asia/Tashkent"
        dateFormatter.timeZone = TimeZone(identifier: timeZone)

        // Act
        function = DateFormatFunction(arity: arity, date: date)

        // Assert
        XCTAssertEqual(function.arity, arity)
        XCTAssertEqual(function.date, date)
        XCTAssertNotNil(function.call(arguments: [dateFormat, timeZone]) as? String)
        XCTAssertEqual(function.call(arguments: [dateFormat, timeZone]) as? String, dateFormatter.string(from: date))
    }
}
