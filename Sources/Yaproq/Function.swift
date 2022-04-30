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
        if let dateFormat = arguments.first as? String, let value = arguments.last as? String {
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.date(from: value)
        }

        return Date()
    }
}

struct DateFormatFunction: Function {
    let arity: Int = 1
    var date: Date
    private let dateFormatter = DateFormatter()

    init(date: Date) {
        self.date = date
    }

    func call(arguments: [Any?]) -> Any? {
        dateFormatter.dateFormat = arguments.first as? String
        return dateFormatter.string(from: date)
    }
}
