/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

 import CCapsicum
 import Glibc

/// A set of flags representing the fcntl commands that may be
/// permitted on a file descriptor when using Capsicum’s fcntl limits.
public struct FcntlRights: OptionSet, Sendable {
    public let rawValue: UInt32

    /// Permits the `F_GETFL` fcntl command.
    public static let getFlags = FcntlRights(rawValue: UInt32(CAP_FCNTL_GETFL))

    /// Permits the `F_SETFL` fcntl command.
    public static let setFlags = FcntlRights(rawValue: UInt32(CAP_FCNTL_SETFL))

    /// Permits the `F_GETOWN` fcntl command.
    public static let getOwner = FcntlRights(rawValue: UInt32(CAP_FCNTL_GETOWN))

    /// Permits the `F_SETOWN` fcntl command.
    public static let setOwner = FcntlRights(rawValue: UInt32(CAP_FCNTL_SETOWN))

    /// Creates a new set of fcntl rights from a raw bitmask.
    ///
    /// - Parameter rawValue: A bitmask of fcntl rights.
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}