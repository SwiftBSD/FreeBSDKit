/*
 * Copyright (c) 2026 Kory Heard
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
 
import Glibc
import Foundation
import FreeBSDKit

// MARK: - InotifyDescriptor (owning kernel resource)

public struct InotifyDescriptor: BSDResource, ~Copyable {

    public typealias RAWBSD = Int32
    private var fd: Int32

    public init(flags: Int32 = 0) throws {
        let raw = (flags == 0)
            ? Glibc.inotify_init()
            : Glibc.inotify_init1(flags)

        guard raw >= 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }
        self.fd = raw
    }

    public func unsafe<R>(
        _ block: (Int32) throws -> R
    ) rethrows -> R where R: ~Copyable {
        try block(fd)
    }

    public consuming func take() -> Int32 {
        let raw = fd
        fd = -1
        return raw
    }

    public consuming func close() {
        if fd >= 0 {
            _ = Glibc.close(fd)
            fd = -1
        }
    }
}

// MARK: - Watch Descriptor

public struct InotifyWatch: BSDValue, Hashable, Sendable {
    public typealias RAWBSD = Int32
    public let rawBSD: Int32
}

// MARK: - Event Mask

public struct InotifyEventMask: OptionSet, BSDValue, Sendable {

    public typealias RAWBSD = UInt32
    public let rawValue: UInt32
    public var rawBSD: UInt32 { rawValue }

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    @inline(__always)
    private static func flag(_ v: Int32) -> UInt32 {
        UInt32(bitPattern: v)
    }

    public static let access        = Self(rawValue: flag(IN_ACCESS))
    public static let attrib        = Self(rawValue: flag(IN_ATTRIB))
    public static let modify        = Self(rawValue: flag(IN_MODIFY))
    public static let closeWrite    = Self(rawValue: flag(IN_CLOSE_WRITE))
    public static let closeNoWrite  = Self(rawValue: flag(IN_CLOSE_NOWRITE))
    public static let open          = Self(rawValue: flag(IN_OPEN))
    public static let movedFrom     = Self(rawValue: flag(IN_MOVED_FROM))
    public static let movedTo       = Self(rawValue: flag(IN_MOVED_TO))
    public static let create        = Self(rawValue: flag(IN_CREATE))
    public static let delete        = Self(rawValue: flag(IN_DELETE))
    public static let deleteSelf    = Self(rawValue: flag(IN_DELETE_SELF))
    public static let moveSelf      = Self(rawValue: flag(IN_MOVE_SELF))

    public static let ignored       = Self(rawValue: flag(IN_IGNORED))
    public static let isDir         = Self(rawValue: flag(IN_ISDIR))
    public static let queueOverflow = Self(rawValue: flag(IN_Q_OVERFLOW))
    public static let unmount       = Self(rawValue: flag(IN_UNMOUNT))
}

// MARK: - Decoded Event

public struct InotifyEvent: Sendable {
    public let watch: InotifyWatch
    public let mask: InotifyEventMask
    public let cookie: UInt32
    public let name: String?
}

// MARK: - Watch Management

public extension InotifyDescriptor {

    func addWatch(
        path: String,
        mask: InotifyEventMask
    ) throws -> InotifyWatch {

        return try self.unsafe { (fd: Int32) -> InotifyWatch in
            let wd = path.withCString {
                Glibc.inotify_add_watch(fd, $0, mask.rawBSD)
            }
            guard wd >= 0 else {
                throw POSIXError(POSIXErrorCode(rawValue: errno)!)
            }
            return InotifyWatch(rawBSD: wd)
        }
    }

    func addWatch(
        directoryFD: Int32,
        path: String,
        mask: InotifyEventMask
    ) throws -> InotifyWatch {

        return try self.unsafe { (fd: Int32) -> InotifyWatch in
            let wd = path.withCString {
                Glibc.inotify_add_watch_at(fd, directoryFD, $0, mask.rawBSD)
            }
            guard wd >= 0 else {
                throw POSIXError(POSIXErrorCode(rawValue: errno)!)
            }
            return InotifyWatch(rawBSD: wd)
        }
    }

    func removeWatch(_ watch: InotifyWatch) throws {
        try self.unsafe { (fd: Int32) -> Void in
            guard Glibc.inotify_rm_watch(fd, watch.rawBSD) == 0 else {
                throw POSIXError(POSIXErrorCode(rawValue: errno)!)
            }
        }
    }
}

// MARK: - Reading Events

public extension InotifyDescriptor {

    func readEvents(maxBytes: Int = 4096) throws -> [InotifyEvent] {

        return try self.unsafe { (fd: Int32) -> [InotifyEvent] in
            var buffer = [UInt8](repeating: 0, count: maxBytes)

            let n = buffer.withUnsafeMutableBytes {
                Glibc.read(fd, $0.baseAddress, maxBytes)
            }

            guard n >= 0 else {
                throw POSIXError(POSIXErrorCode(rawValue: errno)!)
            }

            var events: [InotifyEvent] = []
            var offset = 0

            buffer.withUnsafeBytes { ptr in
                while offset < n {
                    let base = ptr.baseAddress!.advanced(by: offset)
                    let ev = base
                        .assumingMemoryBound(to: inotify_event.self)
                        .pointee

                    let namePtr = base
                        .advanced(by: MemoryLayout<inotify_event>.size)
                        .assumingMemoryBound(to: UInt8.self)

                    let name =
                        ev.len > 0
                        ? String(
                            bytesNoCopy: UnsafeMutableRawPointer(mutating: namePtr),
                            length: Int(ev.len) - 1,
                            encoding: .utf8,
                            freeWhenDone: false
                        )
                        : nil

                    events.append(
                        InotifyEvent(
                            watch: InotifyWatch(rawBSD: ev.wd),
                            mask: InotifyEventMask(rawValue: ev.mask),
                            cookie: ev.cookie,
                            name: name
                        )
                    )

                    offset += MemoryLayout<inotify_event>.size + Int(ev.len)
                }
            }

            return events
        }
    }
}