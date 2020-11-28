import XCTest
@testable import Yaproq

final class DelimiterTests: XCTestCase {
    func testCases() {
        // Arrange
        let delimiters = Set<Delimiter>(Delimiter.all)

        // Assert
        XCTAssertTrue(delimiters.contains(.comment))
        XCTAssertTrue(delimiters.contains(.output))
        XCTAssertTrue(delimiters.contains(.statement))

        // Arrange
        var delimiter: Delimiter = .comment

        // Assert
        XCTAssertEqual(delimiter.name, "comment")
        XCTAssertEqual(delimiter.start, "{#")
        XCTAssertEqual(delimiter.end, "#}")

        // Arrange
        delimiter = .output

        // Assert
        XCTAssertEqual(delimiter.name, "output")
        XCTAssertEqual(delimiter.start, "{{")
        XCTAssertEqual(delimiter.end, "}}")

        // Arrange
        delimiter = .statement

        // Assert
        XCTAssertEqual(delimiter.name, "statement")
        XCTAssertEqual(delimiter.start, "{%")
        XCTAssertEqual(delimiter.end, "%}")

        // Arrange
        Delimiter.comment = .comment("{!", "!}")
        Delimiter.output = .output("{*", "*}")
        Delimiter.statement = .statement("{$", "$}")

        // Assert
        XCTAssertEqual(Delimiter.all, [.comment, .output, .statement])

        // Arrange
        delimiter = .comment

        // Assert
        XCTAssertEqual(delimiter.name, "comment")
        XCTAssertEqual(delimiter.start, "{!")
        XCTAssertEqual(delimiter.end, "!}")

        // Arrange
        delimiter = .output

        // Assert
        XCTAssertEqual(delimiter.name, "output")
        XCTAssertEqual(delimiter.start, "{*")
        XCTAssertEqual(delimiter.end, "*}")

        // Arrange
        delimiter = .statement

        // Assert
        XCTAssertEqual(delimiter.name, "statement")
        XCTAssertEqual(delimiter.start, "{$")
        XCTAssertEqual(delimiter.end, "$}")
    }
}
