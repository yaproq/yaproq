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
    let arity = 0

    func call(arguments: [Any?]) -> Any? {
        Date()
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
