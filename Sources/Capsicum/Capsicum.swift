/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import CCapsicum
import Glibc

/// A Swift interface to the FreeBSD Capsicum sandboxing API.
///
/// Capsicum is a capability and sandbox framework built into FreeBSD that
/// allows a process to restrict itself to a set of permitted operations
/// on file descriptors and in capability mode. After entering capability
/// mode, access to global system namespaces (like files by pathname)
/// is disabled and operations are restricted to those explicitly
/// permitted via rights limits.
public enum Capsicum {

    /// Enters *Capsicum capability mode* for the current process.
    ///
    /// Once in capability mode, the process cannot access global namespaces
    /// such as the file system by path or the PID namespace. Only operations
    /// on file descriptors with appropriate rights remain permitted.
    ///
    /// - Throws: `CapsicumError.capsicumUnsupported` if Capsicum is unavailable.
    public static func enter() throws {
        guard cap_enter() == 0 else {
            throw CapsicumError.capsicumUnsupported
        }
    }

    /// Determines whether the current process is already in capability mode.
    ///
    /// - Returns: `true` if capability mode is enabled, `false` otherwise.
    /// - Throws: `CapsicumError.capsicumUnsupported` if Capsicum is unavailable.
    public static func status() throws -> Bool {
        var mode: UInt32 = 0
        guard cap_getmode(&mode) == 0 else {
            throw CapsicumError.capsicumUnsupported
        }
        return mode == 1
    }
}