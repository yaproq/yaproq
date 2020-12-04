final class Scanner {
    let source: String
    let count: Int
    private let delimiters: [Delimiter]

    private var start = 0
    private var current = 0
    private var line = 1
    private var column = 0
    private var currentDelimiterIndex: Int?
    private lazy var tokens: [Token] = .init()

    init(source: String) {
        self.source = source
        count = source.count
        delimiters = Delimiter.all
    }
}

extension Scanner {
    @discardableResult
    private func advance(_ step: Int = 1) -> String {
        current += step
        column += step

        return character(at: current - step)
    }

    private func skip() {
        start += 1
        current = start
        column = start
    }

    private func peek() -> String {
        isAtEnd() ? Token.Kind.nullTerminator.rawValue : character(at: current)
    }

    private func peekNext() -> String {
        let index = current + 1
        return index >= count ? Token.Kind.nullTerminator.rawValue : character(at: index)
    }

    private func matches(_ character: String) -> Bool {
        if isAtEnd() || character != self.character(at: current) { return false }
        current += 1
        column += 1

        return true
    }

    private func isAtEnd() -> Bool {
        current >= count
    }
}

extension Scanner {
    private func character(at index: Int) -> String {
        substring(from: index, to: index + 1)
    }

    private func substring(next count: Int = 1) -> String {
        let start = current
        var end = start + count
        if end > self.count { end = self.count }

        return substring(from: start, to: end)
    }

    private func substring(from start: Int, to end: Int) -> String {
        let lowerBound = source.index(source.startIndex, offsetBy: start)
        let upperBound = source.index(source.startIndex, offsetBy: end)
        let range = lowerBound..<upperBound

        return String(source[range])
    }
}

extension Scanner {
    private func isAlpha(_ character: String) -> Bool {
        (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") || character == "_"
    }

    private func isAlphaNumeric(_ character: String) -> Bool {
        isAlpha(character) || isNumeric(character)
    }

    private func isNumeric(_ character: String) -> Bool {
        Int(character) != nil
    }
}

extension Scanner {
    private func ignoreNewline() {
        line += 1
        column = 0
    }

    @discardableResult
    private func ignoreNextNewline() -> Bool {
        if peek() == Token.Kind.newline.rawValue {
            advance()
            ignoreNewline()

            return true
        }

        return false
    }

    private func ignoreComment() {
        while let currentDelimiterIndex = currentDelimiterIndex,
              delimiters[currentDelimiterIndex].start == Delimiter.comment.start, !isAtEnd() {
            if let delimiterIndex = delimiters.firstIndex(
                where: { $0.end == Delimiter.comment.end && $0.end == substring(next: $0.end.count) }
            ) {
                let endDelimiter = delimiters[delimiterIndex].end
                advance(endDelimiter.count)
                self.currentDelimiterIndex = nil
                break
            } else {
                advance()
            }
        }
    }
}

extension Scanner {
    func scanTokens() throws -> [Token] {
        while !isAtEnd() {
            start = current
            try scanToken()
        }

        let kind: Token.Kind = .eof
        let token = Token(kind: kind, lexeme: kind.rawValue, line: line, column: column)
        tokens.append(token)

        return tokens
    }

    private func scanToken() throws {
        if let currentDelimiterIndex = currentDelimiterIndex {
            let character = advance()

            if let delimiterIndex = delimiters.firstIndex(where: { $0.end == substring(next: $0.end.count) }) {
                let endDelimiter = delimiters[delimiterIndex].end

                if currentDelimiterIndex != delimiterIndex {
                    throw SyntaxError("An invalid closing delimiter `\(endDelimiter)`.", line: line, column: column)
                }

                advance(endDelimiter.count)
                ignoreNextNewline()
                self.currentDelimiterIndex = nil
            } else {
                let startDelimiter = delimiters[currentDelimiterIndex].start

                if startDelimiter == Delimiter.comment.start {
                    ignoreComment()
                } else if startDelimiter == Delimiter.output.start {
                    try addPrintToken(for: character)
                } else {
                    try addToken(for: character)
                }
            }
        } else {
            let character = self.character(at: current)

            if character == Token.Kind.newline.rawValue {
                ignoreNewline()
            }

            addTextToken()
        }
    }
}

extension Scanner {
    private func addToken(for character: String) throws {
        switch character {
        case Token.Kind.bang.rawValue:
            addToken(kind: matches(Token.Kind.equal.rawValue) ? .bangEqual : .bang)
        case Token.Kind.equal.rawValue:
            addToken(kind: matches(Token.Kind.equal.rawValue) ? .equalEqual : .equal)
        case Token.Kind.greater.rawValue:
            addToken(kind: matches(Token.Kind.equal.rawValue) ? .greaterOrEqual : .greater)
        case Token.Kind.leftParenthesis.rawValue:
            addToken(kind: .leftParenthesis)
        case Token.Kind.less.rawValue:
            addToken(kind: matches(Token.Kind.equal.rawValue) ? .lessOrEqual : .less)
        case Token.Kind.minus.rawValue:
            addToken(kind: .minus)
        case Token.Kind.plus.rawValue:
            addToken(kind: .plus)
        case Token.Kind.quote.rawValue:
            try addStringToken()
        case Token.Kind.rightParenthesis.rawValue:
            addToken(kind: .rightParenthesis)
        case Token.Kind.slash.rawValue:
            addToken(kind: .slash)
        case Token.Kind.star.rawValue:
            addToken(kind: .star)
        case Token.Kind.carriageReturn.rawValue,
             Token.Kind.tab.rawValue,
             Token.Kind.whitespace.rawValue:
            break
        case Token.Kind.newline.rawValue:
            ignoreNewline()
        default:
            if isNumeric(character) {
                addNumberToken()
            } else if isAlpha(character) || Token.Kind.super.rawValue.starts(with: character) {
                try addIdentifierToken()
            } else {
                throw SyntaxError("An unexpected character `\(character)`.", line: line, column: column)
            }
        }
    }

