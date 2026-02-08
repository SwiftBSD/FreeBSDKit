/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
@testable import Capsicum

final class CapsicumTests: XCTestCase {

    func testInitialStatusIsNotInCapabilityMode() throws {
        let status = try Capsicum.status()
        XCTAssertFalse(
            status,
            "Process should not start in Capsicum capability mode"
        )
    }
}
