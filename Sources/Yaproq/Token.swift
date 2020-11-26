struct Token {
    let kind: Kind
    let lexeme: String
    let literal: Any?
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

extension Token {
    enum Kind: String {
        // Single-character.
        case carriageReturn = "\r"
        case comma = ","
        case dot = "."
        case leftBrace = "{"
        case leftParenthesis = "("
        case minus = "-"
        case newline = "\n"
        case nullTerminator = "\0"
        case plus = "+"
        case quote = "\""
        case rightBrace = "}"
        case rightParenthesis = ")"
        case slash = "/"
        case star = "*"
        case tab = "\t"
        case whitespace = " "

        // One or two character.
        case bang = "!"
        case bangEqual = "!="
        case equal = "="
        case equalEqual = "=="
        case greater = ">"
        case greaterOrEqual = ">="
        case less = "<"
        case lessOrEqual = "<="

        // Literals.
        case identifier
        case number
        case string

        // Keywords.
        case and
        case block
        case `else`
        case elseif
        case extend
        case `false`
        case `for`
        case `if`
        case include
        case `nil`
        case or
        case print
        case `super` = "@super"
        case `true`
        case `var`
        case `while`

        // End keywords.
        case endblock
        case endfor
        case endif
        case endwhile

        // End of file.
        case eof = ""

        static var keywords: Set<Kind> = [
            .and, .block, .else, .elseif, .endblock, .endfor, .endif, .endwhile, .extend,
            .false, .for, .if, .include, .nil, .or, .super, .true, .var, .while
        ]
        static var blockStartKeywords: Set<Kind> = [.block, .for, .if, .while]
        static var blockEndKeywords: Set<Kind> = [.endblock, .endfor, .endif, .endwhile]
    }
}