    private func addPrintToken(for character: String) throws {
        addToken(kind: .print, lexeme: Token.Kind.print.rawValue)
        var firstChar = false

        switch character {
        case Token.Kind.carriageReturn.rawValue,
             Token.Kind.tab.rawValue,
             Token.Kind.whitespace.rawValue:
            skip()
        case Token.Kind.newline.rawValue:
            skip()
            ignoreNewline()
        default:
            firstChar = true
            try addToken(for: character)
        }

        while let currentDelimiterIndex = currentDelimiterIndex,
              delimiters[currentDelimiterIndex].start == Delimiter.output.start, !isAtEnd() {
            if let delimiterIndex = delimiters.firstIndex(
                where: { $0.end == Delimiter.output.end && $0.end == substring(next: $0.end.count) }
            ) {
                let endDelimiter = delimiters[delimiterIndex].end
                advance(endDelimiter.count)
                self.currentDelimiterIndex = nil
                break
            } else {
                let character = advance()

                if firstChar {
                    try addToken(for: character)
                } else {
                    switch character {
                    case Token.Kind.carriageReturn.rawValue,
                         Token.Kind.tab.rawValue,
                         Token.Kind.whitespace.rawValue:
                        break
                    case Token.Kind.newline.rawValue:
                        ignoreNewline()
                    default:
                        firstChar = true
                        try addToken(for: character)
                    }
                }
            }
        }
    }

    private func addTextToken() {
        while !isAtEnd() {
            currentDelimiterIndex = delimiters.firstIndex(where: { $0.start == substring(next: $0.start.count) })
            if currentDelimiterIndex != nil { break }
            advance()
        }

        let lexeme = substring(from: start, to: current)

        if lexeme != "" && lexeme != Token.Kind.newline.rawValue {
            addToken(kind: .print, lexeme: Token.Kind.print.rawValue)
            addToken(kind: .string, isText: true)
        }

        if let currentDelimiterIndex = currentDelimiterIndex {
            let startDelimiter = delimiters[currentDelimiterIndex].start
            advance(startDelimiter.count)
        }
    }

    private func addIdentifierToken() throws {
        while isAlpha(peek()) && !isAtEnd() { advance() }
        let text = substring(from: start, to: current)

        if let kind = Token.Kind(rawValue: text), Token.Kind.keywords.contains(kind) {
            if Token.Kind.blockStartKeywords.contains(kind) {
                addToken(kind: kind)

                while currentDelimiterIndex != nil && !isAtEnd() {
                    start = current
                    try scanToken()
                }

                addToken(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue)
            } else if kind == .elseif {
                addToken(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue)
                addToken(kind: kind)

                while currentDelimiterIndex != nil && !isAtEnd() {
                    start = current
                    try scanToken()
                }

                addToken(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue)
            } else if kind == .else {
                addToken(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue)
                addToken(kind: kind)
                addToken(kind: .leftBrace, lexeme: Token.Kind.leftBrace.rawValue)
            } else if Token.Kind.blockEndKeywords.contains(kind) {
                addToken(kind: .rightBrace, lexeme: Token.Kind.rightBrace.rawValue)
            } else {
                addToken(kind: kind)
            }
        } else {
            addToken(kind: .identifier)
        }
    }

    private func addNumberToken() {
        while isNumeric(peek()) && !isAtEnd() { advance() }
        if peek() == Token.Kind.dot.rawValue && isNumeric(peekNext()) { advance() }
        while isNumeric(peek()) && !isAtEnd() { advance() }
        let value = Double(substring(from: start, to: current))
        addToken(kind: .number, literal: value)
    }

    private func addStringToken() throws {
        while peek() != Token.Kind.quote.rawValue && !isAtEnd() {
            if !ignoreNextNewline() {
                advance()
            }
        }

        if isAtEnd() { throw SyntaxError("An unterminated string.", line: line, column: column) }
        advance()
        let value = substring(from: start + 1, to: current - 1)
        addToken(kind: .string, literal: value)
    }

    private func addToken(kind: Token.Kind, lexeme: String? = nil, literal: Any? = nil, isText: Bool = false) {
        let token: Token
        var lexeme = lexeme == nil ? substring(from: start, to: current) : lexeme!
        var literal = literal

        if isText {
            if let lastCharacter = lexeme.last, String(lastCharacter) == Token.Kind.newline.rawValue {
                lexeme.removeLast()
            }

            literal = lexeme
        }

        token = Token(kind: kind, lexeme: lexeme, literal: literal, line: line, column: column)
        tokens.append(token)
    }
}
