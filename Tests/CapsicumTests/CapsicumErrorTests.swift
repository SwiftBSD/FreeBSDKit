/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
@testable import FreeBSDKit
@testable import Capsicum

final class CapsicumErrorTests: XCTestCase {

    func testErrorFromErrnoMapsCorrectly() {
        // ENOSYS should map differently depending on isCasper
        XCTAssertEqual(CapsicumError.errorFromErrno(ENOSYS, isCasper: false), .capsicumUnsupported)
        XCTAssertEqual(CapsicumError.errorFromErrno(ENOSYS, isCasper: true), .casperUnsupported)
        
        XCTAssertEqual(CapsicumError.errorFromErrno(EBADF), .badFileDescriptor)
        XCTAssertEqual(CapsicumError.errorFromErrno(EINVAL), .invalidArgument)
        XCTAssertEqual(CapsicumError.errorFromErrno(ENOTCAPABLE), .notCapable)
        XCTAssertEqual(CapsicumError.errorFromErrno(ECAPMODE), .capabilityModeViolation)
        
        // Some random errno not listed should produce underlyingFailure
        XCTAssertEqual(CapsicumError.errorFromErrno(9999), .underlyingFailure(errno: 9999))
    }

    func testCapsicumErrorEquatable() {
        XCTAssertEqual(CapsicumError.badFileDescriptor, .badFileDescriptor)
        XCTAssertNotEqual(CapsicumError.badFileDescriptor, .capsicumUnsupported)
    }

    func testCapsicumFcntlErrorCases() {
        let _ = CapsicumFcntlError.invalidDescriptor
        let _ = CapsicumFcntlError.invalidFlag
        let _ = CapsicumFcntlError.notCapable
        let _ = CapsicumFcntlError.system(errno: 1)
    }

    func testCapsicumIoctlErrorCases() {
        let _ = CapsicumIoctlError.invalidDescriptor
        let _ = CapsicumIoctlError.badBuffer
        let _ = CapsicumIoctlError.insufficientBuffer(expected: 42)
        let _ = CapsicumIoctlError.allIoctlsAllowed
        let _ = CapsicumIoctlError.system(errno: 1)
    }

}
