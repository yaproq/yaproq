import XCTest
@testable import Yaproq

fileprivate struct Page: Encodable {
    let title: String
    let url: URL
}

final class YaproqConfigurationTests: BaseTests {
    func testInit() {
        // Act
        var configuration = Yaproq.Configuration()

        // Assert
        XCTAssertFalse(configuration.isDebug)
        XCTAssertEqual(configuration.directories, Set(arrayLiteral: Yaproq.Configuration.defaultDirectoryPath))
        XCTAssertEqual(configuration.caching.costLimit, 0)
        XCTAssertEqual(configuration.caching.countLimit, 0)

        // Arrange
        var directories = Set(arrayLiteral: "/templates")
        var costLimit = 1
        var countLimit = 2

        // Act
        configuration = Yaproq.Configuration(
            isDebug: true,
            directories: directories,
            caching: .init(costLimit: costLimit, countLimit: countLimit)
        )

        // Assert
        XCTAssertTrue(configuration.isDebug)
        XCTAssertEqual(configuration.directories, Set(directories.map { $0 + "/" }))
        XCTAssertEqual(configuration.caching.costLimit, costLimit)
        XCTAssertEqual(configuration.caching.countLimit, countLimit)

        // Arrange
        directories = Set(arrayLiteral: "/templates/")
        costLimit = 3
        countLimit = 4

        // Act
        configuration = Yaproq.Configuration(
            isDebug: true,
            directories: directories,
            caching: .init(costLimit: costLimit, countLimit: countLimit)
        )

        // Assert
        XCTAssertTrue(configuration.isDebug)
        XCTAssertEqual(configuration.directories, directories)
        XCTAssertEqual(configuration.caching.costLimit, costLimit)
        XCTAssertEqual(configuration.caching.countLimit, countLimit)

        // Arrange
        var delimiters: Set<Delimiter> = .init()

        // Act/Assert
        XCTAssertNoThrow(try Yaproq.Configuration(directories: directories, delimiters: delimiters))

        // Arrange
        delimiters = [.comment("{#", "#}"), .output("{{", "}}"), .statement("{%", "%}")]

        // Act/Assert
        XCTAssertNoThrow(try Yaproq.Configuration(directories: directories, delimiters: delimiters))

        // Arrange
        delimiters = [.comment("{*", "*}"), .output("{$", "$}"), .statement("{$", "$}")]

        // Act/Assert
        XCTAssertThrowsError(try Yaproq.Configuration(directories: directories, delimiters: delimiters)) { error in
            let error = error as? YaproqError
            XCTAssertEqual(
                error?.errorDescription,
                "\(String(describing: YaproqError.self)): \(ErrorType.delimitersMustBeUnique)"
            )
        }
    }
}

final class YaproqCachingConfigurationTests: BaseTests {
    func testInit() {
        // Act
        var configuration = Yaproq.CachingConfiguration()

        // Assert
        XCTAssertEqual(configuration.costLimit, 0)
        XCTAssertEqual(configuration.countLimit, 0)

        // Arrange
        let costLimit = 1
        let countLimit = 2

        // Act
        configuration = Yaproq.CachingConfiguration(costLimit: costLimit, countLimit: countLimit)

        // Assert
        XCTAssertEqual(configuration.costLimit, costLimit)
        XCTAssertEqual(configuration.countLimit, countLimit)
    }
}

final class YaproqTests: BaseTests {
    var templating: Yaproq!
    fileprivate var pages: [Page]!

    override func setUp() {
        super.setUp()

        let configuration = Yaproq.Configuration(
            isDebug: true,
            directories: Set(arrayLiteral: Bundle.module.resourcePath!)
        )
        templating = Yaproq(configuration: configuration)
        pages = [
            Page(title: "Home", url: URL(string: "/")!),
            Page(title: "Blog", url: URL(string: "/blog")!),
            Page(title: "Projects", url: URL(string: "/projects")!)
        ]
    }
}

extension YaproqTests {
    func testRenderTemplate() {
        // Arrange
        let fileName = "header.html"
        let template = Template("""
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
        """
        )

        // Act
        let result = (try? templating.renderTemplate(named: fileName, in: ["pages": pages])) ?? ""

        // Assert
        XCTAssertEqual(
            result.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: ""),
            "\(template)".replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        )

