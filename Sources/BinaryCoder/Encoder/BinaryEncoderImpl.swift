/// A (stateful) binary encoder.
struct BinaryEncoderImpl: Encoder {
    private let state: BinaryEncodingState

    let codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    init(state: BinaryEncodingState, codingPath: [CodingKey]) {
        self.state = state
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        .init(KeyedBinaryEncodingContainer(state: state, codingPath: codingPath))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnkeyedBinaryEncodingContainer(state: state, codingPath: codingPath)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        SingleValueBinaryEncodingContainer(state: state, codingPath: codingPath)
    }
}
