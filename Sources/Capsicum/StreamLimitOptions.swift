/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import CCapsicum
import Glibc

/// Options for restricting permitted operations on a stream (file descriptor) in Capsicum.
///
/// `StreamLimitOptions` is used with `Capsicum.limitStream(fd:options:)` to
/// specify which operations are allowed on a given file descriptor.
public struct StreamLimitOptions: OptionSet, Sendable {
    public let rawValue: Int32

    /// Creates a new `StreamLimitOptions` from the raw value.
    ///
    /// - Parameter rawValue: The raw `Int32` value representing the options.
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    /// Ignore `EBADF` (bad file descriptor) errors on this stream.
    ///
    /// Use this if you want Capsicum to silently ignore invalid file descriptors.
    public static let ignoreBadFileDescriptor =
        StreamLimitOptions(rawValue: CAPH_IGNORE_EBADF)

    /// Allow reading from the stream.
    public static let read =
        StreamLimitOptions(rawValue: CAPH_READ)

    /// Allow writing to the stream.
    public static let write =
        StreamLimitOptions(rawValue: CAPH_WRITE)
}