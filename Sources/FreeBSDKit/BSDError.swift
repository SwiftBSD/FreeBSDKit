/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */
 
import Foundation
import Glibc

/// Errors from BSD system calls.
///
/// Wraps errno values, converting known codes to `POSIXError` and preserving
/// unknown error codes as raw errno values.
public enum BSDError: Error, Sendable, CustomStringConvertible {
    /// A known POSIX error code.
    case posix(POSIXError)

    /// An errno value not recognized by Swift's POSIXErrorCode.
    case errno(Int32)

    public var description: String {
        switch self {
        case .posix(let err):
            return String(describing: err)
        case .errno(let value):
            return "errno \(value)"
        }
    }

    /// Throws a BSDError derived from the current or provided errno value.
    ///
    /// - Parameter err: The errno value to convert (defaults to `Glibc.errno`)
    /// - Throws: Never returns; always throws a BSDError
    @inline(__always)
    public static func throwErrno(_ err: Int32 = Glibc.errno) throws -> Never {
        throw BSDError.fromErrno(err)
    }

    /// Converts an errno value to a BSDError.
    ///
    /// - Parameter err: The errno value to convert (defaults to `Glibc.errno`)
    /// - Returns: A BSDError wrapping either a POSIXError or the raw errno
    @inline(__always)
    public static func fromErrno(_ err: Int32 = Glibc.errno) -> BSDError {
        if let code = POSIXErrorCode(rawValue: err) {
            return .posix(POSIXError(code))
        } else {
            return .errno(err)
        }
    }
}

extension BSDError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}