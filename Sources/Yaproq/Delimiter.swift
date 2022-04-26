public enum Delimiter: CaseIterable {
    case comment(String, String), output(String, String), statement(String, String)

    /// See `CaseIterable`.
    public static var allCases: [Delimiter] { [.comment, .output, .statement] }

    static var comment: Delimiter = .comment(Default.comment.start, Default.comment.end)
    static var output: Delimiter = .output(Default.output.start, Default.output.end)
    static var statement: Delimiter = .statement(Default.statement.start, Default.statement.end)

    var name: String {
        switch self {
        case .comment: return "comment"
        case .output: return "output"
        case .statement: return "statement"
        }
    }

    var start: String {
        switch self {
        case .comment(let start, _): return start
        case .output(let start, _): return start
        case .statement(let start, _): return start
        }
    }

    var end: String {
        switch self {
        case .comment(_, let end): return end
        case .output(_, let end): return end
        case .statement(_, let end): return end
        }
    }

    static func reset() {
        Delimiter.comment = .comment(Default.comment.start, Default.comment.end)
        Delimiter.output = .output(Default.output.start, Default.output.end)
        Delimiter.statement = .statement(Default.statement.start, Default.statement.end)
    }
}

extension Delimiter {
    enum Default {
        case comment, output, statement

        var start: String {
            switch self {
            case .comment: return "{#"
            case .output: return "{{"
            case .statement: return "{%"
            }
        }

        var end: String {
            switch self {
            case .comment: return "#}"
            case .output: return "}}"
            case .statement: return "%}"
            }
        }
    }
}

extension Delimiter: Hashable {
    /// See `Equatable`.
    public static func == (lhs: Delimiter, rhs: Delimiter) -> Bool {
        lhs.name == rhs.name
    }

    /// See `Hashable`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
