import Foundation
import BinaryCoder

struct LengthTaggedData: MutableDataProtocol, ContiguousBytes, Equatable, Hashable {
    public var startIndex: Data.Index { self.wrappedValue.startIndex }
    public var endIndex: Data.Index { self.wrappedValue.endIndex }
    public var regions: CollectionOfOne<LengthTaggedData> { CollectionOfOne(self) }

    public var wrappedValue: Data

    public init() {
        self.wrappedValue = Data()
    }

    public subscript(position: Data.Index) -> UInt8 {
        get {
            self.wrappedValue[position]
        }
        set(newValue) {
            self.wrappedValue[position] = newValue
        }
    }

    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try self.wrappedValue.withUnsafeBytes(body)
    }

    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        try self.wrappedValue.withUnsafeMutableBytes(body)
    }

    public mutating func replaceSubrange<C>(
        _ subrange: Range<Data.Index>,
        with newElements: __owned C
    ) where C: Collection, C.Element == Element {
        self.wrappedValue.replaceSubrange(subrange, with: newElements)
    }
}

extension LengthTaggedData: Encodable {
    public func encode(to encoder: Encoder) throws {
        if wrappedValue.count > UInt16.max {
            throw BinaryEncodingError.variableSizedTypeTooBig
        }
        var container = encoder.unkeyedContainer()
        try container.encode(UInt16(wrappedValue.count))
        try withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            try container.encode(contentsOf: buffer)
        }
    }
}

extension LengthTaggedData: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let count = Int(try container.decode(UInt16.self))
        wrappedValue = Data(count: count)
        for i in 0..<count {
            let byte = try container.decode(UInt8.self)
            wrappedValue[i] = byte
        }
    }
}
