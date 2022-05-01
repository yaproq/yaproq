import Foundation

struct DateFormatFunction: Function {
    static let arity = 1
    let arity: Int
    var date: Date
    private let dateFormatter = DateFormatter()

    init(arity: Int = DateFormatFunction.arity, date: Date) {
        self.arity = arity == 2 ? arity : DateFormatFunction.arity
        self.date = date
    }

    func call(arguments: [Any?]) -> Any? {
        let argumentsCount = arguments.count

        if argumentsCount == 1, let dateFormat = arguments[0] as? String {
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.string(from: date)
        } else if
            argumentsCount == 2,
            let dateFormat = arguments[0] as? String,
            let timeZone = arguments[1] as? String {
            dateFormatter.dateFormat = dateFormat

            if let timeZone = TimeZone(abbreviation: timeZone) ?? TimeZone(identifier: timeZone) {
                dateFormatter.timeZone = timeZone
            }

            return dateFormatter.string(from: date)
        }

        return nil
    }
}