        // Act/Assert
        XCTAssertThrowsError(try templating.renderTemplate(at: fileName, in: ["pages": pages])) { error in
            guard let error = error as? TemplateError else {
                XCTFail("The error is not of \(String(describing: TemplateError.self)) type.")
                return
            }

            XCTAssertEqual(error.filePath, fileName)
            XCTAssertEqual(error.errorDescription, """
            [Template: "\(fileName)"] \(String(describing: TemplateError.self)): \
            \(ErrorType.invalidTemplateFile)
            """
            )
        }
    }

    func testRenderCachedTemplate() {
        // Arrange
        let fileName = "footer.html"
        let template = Template("""
        <footer class="footer text-center">
            <div class="inner"><p class="text-muted">Copyright &copy; 2020-2021.</p></div>
        </footer>
        """
        )
        templating.configuration = .init(
            directories: Set(arrayLiteral: Bundle.module.resourcePath!),
            caching: .init(costLimit: 2, countLimit: 3)
        )

        // Act
        var result = try? templating.renderTemplate(named: fileName)

        // Assert
        XCTAssertEqual(result, "\(template)")

        // Act
        result = try? templating.renderTemplate(named: fileName)

        // Assert
        XCTAssertEqual(result, "\(template)")
    }

    func testRenderRawTemplate() {
        // Arrange
        let template = Template("""
        <footer class="footer text-center">
            <div class="inner"><p class="text-muted">Copyright &copy; 2020-2021.</p></div>
        </footer>
        """
        )
        templating.configuration = .init(
            directories: Set(arrayLiteral: Bundle.module.resourcePath!),
            caching: .init(costLimit: 2, countLimit: 3)
        )

        // Act
        let result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "\(template)")
    }
}

