/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/// A protocol representing a trivial, copyable BSD value type.
///
/// `BSDValue` models plain data structures originating from BSD APIs that:
/// - have **value semantics**
/// - are **trivially copyable**
/// - do **not** represent ownership of kernel resources
///
/// Examples include:
/// - `cap_rights_t`
/// - `struct stat`
/// - `sockaddr`
/// - `timespec`
///
/// This protocol is distinct from `BSDResource`, which represents owned
/// resources like file descriptors that require explicit lifecycle management.
public protocol BSDValue {
    /// The underlying BSD type represented by this value.
    associatedtype RAWBSD

    /// Returns the underlying BSD value.
    var rawBSD: RAWBSD { get }
}