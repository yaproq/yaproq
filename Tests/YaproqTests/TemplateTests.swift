import XCTest
@testable import Yaproq

final class TemplateTests: BaseTests {
    func testInit() {
        // Arrange
        let source = """
        <!doctype html>
        <html lang="en">
            <head>
                <title>{% block title %}{% endblock %}</title>
                {% block meta %}{% endblock %}
                {% block css %}{% endblock %}
            </head>
            <body>
                {% block body %}{% endblock %}
                {% block js %}{% endblock %}
            </body>
        </html>
        """
        let filePath = "/template.html"

        // Act
        var template = Template(source)

        // Assert
        XCTAssertEqual("\(template)", source)
        XCTAssertEqual(template.source, source)
        XCTAssertNil(template.filePath)

        // Act
        template = Template(source, filePath: filePath)

        // Assert
        XCTAssertEqual("\(template)", source)
        XCTAssertEqual(template.source, source)
        XCTAssertEqual(template.filePath, filePath)
    }
}
