import XCTest
@testable import Yaproq

final class DelimiterTests: BaseTests {
    func testDefault() {
        // Assert
        XCTAssertEqual(Delimiter.comment.name, "comment")
        XCTAssertEqual(Delimiter.comment.start, "{#")
        XCTAssertEqual(Delimiter.comment.end, "#}")
        XCTAssertEqual(Delimiter.output.name, "output")
        XCTAssertEqual(Delimiter.output.start, "{{")
        XCTAssertEqual(Delimiter.output.end, "}}")
        XCTAssertEqual(Delimiter.statement.name, "statement")
        XCTAssertEqual(Delimiter.statement.start, "{%")
        XCTAssertEqual(Delimiter.statement.end, "%}")
    }

    func testCustom() {
        // Act
        Delimiter.comment = .comment("{!", "!}")
        Delimiter.output = .output("{*", "*}")
        Delimiter.statement = .statement("{$", "$}")

        // Assert
        XCTAssertEqual(Delimiter.comment.name, "comment")
        XCTAssertEqual(Delimiter.comment.start, "{!")
        XCTAssertEqual(Delimiter.comment.end, "!}")
        XCTAssertEqual(Delimiter.output.name, "output")
        XCTAssertEqual(Delimiter.output.start, "{*")
        XCTAssertEqual(Delimiter.output.end, "*}")
        XCTAssertEqual(Delimiter.statement.name, "statement")
        XCTAssertEqual(Delimiter.statement.start, "{$")
        XCTAssertEqual(Delimiter.statement.end, "$}")
    }

    func testHashable() {
        // Act
        let delimiters = Set<Delimiter>(Delimiter.all)

        // Assert
        XCTAssertTrue(delimiters.contains(.comment))
        XCTAssertTrue(delimiters.contains(.output))
        XCTAssertTrue(delimiters.contains(.statement))
    }

    func testAll() {
        // Assert
        XCTAssertEqual(Delimiter.all, [.comment, .output, .statement])
    }
}
