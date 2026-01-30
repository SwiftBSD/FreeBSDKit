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

import CJails
import Glibc

// Safe builder for `jail_set` / `jail_get` iovecs.
///
/// All pointer unsafety is contained inside this type.
/// 
/// 


public struct JailIOVector {

    public var iovecs: [iovec] = []
    fileprivate var backing: [Any] = []

    public init() {}

    /// Add a C-string parameter.
    public mutating func addCString(
        _ name: String,
        value: String
    ) {
        let key = strdup(name)
        let val = strdup(value)

        backing.append(key!)
        backing.append(val!)

        let keyVec = iovec(
            iov_base: UnsafeMutableRawPointer(key),
            iov_len: name.utf8.count + 1
        )

        let valueVec = iovec(
            iov_base: UnsafeMutableRawPointer(val),
            iov_len: value.utf8.count + 1
        )

        iovecs.append(keyVec)
        iovecs.append(valueVec)
    }
}

public extension JailIOVector {

    mutating func addInt32(_ name: String, _ value: Int32) {
        addRaw(name: name, value: value)
    }

    mutating func addUInt32(_ name: String, _ value: UInt32) {
        addRaw(name: name, value: value)
    }

    mutating func addInt64(_ name: String, _ value: Int64) {
        addRaw(name: name, value: value)
    }

    mutating func addBool(_ name: String, _ value: Bool) {
        let v: Int32 = value ? 1 : 0
        addRaw(name: name, value: v)
    }

    // MARK: - Internal raw helper (the only unsafe part)

    private mutating func addRaw<T>(
        name: String,
        value: T
    ) {
        precondition(MemoryLayout<T>.stride == MemoryLayout<T>.size,
                     "Type must be POD")

        let key = strdup(name)!
        let val = UnsafeMutablePointer<T>.allocate(capacity: 1)
        val.initialize(to: value)

        backing.append(key)
        backing.append(val)

        let keyVec = iovec(
            iov_base: UnsafeMutableRawPointer(key),
            iov_len: name.utf8.count + 1
        )

        let valueVec = iovec(
            iov_base: UnsafeMutableRawPointer(val),
            iov_len: MemoryLayout<T>.size
        )

        iovecs.append(keyVec)
        iovecs.append(valueVec)
    }
}