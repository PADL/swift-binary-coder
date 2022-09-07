struct KeyedBinaryEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
    private let state: BinaryEncodingState

    var codingPath: [CodingKey] { [] }

    init(state: BinaryEncodingState) {
        self.state = state
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        .init(KeyedBinaryEncodingContainer<NestedKey>(state: state))
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        UnkeyedBinaryEncodingContainer(state: state)
    }

    mutating func superEncoder() -> Encoder {
        BinaryEncoder(state: state)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        BinaryEncoder(state: state)
    }

    mutating func encodeNil(forKey key: Key) throws { try state.encodeNil() }

    mutating func encode(_ value: Bool, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: String, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Double, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Float, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Int, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Int8, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Int16, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Int32, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: Int64, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: UInt, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: UInt8, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: UInt16, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: UInt32, forKey key: Key) throws { try state.encode(value) }

    mutating func encode(_ value: UInt64, forKey key: Key) throws { try state.encode(value) }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable { try state.encode(value) }
}
