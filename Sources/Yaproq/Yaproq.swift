import Foundation

public final class Yaproq {
    public let configuration: Configuration
    private lazy var interpreter = Interpreter(templating: self)

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }

    public func loadTemplate(named name: String) throws -> String {
        try loadTemplate(at: configuration.directoryPath + name)
    }

    public func loadTemplate(at path: String) throws -> String {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path),
            let data = fileManager.contents(atPath: path),
            let source = String(data: data, encoding: .utf8) else { throw TemplateError("An invalid source.") }

        return source
    }

    public func renderTemplate(named name: String, context: [String: Any] = .init()) throws -> String {
        try renderTemplate(at: configuration.directoryPath + name, context: context)
    }

    public func renderTemplate(at path: String, context: [String: Any] = .init()) throws -> String {
        try renderTemplate(try loadTemplate(at: path))
    }

    public func renderTemplate(_ template: String, context: [String: Any] = .init()) throws -> String {
        for (name, value) in context { try interpreter.environment.defineVariable(named: name, with: value) }
        interpreter.statements = try parse(template)

        return try interpreter.interpret()
    }

    func parse(_ source: String) throws -> [Statement] {
        let lexer = Lexer(source: source)
        let tokens = try lexer.scan()
        let parser = Parser(tokens: tokens)

        return try parser.parse()
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
                throw TemplateError("Delimiters must be unique.")
            }
        }
    }
}
