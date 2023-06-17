import XCTest
@testable import BinaryCoder

final class BinaryDecoderTests: XCTestCase {
    func testDefaultBinaryDecoder() throws {
        let decoder = BinaryDecoder()

        try assertThat(decoder, decodes: [4], to: UInt8(4))
        try assertThat(decoder, decodes: [0, 4], to: UInt16(4))
        try assertThat(decoder, decodes: [0, 0, 0, 4], to: UInt32(4))
        try assertThat(decoder, decodes: [0, 0, 0, 0, 0, 0, 0, 4], to: UInt64(4))
        try assertThat(decoder, decodes: [255], to: Int8(-1))
        try assertThat(decoder, decodes: [4], to: Int8(4))
        try assertThat(decoder, decodes: [0, 4], to: Int16(4))
        try assertThat(decoder, decodes: [0, 0, 0, 4], to: Int32(4))
        try assertThat(decoder, decodes: [0, 0, 0, 0, 0, 0, 0, 4], to: Int64(4))

        try assertThat(decoder, decodes: [1, 0, 2, 3], to: Simple(x: 1, y: 2, z: 3))
        try assertThat(decoder, decodes: [0, 0, 0, 2, 120, 0, 0, 0, 0, 0, 0, 0, 4], to: Composite(
            before: 2,
            inner: .init(value: 120),
            after: 4
        ))

        // Since the parser doesn't backtrack, it will consume all bytes while reading the array
        // and then EOF while trying to read the last field.
        try assertThat(decoder, whileDecoding: VariablePrefix.self, from: [1, 2, 2], throws: .eofTooEarly)
        try assertThat(decoder, decodes: [1, 9, 7], to: VariableSuffix(value: 1, suffix: [9, 7]))
        try assertThat(decoder, decodes: [9, 0, 3, 3, 20], to: Generic(value: Simple(x: 9, y: 3, z: 3), additional: 20))
        try assertThat(decoder, decodes: [97, 98, 99, 0], to: "abc")
        try assertThat(decoder, decodes: [97, 98, 99, 0, 3], to: Generic(value: "abc", additional: 3))
    }

    func testNonNullTerminatedStringBinaryDecoder() throws {
        let decoder = BinaryDecoder(config: .init(
            nullTerminateStrings: false
        ))

        try assertThat(decoder, decodes: [], to: "")
        try assertThat(decoder, decodes: [97, 98, 99], to: "abc")
        try assertThat(decoder, whileDecoding: Generic<String>.self, from: [97, 98, 99, 4], throws: .eofTooEarly)
    }
    
    func testLengthTaggedBinaryDecoder() throws {
        let decoder = BinaryDecoder(config: .init(
            endianness: .bigEndian,
            stringEncoding: .utf8,
            stringTypeStrategy: .lengthTagged,
            variableSizedTypeStrategy: .lengthTaggedArrays)
        )

        // single length tagged data
        try assertThat(decoder, decodes: [0x00, 0x03, 0xff, 0x01, 0x02], to: LengthTaggedData([0xff, 0x01, 0x02]))

        struct Foo: Codable, Equatable {
            var a, b: LengthTaggedData
        }

        // double length tagged data
        try assertThat(decoder, decodes: [0x00, 0x02, 0x01, 0x02, 0x00, 0x02, 0x03, 0x04],
                       to: Foo(a: LengthTaggedData([0x01, 0x02]),
                               b: LengthTaggedData([0x03, 0x04])))
        // length tagged data followed by UInt8
        try assertThat(decoder, decodes: [0x00, 0x02, 0x01, 0x02, 0x03],
                       to: Generic(value: LengthTaggedData([0x01, 0x02]), additional: 3))

        // length tagged string
        try assertThat(decoder, decodes: [0, 3, 97, 98, 99], to: "abc")

        // length tagged string followed by something else
        try assertThat(decoder, decodes: [0, 3, 97, 98, 99, 3], to: Generic(value: "abc", additional: 3))

        // length tagged array of UInt16
        try assertThat(decoder, decodes: [0, 2, 0, 1, 0, 2], to: [UInt16(1), UInt16(2)])
        
        // length tagged array of string
        try assertThat(decoder, decodes: [0, 2, 0, 1, 97, 0, 1, 98], to: ["a", "b"])

        // length tagged array of length tagged array
        try assertThat(decoder, decodes: [0, 3, 0, 2, 0, 1, 0, 3, 0, 2, 0, 9, 0, 2, 0, 1, 0, 7],
                       to: [[UInt16(1), UInt16(3)], [UInt16(9), UInt16(2)], [UInt16(7)]])
    }

    private func assertThat<Value>(
        _ decoder: BinaryDecoder,
        decodes array: [UInt8],
        to expectedValue: Value,
        line: UInt = #line
    ) throws where Value: Decodable & Equatable {
        XCTAssertEqual(try decoder.decode(Value.self, from: Data(array)), expectedValue, line: line)
    }

    private func assertThat<Value>(
        _ decoder: BinaryDecoder,
        whileDecoding type: Value.Type,
        from array: [UInt8],
        throws expectedError: BinaryDecodingError,
        line: UInt = #line
    ) throws where Value: Decodable {
        XCTAssertThrowsError(try decoder.decode(Value.self, from: Data(array)), line: line) { error in
            XCTAssertEqual(error as! BinaryDecodingError, expectedError, line: line)
        }
    }
}
