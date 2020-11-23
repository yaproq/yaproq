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
