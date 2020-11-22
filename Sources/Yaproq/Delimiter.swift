public enum Delimiter {
    case comment(String, String)
    case output(String, String)
    case statement(String, String)

    static var comment: Delimiter = .comment("{#", "#}")
    static var output: Delimiter = .output("{{", "}}")
    static var statement: Delimiter = .statement("{%", "%}")
    static var all: [Delimiter] { [.comment, .output, .statement] }

    var name: String {
        switch self {
        case .comment:
            return "comment"
        case .output:
            return "output"
        case .statement:
            return "statement"
        }
    }

    var start: String {
        switch self {
        case .comment(let start, _):
            return start
        case .output(let start, _):
            return start
        case .statement(let start, _):
            return start
        }
    }

    var end: String {
        switch self {
        case .comment(_, let end):
            return end
        case .output(_, let end):
            return end
        case .statement(_, let end):
            return end
        }
    }
}

extension Delimiter: Hashable {
    public static func ==(lhs: Delimiter, rhs: Delimiter) -> Bool {
        lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
