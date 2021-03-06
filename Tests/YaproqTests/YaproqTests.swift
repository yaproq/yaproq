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
    var pages: [Page]!

    override func setUp() {
        super.setUp()

        let configuration = Yaproq.Configuration(directoryPath: Bundle.module.resourcePath!)
        templating = Yaproq(configuration: configuration)
        pages = [
            Page(title: "Home", url: URL(string: "/")!),
            Page(title: "Blog", url: URL(string: "/blog")!),
            Page(title: "Projects", url: URL(string: "/projects")!)
        ]
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

    func testWhileStatement() {
        // Arrange
        let template = Template("""
        {% var number = 0 %}
        {% var maxNumber = 3 %}
        {% while number < maxNumber %}
        {{ number }}
        {% number += 1 %}
        {% endwhile %}
        """
        )

        // Act
        let result = try! templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "012")
    }

    func testIfStatement() {
        for number in 0...3 {
            // Arrange
            let template = Template("""
            {% var number = \(number) %}
            {% if number == 0 %}
            {{ number }}
            {% elseif number == 1 %}
            {{ number }}
            {% elseif number == 2 %}
            {{ number }}
            {% else number == 3 %}
            {{ number }}
            {% endif %}
            """
            )

            // Act
            let result = try! templating.renderTemplate(template)

            // Assert
            XCTAssertEqual(result, "\(number)")
        }
    }

    func testExtendStatement() {
        // Arrange
        let template = Template("""
        {% extend "content.html" %}
        {% block title %}Home{% endblock %}
        {% block body %}
            {% @super %}
            {% block content %}Content{% endblock %}
        {% endblock %}
        """
        )

        // Act
        let result = try! templating.renderTemplate(template, in: ["pages": pages])

        // Assert
        XCTAssertEqual(result.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: ""), """
        <!doctype html>
        <html lang="en">
            <head>
                <title>Home</title>
            </head>
            <body>
                <nav class="navbar navbar-expand-sm navbar-dark sticky-top">
                    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar" aria-controls="collapsibleNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse justify-content-center" id="collapsibleNavbar">
                        <ul class="text-center navbar-nav">
                            <li class="nav-item">
                                <a class="nav-link font-weight-bold" href="/">Home</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link font-weight-bold" href="/blog">Blog</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link font-weight-bold" href="/projects">Projects</a>
                            </li>
                        </ul>
                    </div>
                </nav>
                <div class="container">
                    Content
                </div>
                <footer class="footer text-center">
                    <div class="inner"><p class="text-muted">Copyright &copy; 2020-2021.</p></div>
                </footer>
            </body>
        </html>
        """.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        )
    }

    func testIncludeStatement() {
        // Arrange
        let template = Template("""
        {% include "footer.html" %}
        """
        )

        // Act
        let result = try! templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, """
        <footer class="footer text-center">
            <div class="inner"><p class="text-muted">Copyright &copy; 2020-2021.</p></div>
        </footer>
        """
        )
    }
}
