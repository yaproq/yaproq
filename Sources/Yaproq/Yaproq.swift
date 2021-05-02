import Foundation

public final class Yaproq {
    public var configuration: Configuration
    var currentEnvironment: Environment
    private var defaultEnvironment: Environment
    private var environments: [String: Environment]
    private var cache = Cache<String, [Statement]>()

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        defaultEnvironment = .init()
        currentEnvironment = defaultEnvironment
        environments = .init()
        setCurrentEnvironment()
        cache.costLimit = configuration.caching.costLimit
        cache.countLimit = configuration.caching.countLimit
    }
}

extension Yaproq {
    public func loadTemplate(named name: String) throws -> Template {
        try loadTemplate(at: configuration.directoryPath + name)
    }

    public func loadTemplate(at filePath: String) throws -> Template {
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: filePath) else {
            throw Yaproq.templateError(.invalidTemplateFilePath(filePath: filePath), filePath: filePath)
        }
        guard let source = String(data: data, encoding: .utf8) else {
            throw Yaproq.templateError(.contentMustBeUTF8Encodable(filePath: filePath), filePath: filePath)
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
            let result = try doRenderTemplate(at: filePath, in: context)
            clearEnvironments()

            return result
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
            let result = try doRenderTemplate(template, in: context)
            clearEnvironments()

            return result
        } catch {
            clearEnvironments()
            throw error
        }
    }

    func doRenderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        for (name, value) in context { currentEnvironment.setVariable(value: value, for: name) }
        let statements: [Statement]

        if configuration.isDebug {
            statements = try parseTemplate(template)
        } else {
            if let filePath = template.filePath {
                if let cachedStatements = cache.getValue(forKey: filePath) {
                    statements = cachedStatements
                } else {
                    statements = try parseTemplate(template)
                }
            } else {
                statements = try parseTemplate(template)
            }
        }

        let interpreter = Interpreter(templating: self, statements: statements)
        let result = try interpreter.interpret()

        if let filePath = template.filePath, cache.getValue(forKey: filePath) == nil {
            cache.setValue(statements, forKey: filePath)
        }

        return result
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
        currentEnvironment.clear()
    }
}

extension Yaproq {
    static func error(_ errorType: ErrorType? = nil) -> YaproqError {
        YaproqError(errorType?.message)
    }

    static func error(_ message: String) -> YaproqError {
        YaproqError(message)
    }

    static func templateError(_ errorType: ErrorType? = nil, filePath: String? = nil) -> TemplateError {
        templateError(errorType?.message, filePath: filePath)
    }

    static func templateError(_ message: String? = nil, filePath: String? = nil) -> TemplateError {
        TemplateError(message, filePath: filePath)
    }

    static func syntaxError(_ errorType: ErrorType? = nil, token: Token) -> SyntaxError {
        syntaxError(errorType?.message, filePath: token.filePath, line: token.line, column: token.column)
    }

    static func syntaxError(_ message: String? = nil, token: Token) -> SyntaxError {
        syntaxError(message, filePath: token.filePath, line: token.line, column: token.column)
    }

    static func syntaxError(
        _ errorType: ErrorType? = nil,
        filePath: String? = nil,
        line: Int,
        column: Int
    ) -> SyntaxError {
        syntaxError(errorType?.message, filePath: filePath, line: line, column: column)
    }

    static func syntaxError(
        _ message: String? = nil,
        filePath: String? = nil,
        line: Int,
        column: Int
    ) -> SyntaxError {
        SyntaxError(message, filePath: filePath, line: line, column: column)
    }

    static func runtimeError(_ errorType: ErrorType? = nil, token: Token) -> RuntimeError {
        runtimeError(errorType?.message, token: token)
    }

    static func runtimeError(_ message: String? = nil, token: Token) -> RuntimeError {
        RuntimeError(message, filePath: token.filePath, line: token.line, column: token.column)
    }
}

extension Yaproq {
    public struct Configuration {
        public static let defaultDirectoryPath = "/"
        public let directoryPath: String
        public let isDebug: Bool
        public let caching: CachingConfiguration

        public init(
            directoryPath: String = defaultDirectoryPath,
            isDebug: Bool = false,
            caching: CachingConfiguration = .init()
        ) {
            self.directoryPath = directoryPath.normalizedPath
            self.isDebug = isDebug
            self.caching = caching
        }

        public init(
            directoryPath: String = defaultDirectoryPath,
            isDebug: Bool = false,
            caching: CachingConfiguration = .init(),
            delimiters: Set<Delimiter>
        ) throws {
            self.directoryPath = directoryPath.normalizedPath
            self.isDebug = isDebug
            self.caching = caching
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
                throw Yaproq.error(.delimitersMustBeUnique)
            }
        }
    }
}

extension Yaproq {
    public struct CachingConfiguration {
        public let costLimit: Int
        public let countLimit: Int

        public init(costLimit: Int = 0, countLimit: Int = 0) {
            self.costLimit = costLimit
            self.countLimit = countLimit
        }
    }
}
