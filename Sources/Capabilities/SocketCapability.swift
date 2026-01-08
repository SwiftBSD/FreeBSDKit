
import Glibc
import Descriptors
import Foundation
import FreeBSDKit

// TODO: A seperate protocol should be used to describe file operations.
struct SocketCapability: Capability, SocketDescriptor, ~Copyable {
    public typealias RAWBSD = Int32
    private var fd: RAWBSD

    init(_ value: RAWBSD) {
        self.fd = value
    }

    deinit {
        if fd >= 0 {
            Glibc.close(fd)
        }
    }

    consuming func close() {
        if fd >= 0 {
            Glibc.close(fd)
            fd = -1
        }
    }

    consuming func take() -> RAWBSD {
        let rawDescriptor = fd
        fd = -1
        return rawDescriptor
    }

    func unsafe<R>(_ block: (RAWBSD) throws -> R ) rethrows -> R where R: ~Copyable  {
        return try block(fd)
    }
}