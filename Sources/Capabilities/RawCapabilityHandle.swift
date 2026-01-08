import Glibc
import Descriptors
import Foundation
import FreeBSDKit

/// A reusable noncopyable owner of a raw Int32 descriptor.
public struct RawCapabilityHandle: Sendable, ~Copyable {
    fileprivate var fd: Int32

    /// Create from a raw descriptor.
    public init(_ raw: Int32) {
        self.fd = raw
    }

    /// Always close on destruction if not already closed.
    deinit {
        if fd >= 0 {
            Glibc.close(fd)
        }
    }

    /// Close the descriptor if it hasn’t been closed already.
    public consuming func close() {
        if fd >= 0 {
            Glibc.close(fd)
            fd = -1
        }
    }

    /// Take and return the raw descriptor, leaving this handle invalidated.
    public consuming func take() -> Int32 {
        let raw = fd
        fd = -1
        return raw
    }

    /// Temporarily borrow the raw descriptor for performing actions on it.
    public func unsafe<R>(_ body: (Int32) throws -> R) rethrows -> R where R: ~Copyable {
        return try body(fd)
    }
}
