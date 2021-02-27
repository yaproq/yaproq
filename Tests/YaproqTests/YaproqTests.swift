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

final class YaproqTests: BaseTests {
    var templating: Yaproq!

    override func setUp() {
        super.setUp()

        let configuration = Yaproq.Configuration(directoryPath: Bundle.module.resourcePath!)
        templating = Yaproq(configuration: configuration)
    }

    func testForStatement() {
        // Arrange
        let min = 0
        let max = 3
        var template = Template("""
        {% for value in \(min)...\(max) %}
        {{ value }}
        {% endfor %}
        """
        )

        // Act
        var result = try! templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "0123")

        // Arrange
        template = Template("""
        {% for value in \(min)..<\(max) %}
        {{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "012")

        // Arrange
        template = Template("""
        {% for value in min...max %}
        {{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template, in: ["min": min, "max": max])

        // Assert
        XCTAssertEqual(result, "0123")

        // Arrange
        template = Template("""
        {% for value in min..<max %}
        {{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template, in: ["min": min, "max": max])

        // Assert
        XCTAssertEqual(result, "012")

        // Arrange
        template = Template("""
        {% var min = \(min) %}
        {% var max = \(max) %}
        {% for value in min...max %}
        {{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "0123")

        // Arrange
        template = Template("""
        {% var min = \(min) %}
        {% var max = \(max) %}
        {% for value in min..<max %}
        {{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "012")

        // Arrange
        let array = [1, 2, 3]
        template = Template("""
        {% for item in array %}
        {{ item }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template, in: ["array": array])

        // Assert
        XCTAssertEqual(result, "123")

        // Arrange
        template = Template("""
        {% for index, value in array %}
        {{ index }}-{{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template, in: ["array": array])

        // Assert
        XCTAssertEqual(result, "0-11-22-3")

        // Arrange
        let dictionary = ["one": 1, "two": 2, "three": 3]
        template = Template("""
        {% for key, value in dictionary %}
        {{ key }}-{{ value }}
        {% endfor %}
        """
        )

        // Act
        result = try! templating.renderTemplate(template, in: ["dictionary": dictionary])

        // Assert
        XCTAssertEqual(result.count, 17)
        XCTAssertTrue(result.contains("one-1"))
        XCTAssertTrue(result.contains("two-2"))
        XCTAssertTrue(result.contains("three-3"))
    }
}
