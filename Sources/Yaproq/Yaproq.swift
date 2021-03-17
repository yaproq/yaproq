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

    public func loadTemplate(named name: String) throws -> Template {
        try loadTemplate(at: configuration.directoryPath + name)
    }

    public func loadTemplate(at filePath: String) throws -> Template {
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: filePath) else {
            throw TemplateError("Can't load a template file at `\(filePath)`.", filePath: filePath)
        }
        guard let source = String(data: data, encoding: .utf8) else {
            throw TemplateError("A template file at `\(filePath)` must be UTF8 encodable.", filePath: filePath)
        }

        return Template(source, filePath: filePath)
    }

    public func renderTemplate(named name: String, in context: [String: Encodable] = .init()) throws -> String {
        try renderTemplate(at: configuration.directoryPath + name, in: context)
    }

    func _renderTemplate(named name: String, in context: [String: Encodable] = .init()) throws -> String {
        try _renderTemplate(at: configuration.directoryPath + name, in: context)
    }

    public func renderTemplate(at filePath: String, in context: [String: Encodable] = .init()) throws -> String {
        setCurrentEnvironment(for: filePath)

        do {
            let output = try _renderTemplate(at: filePath, in: context)
            clearEnvironments()

            return output
        } catch {
            clearEnvironments()
            throw error
        }
    }

    func _renderTemplate(at filePath: String, in context: [String: Encodable] = .init()) throws -> String {
        try _renderTemplate(try loadTemplate(at: filePath), in: context)
    }

    public func renderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        setCurrentEnvironment(for: template.filePath)

        do {
            let output = try _renderTemplate(template, in: context)
            clearEnvironments()

            return output
        } catch {
            clearEnvironments()
            throw error
        }
    }

    func _renderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        for (name, value) in context { currentEnvironment.setVariable(named: name, with: value) }
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
    public struct Configuration {
        public static let defaultDirectoryPath = "/"
        public private(set) var directoryPath: String

        public init(directoryPath: String = defaultDirectoryPath) {
            self.directoryPath = directoryPath
            self.directoryPath = normalize(path: self.directoryPath)
        }

        public init(directoryPath: String = defaultDirectoryPath, delimiters: Set<Delimiter>) throws {
            self.directoryPath = directoryPath
            self.directoryPath = normalize(path: self.directoryPath)
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

        private func normalize(path: String) -> String {
            path.last == Character("/") ? path : path + "/"
        }
    }
}

extension Yaproq {
    static func runtimeError(for token: Token, with message: String) -> RuntimeError {
        RuntimeError(message, filePath: token.filePath, line: token.line, column: token.column)
    }
}
