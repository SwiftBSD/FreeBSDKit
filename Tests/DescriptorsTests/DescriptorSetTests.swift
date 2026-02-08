/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
import Glibc
import Foundation
@testable import Descriptors

final class DescriptorSetTests: XCTestCase {

    func testDescriptorSetInsertAndAll() throws {
        var set = DescriptorSet([])

        // Create some pipes
        var fds1: [Int32] = [0, 0]
        var fds2: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds1), 0)
        XCTAssertEqual(pipe(&fds2), 0)
        defer {
            close(fds1[0])
            close(fds1[1])
            close(fds2[0])
            close(fds2[1])
        }

        // Insert descriptors
        set.insert(TestDescriptor(fds1[0]), kind: .pipe)
        set.insert(TestDescriptor(fds1[1]), kind: .pipe)
        set.insert(TestDescriptor(fds2[0]), kind: .file)

        // Check all of kind
        let pipes = set.all(ofKind: .pipe)
        XCTAssertEqual(pipes.count, 2, "Should have 2 pipes")

        let files = set.all(ofKind: .file)
        XCTAssertEqual(files.count, 1, "Should have 1 file")

        let sockets = set.all(ofKind: .socket)
        XCTAssertEqual(sockets.count, 0, "Should have 0 sockets")
    }

    func testDescriptorSetFirst() throws {
        var set = DescriptorSet([])

        var fds: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds), 0)
        defer {
            close(fds[0])
            close(fds[1])
        }

        set.insert(TestDescriptor(fds[0]), kind: .pipe)

        // Find first pipe
        let pipe = set.first(ofKind: .pipe)
        XCTAssertNotNil(pipe, "Should find pipe")
        XCTAssertEqual(pipe?.kind, .pipe)

        // No socket
        let socket = set.first(ofKind: .socket)
        XCTAssertNil(socket, "Should not find socket")
    }

    func testDescriptorSetIteration() throws {
        var set = DescriptorSet([])

        var fds1: [Int32] = [0, 0]
        var fds2: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds1), 0)
        XCTAssertEqual(pipe(&fds2), 0)
        defer {
            close(fds1[0])
            close(fds1[1])
            close(fds2[0])
            close(fds2[1])
        }

        set.insert(TestDescriptor(fds1[0]), kind: .pipe)
        set.insert(TestDescriptor(fds2[0]), kind: .file)
        set.insert(TestDescriptor(fds2[1]), kind: .socket)

        // Iterate and count
        var count = 0
        for desc in set {
            if let fd = desc.toBSDValue() {
                XCTAssertGreaterThanOrEqual(fd, 0)
            }
            count += 1
        }

        XCTAssertEqual(count, 3, "Should iterate over all 3 descriptors")
    }

    func testDescriptorSetEmpty() throws {
        let set = DescriptorSet([])

        XCTAssertEqual(set.all(ofKind: .pipe).count, 0)
        XCTAssertNil(set.first(ofKind: .pipe))

        var count = 0
        for _ in set {
            count += 1
        }
        XCTAssertEqual(count, 0, "Empty set should not iterate")
    }
}

// Test descriptor implementation
struct TestDescriptor: Descriptor {
    typealias RAWBSD = Int32
    let fd: Int32

    init(_ fd: Int32) {
        self.fd = fd
    }

    consuming func close() {
        // Don't actually close - we manage that in the test
    }

    consuming func take() -> Int32 {
        return fd
    }

    func unsafe<R>(_ block: (Int32) throws -> R) rethrows -> R where R: ~Copyable {
        try block(fd)
    }
}
