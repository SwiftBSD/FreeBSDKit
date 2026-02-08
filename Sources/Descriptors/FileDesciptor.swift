/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Glibc
import Foundation
import FreeBSDKit

public protocol FileDescriptor: ReadWriteDescriptor, ~Copyable {
    func seek(offset: off_t, whence: Int32) throws -> off_t
    func pread(count: Int, offset: off_t) throws -> Data
    func pwrite(_ data: Data, offset: off_t) throws -> Int
    func truncate(to length: off_t) throws
    func sync() throws
}

public extension FileDescriptor where Self: ~Copyable {

    func seek(offset: off_t, whence: Int32) throws -> off_t {
        try self.unsafe { fd in
            while true {
                let pos = Glibc.lseek(fd, offset, whence)
                if pos != -1 { return pos }
                if errno == EINTR { continue }
                try BSDError.throwErrno(errno)
            }
        }
    }

    func pread(count: Int, offset: off_t) throws -> Data {
        var buffer = Data(count: count)

        let n = self.unsafe { fd in
            buffer.withUnsafeMutableBytes { ptr in
                while true {
                    let r = Glibc.pread(fd, ptr.baseAddress, ptr.count, offset)
                    if r != -1 { return r }
                    if errno == EINTR { continue }
                    return -1
                }
            }
        }

        if n == -1 {
            try BSDError.throwErrno(errno)
        }

        buffer.removeSubrange(n..<buffer.count)
        return buffer
    }

    func pwrite(_ data: Data, offset: off_t) throws -> Int {
        try self.unsafe { fd in
            let n = data.withUnsafeBytes { ptr in
                while true {
                    let r = Glibc.pwrite(fd, ptr.baseAddress, ptr.count, offset)
                    if r != -1 { return r }
                    if errno == EINTR { continue }
                    return -1
                }
            }

            if n == -1 {
                try BSDError.throwErrno(errno)
            }

            return n
        }
    }

    func truncate(to length: off_t) throws {
        try self.unsafe { fd in
            while true {
                let r = Glibc.ftruncate(fd, length)
                if r == 0 { return }
                if errno == EINTR { continue }
                try BSDError.throwErrno(errno)
            }
        }
    }

    func sync() throws {
        try self.unsafe { fd in
            while true {
                let r = Glibc.fsync(fd)
                if r == 0 { return }
                if errno == EINTR { continue }
                try BSDError.throwErrno(errno)
            }
        }
    }
}
