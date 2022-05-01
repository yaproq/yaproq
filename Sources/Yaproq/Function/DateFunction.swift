import Foundation

struct DateFunction: Function {
    static let arity = 0
    let arity: Int
    private let dateFormatter = DateFormatter()

    init(arity: Int = DateFunction.arity) {
        if arity == 3 || arity == 2 {
            self.arity = arity
        } else {
            self.arity = DateFunction.arity
        }
    }

    func call(arguments: [Any?]) -> Any? {
        let argumentsCount = arguments.count

        if argumentsCount == 0 {
            return Date()
        } else if argumentsCount == 2, let value = arguments[0] as? String, let dateFormat = arguments[1] as? String {
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.date(from: value)
        } else if
            argumentsCount == 3,
            let value = arguments[0] as? String,
            let dateFormat = arguments[1] as? String,
            let timeZone = arguments[2] as? String {
            dateFormatter.dateFormat = dateFormat

            if let timeZone = TimeZone(abbreviation: timeZone) ?? TimeZone(identifier: timeZone) {
                dateFormatter.timeZone = timeZone
            }

            return dateFormatter.date(from: value)
        }

        return nil
    }
}
