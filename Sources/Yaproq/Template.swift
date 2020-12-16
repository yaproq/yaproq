public struct Template: Equatable, ExpressibleByStringLiteral {
    public let source: String

    public init(stringLiteral source: String) {
        self.source = source
    }
}