extension YaproqTests {
    func testExpressionStatement() {
        // Arrange
        var template = Template("""
        {% var result = 5 * 4 / (3 + 2) - 7 % 2 ^ 2 %}
        {{ result }}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1")

        // Arrange
        template = Template("""
        {% var five = 5.0 %}
        {% var four = 4 %}
        {% var three = 3 %}
        {% var two = 2.0 %}
        {% var seven = 7.0 %}
        {% var six = 6 %}
        {% var one = 1.0 %}
        {% var result = five * four / (three + two) - seven % six ^ one %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "3")
    }

    func testExtendStatement() {
        // Arrange
        var template = Template("""
        {% block title %}Home{% endblock %}
        {% extend "content.html" %}
        """
        )

        // Act/Assert
        XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
            guard let error = error as? TemplateError else {
                XCTFail("The error is not of \(String(describing: TemplateError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.errorDescription, """
            \(String(describing: TemplateError.self)): \(ErrorType.extendMustBeFirstStatement)
            """
            )
        }

        // Arrange
        template = Template("""
        {% extend "header.html" %}
        {% extend "content.html" %}
        """
        )

        // Act/Assert
        XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
            guard let error = error as? TemplateError else {
                XCTFail("The error is not of \(String(describing: TemplateError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.errorDescription, """
            \(String(describing: TemplateError.self)): \(ErrorType.extendingMultipleTemplatesNotSupported)
            """
            )
        }

        // Arrange
        template = Template("""
        {% extend "content.html" %}
        {% block title %}Home{% endblock %}
        {% block body %}
            {% super %}
            {% block content %}Content{% endblock %}
        {% endblock %}
        """
        )

        // Act
        let result = (try? templating.renderTemplate(template, in: ["pages": pages])) ?? ""

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

        // Arrange
        let data: [(String, Int)] = [
            ("1", 11),
            ("true", 14),
            ("false", 15)
        ]

        for item in data {
            // Arrange
            let filePath = item.0
            let template = Template("""
            {% extend \(filePath) %}
            """
            )

            // Act/Assert
            XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
                guard let error = error as? TemplateError else {
                    XCTFail("The error is not of \(String(describing: TemplateError.self)) type.")
                    return
                }

                XCTAssertEqual(error.filePath, filePath)
                XCTAssertEqual(error.errorDescription, """
                [Template: "\(filePath)"] \(String(describing: TemplateError.self)): \
                \(ErrorType.invalidTemplateFile)
                """
                )
            }
        }
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
        var result = try? templating.renderTemplate(template)

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
        result = try? templating.renderTemplate(template)

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
        result = try? templating.renderTemplate(template, in: ["min": min, "max": max])

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
        result = try? templating.renderTemplate(template, in: ["min": min, "max": max])

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
        result = try? templating.renderTemplate(template)

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
        result = try? templating.renderTemplate(template)

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
        result = try? templating.renderTemplate(template, in: ["array": array])

        // Assert
        XCTAssertEqual(result, "123")

        // Arrange
        template = Template("""
        {% for index, value in array %}
        {{ index }}-{{ value }}_{{ array[index] }}
        {% endfor %}
        """
        )

        // Act
        result = try? templating.renderTemplate(template, in: ["array": array])

        // Assert
        XCTAssertEqual(result, "0-1_11-2_22-3_3")
        // Arrange
        let dictionary = ["one": 1, "two": 2, "three": 3]
        template = Template("""
        {% for key, value in dictionary %}
        {{ key }}-{{ value }}_{{ dictionary[key] }}
        {% endfor %}
        """
        )

        // Act
        result = try? templating.renderTemplate(template, in: ["dictionary": dictionary])

        // Assert
        XCTAssertEqual(result?.count, 23)
        XCTAssertTrue(result?.contains("one-1_1") ?? false)
        XCTAssertTrue(result?.contains("two-2_2") ?? false)
        XCTAssertTrue(result?.contains("three-3_3") ?? false)
    }

    func testIfStatement() {
        // Arrange
        let data: [String: String] = [ // condition, result
            "nil == nil": "true",
            "nil == \"text\"": "false",
            "\"text\"": "false"
        ]

        for (key, value) in data {
            // Arrange
            let template = Template("""
            {% if \(key) %}
            true
            {% else %}
            false
            {% endif %}
            """
            )

            // Act
            let result = try? templating.renderTemplate(template)

            // Assert
            XCTAssertEqual(result, value)
        }

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
            {% else %}
            {{ number }}
            {% endif %}
            """
            )

            // Act
            let result = try? templating.renderTemplate(template)

            // Assert
            XCTAssertEqual(result, "\(number)")
        }

        // Arrange
        let number = 3
        var template = Template("""
        {% var number = \(number) %}
        {% if number == 3 %}
        {{ number }}
        {% endif %}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "\(number)")

        // Arrange
        template = Template("""
        {% var number = \(number) %}
        {% if number == 2 %}
        Equal to 2
        {% elseif number == 3 %}
        {{ number }}
        {% endif %}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "\(number)")

        // Arrange
        template = Template("""
        {% var number = \(number) %}
        {% if number == 2 %}
        Equal to 2
        {% else %}
        {{ number }}
        {% endif %}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "\(number)")

        // Arrange
        template = Template("""
        {% var number = \(number) %}
        {% if number == 1 %}
        Equal to 1
        {% elseif number == 2 %}
        Equal to 2
        {% else %}
        {{ number }}
        {% endif %}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "\(number)")
    }

    func testIncludeStatement() {
        // Arrange
        let template = Template("""
        {% include "footer.html" %}
        """
        )

        // Act
        let result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, """
        <footer class="footer text-center">
            <div class="inner"><p class="text-muted">Copyright &copy; 2020-2021.</p></div>
        </footer>
        """
        )

        // Arrange
        let data: [(String, Int)] = [
            ("1", 11),
            ("true", 14),
            ("false", 15)
        ]

        for item in data {
            // Arrange
            let filePath = item.0
            let template = Template("""
            {% include \(filePath) %}
            """
            )

            // Act/Assert
            XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
                guard let error = error as? TemplateError else {
                    XCTFail("The error is not of \(String(describing: TemplateError.self)) type.")
                    return
                }

                XCTAssertEqual(error.filePath, filePath)
                XCTAssertEqual(error.errorDescription, """
                [Template: "\(filePath)"] \(String(describing: TemplateError.self)): \
                \(ErrorType.invalidTemplateFile)
                """
                )
            }
        }
    }

    func testVariableStatement() {
        // Arrange
        let template = Template("""
        {% var integer = 1 %}
        {% var float = 2.5 %}
        {% var string = "text" %}
        {{ integer }}, {{ float }}, {{ string }}
        {% integer = 2 %}
        {% float = 3.2 %}
        {% string = "text2" %}
        {{ integer }}, {{ float }}, {{ string }}
        """
        )

        // Act
        let result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1, 2.5, text2, 3.2, text2")
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
        let result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "012")
    }
}

