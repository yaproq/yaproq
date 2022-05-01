protocol Function {
    var arity: Int { get }

    func call(arguments: [Any?]) -> Any?
}

extension Function {
    func call() -> Any? {
        call(arguments: .init())
    }
}
