import Foundation

public final class Yaproq {
    public var configuration: Configuration
    public private(set) var templates: [String: Template] = .init()
    private var templateCache = Cache<String, Template>()
    private var statementCache = Cache<String, [Statement]>()

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        templateCache.costLimit = configuration.caching.costLimit
        templateCache.countLimit = configuration.caching.countLimit
        statementCache.costLimit = configuration.caching.costLimit
        statementCache.countLimit = configuration.caching.countLimit
    }
}

extension Yaproq {
    public func loadTemplate(named name: String) throws -> Template {
        try loadTemplate(at: configuration.directoryPath + name)
    }

    public func loadTemplate(at filePath: String) throws -> Template {
        let fileManager = FileManager.default
        guard let data = fileManager.contents(atPath: filePath) else {
            throw templateError(.invalidTemplateFile, filePath: filePath)
        }
        guard let source = String(data: data, encoding: .utf8) else {
            throw templateError(.templateFileMustBeUTF8Encodable, filePath: filePath)
        }

        return Template(source, filePath: filePath)
    }

    private func loadTemplates(in statements: [Statement], with interpreter: Interpreter) throws {
        for statement in statements {
            if let extendStatement = statement as? ExtendStatement {
                try loadTemplate(from: extendStatement.expression, with: interpreter)
            } else if let includeStatement = statement as? IncludeStatement {
                try loadTemplate(from: includeStatement.expression, with: interpreter)
            } else if let blockStatement = statement as? BlockStatement {
                try loadTemplates(in: blockStatement.statements, with: interpreter)
            }
        }
    }

    private func loadTemplate(from expression: AnyExpression, with interpreter: Interpreter) throws {
        if var filePath = try interpreter.evaluate(expression: expression) as? String {
            let absoluteFilePath = configuration.directoryPath + filePath

            if cachedTemplate(at: absoluteFilePath) == nil && cachedTemplate(at: filePath) == nil {
                let template: Template

                do {
                    template = try loadAndCacheTemplate(at: absoluteFilePath)
                    filePath = absoluteFilePath
                } catch is TemplateError {
                    template = try loadAndCacheTemplate(at: filePath)
                }

                let childStatements = try parseTemplate(template)
                cacheStatements(childStatements, for: template)
                if templates[filePath] == nil { templates[filePath] = template }
                try loadTemplates(in: childStatements, with: interpreter)
            }
        }
    }

    private func cachedTemplate(at filePath: String) -> Template? {
        if let template = templateCache.getValue(forKey: filePath) {
            return template
        } else if let template = templates[filePath] {
            return template
        }

        return nil
    }
}

extension Yaproq {
    private func parseTemplate(_ template: Template) throws -> [Statement] {
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

    public func renderTemplate(at filePath: String, in context: [String: Encodable] = .init()) throws -> String {
        try renderTemplate(try loadAndCacheTemplate(at: filePath), in: context)
    }

    public func renderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        let interpreter = Interpreter()
        interpreter.environment.directoryPath = configuration.directoryPath
        let statements = try cachedStatements(for: template)
        for (name, value) in context { interpreter.environment.setVariable(value: value, for: name) }
        try loadTemplates(in: statements, with: interpreter)
        interpreter.environment.templates = templates
        let result = try interpreter.interpret(statements: statements)
        cacheStatements(statements, for: template)

        return result
    }
}

extension Yaproq {
    private func loadAndCacheTemplate(at filePath: String) throws -> Template {
        if configuration.isDebug {
            templateCache.removeValue(forKey: filePath)
            statementCache.removeValue(forKey: filePath)
        }

        if let template = templateCache.getValue(forKey: filePath) { return template }
        let template = try loadTemplate(at: filePath)

        if !configuration.isDebug {
            var template = template
            template.isCached = true
            templateCache.setValue(template, forKey: filePath)
        }

        return template
    }

    private func cachedStatements(for template: Template) throws -> [Statement] {
        if template.isCached,
           let filePath = template.filePath,
           let statements = statementCache.getValue(forKey: filePath) {
            return statements
        }

        return try parseTemplate(template)
    }

    private func cacheStatements(_ statements: [Statement], for template: Template) {
        if !configuration.isDebug, !template.isCached, let filePath = template.filePath {
            statementCache.setValue(statements, forKey: filePath)
        }
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
                throw error(.delimitersMustBeUnique)
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
