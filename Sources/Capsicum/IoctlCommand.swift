/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import CCapsicum
import Glibc

/// A wrapper type representing a single `ioctl(2)` command code
/// that may be permitted or returned by Capsicum's ioctl limits.
///
/// The rawValue type matches FreeBSD's `cap_ioctl_t` which is `unsigned long`.
public struct IoctlCommand: Sendable {
    public let rawValue: CUnsignedLong
    public init(rawValue: CUnsignedLong) {
        self.rawValue = rawValue
    }
}