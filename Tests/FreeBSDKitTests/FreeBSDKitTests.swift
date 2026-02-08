/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Testing
@testable import FreeBSDKit

// MARK: - BSDSignal Tests

@Test func testSignalRawValues() {
    #expect(BSDSignal.hup.rawValue == 1)
    #expect(BSDSignal.int.rawValue == 2)
    #expect(BSDSignal.quit.rawValue == 3)
    #expect(BSDSignal.kill.rawValue == 9)
    #expect(BSDSignal.term.rawValue == 15)
}

@Test func testSignalIsCatchable() {
    #expect(BSDSignal.kill.isCatchable == false)
    #expect(BSDSignal.stop.isCatchable == false)
    #expect(BSDSignal.usr1.isCatchable == true)
    #expect(BSDSignal.usr2.isCatchable == true)
    #expect(BSDSignal.term.isCatchable == true)
    #expect(BSDSignal.int.isCatchable == true)
}

@Test func testAllCatchableSignals() {
    let catchableSignals: [BSDSignal] = [.hup, .int, .quit, .usr1, .usr2, .term]

    for signal in catchableSignals {
        #expect(signal.isCatchable == true)
    }
}

@Test func testNonCatchableSignals() {
    let nonCatchable: [BSDSignal] = [.kill, .stop]

    for signal in nonCatchable {
        #expect(signal.isCatchable == false)
    }
}

// MARK: - BSDError Tests

@Test func testBSDErrorFromErrno() {
    let error = BSDError.fromErrno(2) // ENOENT

    switch error {
    case .posix(let posixError):
        #expect(posixError.code.rawValue == 2)
    case .errno:
        Issue.record("Expected POSIXError, got errno")
    }
}

@Test func testBSDErrorFromUnknownErrno() {
    let error = BSDError.fromErrno(999999)

    switch error {
    case .errno(let value):
        #expect(value == 999999)
    case .posix:
        Issue.record("Expected errno case, got POSIXError")
    }
}

@Test func testBSDErrorDescription() {
    let posixError = BSDError.fromErrno(2)
    let desc = posixError.description
    #expect(!desc.isEmpty)

    let unknownError = BSDError.fromErrno(999999)
    let unknownDesc = unknownError.description
    #expect(unknownDesc.contains("errno"))
    #expect(unknownDesc.contains("999999"))
}

// MARK: - BSDResource Protocol Tests

@Test func testBSDResourceProtocol() {
    struct TestResource: BSDResource {
        typealias RAWBSD = Int32
        let fd: Int32

        consuming func take() -> Int32 {
            return fd
        }

        func unsafe<R>(_ block: (Int32) throws -> R) rethrows -> R where R: ~Copyable {
            try block(fd)
        }
    }

    let resource = TestResource(fd: 42)

    // Test unsafe access
    let result = resource.unsafe { fd in
        return fd * 2
    }
    #expect(result == 84)

    // Test take
    let fd = resource.take()
    #expect(fd == 42)
}

// MARK: - BSDValue Protocol Tests

@Test func testBSDValueProtocol() {
    struct TestValue: BSDValue {
        typealias RAWBSD = Int32
        let rawBSD: Int32
    }

    let value = TestValue(rawBSD: 123)
    #expect(value.rawBSD == 123)
}
