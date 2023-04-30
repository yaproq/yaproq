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
            if let value = value as? String {
                return value.capitalized
            }
        case .capitalizeFirstCharacter:
            if let value = value as? String {
                return value.capitalizeFirstCharacter
            }
        case .count:
            if let value = value as? [Any] {
                return value.count
            } else if let value = value as? [AnyHashable: Any] {
                return value.count
            } else if let value = value as? String {
                return value.count
            }
        case .first:
            if let value = value as? [Any] {
                return value.first
            } else if let value = value as? String {
                return value.first
            }
        case .isEmpty:
            if let value = value as? [Any] {
                return value.isEmpty
            } else if let value = value as? [AnyHashable: Any] {
                return value.isEmpty
            } else if let value = value as? String {
                return value.isEmpty
            }
        case .keys:
            if let value = value as? [AnyHashable: Any] {
                return Array(value.keys)
            }
        case .last:
            if let value = value as? [Any] {
                return value.last
            } else if let value = value as? String {
                return value.last
            }
        case .localizedCapitalized:
            if let value = value as? String {
                return value.localizedCapitalized
            }
        case .localizedLowercase:
            if let value = value as? String {
                return value.localizedLowercase
            }
        case .localizedUppercase:
            if let value = value as? String {
                return value.localizedUppercase
            }
        case .lowercased:
            if let value = value as? String {
                return value.lowercased()
            }
        case .reversed:
            if let value = value as? [Any] {
                return Array(value.reversed())
            } else if let value = value as? String {
                return String(value.reversed())
            }
        case .uppercased:
            if let value = value as? String {
                return value.uppercased()
            }
        case .values:
            if let value = value as? [AnyHashable: Any] {
                return Array(value.values)
            }
        }

        throw runtimeError(.undefinedVariableOrProperty(rawValue), token: token)
    }
}
