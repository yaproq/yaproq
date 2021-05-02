import Foundation

public struct YaproqError: LocalizedError {
    let message: String
    public var errorDescription: String? { message }

    init(_ message: String? = nil) {
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }
    }
}

public struct TemplateError: LocalizedError {
    public let filePath: String?
    private(set) var message: String
    public var errorDescription: String? { message }

    init(_ message: String? = nil, filePath: String? = nil) {
        self.filePath = filePath
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }

        if let filePath = filePath {
            self.message = "[Template: \(filePath)] " + self.message
        }
    }
}

public struct SyntaxError: LocalizedError {
    public let filePath: String?
    private(set) var message: String
    public let line: Int
    public let column: Int
    public var errorDescription: String? { message }

    init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
        self.filePath = filePath
        self.line = line
        self.column = column
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }

        if let filePath = filePath {
            self.message = "[Template: \(filePath), Line: \(line), Column: \(column)] " + self.message
        } else {
            self.message = "[Line: \(line), Column: \(column)] " + self.message
        }
    }
}

public struct RuntimeError: LocalizedError {
    public let filePath: String?
    private(set) var message: String
    public let line: Int
    public let column: Int
    public var errorDescription: String? { message }

    init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
        self.filePath = filePath
        self.line = line
        self.column = column
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }

        if let filePath = filePath {
            self.message = "[Template: \(filePath), Line: \(line), Column: \(column)] " + self.message
        } else {
            self.message = "[Line: \(line), Column: \(column)] " + self.message
        }
    }
}

enum ErrorType: CustomStringConvertible {
    case unknownedError

    // YaproqError
    case delimitersMustBeUnique

    // TemplateError
    case contentMustBeUTF8Encodable(filePath: String)
    case extendingMultipleTemplatesNotSupported
    case extendMustBeFirstStatement
    case invalidTemplateFilePath(filePath: String)

    // SyntaxError
    case expectingCharacter(character: String)
    case expectingExpression
    case expectingVariable
    case invalidAssignmentTarget
    case invalidBlock(name: String)
    case invalidCharacter(character: String)
    case invalidDelimiterEnd(delimiterEnd: String)
    case invalidOperator(name: String)
    case unterminatedString

    // RuntimeError
    case indexMustBeInteger(index: String)
    case keyMustBeHashable(key: String)
    case operandMustBeBoolean
    case operandMustBeNumber
    case operandsMustBeComparable
    case operandsMustBeEitherIntegersOrDoubles
    case operandsMustBeEitherNumbersOrStrings
    case operandsMustBeNumbers
    case variableExists(name: String)
    case variableMustBeEitherArrayOrDictionary(name: String)
    case undefinedVariable(name: String)

    var description: String { message }

    var message: String {
        switch self {
        case .unknownedError:
            return "An unknown error."

        // YaproqError
        case .delimitersMustBeUnique:
            return "Delimiters must be unique."

        // TemplateError
        case .contentMustBeUTF8Encodable(let filePath):
            return "A template file at `\(filePath)` must be UTF8 encodable."
        case .extendingMultipleTemplatesNotSupported:
            return "Extending multiple templates is not supported."
        case .extendMustBeFirstStatement:
            return "An '\(Token.Kind.extend.rawValue)' must the first statement in a template file."
        case .invalidTemplateFilePath(let filePath):
            return "An invalid template at `\(filePath)`."

        // SyntaxError
        case .expectingCharacter(let character):
            return "Expecting '\(character)'."
        case .expectingExpression:
            return "Expecting an expression."
        case .expectingVariable:
            return "Expecting a variable."
        case .invalidAssignmentTarget:
            return "An invalid assignment target."
        case .invalidBlock(let name):
            return "An invalid block name `\(name)."
        case .invalidCharacter(let character):
            return "An invalid character `\(character)`."
        case .invalidDelimiterEnd(let delimiterEnd):
            return "The closing delimiter `\(delimiterEnd)` is invalid."
        case .invalidOperator(let name):
            return "An invalid operator `\(name)`."
        case .unterminatedString:
            return "An unterminated string."

        // RuntimeError
        case .indexMustBeInteger(let index):
            return "The index `\(index)` must be an integer."
        case .keyMustBeHashable(let key):
            return "The key `\(key)` must be hashable."
        case .operandMustBeBoolean:
            return "The operand must be a boolean."
        case .operandMustBeNumber:
            return "The operand must be a number."
        case .operandsMustBeComparable:
            return "The operands must be comparable."
        case .operandsMustBeEitherIntegersOrDoubles:
            return "The operands must be either integers or doubles."
        case .operandsMustBeEitherNumbersOrStrings:
            return "The operands must be numbers or strings."
        case .operandsMustBeNumbers:
            return "The operands must be numbers."
        case .variableExists(let name):
            return "The variable '\(name)' already exists."
        case .variableMustBeEitherArrayOrDictionary(let name):
            return "The `\(name)` must be an array or dictionary."
        case .undefinedVariable(let name):
            return "An undefined variable '\(name)'."
        }
    }
}
