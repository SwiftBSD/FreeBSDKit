/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
import Glibc
import Foundation
@testable import Descriptors

final class PipeDescriptorTests: XCTestCase {

    func testPipeReadWrite() throws {
        var fds: [Int32] = [0, 0]
        let result = pipe(&fds)
        XCTAssertEqual(result, 0, "pipe() failed")

        let readEnd = SystemPipeReadDescriptor(fds[0])
        let writeEnd = SystemPipeWriteDescriptor(fds[1])

        // Write data to pipe
        let testData = "Hello through the pipe!".data(using: .utf8)!
        let written = try writeEnd.writeOnce(testData)
        XCTAssertEqual(written, testData.count, "Write to pipe failed")

        // Read data from pipe
        let readResult = try readEnd.read(maxBytes: testData.count)
        if case .data(let readData) = readResult {
            XCTAssertEqual(readData, testData, "Read from pipe failed")
        } else {
            XCTFail("Expected data, got EOF")
        }

        readEnd.close()
        writeEnd.close()
    }

    func testPipePartialRead() throws {
        var fds: [Int32] = [0, 0]
        let result = pipe(&fds)
        XCTAssertEqual(result, 0, "pipe() failed")

        let readEnd = SystemPipeReadDescriptor(fds[0])
        let writeEnd = SystemPipeWriteDescriptor(fds[1])

        // Write more data
        let testData = "ABCDEFGHIJKLMNOP".data(using: .utf8)!
        try writeEnd.writeAll(testData)

        // Read partial
        let result1 = try readEnd.read(maxBytes: 5)
        if case .data(let partial1) = result1 {
            XCTAssertEqual(String(data: partial1, encoding: .utf8), "ABCDE")
        } else {
            XCTFail("Expected data")
        }

        let result2 = try readEnd.read(maxBytes: 5)
        if case .data(let partial2) = result2 {
            XCTAssertEqual(String(data: partial2, encoding: .utf8), "FGHIJ")
        } else {
            XCTFail("Expected data")
        }

        readEnd.close()
        writeEnd.close()
    }
}

// Concrete implementations for testing
struct SystemPipeReadDescriptor: PipeReadDescriptor {
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

struct SystemPipeWriteDescriptor: PipeWriteDescriptor {
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
