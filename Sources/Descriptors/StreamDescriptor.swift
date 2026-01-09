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

/// A generic stream descriptor (read/write)
public protocol StreamDescriptor: ReadWriteDescriptor, ~Copyable {
    func send(_ data: Data, flags: Int32) throws -> Int
    func recv(count: Int, flags: Int32) throws -> Data
}

// TODO: 
public extension StreamDescriptor where Self: ~Copyable {
    /// Default send implementation using the unsafe fd
    func send(_ data: Data, flags: Int32 = 0) throws -> Int {
        return try self.unsafe { fd in
            let bytesSent = data.withUnsafeBytes { ptr in
                Glibc.send(fd, ptr.baseAddress, ptr.count, flags)
            }
            if bytesSent == -1 { throw POSIXError(POSIXErrorCode(rawValue: errno)!) }
            return bytesSent
        }
    }

    /// Default recv implementation using the unsafe fd
    func recv(count: Int, flags: Int32 = 0) throws -> Data {
        var buffer = Data(count: count)
        let n = try self.unsafe { fd in
            let bytesRead = buffer.withUnsafeMutableBytes { ptr in
                Glibc.recv(fd, ptr.baseAddress, count, flags)
            }
            if bytesRead == -1 { throw POSIXError(POSIXErrorCode(rawValue: errno)!) }
            return bytesRead
        }
        buffer.removeSubrange(n..<buffer.count)
        return buffer
    }
}

