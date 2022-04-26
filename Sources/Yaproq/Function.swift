import Foundation

protocol Function {
    var arity: Int { get }

    func call(interpreter: Interpreter, arguments: [Any?]) -> Any?
}

struct DateFunction: Function {
    var arity = 0

    func call(interpreter: Interpreter, arguments: [Any?]) -> Any? {
        Date()
    }
}

struct DateFormatFunction: Function {
    let dateFormatter = DateFormatter()
    var arity = 1
    var date: Date

    func call(interpreter: Interpreter, arguments: [Any?]) -> Any? {
        dateFormatter.dateFormat = arguments.first as? String

        return dateFormatter.string(from: date)
    }
}
