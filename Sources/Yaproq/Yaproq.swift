import Foundation

public final class Yaproq {
    public let configuration: Configuration
    var environment: Environment
    private var defaultEnvironment: Environment
    private var environments: [String: Environment]

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        defaultEnvironment = .init()
        environment = defaultEnvironment
        environments = .init()
        setCurrentEnvironment()
    }

    public func loadTemplate(named name: String) throws -> Template {
        try loadTemplate(at: configuration.directoryPath + name)
    }

    func _loadTemplate(named name: String) throws -> Template {
        try _loadTemplate(at: configuration.directoryPath + name)
    }

    public func loadTemplate(at filePath: String) throws -> Template {
        let template = try _loadTemplate(at: filePath)
        setCurrentEnvironment(for: filePath)

        return template
    }

    func _loadTemplate(at filePath: String) throws -> Template {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath),
            let data = fileManager.contents(atPath: filePath),
            let source = String(data: data, encoding: .utf8) else { throw TemplateError("An invalid template.") }

        return Template(source, filePath: filePath)
    }

    public func renderTemplate(named name: String, context: [String: Encodable] = .init()) throws -> String {
        try renderTemplate(at: configuration.directoryPath + name, context: context)
    }

    func _renderTemplate(named name: String, context: [String: Encodable] = .init()) throws -> String {
        try _renderTemplate(at: configuration.directoryPath + name, context: context)
    }

    public func renderTemplate(at filePath: String, context: [String: Encodable] = .init()) throws -> String {
        setCurrentEnvironment(for: filePath)
        return try _renderTemplate(at: filePath, context: context)
    }

    func _renderTemplate(at filePath: String, context: [String: Encodable] = .init()) throws -> String {
        try _renderTemplate(try _loadTemplate(at: filePath), context: context)
    }

    public func renderTemplate(_ template: Template, context: [String: Encodable] = .init()) throws -> String {
        setCurrentEnvironment(for: template.filePath)
        return try _renderTemplate(template, context: context)
    }

    func _renderTemplate(_ template: Template, context: [String: Encodable] = .init()) throws -> String {
        for (name, value) in context { environment.setVariable(named: name, with: value) }
        let interpreter = Interpreter(templating: self, statements: try parseTemplate(template))

        return try interpreter.interpret()
    }

    func parseTemplate(_ template: Template) throws -> [Statement] {
        let lexer = Lexer(template: template)
        let tokens = try lexer.scan()
        let parser = Parser(tokens: tokens)

        return try parser.parse()
    }

    private func setCurrentEnvironment(for filePath: String? = nil) {
        if let filePath = filePath {
            if let environment = environments[filePath] {
                self.environment = environment
            } else {
                environment = .init()
                environments[filePath] = environment
            }
        } else {
            environment = defaultEnvironment
        }
    }
}

extension Yaproq {
    public struct Configuration {
        public static let defaultDirectoryPath = "/"
        public let directoryPath: String

        public init(directoryPath: String = defaultDirectoryPath) {
            self.directoryPath = directoryPath
        }

        public init(directoryPath: String = defaultDirectoryPath, delimiters: Set<Delimiter>) throws {
            self.directoryPath = directoryPath
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
                throw YaproqError("Delimiters must be unique.")
            }
        }
    }
}
