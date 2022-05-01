import Foundation

public struct TemplateError: LocalizedError {
    public let filePath: String?
    private(set) var message: String
    public var errorDescription: String? { message }

    init(_ errorType: ErrorType, filePath: String? = nil) {
        self.init(errorType.message, filePath: filePath)
    }

    init(_ message: String? = nil, filePath: String? = nil) {
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
