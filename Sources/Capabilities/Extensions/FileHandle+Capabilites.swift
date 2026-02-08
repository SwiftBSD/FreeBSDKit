/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Foundation
import Capsicum

public extension FileHandle {

    /// Apply Capsicum rights to this file handle.
    /// Returns `true` if the rights were applied, `false` on failure.
    func applyCapsicumRights(_ rights: CapsicumRightSet) -> Bool {
        return CapsicumHelper.limit(fd: fileDescriptor, rights: rights)
    }

    /// Restrict allowed stream operations.
    func limitCapsicumStream(options: StreamLimitOptions) throws {
        try CapsicumHelper.limitStream(fd: fileDescriptor, options: options)
    }

    /// Restrict allowed ioctl commands.
    func limitCapsicumIoctls(_ commands: [IoctlCommand]) throws {
        try CapsicumHelper.limitIoctls(fd: fileDescriptor, commands: commands)
    }

    /// Restrict allowed fcntl commands.
    func limitCapsicumFcntls(_ rights: FcntlRights) throws {
        try CapsicumHelper.limitFcntls(fd: fileDescriptor, rights: rights)
    }
    /// Get the currently allowed ioctl commands.
    func getCapsicumIoctls(maxCount: Int = 32) throws -> [IoctlCommand] {
        try CapsicumHelper.getIoctls(fd: fileDescriptor, maxCount: maxCount)
    }
    /// Get allowed fcntl commands mask.
    func getCapsicumFcntls() throws -> FcntlRights {
        try CapsicumHelper.getFcntls(fd: fileDescriptor)
    }
}