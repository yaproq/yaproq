public struct Template: CustomStringConvertible, Equatable, ExpressibleByStringLiteral {
    public let source: String
    public let filePath: String?
    public internal(set) var isCached = false
    public var description: String { source }

    public init(stringLiteral source: String) {
        self.source = source
        filePath = nil
    }

    public init(_ source: String, filePath: String? = nil) {
        self.source = source
        self.filePath = filePath
    }
}
