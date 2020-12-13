struct Token {
    let kind: Kind
    let lexeme: String
    var literal: Any?
    let line: Int
    let column: Int

    init(kind: Kind, lexeme: String, literal: Any? = nil, line: Int, column: Int) {
        self.kind = kind
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
        self.column = column
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        var description = "[\(line):\(column)] \(kind), \(lexeme)"
        if let literal = literal { description += ", \(String(describing: literal))" }

        return description
    }
}

extension Token: Equatable {
    static func ==(lhs: Token, rhs: Token) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.lexeme == rhs.lexeme &&
        String(describing: lhs.literal ?? "") == String(describing: rhs.literal ?? "") &&
        lhs.line == rhs.line &&
        lhs.column == rhs.column
    }
}

extension Token {
    enum Kind: String {
        // Single-character.
        case carriageReturn = "\r"
        case colon = ":"
        case comma = ","
        case dot = "."
        case leftBrace = "{"
        case leftBracket = "["
        case leftParenthesis = "("
        case newline = "\n"
        case quote = "\""
        case rightBrace = "}"
        case rightBracket = "]"
        case rightParenthesis = ")"
        case tab = "\t"
        case whitespace = " "

        // One or two character.
        case bang = "!"
        case bangEqual = "!="
        case closedRange = "..."
        case equal = "="
        case equalEqual = "=="
        case greater = ">"
        case greaterOrEqual = ">="
        case halfOpenRange = "..<"
        case less = "<"
        case lessOrEqual = "<="
        case minus = "-"
        case minusEqual = "-="
        case percent = "%"
        case percentEqual = "%="
        case plus = "+"
        case plusEqual = "+="
        case power = "^"
        case powerEqual = "^="
        case question = "?"
        case questionQuestion = "??"
        case slash = "/"
        case slashEqual = "/="
        case star = "*"
        case starEqual = "*="

        // Literals.
        case `false`
        case identifier
        case `nil`
        case number
        case string
        case `true`

        // Keywords.
        case and
        case block
        case `else`
        case elseif
        case extend
        case `for`
        case `if`
        case `in`
        case include
        case or
        case print
        case `super` = "@super"
        case `var`
        case `while`

        // End keywords.
        case endblock
        case endfor
        case endif
        case endwhile

        // End of file.
        case eof = "\0"

        static var keywords: Set<Kind> = [
            .and, .block, .else, .elseif, .endblock, .endfor, .endif, .endwhile, .extend,
            .false, .for, .if, .in, .include, .nil, .or, .super, .true, .var, .while
        ]
        static var blockStartKeywords: Set<Kind> = [.block, .for, .if, .while]
        static var blockEndKeywords: Set<Kind> = [.endblock, .endfor, .endif, .endwhile]
    }
}