extension YaproqTests {
    func testAssignmentOperator() {
        // Arrange
        let template = Template("{% true += 1 %}")

        // Act/Assert
        XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 12)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            \(String(describing: SyntaxError.self)): \(ErrorType.invalidAssignmentTarget)
            """
            )
        }

        // Arrange
        let data: [String: [(String, String, String, String)]] = [ // variable, initial value, assigned value, result
            Token.Kind.minusEqual.rawValue: [
                ("result", "1", "1", "0"),
                ("result", "1.5", "1", "0.5"),
                ("result", "1", "1.5", "-0.5"),
                ("result", "1.5", "1.5", "0")
            ],
            Token.Kind.percentEqual.rawValue: [
                ("result", "1", "1", "0"),
                ("result", "1.5", "1", "0.5"),
                ("result", "1", "1.5", "1"),
                ("result", "1.5", "1.5", "0")
            ],
            Token.Kind.plusEqual.rawValue: [
                ("result", "1", "1", "2"),
                ("result", "1.5", "1", "2.5"),
                ("result", "1", "1.5", "2.5"),
                ("result", "1.5", "1.5", "3")
            ],
            Token.Kind.powerEqual.rawValue: [
                ("result", "2", "3", "8"),
                ("result", "1.5", "2", "2.25"),
                ("result", "2", "1.5", "2.8284271247461903"),
                ("result", "1.5", "1.5", "1.8371173070873836")
            ],
            Token.Kind.slashEqual.rawValue: [
                ("result", "1", "1", "1"),
                ("result", "1.5", "1", "1.5"),
                ("result", "3", "1.5", "2"),
                ("result", "1.2", "2.4", "0.5")
            ],
            Token.Kind.starEqual.rawValue: [
                ("result", "1", "1", "1"),
                ("result", "1.5", "1", "1.5"),
                ("result", "1", "1.5", "1.5"),
                ("result", "1.5", "1.5", "2.25")
            ]
        ]

        for (key, value) in data {
            for item in value {
                // Arrange
                let template = Template("""
                {% var \(item.0) = \(item.1) %}
                {% \(item.0) \(key) \(item.2) %}
                {{ \(item.0) }}
                """
                )

                // Act
                let result = try? templating.renderTemplate(template)

                // Assert
                XCTAssertEqual(result, "\(item.3)")
            }
        }

        // Arrange
        let errorData = [
            ("result", "1", "\"a\"", ErrorType.operandsMustBeNumbers.message, 2, 12),
            ("result", "1.5", "\"a\"", ErrorType.operandsMustBeNumbers.message, 2, 12),
            ("result", "2", "true", ErrorType.operandsMustBeNumbers.message, 2, 12),
            ("result", "2.5", "false", ErrorType.operandsMustBeNumbers.message, 2, 12)
        ]
        let invalidData: [String: [(String, String, String, String, Int, Int)]] = [
            Token.Kind.minusEqual.rawValue: errorData,
            Token.Kind.percentEqual.rawValue: errorData,
            Token.Kind.plusEqual.rawValue: errorData,
            Token.Kind.powerEqual.rawValue: errorData,
            Token.Kind.slashEqual.rawValue: errorData,
            Token.Kind.starEqual.rawValue: errorData
        ]

        for (key, value) in invalidData {
            for item in value {
                // Arrange
                let template = Template("""
                {% var \(item.0) = \(item.1) %}
                {% \(item.0) \(key) \(item.2) %}
                """
                )

                // Act/Assert
                XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
                    guard let error = error as? RuntimeError else {
                        XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                        return
                    }

                    XCTAssertNil(error.filePath)
                    XCTAssertEqual(error.line, item.4)
                    XCTAssertEqual(error.column, item.5)
                    XCTAssertEqual(error.errorDescription, """
                    [Line: \(error.line), Column: \(error.column)] \
                    \(String(describing: RuntimeError.self)): \(item.3)
                    """
                    )
                }
            }
        }
    }

    func testBinaryOperators() {
        // Arrange
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(1)
        let data: [String: [(String, String, String)]] = [ // left, right, result
            Token.Kind.bangEqual.rawValue: [
                ("1", "0", "true"),
                ("0.5", "1.0", "true"),
                ("1", "0.5", "true"),
                ("0.5", "1", "true"),
                ("1", "1", "false"),
                ("0.5", "0.5", "false"),
                ("\"a\"", "\"b\"", "true"),
                ("startDate", "endDate", "true")
            ],
            Token.Kind.equalEqual.rawValue: [
                ("1", "0", "false"),
                ("0.5", "1.0", "false"),
                ("1", "0.5", "false"),
                ("0.5", "1", "false"),
                ("1", "1", "true"),
                ("0.5", "0.5", "true"),
                ("\"a\"", "\"b\"", "false"),
                ("startDate", "endDate", "false")
            ],
            Token.Kind.greater.rawValue: [
                ("1", "0", "true"),
                ("0.5", "1.0", "false"),
                ("1", "0.5", "true"),
                ("0.5", "1", "false"),
                ("1", "1", "false"),
                ("0.5", "0.5", "false"),
                ("\"a\"", "\"b\"", "false"),
                ("startDate", "endDate", "false")
            ],
            Token.Kind.greaterOrEqual.rawValue: [
                ("1", "0", "true"),
                ("0.5", "1.0", "false"),
                ("1", "0.5", "true"),
                ("0.5", "1", "false"),
                ("1", "1", "true"),
                ("0.5", "0.5", "true"),
                ("\"a\"", "\"b\"", "false"),
                ("startDate", "endDate", "false")
            ],
            Token.Kind.less.rawValue: [
                ("1", "0", "false"),
                ("0.5", "1.0", "true"),
                ("1", "0.5", "false"),
                ("0.5", "1", "true"),
                ("1", "1", "false"),
                ("0.5", "0.5", "false"),
                ("\"a\"", "\"b\"", "true"),
                ("startDate", "endDate", "true")
            ],
            Token.Kind.lessOrEqual.rawValue: [
                ("1", "0", "false"),
                ("0.5", "1.0", "true"),
                ("1", "0.5", "false"),
                ("0.5", "1", "true"),
                ("1", "1", "true"),
                ("0.5", "0.5", "true"),
                ("\"a\"", "\"b\"", "true"),
                ("startDate", "endDate", "true")
            ],
            Token.Kind.minus.rawValue: [
                ("1", "0", "1"),
                ("0.5", "1.0", "-0.5"),
                ("1", "0.5", "0.5"),
                ("0.5", "1", "-0.5"),
                ("1", "1", "0"),
                ("0.5", "0.5", "0")
            ],
            Token.Kind.percent.rawValue: [
                ("3", "2", "1"),
                ("0.5", "1.0", "0.5"),
                ("1", "0.5", "0"),
                ("0.5", "1", "0.5"),
                ("1", "1", "0"),
                ("0.5", "0.5", "0")
            ],
            Token.Kind.plus.rawValue: [
                ("1", "0", "1"),
                ("0.5", "1.0", "1.5"),
                ("1", "0.5", "1.5"),
                ("0.5", "1", "1.5"),
                ("1", "1", "2"),
                ("0.5", "0.5", "1"),
                ("\"a\"", "\"b\"", "ab")
            ],
            Token.Kind.power.rawValue: [
                ("1", "0", "1"),
                ("0.5", "1.0", "0.5"),
                ("1", "0.5", "1"),
                ("0.5", "1", "0.5"),
                ("1", "1", "1"),
                ("0.5", "0.5", "0.7071067811865476")
            ],
            Token.Kind.questionQuestion.rawValue: [
                ("1", "0", "1"),
                ("0", "1", "0"),
                ("nil", "0", "0")
            ],
            Token.Kind.slash.rawValue: [
                ("3", "2", "1.5"),
                ("4", "2", "2"),
                ("0.5", "1.0", "0.5"),
                ("1", "0.5", "2"),
                ("0.5", "1", "0.5"),
                ("1", "1", "1"),
                ("0.5", "0.5", "1")
            ],
            Token.Kind.star.rawValue: [
                ("1", "0", "0"),
                ("0.5", "1.0", "0.5"),
                ("1", "0.5", "0.5"),
                ("0.5", "1", "0.5"),
                ("1", "1", "1"),
                ("0.5", "0.5", "0.25")
            ]
        ]

        for (key, value) in data {
            for item in value {
                // Arrange
                let template = Template("{{ \(item.0) \(key) \(item.1) }}")

                // Act
                let result = try? templating.renderTemplate(
                    template,
                    in: ["startDate": startDate, "endDate": endDate]
                )

                // Assert
                XCTAssertEqual(result, "\(item.2)")
            }
        }

        // Arrange
        let invalidData: [String: [(String, String, String, Int, Int)]] = [ // left, right, error, line, column
            Token.Kind.greater.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeComparable.message, 1, 6)
            ],
            Token.Kind.greaterOrEqual.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeComparable.message, 1, 7)
            ],
            Token.Kind.less.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeComparable.message, 1, 6)
            ],
            Token.Kind.lessOrEqual.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeComparable.message, 1, 7)
            ],
            Token.Kind.minus.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeNumbers.message, 1, 6)
            ],
            Token.Kind.percent.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeNumbers.message, 1, 6)
            ],
            Token.Kind.plus.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeEitherNumbersOrStrings.message, 1, 6)
            ],
            Token.Kind.power.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeNumbers.message, 1, 6)
            ],
            Token.Kind.slash.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeNumbers.message, 1, 6)
            ],
            Token.Kind.star.rawValue: [
                ("1", "\"a\"", ErrorType.operandsMustBeNumbers.message, 1, 6)
            ]
        ]

        for (key, value) in invalidData {
            for item in value {
                // Arrange
                let template = Template("{{ \(item.0) \(key) \(item.1) }}")

                // Act/Assert
                XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
                    guard let error = error as? RuntimeError else {
                        XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                        return
                    }

                    XCTAssertNil(error.filePath)
                    XCTAssertEqual(error.line, item.3)
                    XCTAssertEqual(error.column, item.4)
                    XCTAssertEqual(error.errorDescription, """
                    [Line: \(error.line), Column: \(error.column)] \
                    \(String(describing: RuntimeError.self)): \(item.2)
                    """
                    )
                }
            }
        }
    }

    func testClosedRangeOperator() {
        // Arrange
        var template = Template("""
        {% var result = 1...3 %}
        {{ result }}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1...3")

