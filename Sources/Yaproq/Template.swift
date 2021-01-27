public struct Template: CustomStringConvertible, Equatable, ExpressibleByStringLiteral {
    public let source: String
    public private(set) var filePath: String?
    public var description: String { source }

    public init(stringLiteral source: String) {
        self.source = source
    }

    public init(_ source: String, filePath: String? = nil) {
        self.source = source
        self.filePath = filePath
    }
}
