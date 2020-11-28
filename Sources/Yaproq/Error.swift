import Foundation

public struct TemplateError: LocalizedError {
    let message: String?
    public var errorDescription: String? { message }

    init(_ message: String? = nil) {
        if let message = message {
            self.message = "Template error: \(message)"
        } else {
            self.message = "Template error: An unknown error."
        }
    }
}

public struct SyntaxError: LocalizedError {
    let message: String?
    let line: Int
    let column: Int
    public var errorDescription: String? { message }

    init(_ message: String? = nil, line: Int, column: Int) {
        self.line = line
        self.column = column

        if let message = message {
            self.message = "[\(line):\(column)] Syntax error: \(message)"
        } else {
            self.message = "[\(line):\(column)] Syntax error: An unknown error."
        }
    }
}

public struct RuntimeError: LocalizedError {
    let message: String?
    let line: Int
    let column: Int
    public var errorDescription: String? { message }

    init(_ message: String? = nil, line: Int, column: Int) {
        self.line = line
        self.column = column

        if let message = message {
            self.message = "[\(line):\(column)] Runtime error: \(message)"
        } else {
            self.message = "[\(line):\(column)] Runtime error: An unknown error."
        }
    }
}
