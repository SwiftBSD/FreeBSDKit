/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
import Glibc
import Foundation
@testable import Descriptors

final class SharedMemoryDescriptorTests: XCTestCase {

    var shmName: String!

    override func setUp() {
        super.setUp()
        shmName = "/test_shm_\(UUID().uuidString)"
    }

    override func tearDown() {
        if let name = shmName {
            try? SystemSharedMemoryDescriptor.unlink(name: name)
        }
        super.tearDown()
    }

    func testCreateAndUnlink() throws {
        let shm = try SystemSharedMemoryDescriptor.open(
            name: shmName,
            oflag: O_RDWR | O_CREAT | O_EXCL,
            mode: 0o600
        )
        shm.close()

        try SystemSharedMemoryDescriptor.unlink(name: shmName)
        shmName = nil // Prevent double unlink in tearDown
    }

    func testSetSize() throws {
        let shm = try SystemSharedMemoryDescriptor.open(
            name: shmName,
            oflag: O_RDWR | O_CREAT | O_EXCL,
            mode: 0o600
        )
        defer { shm.close() }

        try shm.setSize(4096)

        // Verify size by attempting to map
        let region = try shm.map(
            size: 4096,
            protection: [.read, .write],
            flags: .shared
        )

        XCTAssertEqual(region.size, 4096)
        try region.unmap()
    }

    func testMapAndWrite() throws {
        let shm = try SystemSharedMemoryDescriptor.open(
            name: shmName,
            oflag: O_RDWR | O_CREAT | O_EXCL,
            mode: 0o600
        )
        defer { shm.close() }

        let size = 1024
        try shm.setSize(size)

        let region = try shm.map(
            size: size,
            protection: [.read, .write],
            flags: .shared
        )

        // Write to shared memory
        let testData = "Hello, Shared Memory!"
        let ptr = UnsafeMutableRawPointer(mutating: region.base)
        _ = testData.withCString { cstr in
            strcpy(ptr.assumingMemoryBound(to: CChar.self), cstr)
        }

        // Read back
        let readBack = String(cString: region.base.assumingMemoryBound(to: CChar.self))
        XCTAssertEqual(readBack, testData)

        try region.unmap()
    }

    func testMultipleProcessSharing() throws {
        let shm = try SystemSharedMemoryDescriptor.open(
            name: shmName,
            oflag: O_RDWR | O_CREAT | O_EXCL,
            mode: 0o600
        )
        defer { shm.close() }

        let size = 1024
        try shm.setSize(size)

        let region = try shm.map(
            size: size,
            protection: [.read, .write],
            flags: .shared
        )

        // Write a test value
        let ptr = UnsafeMutableRawPointer(mutating: region.base)
        ptr.storeBytes(of: Int32(12345), as: Int32.self)

        // Open the same shared memory in "another process" (simulated)
        let shm2 = try SystemSharedMemoryDescriptor.open(
            name: shmName,
            oflag: O_RDWR,
            mode: 0
        )

        let region2 = try shm2.map(
            size: size,
            protection: [.read],
            flags: .shared
        )

        // Read the value written by the first "process"
        let value = region2.base.load(as: Int32.self)
        XCTAssertEqual(value, 12345, "Shared memory not working across opens")

        try region2.unmap()
        shm2.close()
        try region.unmap()
    }
}

// Concrete implementation for testing
struct SystemSharedMemoryDescriptor: SharedMemoryDescriptor {
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
