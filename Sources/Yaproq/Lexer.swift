final class Lexer {
    let source: String
    private let count: Int
    private let delimiters: [Delimiter]

    private var start = 0
    private var current = 0
    private var line = 1
    private var column = 0
    private var currentDelimiter: Delimiter?
    private lazy var tokens: [Token] = .init()

    init(source: String) {
        self.source = source
        count = source.count
        delimiters = Delimiter.allCases
    }
}

extension Lexer {
    @discardableResult
    private func advance(_ step: Int = 1) -> String {
        current += step
        column += step

        return character(at: current - step)
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
        advance()

        return true
    }

    private func isAtEnd() -> Bool {
        current >= count
    }
}

extension Lexer {
    private func character(at index: Int) -> String {
        substring(from: index, to: index + 1)
    }

    private func substring(next count: Int = 1) -> String {
        substring(from: current, to: current + count)
    }

    private func substring(from start: Int, to end: Int) -> String {
        if start > end || start > count { return "" }
        let end = end > count ? count : end
        let lowerBound = source.index(source.startIndex, offsetBy: start)
        let upperBound = source.index(source.startIndex, offsetBy: end)
        let range = lowerBound..<upperBound

        return String(source[range])
    }
}

extension Lexer {
    private func isAlpha(_ character: String) -> Bool {
        (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") || character == "_"
    }

    private func isNumeric(_ character: String) -> Bool {
        Int(character) != nil
    }
}

extension Lexer {
    func scan() throws -> [Token] {
        while !isAtEnd() {
            start = current

            if let delimiter = currentDelimiter {
                try addTokens(for: delimiter)
            } else {
                addRawTextToken()
            }
        }

        let kind: Token.Kind = .eof
        let token = Token(kind: kind, lexeme: kind.rawValue, line: line, column: column)
        tokens.append(token)

        return tokens
    }
}

extension Lexer {
    private func addTokens(for delimiter: Delimiter) throws {
        while currentDelimiter == delimiter, !isAtEnd() {
            if delimiter.end == substring(next: delimiter.end.count) {
                advance(delimiter.end.count)
                currentDelimiter = nil
                break
            } else {
                let character = advance()

                if delimiter == .comment {
                    if character == Token.Kind.newline.rawValue {
                        line += 1
                        column = 0
                    }
                } else {
                    try addToken(for: character)
                }
            }
        }
    }

    private func addRawTextToken() {
        while !isAtEnd() {
            currentDelimiter = delimiters.first(where: { $0.start == substring(next: $0.start.count) })
            if currentDelimiter != nil { break }

            if advance() == Token.Kind.newline.rawValue {
                line += 1
                column = 0
            }
        }

        var lexeme = substring(from: start, to: current)

        if !lexeme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if lexeme.hasPrefix(Token.Kind.newline.rawValue) { lexeme.removeFirst() }
            if lexeme.hasSuffix(Token.Kind.newline.rawValue) { lexeme.removeLast() }
            addToken(kind: .print, line: -1, column: -1)
            addToken(kind: .string, lexeme: lexeme, literal: lexeme)
        }

        if let delimiter = currentDelimiter {
            if delimiter == .output { addToken(kind: .print, line: -1, column: -1) }
            advance(delimiter.start.count)
        }
    }
}

extension Lexer {
    private func addIdentifierToken() throws {
        while isAlpha(peek()) && !isAtEnd() { advance() }
        let lexeme = substring(from: start, to: current)

        if let kind = Token.Kind(rawValue: lexeme), Token.Kind.keywords.contains(kind) {
            if Token.Kind.blockStartKeywords.contains(kind) {
                addToken(kind: kind)

                while !isAtEnd() {
                    if let delimiter = delimiters.first(where: { $0.end == substring(next: $0.end.count) }) {
                        if currentDelimiter == delimiter { break }
                        // TODO: raise an invalid closing tag exception
                    } else {
                        let character = advance()
                        try addToken(for: character)
                    }
                }

                addToken(kind: .leftBrace, line: -1, column: -1)
            } else if kind == .elseif {
                addToken(kind: .rightBrace, line: -1, column: -1)
                addToken(kind: kind)

                while !isAtEnd() {
                    if let delimiter = delimiters.first(where: { $0.end == substring(next: $0.end.count) }) {
                        if currentDelimiter == delimiter { break }
                        // TODO: raise an invalid closing tag exception
                    } else {
                        let character = advance()
                        try addToken(for: character)
                    }
                }

                addToken(kind: .leftBrace, line: -1, column: -1)
            } else if kind == .else {
                addToken(kind: .rightBrace, line: -1, column: -1)
                addToken(kind: kind)
                addToken(kind: .leftBrace, line: -1, column: -1)
            } else if Token.Kind.blockEndKeywords.contains(kind) {
                addToken(kind: .rightBrace, line: -1, column: -1)
            } else {
                addToken(kind: kind, lexeme: lexeme)
            }
        } else {
            addToken(kind: .identifier, lexeme: lexeme)
        }
    }

    private func addNumberToken() {
        while isNumeric(peek()) && !isAtEnd() { advance() }
        if peek() == Token.Kind.dot.rawValue && isNumeric(peekNext()) { advance() }
        while isNumeric(peek()) && !isAtEnd() { advance() }
        let lexeme = substring(from: start, to: current)
        let value = Double(lexeme)
        addToken(kind: .number, lexeme: lexeme, literal: value)
    }

    private func addStringToken() throws {
        while peek() != Token.Kind.quote.rawValue && !isAtEnd() { advance() }
        if isAtEnd() { throw SyntaxError("An unterminated string.", line: line, column: column) }
        advance()
        let lexeme = substring(from: start, to: current)
        let value = substring(from: start + 1, to: current - 1)
        addToken(kind: .string, lexeme: lexeme, literal: value)
    }

    private func addToken(
        kind: Token.Kind,
        lexeme: String? = nil,
        literal: Any? = nil,
        line: Int? = nil,
        column: Int? = nil
    ) {
        let lexeme = lexeme == nil ? kind.rawValue : lexeme!
        let line = line == nil ? self.line : line!
        let column = column == nil ? self.column : column!
        let token = Token(kind: kind, lexeme: lexeme, literal: literal, line: line, column: column)
        tokens.append(token)
        start = current
    }

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
            start += 1
            current = start
        case Token.Kind.newline.rawValue:
            start += 1
            current = start
            line += 1
            column = 0
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
}
