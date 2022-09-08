import Foundation

/// The internal state used by the decoders.
class BinaryDecodingState {
    private let config: BinaryCodingConfiguration
    private var data: Data

    init(config: BinaryCodingConfiguration, data: Data) {
        self.config = config
        self.data = data
    }

    func decodeNil() throws -> Bool {
        // Since we don't encode `nil`s, we just always return `false``
        false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard let byte = data.popFirst() else {
            throw BinaryDecodingError.eofTooEarly
        }
        return byte != 0
    }

    func decode(_ type: String.Type) throws -> String {
        var raw = Data()
        while true {
            guard let byte = data.popFirst() else {
                throw BinaryDecodingError.eofTooEarly
            }
            if byte == 0 {
                break
            }
            raw.append(byte)
        }
        guard let value = String(data: raw, encoding: config.stringEncoding) else {
            throw BinaryDecodingError.stringNotDecodable(raw)
        }
        return value
    }

    func decodeInteger<Integer>(_ type: Integer.Type) throws -> Integer where Integer: FixedWidthInteger {
        let bitWidth = Integer.bitWidth
        let raw = data.prefix(bitWidth)
        let value = raw.withUnsafeBytes {
            config.endianness.assume($0.load(as: type))
        }
        data.removeFirst(bitWidth)
        return value
    }

    func decode(_ type: Double.Type) throws -> Double {
        Double(bitPattern: try decodeInteger(UInt64.self))
    }

    func decode(_ type: Float.Type) throws -> Float {
        Float(bitPattern: try decodeInteger(UInt32.self))
    }

    func decode(_ type: Int.Type) throws -> Int {
        try decodeInteger(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try decodeInteger(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try decodeInteger(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try decodeInteger(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try decodeInteger(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try decodeInteger(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decodeInteger(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decodeInteger(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decodeInteger(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decodeInteger(type)
    }

    func decode<T>(_ type: T.Type, codingPath: [CodingKey]) throws -> T where T: Decodable {
        try T(from: BinaryDecoderImpl(state: self, codingPath: codingPath))
    }
}
