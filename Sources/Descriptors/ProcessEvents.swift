/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Glibc

/// Events for monitoring processes via `EVFILT_PROC` or `EVFILT_PROCDESC`.
///
/// These events are specified in the `fflags` field when registering
/// a process filter, and returned in `fflags` to indicate which events
/// occurred.
public struct ProcessEvents: OptionSet, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    // MARK: - Process Lifecycle Events

    /// The process exited.
    ///
    /// The `data` field contains the exit status in `wait(2)` format.
    /// Use `WIFEXITED()`, `WEXITSTATUS()`, `WIFSIGNALED()`, `WTERMSIG()`,
    /// etc. to interpret the status.
    public static let exit = ProcessEvents(rawValue: UInt32(NOTE_EXIT))

    /// The process called `fork()`.
    ///
    /// This event fires when the process creates a child.
    public static let fork = ProcessEvents(rawValue: UInt32(NOTE_FORK))

    /// The process executed a new program via `execve(2)`.
    public static let exec = ProcessEvents(rawValue: UInt32(NOTE_EXEC))

    // MARK: - Process Tracking

    /// Follow the process across `fork()` calls.
    ///
    /// When the monitored process forks, a new kevent is automatically
    /// registered for the child process. The child event will have
    /// `NOTE_CHILD` set in `fflags` with the parent PID in `data`.
    ///
    /// If registration for the child fails, `NOTE_TRACKERR` is returned
    /// instead of `NOTE_CHILD`.
    public static let track = ProcessEvents(rawValue: UInt32(NOTE_TRACK))

    // MARK: - Output-Only Flags (set by kernel)

    /// Indicates this event is for a child process (output only).
    ///
    /// Set when `NOTE_TRACK` was used and a child was forked.
    /// The `data` field contains the parent's PID.
    public static let child = ProcessEvents(rawValue: UInt32(NOTE_CHILD))

    /// Indicates child tracking registration failed (output only).
    ///
    /// Returned instead of `NOTE_CHILD` when the system couldn't
    /// register a kevent for the forked child process.
    public static let trackErr = ProcessEvents(rawValue: UInt32(NOTE_TRACKERR))

    // MARK: - Common Combinations

    /// All lifecycle events (exit, fork, exec).
    public static let lifecycle: ProcessEvents = [.exit, .fork, .exec]

    /// Track process and all its children through forks.
    public static let trackAll: ProcessEvents = [.exit, .fork, .exec, .track]
}

extension ProcessEvents: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if contains(.exit) { parts.append("exit") }
        if contains(.fork) { parts.append("fork") }
        if contains(.exec) { parts.append("exec") }
        if contains(.track) { parts.append("track") }
        if contains(.child) { parts.append("child") }
        if contains(.trackErr) { parts.append("trackErr") }
        return "ProcessEvents([\(parts.joined(separator: ", "))])"
    }
}

// MARK: - Exit Status Helpers

extension ProcessEvents {
    /// Check if the process exited normally.
    ///
    /// - Parameter status: The exit status from `data` field
    /// - Returns: `true` if the process called `exit()` or returned from `main()`
    public static func exitedNormally(_ status: Int32) -> Bool {
        return (status & 0x7f) == 0  // WIFEXITED
    }

    /// Get the exit code if the process exited normally.
    ///
    /// - Parameter status: The exit status from `data` field
    /// - Returns: The exit code (0-255), or `nil` if not a normal exit
    public static func exitCode(_ status: Int32) -> Int32? {
        guard exitedNormally(status) else { return nil }
        return (status >> 8) & 0xff  // WEXITSTATUS
    }

    /// Check if the process was terminated by a signal.
    ///
    /// - Parameter status: The exit status from `data` field
    /// - Returns: `true` if the process was killed by a signal
    public static func wasSignaled(_ status: Int32) -> Bool {
        return (status & 0x7f) != 0 && (status & 0x7f) != 0x7f  // WIFSIGNALED
    }

    /// Get the signal that terminated the process.
    ///
    /// - Parameter status: The exit status from `data` field
    /// - Returns: The signal number, or `nil` if not terminated by signal
    public static func termSignal(_ status: Int32) -> Int32? {
        guard wasSignaled(status) else { return nil }
        return status & 0x7f  // WTERMSIG
    }

    /// Check if the process dumped core.
    ///
    /// - Parameter status: The exit status from `data` field
    /// - Returns: `true` if a core dump was produced
    public static func didCoreDump(_ status: Int32) -> Bool {
        return wasSignaled(status) && (status & 0x80) != 0  // WCOREDUMP
    }
}