        // Arrange
        template = Template("""
        {% var min = 1 %}
        {% var result = min...3 %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1...3")

        // Arrange
        template = Template("""
        {% var max = 3 %}
        {% var result = 1...max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1...3")

        // Arrange
        template = Template("""
        {% var min = 1 %}
        {% var max = 3 %}
        {% var result = min...max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1...3")

        // Arrange
        template = Template("""
        {% var result = 1.5...3.0 %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.5...3.0")

        // Arrange
        template = Template("""
        {% var min = 1.0 %}
        {% var result = min...3.5 %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.0...3.5")

        // Arrange
        template = Template("""
        {% var max = 3.0 %}
        {% var result = 1.5...max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.5...3.0")

        // Arrange
        template = Template("""
        {% var min = 1.0 %}
        {% var max = 3.5 %}
        {% var result = min...max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.0...3.5")

        // Arrange
        template = Template("""
        {% var min = 1 %}
        {% var max = 3.5 %}
        {% var result = min...max %}
        {{ result }}
        """
        )

        XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
            guard let error = error as? RuntimeError else {
                XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 3)
            XCTAssertEqual(error.column, 22)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            \(String(describing: RuntimeError.self)): \(ErrorType.operandsMustBeEitherIntegersOrDoubles)
            """
            )
        }
    }

    func testLogicalAndOperator() {
        // Arrange
        var template = Template("""
        {{ true and true }}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "true")

        // Arrange
        template = Template("""
        {{ true and false }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "false")

        // Arrange
        template = Template("""
        {{ false and true }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "false")

        // Arrange
        template = Template("""
        {{ false and false }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "false")
    }

    func testLogicalOrOperator() {
        // Arrange
        var template = Template("""
        {{ true or true }}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "true")

        // Arrange
        template = Template("""
        {{ true or false }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "true")

        // Arrange
        template = Template("""
        {{ false or true }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "true")

        // Arrange
        template = Template("""
        {{ false or false }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "false")
    }

    func testRangeOperator() {
        // Arrange
        var template = Template("""
        {% var result = 1..<3 %}
        {{ result }}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1..<3")

        // Arrange
        template = Template("""
        {% var min = 1 %}
        {% var result = min..<3 %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1..<3")

        // Arrange
        template = Template("""
        {% var max = 3 %}
        {% var result = 1..<max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1..<3")

        // Arrange
        template = Template("""
        {% var min = 1 %}
        {% var max = 3 %}
        {% var result = min..<max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1..<3")

        // Arrange
        template = Template("""
        {% var result = 1.5..<3.0 %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.5..<3.0")

        // Arrange
        template = Template("""
        {% var min = 1.0 %}
        {% var result = min..<3.5 %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.0..<3.5")

        // Arrange
        template = Template("""
        {% var max = 3.0 %}
        {% var result = 1.5..<max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.5..<3.0")

        // Arrange
        template = Template("""
        {% var min = 1.0 %}
        {% var max = 3.5 %}
        {% var result = min..<max %}
        {{ result }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1.0..<3.5")

        // Arrange
        template = Template("""
        {% var min = 1.5 %}
        {% var max = 3 %}
        {% var result = min...max %}
        {{ result }}
        """
        )

        XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
            guard let error = error as? RuntimeError else {
                XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 3)
            XCTAssertEqual(error.column, 22)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            \(String(describing: RuntimeError.self)): \(ErrorType.operandsMustBeEitherIntegersOrDoubles)
            """
            )
        }
    }

    func testTernaryOperator() {
        // Arrange
        var template = Template("""
        {{ true ? 1 : 0 }}
        """
        )

        // Act
        var result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "1")

        // Arrange
        template = Template("""
        {{ false ? 1 : 0 }}
        """
        )

        // Act
        result = try? templating.renderTemplate(template)

        // Assert
        XCTAssertEqual(result, "0")

        // Arrange
        template = Template("""
        {{ true ? 1 }}
        """
        )

        // Act/Assert
        XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
            guard let error = error as? SyntaxError else {
                XCTFail("The error is not of \(String(describing: SyntaxError.self)) type.")
                return
            }

            XCTAssertNil(error.filePath)
            XCTAssertEqual(error.line, 1)
            XCTAssertEqual(error.column, 9)
            XCTAssertEqual(error.errorDescription, """
            [Line: \(error.line), Column: \(error.column)] \
            \(String(describing: SyntaxError.self)): \(ErrorType.invalidCharacter(Token.Kind.question.rawValue))
            """
            )
        }
    }

    func testUnaryOperators() {
        // Arrange
        let data: [String: [(String, String)]] = [ // right, result
            Token.Kind.bang.rawValue: [
                ("true", "false"),
                ("false", "true")
            ],
            Token.Kind.minus.rawValue: [
                ("1", "-1"),
                ("0.5", "-0.5"),
                ("-1", "1"),
                ("-0.5", "0.5")
            ]
        ]

        for (key, value) in data {
            for item in value {
                // Arrange
                let template = Template("{{ \(key)\(item.0) }}")

                // Act
                let result = try? templating.renderTemplate(template)

                // Assert
                XCTAssertEqual(result, "\(item.1)")
            }
        }

        // Arrange
        let invalidData: [String: [(String, String, Int, Int)]] = [ // right, error, line, column
            Token.Kind.bang.rawValue: [
                ("1", ErrorType.operandMustBeBoolean.message, 1, 4),
                ("0.5", ErrorType.operandMustBeBoolean.message, 1, 4),
                ("\"a\"", ErrorType.operandMustBeBoolean.message, 1, 4)
            ],
            Token.Kind.minus.rawValue: [
                ("true", ErrorType.operandMustBeNumber.message, 1, 4),
                ("false", ErrorType.operandMustBeNumber.message, 1, 4),
                ("\"a\"", ErrorType.operandMustBeNumber.message, 1, 4)
            ]
        ]

        for (key, value) in invalidData {
            for item in value {
                // Arrange
                let template = Template("{{ \(key)\(item.0) }}")

                // Act/Assert
                XCTAssertThrowsError(try templating.renderTemplate(template)) { error in
                    guard let error = error as? RuntimeError else {
                        XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                        return
                    }

                    XCTAssertNil(error.filePath)
                    XCTAssertEqual(error.line, item.2)
                    XCTAssertEqual(error.column, item.3)
                    XCTAssertEqual(error.errorDescription, """
                    [Line: \(error.line), Column: \(error.column)] \
                    \(String(describing: RuntimeError.self)): \(item.1)
                    """
                    )
                }
            }
        }
    }
}
