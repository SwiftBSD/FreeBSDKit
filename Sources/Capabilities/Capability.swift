/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Capsicum
import Descriptors
import FreeBSDKit
import Glibc


/// Conforming types indicate that the resource represents a **capability** in the
/// system — that is, a controlled access token to perform operations, rather than
/// just a raw descriptor. This is useful for enforcing capability-based security
/// patterns in your code.
///
/// Typically, types conforming to `Capability` are more restrictive or specialized
/// descriptors (e.g., `FileDescriptor`, `SocketDescriptor`, `KqueueDescriptor`),
/// providing safe operations in addition to the universal `close()` method.
public protocol Capability: Descriptor, ~Copyable {
    func limit(rights: CapsicumRightSet) -> Bool
    func limitStream(options: StreamLimitOptions) throws
    func limitIoctls(commands: [IoctlCommand]) throws
    func limitFcntls(rights: FcntlRights) throws
    func getIoctls(maxCount: Int) throws -> [IoctlCommand]
    func getFcntls() throws -> FcntlRights
}

public extension Capability where Self: ~Copyable {

    func limit(rights: CapsicumRightSet) -> Bool {
        return self.unsafe { fd in
            CapsicumHelper.limit(fd: fd, rights: rights)
        }
    }

    func limitStream(options: StreamLimitOptions) throws {
        try self.unsafe { fd in
            try CapsicumHelper.limitStream(fd: fd, options: options)
        }
    }

    func limitIoctls(commands: [IoctlCommand]) throws {
        try self.unsafe { fd in
            try CapsicumHelper.limitIoctls(fd: fd, commands: commands)
        }
    }

    func limitFcntls(rights: FcntlRights) throws {
        try self.unsafe { fd in
            try CapsicumHelper.limitFcntls(fd: fd, rights: rights)
        }
    }

    func getIoctls(maxCount: Int = 32) throws -> [IoctlCommand] {
        return try self.unsafe { fd in
            try CapsicumHelper.getIoctls(fd: fd, maxCount: maxCount)
        }
    }

    func getFcntls() throws -> FcntlRights {
        return try self.unsafe { fd in
            try CapsicumHelper.getFcntls(fd: fd)
        }
    }
}
