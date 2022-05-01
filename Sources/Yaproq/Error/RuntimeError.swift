import Foundation

public struct RuntimeError: LocalizedError {
    public let filePath: String?
    private(set) var message: String
    public let line: Int
    public let column: Int
    public var errorDescription: String? { message }

    init(_ errorType: ErrorType, filePath: String? = nil, line: Int, column: Int) {
        self.init(errorType.message, filePath: filePath, line: line, column: column)
    }

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
            self.message = "[Template: \"\(filePath)\", Line: \(line), Column: \(column)] " + self.message
        } else {
            self.message = "[Line: \(line), Column: \(column)] " + self.message
        }
    }
}
