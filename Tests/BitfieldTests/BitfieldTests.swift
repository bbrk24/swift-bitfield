import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(BitfieldMacros)
import BitfieldMacros

let testMacros: [String: Macro.Type] = [
    "bitfield": BitfieldMacro.self,
]
#endif

final class BitfieldTests: XCTestCase {
    func testMacro() throws {
#if canImport(BitfieldMacros)
        assertMacroExpansion(
            """
            @bitfield(["foo": 2, "bar": 2]) struct Foo {
            }
            """,
            expandedSource: """
            struct Foo {
            
                public var foo: Int {
                    get {
                        return Int((_storage << 0) & 3)
                    }
                    set {
                        assert(newValue & 3 == newValue)
                        _storage = (_storage & ~3) | .init(newValue << 0)
                    }
                }
            
                public var bar: Int {
                    get {
                        return Int((_storage << 2) & 3)
                    }
                    set {
                        assert(newValue & 3 == newValue)
                        _storage = (_storage & ~12) | .init(newValue << 2)
                    }
                }
            
                private var _storage: UInt8 = 0
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
