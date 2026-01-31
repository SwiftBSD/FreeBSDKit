import XCTest
@testable import Jails
import CJails

final class JailFlagsValueTests: XCTestCase {

    func testJailSetFlagsRawValuesMatchCConstants() {
        XCTAssertEqual(JailSetFlags.create.rawValue, JAIL_CREATE)
        XCTAssertEqual(JailSetFlags.update.rawValue, JAIL_UPDATE)
        XCTAssertEqual(JailSetFlags.attach.rawValue, JAIL_ATTACH)

        XCTAssertEqual(JailSetFlags.useDesc.rawValue, JAIL_USE_DESC)
        XCTAssertEqual(JailSetFlags.atDesc.rawValue, JAIL_AT_DESC)
        XCTAssertEqual(JailSetFlags.getDesc.rawValue, JAIL_GET_DESC)
        XCTAssertEqual(JailSetFlags.ownDesc.rawValue, JAIL_OWN_DESC)
    }

    func testJailGetFlagsRawValuesMatchCConstants() {
        XCTAssertEqual(JailGetFlags.dying.rawValue, JAIL_DYING)
        XCTAssertEqual(JailGetFlags.useDesc.rawValue, JAIL_USE_DESC)
        XCTAssertEqual(JailGetFlags.atDesc.rawValue, JAIL_AT_DESC)
        XCTAssertEqual(JailGetFlags.getDesc.rawValue, JAIL_GET_DESC)
        XCTAssertEqual(JailGetFlags.ownDesc.rawValue, JAIL_OWN_DESC)
    }
}

final class JailFlagsOptionSetTests: XCTestCase {
    func testSetFlagCombination() {
        let flags: JailSetFlags = [.create, .attach]

        XCTAssertTrue(flags.contains(.create))
        XCTAssertTrue(flags.contains(.attach))
        XCTAssertFalse(flags.contains(.update))
    }

    func testGetFlagCombination() {
        let flags: JailGetFlags = [.dying, .getDesc]

        XCTAssertTrue(flags.contains(.dying))
        XCTAssertTrue(flags.contains(.getDesc))
        XCTAssertFalse(flags.contains(.useDesc))
    }
}

final class JailFlagsEdgeCaseTests: XCTestCase {

    func testEmptyFlags() {
        let flags = JailSetFlags([])
        XCTAssertEqual(flags.rawValue, 0)
    }

    func testUnionProducesExpectedRawValue() {
        let flags: JailSetFlags = [.create, .update]
        XCTAssertEqual(flags.rawValue, JAIL_CREATE | JAIL_UPDATE)
    }
}