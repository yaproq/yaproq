import Foundation

public final class Yaproq {
    public var configuration: Configuration
    public private(set) var templates = [String: Template]()
    private let templateCache: Cache<String, Template>
    private let statementCache: Cache<String, [Statement]>

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        let costLimit = configuration.caching.costLimit
        let countLimit = configuration.caching.countLimit
        templateCache = .init(costLimit: costLimit, countLimit: countLimit)
        statementCache = .init(costLimit: costLimit, countLimit: countLimit)
    }
}

extension Yaproq {
    public func loadTemplate(named name: String) throws -> Template {
        let directories = Array(configuration.directories)

        for directory in directories {
            do {
                return try loadTemplate(at: directory + name)
            } catch {
                if directory == directories.last {
                    throw error
                }
            }
        }

        throw templateError(.invalidTemplateFile, filePath: name)
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

    private func loadTemplates(in statements: [Statement], with compiler: Compiler) throws {
        for statement in statements {
            if let extendStatement = statement as? ExtendStatement {
                try loadTemplate(from: extendStatement.expression, with: compiler)
            } else if let includeStatement = statement as? IncludeStatement {
                try loadTemplate(from: includeStatement.expression, with: compiler)
            } else if let blockStatement = statement as? BlockStatement {
                try loadTemplates(in: blockStatement.statements, with: compiler)
            }
        }
    }

    private func loadTemplate(from expression: AnyExpression, with compiler: Compiler) throws {
        if var filePath = try compiler.evaluate(expression: expression) as? String {
            let directories = Array(configuration.directories)

            for directory in directories {
                let absoluteFilePath = directory + filePath

                if cachedTemplate(at: absoluteFilePath) == nil && cachedTemplate(at: filePath) == nil {
                    var template: Template?

                    do {
                        template = try loadAndCacheTemplate(at: absoluteFilePath)
                        filePath = absoluteFilePath
                    } catch {
                        do {
                            template = try loadAndCacheTemplate(at: filePath)
                        } catch {
                            if directory == directories.last {
                                throw error
                            }
                        }
                    }

                    if let template = template {
                        let childStatements = try parseTemplate(template)
                        cacheStatements(childStatements, for: template)

                        if templates[filePath] == nil {
                            templates[filePath] = template
                        }

                        try loadTemplates(in: childStatements, with: compiler)
                        break
                    }
                } else {
                    break
                }
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
        let directories = Array(configuration.directories)

        for directory in directories {
            do {
                return try renderTemplate(at: directory + name, in: context)
            } catch {
                if directory == directories.last {
                    throw error
                }
            }
        }

        throw templateError(.invalidTemplateFile, filePath: name)
    }

    public func renderTemplate(at filePath: String, in context: [String: Encodable] = .init()) throws -> String {
        try renderTemplate(try loadAndCacheTemplate(at: filePath), in: context)
    }

    public func renderTemplate(_ template: Template, in context: [String: Encodable] = .init()) throws -> String {
        let compiler = Compiler()
        compiler.environment.directories = configuration.directories
        let statements = try cachedStatements(for: template)

        for (name, value) in context {
            compiler.environment.setVariable(value: value, for: name)
        }

        try loadTemplates(in: statements, with: compiler)
        compiler.environment.templates = templates
        let result = try compiler.compile(statements: statements)
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

        if let template = templateCache.getValue(forKey: filePath) {
            return template
        }

        var template = try loadTemplate(at: filePath)

        if !configuration.isDebug {
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
        public static let defaultDirectory = "/"
        public let isDebug: Bool
        public let directories: Set<String>
        public let caching: Caching

        public init(
            caching: Caching = .init(),
            directories: Set<String> = .init(arrayLiteral: defaultDirectory),
            isDebug: Bool = false
        ) {
            self.caching = caching
            Delimiter.reset()
            self.directories = Set<String>(directories.map { $0.normalizedPath })
            self.isDebug = isDebug
        }

        public init(
            caching: Caching = .init(),
            delimiters: Set<Delimiter>,
            directories: Set<String> = .init(arrayLiteral: defaultDirectory),
            isDebug: Bool = false
        ) throws {
            self.init(caching: caching, directories: directories, isDebug: isDebug)

            let initialDelimiters = Delimiter.allCases
            let initialRawDelimiters = Set<String>(
                initialDelimiters.map { $0.start } + initialDelimiters.map { $0.end }
            )

            for delimiter in delimiters {
                switch delimiter {
                case .comment(let start, let end): Delimiter.comment = .comment(start, end)
                case .output(let start, let end): Delimiter.output = .output(start, end)
                case .statement(let start, let end): Delimiter.statement = .statement(start, end)
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

extension Yaproq.Configuration {
    public struct Caching {
        public let costLimit: Int
        public let countLimit: Int

        public init(costLimit: Int = 0, countLimit: Int = 0) {
            self.costLimit = costLimit
            self.countLimit = countLimit
        }
    }
}
