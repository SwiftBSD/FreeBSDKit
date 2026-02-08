/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Foundation

/// A protocol representing a low-level BSD resource, such as a file descriptor or socket.
///
/// Types conforming to `BSDResource` provide access to the underlying raw BSD handle (`RAWBSD`)
/// while offering safe, Swift-friendly operations.
///
/// Conforming types can be `~Copyable` to ensure that ownership semantics are respected,
/// and the `take()` method provides a consuming way to extract the underlying resource.
public protocol BSDResource: ~Copyable {
    /// The type of the underlying raw BSD resource (e.g., `Int32` for file descriptors).
    associatedtype RAWBSD

    /// Consumes the conforming instance and returns the underlying raw BSD resource.
    ///
    /// - Returns: The raw BSD resource of type `RAWBSD`.
    consuming func take() -> RAWBSD

    /// Provides temporary access to the raw BSD resource for low-level operations.
    ///
    /// This method executes the given closure with the underlying resource as its argument.
    /// Any errors thrown inside the closure are propagated to the caller.
    ///
    /// - Parameter block: A closure that receives the raw BSD resource and can throw an error.
    /// - Returns: The result of the closure.
    /// - Throws: Any error thrown by the closure.
    ///
    /// - Warning: Tinkering with the internal state of the raw resource is generally unsafe
    ///   and may lead to undefined behavior. Prefer using higher-level abstractions.
    func unsafe<R>(_ block: (RAWBSD) throws -> R) rethrows -> R where R: ~Copyable
}