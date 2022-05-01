import Foundation

public struct YaproqError: LocalizedError {
    let message: String
    public var errorDescription: String? { message }

    init(_ errorType: ErrorType) {
        self.init(errorType.message)
    }

    init(_ message: String? = nil) {
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknownedError)"
        }
    }
}
