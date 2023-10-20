import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BitfieldMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // There's no way you have to do this just to get your macro arguments. That's way too convoluted.
        guard case .argumentList(let args) = node.arguments,
              let firstArg = args.first?.expression.as(DictionaryExprSyntax.self) else {
            throw CompileTimeError.needsDictLiteral
        }

        var properties = Array<(String, Int)>()

        switch firstArg.content {
        case .colon(_):
            return []
        case .elements(let listSyntax):
            for element in listSyntax {
                guard let keySyntax = element.key.as(StringLiteralExprSyntax.self),
                      keySyntax.segments.count == 1,
                      case .stringSegment(let strSyntax) = keySyntax.segments.first else {
                    throw CompileTimeError.needsStringLiteralKey
                }

                guard let valueSyntax = element.value.as(IntegerLiteralExprSyntax.self),
                      let value = Int(valueSyntax.trimmedDescription) else {
                    throw CompileTimeError.needsIntLiteralValue
                }

                properties.append((strSyntax.description, value))
            }
        }

        var results = Array<DeclSyntax>()
        results.reserveCapacity(properties.count + 1)

        var runningUsedWidth = 0
        for (name, width) in properties {
            switch width {
            case 0:
                results.append("public var \(raw: name): Void = ()")
            case 1:
                let bit = 1 << runningUsedWidth
                results.append("""
                    public var \(raw: name): Bool {
                        get {
                            return _storage & \(raw: bit) != 0
                        }
                        set {
                            if newValue {
                                _storage |= \(raw: bit)
                            } else {
                                _storage &= ~\(raw: bit)
                            }
                        }
                    }
                    """)
            default:
                let mask: UInt = 1 << width - 1
                let shiftedMask = mask << runningUsedWidth
                results.append("""
                    public var \(raw: name): Int {
                        get {
                            return Int((_storage << \(raw: runningUsedWidth)) & \(raw: mask))
                        }
                        set {
                            assert(newValue & \(raw: mask) == newValue)
                            _storage = (_storage & ~\(raw: shiftedMask)) | .init(newValue << \(raw: runningUsedWidth))
                        }
                    }
                    """)
            }

            runningUsedWidth += width
            guard runningUsedWidth <= 64 else {
                throw CompileTimeError.tooLong(runningUsedWidth)
            }
        }

        var backingType: TypeSyntax
        switch runningUsedWidth {
        case 0:
            backingType = "Void"
        case 1...8:
            backingType = "UInt8"
        case 9...16:
            backingType = "UInt16"
        case 17...32:
            backingType = "UInt32"
        case 33...64:
            backingType = "UInt64"
        default:
            fatalError("Unreachable")
        }

        results.append("private var _storage: \(backingType) = \(raw: runningUsedWidth == 0 ? "()" : "0")")

        return results
    }
}

@main
struct BitfieldPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BitfieldMacro.self,
    ]
}
