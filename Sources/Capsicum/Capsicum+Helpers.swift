/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */


import CCapsicum
import Glibc

/// Utilities for interacting with Capsicum sandbox helpers (`<capsicum_helpers>`).
/// 
/// These functions provide safe Swift wrappers around the Capsicum Casper API.
/// Most functions throw a `CapsicumError` if the underlying C call fails.
extension Capsicum {

    /// Enter Casper mode, restricting the process to Capsicum sandbox helpers.
    ///
    /// - Throws: `CapsicumError.casperUnsupported` if Casper is not available,
    ///           or another `CapsicumError` if the underlying call fails.
    public static func enterCasper() throws {
        guard caph_enter_casper() == 0 else {
            throw CapsicumError.errorFromErrno(errno, isCasper: true)
        }
    }

    /// Restricts standard input (stdin) for the process.
    ///
    /// - Throws: `CapsicumError` if the underlying call fails.
    public static func limitStdin() throws {
        guard caph_limit_stdin() == 0 else {
            throw CapsicumError.errorFromErrno(errno)
        }
    }

    /// Restricts standard error (stderr) for the process.
    ///
    /// - Throws: `CapsicumError` if the underlying call fails.
    public static func limitStderr() throws {
        guard caph_limit_stderr() == 0 else {
            throw CapsicumError.errorFromErrno(errno)
        }
    }

    /// Restricts standard output (stdout) for the process.
    ///
    /// - Throws: `CapsicumError` if the underlying call fails.
    public static func limitStdout() throws {
        guard caph_limit_stdout() == 0 else {
            throw CapsicumError.errorFromErrno(errno)
        }
    }

    /// Restricts all standard I/O streams (stdin, stdout, stderr) for the process.
    ///
    /// - Throws: `CapsicumError` if the underlying call fails.
    public static func limitStdio() throws {
        guard caph_limit_stdio() == 0 else {
            throw CapsicumError.errorFromErrno(errno)
        }
    }

    /// Cache timezone data in memory for faster access.
    public static func cacheTZData() {
        caph_cache_tzdata()
    }

    /// Cache "cat" man pages in memory for faster access.
    public static func cacheCatPages() {
        caph_cache_catpages()
    }
}