// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: arbitrary)
public macro bitfield(_ fields: KeyValuePairs<String, UInt8>) = #externalMacro(module: "BitfieldMacros", type: "BitfieldMacro")
