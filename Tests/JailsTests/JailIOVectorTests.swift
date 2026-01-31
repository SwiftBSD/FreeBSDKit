import XCTest
@testable import Jails   // or FreeBSDKit / your module name
import Glibc

final class JailIOVectorTests: XCTestCase {

    func testStartsEmpty() {
        let iov = JailIOVector()
        XCTAssertEqual(iov.iovecs.count, 0)
    }

    func testPairsAreAlwaysEven() {
        let iov = JailIOVector()
        iov.addCString("name", value: "test")
        XCTAssertEqual(iov.iovecs.count % 2, 0)

        iov.addInt32("jid", 42)
        XCTAssertEqual(iov.iovecs.count % 2, 0)
    }

    func testAddCStringProducesTwoIOVecs() {
        let iov = JailIOVector()
        iov.addCString("name", value: "testjail")

        XCTAssertEqual(iov.iovecs.count, 2)
    }

    func testCStringKeyAndValueAreCorrect() {
        let iov = JailIOVector()
        iov.addCString("name", value: "test")

        let key = iov.iovecs[0]
        let val = iov.iovecs[1]

        XCTAssertEqual(
            String(cString: key.iov_base!.assumingMemoryBound(to: CChar.self)),
            "name"
        )
        XCTAssertEqual(
            String(cString: val.iov_base!.assumingMemoryBound(to: CChar.self)),
            "test"
        )
    }

    func testCStringLengthsIncludeNullTerminator() {
        let iov = JailIOVector()
        iov.addCString("abc", value: "xyz")

        XCTAssertEqual(iov.iovecs[0].iov_len, 4) // "abc\0"
        XCTAssertEqual(iov.iovecs[1].iov_len, 4) // "xyz\0"
    }

    func testAddInt32Layout() {
        let iov = JailIOVector()
        iov.addInt32("jid", 123)

        let value = iov.iovecs[1]

        XCTAssertEqual(value.iov_len, MemoryLayout<Int32>.size)
        XCTAssertEqual(
            value.iov_base!.load(as: Int32.self),
            123
        )
    }

    func testAddUInt32Layout() {
        let iov = JailIOVector()
        iov.addUInt32("flags", 0xdeadbeef)

        let value = iov.iovecs[1]

        XCTAssertEqual(value.iov_len, MemoryLayout<UInt32>.size)
        XCTAssertEqual(
            value.iov_base!.load(as: UInt32.self),
            0xdeadbeef
        )
    }

    func testAddInt64Layout() {
        let iov = JailIOVector()
        iov.addInt64("hostid", 0x1122334455667788)

        let value = iov.iovecs[1]

        XCTAssertEqual(value.iov_len, MemoryLayout<Int64>.size)
        XCTAssertEqual(
            value.iov_base!.load(as: Int64.self),
            0x1122334455667788
        )
    }

    func testBoolTrueEncodesAsOne() {
        let iov = JailIOVector()
        iov.addBool("persist", true)

        let value = iov.iovecs[1]
        XCTAssertEqual(value.iov_len, MemoryLayout<Int32>.size)
        XCTAssertEqual(value.iov_base!.load(as: Int32.self), 1)
    }

    func testBoolFalseEncodesAsZero() {
        let iov = JailIOVector()
        iov.addBool("persist", false)

        let value = iov.iovecs[1]
        XCTAssertEqual(value.iov_base!.load(as: Int32.self), 0)
    }

    func testKeyValueOrdering() {
        let iov = JailIOVector()
        iov.addCString("name", value: "a")
        iov.addInt32("jid", 1)

        let key1 = String(cString: iov.iovecs[0].iov_base!.assumingMemoryBound(to: CChar.self))
        let key2 = String(cString: iov.iovecs[2].iov_base!.assumingMemoryBound(to: CChar.self))

        XCTAssertEqual(key1, "name")
        XCTAssertEqual(key2, "jid")
    }

    func testWithUnsafeMutableIOVecsProvidesMutableAccess() {
        let iov = JailIOVector()
        iov.addInt32("jid", 10)

        let rc: Int32 = iov.withUnsafeMutableIOVecs { buf in
            XCTAssertEqual(buf.count, 2)
            return 0
        }

        XCTAssertEqual(rc, 0)
    }
}