/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Glibc
import Foundation
import FreeBSDKit

// MARK: - Kqueue Descriptor

/// A BSD descriptor representing a `kqueue(2)`.
public protocol KqueueDescriptor: Descriptor, ~Copyable {

    /// Create a new kqueue descriptor.
    static func makeKqueue() throws -> Self

    /// Perform a kevent operation.
    ///
    /// - Parameters:
    ///   - changes: Events to register.
    ///   - maxEvents: Maximum number of events to return.
    ///   - timeout: Optional timeout; `nil` waits indefinitely.
    ///
    /// - Returns: (number of events, returned events)
    func kevent(
        changes: [kevent],
        maxEvents: Int,
        timeout: TimeInterval?
    ) throws -> (Int, [kevent])
}

// MARK: - C ABI hook
@_silgen_name("kevent")
public func _kevent_c(
    _ kq: Int32,
    _ changelist: UnsafePointer<kevent>?,
    _ nchanges: Int32,
    _ eventlist: UnsafeMutablePointer<kevent>?,
    _ nevents: Int32,
    _ timeout: UnsafePointer<timespec>?
) -> Int32

// MARK: - Default Implementations

public extension KqueueDescriptor where Self: ~Copyable {

    static func makeKqueue() throws -> Self {
        let raw = Glibc.kqueue()
        guard raw >= 0 else {
            try BSDError.throwErrno(errno)
        }
        return Self(raw)
    }

    func kevent(
        changes: [kevent],
        maxEvents: Int,
        timeout: TimeInterval?
    ) throws -> (Int, [kevent]) {
        var events = Array<kevent>(repeating: Glibc.kevent(), count: maxEvents)

        var tsStorage: timespec?
        if let timeout = timeout {
            let sec = Int(timeout)
            let frac = timeout - Double(sec)
            let nsec = min(
                max(Int(frac * 1_000_000_000), 0),
                999_999_999
            )
            tsStorage = timespec(
                tv_sec: time_t(sec),
                tv_nsec: nsec
            )
        }

        let count = try self.unsafe { fd in
            let result = events.withUnsafeMutableBufferPointer { evBuf in
                changes.withUnsafeBufferPointer { chBuf in
                    if var ts = tsStorage {
                        return _kevent_c(
                            fd,
                            chBuf.baseAddress,
                            Int32(chBuf.count),
                            evBuf.baseAddress,
                            Int32(maxEvents),
                            &ts
                        )
                    } else {
                        return _kevent_c(
                            fd,
                            chBuf.baseAddress,
                            Int32(chBuf.count),
                            evBuf.baseAddress,
                            Int32(maxEvents),
                            nil
                        )
                    }
                }
            }

            guard result >= 0 else {
                try BSDError.throwErrno(errno)
            }
            return Int(result)
        }

        return (count, Array(events.prefix(count)))
    }
}
