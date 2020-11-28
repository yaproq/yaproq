import Foundation

public struct YaproqError: LocalizedError {
    let message: String?
    public var errorDescription: String? { message }

    init(_ message: String? = nil) {
        if let message = message {
            self.message = "Yaproq error: \(message)"
        } else {
            self.message = "Yaproq error: Unknown error."
        }
    }
}

public struct SyntaxError: LocalizedError {
    let message: String?
    let line: Int?
    let column: Int?
    public var errorDescription: String? { message }

    init(_ message: String? = nil, line: Int? = nil, column: Int? = nil) {
        self.line = line
        self.column = column

        if let line = line, let column = column {
            if let message = message {
                self.message = "[\(line):\(column)] Syntax error: \(message)"
            } else {
                self.message = "[\(line):\(column)] Syntax error: An unknown error."
            }
        } else {
            self.message = message
        }
    }
}

public struct RuntimeError: LocalizedError {
    let message: String?
    let line: Int?
    let column: Int?
    public var errorDescription: String? { message }

    init(_ message: String? = nil, line: Int? = nil, column: Int? = nil) {
        self.line = line
        self.column = column

        if let line = line, let column = column {
            if let message = message {
                self.message = "[\(line):\(column)] Runtime error: \(message)"
            } else {
                self.message = "[\(line):\(column)] Runtime error: An unknown error."
            }
        } else {
            self.message = message
        }
    }
}
