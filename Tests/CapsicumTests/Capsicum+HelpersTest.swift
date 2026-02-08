/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
@testable import Capsicum

final class CapsicumHelperTests: XCTestCase {

    func testCacheTZDataDoesNotCrash() {
        Capsicum.cacheTZData()
        // Nothing to assert, just ensuring no crash
    }

    func testCacheCatPagesDoesNotCrash() {
        Capsicum.cacheCatPages()
        // Again, safe to call
    }
}
