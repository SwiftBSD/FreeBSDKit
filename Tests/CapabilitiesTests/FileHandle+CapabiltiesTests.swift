/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
import Foundation
import Glibc
@testable import Capabilities
import Capsicum

final class FileHandleCapsicumTests: XCTestCase {

    // MARK: - Pipe-based tests (avoid filesystem in capability mode)

    func testApplyCapsicumRightsOnPipe() throws {
        var fds: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds), 0)
        defer {
            close(fds[0])
            close(fds[1])
        }

        let fh = FileHandle(fileDescriptor: fds[0], closeOnDealloc: false)

        var rights = CapsicumRightSet()
        rights.add(capability: .read)

        let result = fh.applyCapsicumRights(rights)
        XCTAssertTrue(result, "Should successfully apply rights to pipe")
    }

    func testApplyCapsicumRightsIdempotent() throws {
        var fds: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds), 0)
        defer {
            close(fds[0])
            close(fds[1])
        }

        let fh = FileHandle(fileDescriptor: fds[0], closeOnDealloc: false)

        var rights = CapsicumRightSet()
        rights.add(capability: .read)

        XCTAssertTrue(fh.applyCapsicumRights(rights))
        XCTAssertTrue(fh.applyCapsicumRights(rights), "Applying same rights should be idempotent")
    }

    func testLimitCapsicumStreamOnPipe() throws {
        var fds: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds), 0)
        defer {
            close(fds[0])
            close(fds[1])
        }

        let fh = FileHandle(fileDescriptor: fds[0], closeOnDealloc: false)

        XCTAssertNoThrow(
            try fh.limitCapsicumStream(options: [])
        )
    }

    func testLimitCapsicumFcntlsOnPipe() throws {
        var fds: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&fds), 0)
        defer {
            close(fds[0])
            close(fds[1])
        }

        let fh = FileHandle(fileDescriptor: fds[0], closeOnDealloc: false)

        let rights = FcntlRights()

        XCTAssertNoThrow(
            try fh.limitCapsicumFcntls(rights)
        )

        let queried = try fh.getCapsicumFcntls()
        _ = queried
    }

    // Disabled: Complex fork-based capability mode test
    func disabled_testRightsWorkInCapabilityMode() throws {
        let pid = fork()
        XCTAssertNotEqual(pid, -1)

        if pid == 0 {
            // Child process
            var fds: [Int32] = [0, 0]
            guard pipe(&fds) == 0 else { exit(1) }

            let readEnd = FileHandle(fileDescriptor: fds[0], closeOnDealloc: true)
            let writeEnd = FileHandle(fileDescriptor: fds[1], closeOnDealloc: true)

            // Apply rights before entering capability mode
            var readRights = CapsicumRightSet()
            readRights.add(capability: .read)
            guard readEnd.applyCapsicumRights(readRights) else { exit(1) }

            var writeRights = CapsicumRightSet()
            writeRights.add(capability: .write)
            guard writeEnd.applyCapsicumRights(writeRights) else { exit(1) }

            // Enter capability mode
            do {
                try Capsicum.enter()
            } catch {
                exit(1)
            }

            // Write data
            let testData = "test".data(using: .utf8)!
            do {
                try writeEnd.write(contentsOf: testData)
            } catch {
                exit(1)
            }

            // Read data back
            do {
                let data = try readEnd.read(upToCount: 4)
                guard data == testData else { exit(1) }
            } catch {
                exit(1)
            }

            exit(0)
        } else {
            var status: Int32 = 0
            waitpid(pid, &status, 0)
            // WEXITSTATUS equivalent: (status >> 8) & 0xff
            let exitCode = Int32((status >> 8) & 0xff)
            XCTAssertEqual(exitCode, 0, "Child process should exit successfully")
        }
    }

}
