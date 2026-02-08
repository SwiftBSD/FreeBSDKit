/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import CCapsicum
import Glibc

/// A wrapper type representing a single `ioctl(2)` command code
/// that may be permitted or returned by Capsicum’s ioctl limits.
public struct IoctlCommand: Sendable {
    public let rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}