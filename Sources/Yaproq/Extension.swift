import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any]? {
        try JSONSerialization.jsonObject(
            with: try JSONEncoder().encode(self),
            options: .allowFragments
        ) as? [String: Any]
    }
}
