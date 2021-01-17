import Foundation

public struct YaproqError: LocalizedError {
    let message: String?
    public var errorDescription: String? { message }

    init(_ message: String? = nil) {
        if let message = message {
            self.message = "\(String(describing: type(of: self))): \(message)"
        } else {
            self.message = "\(String(describing: type(of: self))): An unknown error."
        }
    }
}

public struct TemplateError: LocalizedError {
    public let filePath: String?
    let message: String?
    public var errorDescription: String? { message }

    init(_ message: String? = nil, filePath: String? = nil) {
        self.filePath = filePath

        if let message = message {
            self.message = "\(String(describing: type(of: self))): \(message)"
        } else {
            self.message = "\(String(describing: type(of: self))): An unknown error."
        }
    }
}

public struct SyntaxError: LocalizedError {
    public let filePath: String?
    let message: String?
    let line: Int
    let column: Int
    public var errorDescription: String? { message }

    init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
        self.filePath = filePath
        self.line = line
        self.column = column

        if let message = message {
            self.message = "[\(line):\(column)] \(String(describing: type(of: self))): \(message)"
        } else {
            self.message = "[\(line):\(column)] \(String(describing: type(of: self))): An unknown error."
        }
    }
}

public struct RuntimeError: LocalizedError {
    public let filePath: String?
    let message: String?
    let line: Int
    let column: Int
    public var errorDescription: String? { message }

    init(_ message: String? = nil, filePath: String? = nil, line: Int, column: Int) {
        self.filePath = filePath
        self.line = line
        self.column = column

        if let message = message {
            self.message = "[\(line):\(column)] \(String(describing: type(of: self))): \(message)"
        } else {
            self.message = "[\(line):\(column)] \(String(describing: type(of: self))): An unknown error."
        }
    }
}
