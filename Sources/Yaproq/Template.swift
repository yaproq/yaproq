public struct Template: Equatable, ExpressibleByStringLiteral {
    public let source: String
    public private(set) var filePath: String?

    public init(stringLiteral source: String) {
        self.source = source
    }

    public init(_ source: String, filePath: String? = nil) {
        self.source = source
        self.filePath = filePath
    }
}
