import Foundation

public struct YaproqError: LocalizedError {
    let message: String
    public var errorDescription: String? { message }

    public init(_ errorType: ErrorType) {
        self.init(errorType.message)
    }

    public init(_ message: String? = nil) {
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

    public init(_ errorType: ErrorType, filePath: String? = nil) {
        self.init(errorType.message, filePath: filePath)
    }

    public init(_ message: String? = nil, filePath: String? = nil) {
        self.filePath = filePath
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }

        if let filePath = filePath {
            self.message = "[Template: \"\(filePath)\"] " + self.message
        }
    }
}

public struct SyntaxError: LocalizedError {
    public let filePath: String?
    private(set) var message: String
    public let line: Int
    public let column: Int
    public var errorDescription: String? { message }

    public init(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) {
        self.init(errorType.message, filePath: filePath, line: line, column: column)
    }

    public init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
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
            self.message = "[Template: \"\(filePath)\", Line: \(line), Column: \(column)] " + self.message
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

    public init(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) {
        self.init(errorType.message, filePath: filePath, line: line, column: column)
    }

    public init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
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
            self.message = "[Template: \"\(filePath)\", Line: \(line), Column: \(column)] " + self.message
        } else {
            self.message = "[Line: \(line), Column: \(column)] " + self.message
        }
    }
}

public enum ErrorType: CustomStringConvertible {
    case unknownedError

    // YaproqError
    case delimitersMustBeUnique

    // TemplateError
    case extendingMultipleTemplatesNotSupported
    case extendMustBeFirstStatement
    case invalidTemplateFile
    case templateFileMustBeUTF8Encodable

    // SyntaxError
    case expectingCharacter(_ character: String)
    case expectingExpression
    case expectingVariable
    case invalidAssignmentTarget
    case invalidBlockName(_ name: String)
    case invalidCharacter(_ character: String)
    case invalidDelimiterEnd(_ delimiterEnd: String)
    case invalidOperator(_ name: String)
    case unterminatedString

    // RuntimeError
    case indexMustBeInteger(_ index: String)
    case keyMustBeHashable(_ key: String)
    case operandMustBeBoolean
    case operandMustBeNumber
    case operandsMustBeComparable
    case operandsMustBeEitherIntegersOrDoubles
    case operandsMustBeEitherNumbersOrStrings
    case operandsMustBeNumbers
    case variableExists(_ name: String)
    case variableMustBeEitherArrayOrDictionary(_ name: String)
    case undefinedVariableOrProperty(_ name: String)

    public var description: String { message }

    public var message: String {
        switch self {
        case .unknownedError:
            return "An unknown error."

        // YaproqError
        case .delimitersMustBeUnique:
            return "The delimiters must be unique."

        // TemplateError
        case .extendingMultipleTemplatesNotSupported:
            return "Extending multiple templates is not supported."
        case .extendMustBeFirstStatement:
            return "The `\(Token.Kind.extend.rawValue)` must be the first statement."
        case .invalidTemplateFile:
            return "An invalid template file."
        case .templateFileMustBeUTF8Encodable:
            return "The template file must be UTF8 encodable."

        // SyntaxError
        case .expectingCharacter(let character):
            return "Expecting `\(character)`."
        case .expectingExpression:
            return "Expecting an expression."
        case .expectingVariable:
            return "Expecting a variable."
        case .invalidAssignmentTarget:
            return "An invalid assignment target."
        case .invalidBlockName(let name):
            return "An invalid block name `\(name)."
        case .invalidCharacter(let character):
            return "An invalid character `\(character)`."
        case .invalidDelimiterEnd(let delimiterEnd):
            return "An invalid closing delimiter `\(delimiterEnd)`."
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
            return "The operands must be either numbers or strings."
        case .operandsMustBeNumbers:
            return "The operands must be numbers."
        case .variableExists(let name):
            return "The variable `\(name)` already exists."
        case .variableMustBeEitherArrayOrDictionary(let name):
            return "The `\(name)` must be either an array or dictionary."
        case .undefinedVariableOrProperty(let name):
            return "An undefined variable or property `\(name)`."
        }
    }
}

func error(_ errorType: ErrorType) -> YaproqError {
    YaproqError(errorType)
}

func templateError(_ errorType: ErrorType, filePath: String? = nil) -> TemplateError {
    TemplateError(errorType, filePath: filePath)
}

func syntaxError(_ errorType: ErrorType, token: Token) -> SyntaxError {
    syntaxError(errorType, filePath: token.filePath, line: token.line, column: token.column)
}

func syntaxError(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) -> SyntaxError {
    SyntaxError(errorType, filePath: filePath, line: line, column: column)
}

func runtimeError(_ errorType: ErrorType, token: Token) -> RuntimeError {
    RuntimeError(errorType, filePath: token.filePath, line: token.line, column: token.column)
}
