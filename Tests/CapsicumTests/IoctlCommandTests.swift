/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */
 
import XCTest
@testable import Capsicum

final class IoctlCommandTests: XCTestCase {

    func testInitialization() {
        let cmd = IoctlCommand(rawValue: 0x1234)
        XCTAssertEqual(cmd.rawValue, 0x1234)
    }

    func testMultipleValues() {
        let cmds: [UInt] = [0, 1, 42, 0xFFFF]
        for raw in cmds {
            let cmd = IoctlCommand(rawValue: raw)
            XCTAssertEqual(cmd.rawValue, raw)
        }
    }

    func testRawValueRoundTrip() {
        let raw: UInt = 0xDEADBEEF
        let cmd = IoctlCommand(rawValue: raw)
        let roundTrip = cmd.rawValue
        XCTAssertEqual(roundTrip, raw)
    }
}
