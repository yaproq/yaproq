import Foundation

protocol Function {
    var arity: Int { get }

    func call(arguments: [Any?]) -> Any?
}

extension Function {
    func call() -> Any? {
        call(arguments: .init())
    }
}

struct DateFunction: Function {
    let arity: Int
    private let dateFormatter = DateFormatter()

    init(arity: Int = 0) {
        self.arity = arity == 2 ? arity : 0
    }

    func call(arguments: [Any?]) -> Any? {
        if let value = arguments.first as? String, let dateFormat = arguments.last as? String {
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.date(from: value)
        }

        return Date()
    }
}

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
