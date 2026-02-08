/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
@testable import Capsicum

final class CapsicumRightTests: XCTestCase {
    func testAllCapsicumRightsHaveValidBridgeValue() {
        for right in CapsicumRight.allCases {
            XCTAssertNotNil(right.bridged)
        }
    }
}
