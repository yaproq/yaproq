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
                self.message = "[Line: \(line), Column: \(column)] Syntax error: \(message)"
            } else {
                self.message = "[Line: \(line), Column: \(column)] Syntax error: Unknown error."
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
                self.message = "[Line: \(line), Column: \(column)] Runtime error: \(message)"
            } else {
                self.message = "[Line: \(line), Column: \(column)] Runtime error: Unknown error."
            }
        } else {
            self.message = message
        }
    }
}
