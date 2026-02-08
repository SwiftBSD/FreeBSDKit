/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
import Glibc
import Foundation
@testable import SignalDispatchers
@testable import Descriptors
@testable import FreeBSDKit

final class KqueueSignalDispatcherTests: XCTestCase {

    func testBlockSignals() throws {
        // Test that blockSignals doesn't throw
        try SystemKqueueDescriptor.blockSignals([.usr1, .usr2])
    }

    func testRegisterSignal() throws {
        let kq = SystemKqueueDescriptor(kqueue())
        defer { kq.close() }

        // Register catchable signal
        try kq.registerSignal(.usr1)

        // Should not throw for catchable signals
        try kq.registerSignal(.usr2)
    }

    func testUnregisterSignal() throws {
        let kq = SystemKqueueDescriptor(kqueue())
        defer { kq.close() }

        // Register and unregister
        try kq.registerSignal(.usr1)
        try kq.unregisterSignal(.usr1)
    }

    func testRegisterNonCatchableSignalFails() throws {
        let kq = SystemKqueueDescriptor(kqueue())
        defer { kq.close() }

        // Attempting to register KILL or STOP should fail
        XCTAssertThrowsError(try kq.registerSignal(.kill))
        XCTAssertThrowsError(try kq.registerSignal(.stop))
    }
}

// Concrete implementation for testing
struct SystemKqueueDescriptor: KqueueDescriptor {
    typealias RAWBSD = Int32
    private let fd: Int32

    init(_ fd: Int32) {
        self.fd = fd
    }

    consuming func close() {
        Glibc.close(fd)
    }

    consuming func take() -> Int32 {
        return fd
    }

    func unsafe<R>(_ block: (Int32) throws -> R) rethrows -> R where R: ~Copyable {
        try block(fd)
    }
}
