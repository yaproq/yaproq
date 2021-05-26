enum Property: String, CaseIterable {
    case capitalized
    case capitalizeFirstCharacter
    case count
    case first
    case isEmpty
    case keys
    case last
    case localizedCapitalized
    case localizedLowercase
    case localizedUppercase
    case lowercased
    case reversed
    case uppercased
    case values

    func value(from value: Any, for token: Token) throws -> Any? {
        switch self {
        case .capitalized:
            if let value = value as? String { return value.capitalized }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .capitalizeFirstCharacter:
            if let value = value as? String { return value.capitalizeFirstCharacter }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .count:
            if let value = value as? [Any] { return value.count }
            if let value = value as? [AnyHashable: Any] { return value.count }
            if let value = value as? String { return value.count }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .first:
            if let value = value as? [Any] { return value.first }
            if let value = value as? String { return value.first }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .isEmpty:
            if let value = value as? [Any] { return value.isEmpty }
            if let value = value as? [AnyHashable: Any] { return value.isEmpty }
            if let value = value as? String { return value.isEmpty }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .keys:
            if let value = value as? [AnyHashable: Any] { return Array(value.keys) }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .last:
            if let value = value as? [Any] { return value.last }
            if let value = value as? String { return value.last }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .localizedCapitalized:
            if let value = value as? String { return value.localizedCapitalized }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .localizedLowercase:
            if let value = value as? String { return value.localizedLowercase }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .localizedUppercase:
            if let value = value as? String { return value.localizedUppercase }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .lowercased:
            if let value = value as? String { return value.lowercased() }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .reversed:
            if let value = value as? [Any] { return Array(value.reversed()) }
            if let value = value as? String { return String(value.reversed()) }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .uppercased:
            if let value = value as? String { return value.uppercased() }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        case .values:
            if let value = value as? [AnyHashable: Any] { return Array(value.values) }
            throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
        }
    }
}
