/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/// A protocol representing a trivial, possibly copyable BSD value type.
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
public protocol BSDValue: ~Copyable {
    /// The underlying BSD type represented by this value.
    associatedtype RAWBSD

    /// Returns the underlying BSD value.
    var rawBSD: RAWBSD { get }
}