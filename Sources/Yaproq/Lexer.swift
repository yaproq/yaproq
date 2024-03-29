final class Lexer {
    let template: Template
    private let count: Int
    private let delimiters: Set<Delimiter>

    private var currentDelimiter: Delimiter?
    private var isAtEnd: Bool { current >= count }
    private var start = 0
    private var current = 0
    private var line = 1
    private var column = 0
    private var tokens = [Token]()

    init(template: Template) {
        self.template = template
        count = template.source.count
        delimiters = .init(Delimiter.allCases)
    }
}

extension Lexer {
    func scan() throws -> [Token] {
        while !isAtEnd {
            start = current

            if let delimiter = currentDelimiter {
                try addTokens(for: delimiter)
            } else {
                addRawTextToken()
            }
        }

        if let delimiter = currentDelimiter {
            throw syntaxError(
                .invalidDelimiterEnd(delimiter.end),
                filePath: template.filePath,
                line: line,
                column: column
            )
        }

        addToken(kind: .eof)

        return tokens
    }
}

extension Lexer {
    @discardableResult
    private func advance(_ step: Int = 1) -> String {
        current += step
        column += step

        return character(at: current - step)
    }

    private func character(at index: Int) -> String {
        substring(from: index, to: index + 1)
    }

    private func isAlpha(_ character: String) -> Bool {
        (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") || character == "_"
    }

    private func isAlphaNumeric(_ character: String) -> Bool {
        isAlpha(character) || isNumeric(character)
    }

    private func isNumeric(_ character: String) -> Bool {
        Int(character) != nil
    }

    private func matches(_ character: String) -> Bool {
        if isAtEnd || character != self.character(at: current) {
            return false
        }

        advance()

        return true
    }

    private func peek(next: Int = 0) -> String {
        current + next >= count ? Token.Kind.eof.rawValue : character(at: current + next)
    }

    func substring(from start: Int, to end: Int) -> String {
        if start < 0 || end < 0 || start > end || start > count {
            return Token.Kind.eof.rawValue
        }

        let end = end > count ? count : end
        let source = template.source
        let lowerBound = source.index(source.startIndex, offsetBy: start)
        let upperBound = source.index(source.startIndex, offsetBy: end)
        let range = lowerBound..<upperBound

        return String(source[range])
    }

    private func substring(next count: Int) -> String {
        substring(from: current, to: current + count)
    }
}

extension Lexer {
    private func addIdentifierToken() throws {
        let dot = Token.Kind.dot.rawValue

        while (isAlphaNumeric(peek()) || (peek() == dot && peek(next: 1) != dot)) && !isAtEnd {
            advance()
        }

        let lexeme = substring(from: start, to: current)

        if let lastCharacter = lexeme.last, String(lastCharacter) == dot {
            throw syntaxError(.invalidCharacter(dot), filePath: template.filePath, line: line, column: column)
        }

        if let kind = Token.Kind(rawValue: lexeme), Token.Kind.keywords.contains(kind) {
            if Token.Kind.blockStartKeywords.contains(kind) {
                addToken(kind: kind)

                while !isAtEnd {
                    if delimiters.first(where: { $0.end == substring(next: $0.end.count) }) == nil {
                        try addToken(for: advance())
                    } else {
                        break
                    }
                }

                addToken(kind: .leftBrace, line: -1, column: -1)
            } else if kind == .elseif {
                addToken(kind: .rightBrace, line: -1, column: -1)
                addToken(kind: kind)

                while !isAtEnd {
                    if delimiters.first(where: { $0.end == substring(next: $0.end.count) }) == nil {
                        try addToken(for: advance())
                    } else {
                        break
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
                addToken(kind: kind, lexeme: lexeme, literal: kind == .false || kind == .true ? Bool(lexeme) : nil)
            }
        } else {
            addToken(kind: .identifier, lexeme: lexeme)
        }
    }

    private func addNumberToken() {
        while isNumeric(peek()) && !isAtEnd {
            advance()
        }

        if peek() == Token.Kind.dot.rawValue && isNumeric(peek(next: 1)) {
            advance()
        }

        while isNumeric(peek()) && !isAtEnd {
            advance()
        }

        let lexeme = substring(from: start, to: current)
        addToken(kind: .number, lexeme: lexeme, literal: Int(lexeme) ?? Double(lexeme))
    }

    private func addRawTextToken() {
        while !isAtEnd {
            currentDelimiter = delimiters.first(where: { $0.start == substring(next: $0.start.count) })

            if currentDelimiter != nil {
                break
            }

            if advance() == Token.Kind.newline.rawValue {
                line += 1
                column = 0
            }
        }

        var lexeme = substring(from: start, to: current)

        if !lexeme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if lexeme.hasPrefix(Token.Kind.newline.rawValue) {
                lexeme.removeFirst()
            }

            if lexeme.hasSuffix(Token.Kind.newline.rawValue) {
                lexeme.removeLast()
            }

            addToken(kind: .print, line: -1, column: -1)
            addToken(kind: .string, lexeme: lexeme, literal: lexeme)
        }

        if let delimiter = currentDelimiter {
            if delimiter == .output {
                addToken(kind: .print, line: -1, column: -1)
            }

            advance(delimiter.start.count)
        }
    }

    private func addStringToken() throws {
        while peek() != Token.Kind.quote.rawValue && !isAtEnd {
            advance()
        }

        if isAtEnd {
            throw syntaxError(.unterminatedString, filePath: template.filePath, line: line, column: column)
        }

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
        let token = Token(
            kind: kind,
            lexeme: lexeme ?? kind.rawValue,
            literal: literal,
            filePath: template.filePath,
            line: line ?? self.line,
            column: column ?? self.column
        )
        tokens.append(token)
        start = current
    }

    private func addToken(for character: String) throws {
        switch character {
        case Token.Kind.bang.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .bangEqual : .bang)
        case Token.Kind.comma.rawValue: addToken(kind: .comma)
        case Token.Kind.colon.rawValue: addToken(kind: .colon)
        case Token.Kind.dot.rawValue:
            if matches(Token.Kind.dot.rawValue) {
                if matches(Token.Kind.dot.rawValue) {
                    addToken(kind: .closedRange)
                } else if matches(Token.Kind.less.rawValue) {
                    addToken(kind: .range)
                } else {
                    throw syntaxError(
                        .invalidCharacter(character),
                        filePath: template.filePath,
                        line: line,
                        column: column
                    )
                }
            } else {
                throw syntaxError(
                    .invalidCharacter(character),
                    filePath: template.filePath,
                    line: line,
                    column: column
                )
            }
        case Token.Kind.equal.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .equalEqual : .equal)
        case Token.Kind.greater.rawValue:
            addToken(kind: matches(Token.Kind.equal.rawValue) ? .greaterOrEqual : .greater)
        case Token.Kind.leftBracket.rawValue: addToken(kind: .leftBracket)
        case Token.Kind.leftParenthesis.rawValue: addToken(kind: .leftParenthesis)
        case Token.Kind.less.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .lessOrEqual : .less)
        case Token.Kind.minus.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .minusEqual : .minus)
        case Token.Kind.percent.rawValue:
            addToken(kind: matches(Token.Kind.equal.rawValue) ? .percentEqual : .percent)
        case Token.Kind.plus.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .plusEqual : .plus)
        case Token.Kind.power.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .powerEqual : .power)
        case Token.Kind.question.rawValue:
            addToken(kind: matches(Token.Kind.question.rawValue) ? .questionQuestion : .question)
        case Token.Kind.quote.rawValue: try addStringToken()
        case Token.Kind.rightBracket.rawValue: addToken(kind: .rightBracket)
        case Token.Kind.rightParenthesis.rawValue: addToken(kind: .rightParenthesis)
        case Token.Kind.slash.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .slashEqual : .slash)
        case Token.Kind.star.rawValue: addToken(kind: matches(Token.Kind.equal.rawValue) ? .starEqual : .star)
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
            } else if isAlpha(character) {
                try addIdentifierToken()
            } else {
                throw syntaxError(
                    .invalidCharacter(character),
                    filePath: template.filePath,
                    line: line,
                    column: column
                )
            }
        }
    }

    private func addTokens(for delimiter: Delimiter) throws {
        while currentDelimiter == delimiter, !isAtEnd {
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
}
