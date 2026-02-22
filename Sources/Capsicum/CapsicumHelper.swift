/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import CCapsicum
import Glibc

public enum CapsicumHelper {

    /// Apply basic capability rights to a raw descriptor.
    public static func limit(fd: Int32, rights: CapsicumRightSet) -> Bool {
        var mutable = rights.rawBSD
        return ccapsicum_cap_limit(fd, &mutable) == 0
    }

    /// Limit a stream according to options.
    public static func limitStream(fd: Int32, options: StreamLimitOptions) throws {
        let result = caph_limit_stream(fd, options.rawValue)
        guard result == 0 else {
            let err = errno
            // Ignore ENOSYS (Capsicum not supported on this system)
            if err == ENOSYS {
                return
            }
            throw CapsicumError.errorFromErrno(err)
        }
    }

    /// Limit ioctl commands on a descriptor.
    public static func limitIoctls(fd: Int32, commands: [IoctlCommand]) throws {
        let values = commands.map(\.rawValue)
        var result: Int32 = -1
        var capturedErrno: Int32 = 0

        values.withUnsafeBufferPointer { buffer in
            result = ccapsicum_limit_ioctls(fd, buffer.baseAddress, buffer.count)
            if result == -1 {
                capturedErrno = errno
            }
        }

        guard result != -1 else {
            throw CapsicumError.errorFromErrno(capturedErrno)
        }
    }

    /// Limit fcntl rights.
    public static func limitFcntls(fd: Int32, rights: FcntlRights) throws {
        let res = ccapsicum_limit_fcntls(fd, rights.rawValue)
        guard res == 0 else {
            let err = errno
            switch err {
            case EBADF:       throw CapsicumFcntlError.invalidDescriptor
            case EINVAL:      throw CapsicumFcntlError.invalidFlag
            case ENOTCAPABLE: throw CapsicumFcntlError.notCapable
            default:          throw CapsicumFcntlError.system(errno: err)
            }
        }
    }
    /// Get ioctl limits.
    public static func getIoctls(fd: Int32, maxCount: Int = 32) throws -> [IoctlCommand] {
        var buffer = [CUnsignedLong](repeating: 0, count: maxCount)
        var result: Int = -1
        var capturedErrno: Int32 = 0

        buffer.withUnsafeMutableBufferPointer { ptr in
            result = ccapsicum_get_ioctls(fd, ptr.baseAddress, ptr.count)
            if result < 0 {
                capturedErrno = errno
            }
        }

        guard result >= 0 else {
            switch capturedErrno {
            case EBADF:  throw CapsicumIoctlError.invalidDescriptor
            case EFAULT: throw CapsicumIoctlError.badBuffer
            default:     throw CapsicumIoctlError.system(errno: capturedErrno)
            }
        }

        // CAP_IOCTLS_ALL is SSIZE_MAX - if returned, all ioctls are allowed
        guard result != CAP_IOCTLS_ALL else {
            throw CapsicumIoctlError.allIoctlsAllowed
        }

        return Array(buffer.prefix(Int(result))).map { IoctlCommand(rawValue: $0) }
    }
    /// Get fcntl rights.
    public static func getFcntls(fd: Int32) throws -> FcntlRights {
        var rawMask: UInt32 = 0
        let res = ccapsicum_get_fcntls(fd, &rawMask)
        guard res >= 0 else {
            let err = errno
            throw CapsicumFcntlError.system(errno: err)
        }
        return FcntlRights(rawValue: rawMask)
    }
}
