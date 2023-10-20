public enum CompileTimeError: Error, CustomStringConvertible {
    case needsDictLiteral
    case needsStringLiteralKey
    case needsIntLiteralValue
    case tooLong(Int)

    public var description: String {
        switch self {
        case .needsDictLiteral: "#bitfield(_:) needs a dictionary literal"
        case .needsStringLiteralKey: "Dictionary keys must be string literals"
        case .needsIntLiteralValue: "Dictionary values must be integer literals"
        case .tooLong(let i): "Required bit width \(i) is greater than 64"
        }
    }
}
