import Foundation

public final class Yaproq {
    public let configuration: Configuration
    var currentEnvironment: Environment
    private var defaultEnvironment: Environment
    private var environments: [String: Environment]

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        defaultEnvironment = .init()
        currentEnvironment = defaultEnvironment
        environments = .init()
        setCurrentEnvironment()
    }
}

extension Yaproq {
    public func loadTemplate(named name: String) throws -> Template {
        try loadTemplate(at: configuration.directoryPath + name)
    }

    public func loadTemplate(at filePath: String) throws -> Template {
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: filePath) else {
            throw Yaproq.templateError("Can't load a template file at `\(filePath)`.", filePath: filePath)
        }
        guard let source = String(data: data, encoding: .utf8) else {
            throw Yaproq.templateError("A template file at `\(filePath)` must be UTF8 encodable.", filePath: filePath)
        }

        return Template(source, filePath: filePath)
    }
}

extension Yaproq {
    func parseTemplate(_ template: Template) throws -> [Statement] {
        let lexer = Lexer(template: template)
        let tokens = try lexer.scan()
        let parser = Parser(tokens: tokens)

        return try parser.parse()
    }
}

extension Yaproq {
    public func renderTemplate(named name: String, in context: [String: Encodable] = .init()) throws -> String {
        try renderTemplate(at: configuration.directoryPath + name, in: context)
    }

    func doRenderTemplate(named name: String, in context: [String: Encodable] = .init()) throws -> String {
        try doRenderTemplate(at: configuration.directoryPath + name, in: context)
    }

    public func renderTemplate(at filePath: String, in context: [String: Encodable] = .init()) throws -> String {
        setCurrentEnvironment(for: filePath)

        do {
            let output = try doRenderTemplate(at: filePath, in: context)
            clearEnvironments()

            return output
        } catch {
            clearEnvironments()
            throw error
        }
    }

    func doRenderTemplate(at filePath: String, in context: [String: Encodable] = .init()) throws -> String {
        try doRenderTemplate(try loadTemplate(at: filePath), in: context)
    }

    public func renderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        setCurrentEnvironment(for: template.filePath)

        do {
            let output = try doRenderTemplate(template, in: context)
            clearEnvironments()

            return output
        } catch {
            clearEnvironments()
            throw error
        }
    }

    func doRenderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        for (name, value) in context { currentEnvironment.setVariable(named: name, with: value) }
        let interpreter = Interpreter(templating: self, statements: try parseTemplate(template))

        return try interpreter.interpret()
    }
}

extension Yaproq {
    private func setCurrentEnvironment(for filePath: String? = nil) {
        if let filePath = filePath {
            if let environment = environments[filePath] {
                self.currentEnvironment = environment
            } else {
                currentEnvironment = .init()
                environments[filePath] = currentEnvironment
            }
        } else {
            currentEnvironment = defaultEnvironment
        }
    }

    private func clearEnvironments() {
        environments.removeAll()
        setCurrentEnvironment()
        currentEnvironment.reset()
    }
}

extension Yaproq {
    static func error(_ message: String) -> YaproqError {
        YaproqError(message)
    }

    static func templateError(_ message: String? = nil, filePath: String? = nil) -> TemplateError {
        TemplateError(message, filePath: filePath)
    }

    static func syntaxError(
        _ message: String? = nil,
        filePath: String? = nil,
        line: Int,
        column: Int
    ) -> SyntaxError {
        SyntaxError(message, filePath: filePath, line: line, column: column)
    }

    static func syntaxError(_ message: String? = nil, token: Token) -> SyntaxError {
        syntaxError(message, filePath: token.filePath, line: token.line, column: token.column)
    }

    static func runtimeError(_ message: String? = nil, token: Token) -> RuntimeError {
        RuntimeError(message, filePath: token.filePath, line: token.line, column: token.column)
    }
}

extension Yaproq {
    public struct Configuration {
        public static let defaultDirectoryPath = "/"
        public let directoryPath: String

        public init(directoryPath: String = defaultDirectoryPath) {
            self.directoryPath = directoryPath.normalizedPath
        }

        public init(directoryPath: String = defaultDirectoryPath, delimiters: Set<Delimiter>) throws {
            self.directoryPath = directoryPath.normalizedPath
            let initialDelimiters = Delimiter.allCases
            let initialRawDelimiters = Set<String>(
                initialDelimiters.map { $0.start } + initialDelimiters.map { $0.end }
            )

            for delimiter in delimiters {
                switch delimiter {
                case .comment(let start, let end):
                    Delimiter.comment = .comment(start, end)
                case .output(let start, let end):
                    Delimiter.output = .output(start, end)
                case .statement(let start, let end):
                    Delimiter.statement = .statement(start, end)
                }
            }

            let updatedDelimiters = Delimiter.allCases
            let updatedRawDelimiters = Set<String>(
                updatedDelimiters.map { $0.start } + updatedDelimiters.map { $0.end }
            )

            if updatedRawDelimiters.count != initialRawDelimiters.count {
                throw Yaproq.error("Delimiters must be unique.")
            }
        }
    }
}
