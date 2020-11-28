import Foundation

public final class Yaproq {
    public let configuration: Configuration
    private lazy var interpreter = Interpreter(templating: self)

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public func loadTemplate(at path: String) throws -> String {
        let path = configuration.directoryPath + path
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path),
            let data = fileManager.contents(atPath: path),
            let source = String(data: data, encoding: .utf8) else { throw TemplateError("An invalid source.") }

        return source
    }

    public func renderTemplate(at path: String, context: [String: Any] = .init()) throws {
        let source = try loadTemplate(at: path)
        interpreter.environment.variables = context
        interpreter.statements = try parse(source)
        try interpreter.interpret()
    }

    func parse(_ source: String) throws -> [Statement] {
        let scanner = Scanner(source: source)
        let tokens = try scanner.scanTokens()
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
            let initialDelimiters = Delimiter.all
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

            let updatedDelimiters = Delimiter.all
            let updatedRawDelimiters = Set<String>(
                updatedDelimiters.map { $0.start } + updatedDelimiters.map { $0.end }
            )

            if updatedRawDelimiters.count != initialRawDelimiters.count {
                throw TemplateError("Delimiters must be unique.")
            }
        }
    }
}
