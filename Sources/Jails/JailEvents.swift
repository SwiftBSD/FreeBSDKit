/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Glibc

/// Events for monitoring jails via `EVFILT_JAIL` or `EVFILT_JAILDESC`.
///
/// These events are specified in the `fflags` field when registering
/// a jail filter, and returned in `fflags` to indicate which events
/// occurred.
public struct JailEvents: OptionSet, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    // MARK: - Jail Lifecycle Events

    /// The jail was modified via `jail_set(2)`.
    public static let set = JailEvents(rawValue: UInt32(NOTE_JAIL_SET))

    /// A process attached to the jail via `jail_attach(2)`.
    ///
    /// The `data` field contains the PID of the attached process,
    /// or 0 if multiple processes attached since the last `kevent()` call.
    public static let attach = JailEvents(rawValue: UInt32(NOTE_JAIL_ATTACH))

    /// The jail was removed.
    public static let remove = JailEvents(rawValue: UInt32(NOTE_JAIL_REMOVE))

    /// A child jail was created.
    ///
    /// The `data` field contains the JID of the child jail,
    /// or 0 if multiple children were created since the last `kevent()` call.
    public static let child = JailEvents(rawValue: UInt32(NOTE_JAIL_CHILD))

    // MARK: - Output-Only Flags (set by kernel)

    /// Multiple events of the same type occurred.
    ///
    /// Set when multiple `attach` or `child` events occurred since
    /// the last `kevent()` call. In this case, the `data` field is 0.
    public static let multi = JailEvents(rawValue: UInt32(NOTE_JAIL_MULTI))

    // MARK: - Common Combinations

    /// All jail events.
    public static let all: JailEvents = [.set, .attach, .remove, .child]
}

extension JailEvents: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if contains(.set) { parts.append("set") }
        if contains(.attach) { parts.append("attach") }
        if contains(.remove) { parts.append("remove") }
        if contains(.child) { parts.append("child") }
        if contains(.multi) { parts.append("multi") }
        return "JailEvents([\(parts.joined(separator: ", "))])"
    }
}
