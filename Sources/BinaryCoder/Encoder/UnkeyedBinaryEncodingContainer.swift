struct UnkeyedBinaryEncodingContainer: UnkeyedEncodingContainer {
    private let state: BinaryEncodingState
    private(set) var count: Int = 0

    var codingPath: [CodingKey] { [] }

    init(state: BinaryEncodingState) {
        self.state = state
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        .init(KeyedBinaryEncodingContainer<NestedKey>(state: state))
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        UnkeyedBinaryEncodingContainer(state: state)
    }

    mutating func superEncoder() -> Encoder {
        BinaryEncoder(state: state)
    }

    mutating func encodeNil() throws { try state.encodeNil() }

    mutating func encode(_ value: Bool) throws { try state.encode(value) }

    mutating func encode(_ value: String) throws { try state.encode(value) }

    mutating func encode(_ value: Double) throws { try state.encode(value) }

    mutating func encode(_ value: Float) throws { try state.encode(value) }

    mutating func encode(_ value: Int) throws { try state.encode(value) }

    mutating func encode(_ value: Int8) throws { try state.encode(value) }

    mutating func encode(_ value: Int16) throws { try state.encode(value) }

    mutating func encode(_ value: Int32) throws { try state.encode(value) }

    mutating func encode(_ value: Int64) throws { try state.encode(value) }

    mutating func encode(_ value: UInt) throws { try state.encode(value) }

    mutating func encode(_ value: UInt8) throws { try state.encode(value) }

    mutating func encode(_ value: UInt16) throws { try state.encode(value) }

    mutating func encode(_ value: UInt32) throws { try state.encode(value) }

    mutating func encode(_ value: UInt64) throws { try state.encode(value) }

    mutating func encode<T>(_ value: T) throws where T : Encodable { try state.encode(value) }
}
