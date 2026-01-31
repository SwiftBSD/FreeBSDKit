import XCTest
import Foundation
@testable import Capabilities
import Capsicum

final class FileHandleCapsicumTests: XCTestCase {

    // MARK: - Helpers

    private func makeTempFile() throws -> FileHandle {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        _ = FileManager.default.createFile(atPath: url.path, contents: Data())
        return try FileHandle(forUpdating: url)
    }

    // MARK: - applyCapsicumRights

    func testApplyCapsicumRightsSucceeds() throws {
        let fh = try makeTempFile()

        var rights = CapsicumRightSet()
        rights.add(capability: .read)

        let result = fh.applyCapsicumRights(rights)
        XCTAssertTrue(result)
    }

    func testApplyCapsicumRightsIdempotent() throws {
        let fh = try makeTempFile()

        var rights = CapsicumRightSet()
        rights.add(capability: .read)

        XCTAssertTrue(fh.applyCapsicumRights(rights))
        XCTAssertTrue(fh.applyCapsicumRights(rights))
    }

    // MARK: - Stream limits

    func testLimitCapsicumStream() throws {
        let fh = try makeTempFile()

        XCTAssertNoThrow(
            try fh.limitCapsicumStream(options: [])
        )
    }

    // MARK: - Ioctl limits

    func testLimitCapsicumIoctlsAndQueryDoesNotThrow() throws {
        let fh = try makeTempFile()

        let allowed: [IoctlCommand] = []

        XCTAssertNoThrow(
            try fh.limitCapsicumIoctls(allowed)
        )

        let queried = try fh.getCapsicumIoctls(maxCount: 8)
        XCTAssertTrue(queried.isEmpty)
    }

    // MARK: - Fcntl limits

    func testLimitCapsicumFcntlsRoundTrip() throws {
        let fh = try makeTempFile()

        let rights = FcntlRights() // empty / default

        XCTAssertNoThrow(
            try fh.limitCapsicumFcntls(rights)
        )

        let queried = try fh.getCapsicumFcntls()
        _ = queried // existence + no-throw is the assertion
    }

    func testRightsPersistInCapabilityMode() throws {
        let pid = fork()
        XCTAssertNotEqual(pid, -1)

        if pid == 0 {
            // Child process
            do {
                let fh = try makeTempFile()

                var rights = CapsicumRightSet()
                rights.add(capability: .read)

                XCTAssertTrue(fh.applyCapsicumRights(rights))
                try Capsicum.enter()

                XCTAssertNoThrow(_ = try fh.readToEnd())
                exit(0)
            } catch {
                exit(1)
            }
        } else {
            var status: Int32 = 0
            waitpid(pid, &status, 0)
            XCTAssertEqual(status, 0)
        }
    }

}
