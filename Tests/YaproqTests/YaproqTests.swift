import XCTest
@testable import Yaproq

final class YaproqConfigurationTests: BaseTests {
    func testInit() {
        // Act
        var configuration = Yaproq.Configuration()

        // Assert
        XCTAssertEqual(configuration.directoryPath, Yaproq.Configuration.defaultDirectoryPath)

        // Arrange
        var directoryPath = "/templates"

        // Act
        configuration = Yaproq.Configuration(directoryPath: directoryPath)

        // Assert
        XCTAssertEqual(configuration.directoryPath, "\(directoryPath)/")

        // Arrange
        directoryPath = "/templates/"

        // Act
        configuration = Yaproq.Configuration(directoryPath: directoryPath)

        // Assert
        XCTAssertEqual(configuration.directoryPath, directoryPath)

        // Arrange
        var delimiters: Set<Delimiter> = .init()

        // Act/Assert
        XCTAssertNoThrow(try Yaproq.Configuration(directoryPath: directoryPath, delimiters: delimiters))

        // Arrange
        delimiters = [.comment("{#", "#}"), .output("{{", "}}"), .statement("{%", "%}")]

        // Act/Assert
        XCTAssertNoThrow(try Yaproq.Configuration(directoryPath: directoryPath, delimiters: delimiters))

        // Arrange
        delimiters = [.comment("{*", "*}"), .output("{$", "$}"), .statement("{$", "$}")]

        // Act/Assert
        XCTAssertThrowsError(try Yaproq.Configuration(directoryPath: directoryPath, delimiters: delimiters)) { error in
            let error = error as! YaproqError
            XCTAssertEqual(error.errorDescription, "YaproqError: Delimiters must be unique.")
        }
    }
}
