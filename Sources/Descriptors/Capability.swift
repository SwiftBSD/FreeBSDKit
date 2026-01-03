import Capsicum
import CCapsicum
import Glibc
import FreeBSDKit

protocol Capability: Descriptor, ~Copyable {}

extension Capability {
    // MARK: — Limiting Rights

    /// Applies a set of capability rights to a given file descriptor.
    ///
    /// - Parameter rights: A `CapabilityRightSet` representing the rights to permit.
    /// - Returns: `true` if the rights were successfully applied; `false` on failure.
    public func limit(rights: CapabilityRightSet) -> Bool {
        var mutableRights: cap_rights_t = cap_rights_t()
        rights.unsafe { borrowedRights in
            mutableRights = borrowedRights
        }

        return self.unsafe { fd in
            return ccapsicum_cap_limit(fd, &mutableRights) == 0
        }
    }


    /// Restricts the set of permitted ioctl commands for a file descriptor.
    ///
    /// - Parameter commands: A list of ioctl codes (`IoctlCommand`) to permit.
    /// - Throws: `CapsicumError` if the underlying call fails.
    public func limitIoctls(commands: [IoctlCommand]) throws {
        let values = commands.map { $0.rawValue }

        // Borrow descriptor
        let result: Int32 = self.unsafe { fd in
            values.withUnsafeBufferPointer { cmdArray in
                ccapsicum_limit_ioctls(fd, cmdArray.baseAddress, cmdArray.count)
            }
        }

        // Check for errors
        guard result != -1 else {
            throw CapsicumError.errorFromErrno(errno)
        }
    }


    /// Restricts the permitted `fcntl(2)` commands on a file descriptor.
    ///
    /// - Parameters:
    ///   - rights: An OptionSet of allowed fcntl commands.
    /// - Throws: `CapsicumFcntlError` on failure.
    public func limitFcntls(rights: FcntlRights) throws {
        let result: Int32 = self.unsafe { fd in
            ccapsicum_limit_fcntls(fd, rights.rawValue)
        }

        guard result == 0 else {
            switch errno {
            case EBADF:
                throw CapsicumFcntlError.invalidDescriptor
            case EINVAL:
                throw CapsicumFcntlError.invalidFlag
            case ENOTCAPABLE:
                throw CapsicumFcntlError.notCapable
            default:
                throw CapsicumFcntlError.system(errno: errno)
            }
        }
    }

    // MARK: — Querying Limits

    /// Fetches the set of currently allowed ioctl commands for a descriptor.
    ///
    /// - Parameter maxCount: A buffer size hint for how many commands to buffer.
    /// - Throws: `CapsicumIoctlError` for invalid descriptors, bad buffers,
    ///   insufficient buffer size, “all allowed” state, or other errno conditions.
    /// - Returns: An array of permitted `IoctlCommand` values.
    public func getIoctls(maxCount: Int = 32) throws -> [IoctlCommand] {
        var rawBuffer = [UInt](repeating: 0, count: maxCount)
        var result: Int = -1

        // Step 1: borrow the descriptor
        self.unsafe { fd in
            // Step 2: safely access the array memory
            rawBuffer.withUnsafeMutableBufferPointer { bufPtr in
                // C function returns Int32
                result = ccapsicum_get_ioctls(fd, bufPtr.baseAddress, bufPtr.count)
            }
        }

        // Step 3: handle errors
        guard result >= 0 else {
            switch errno {
            case EBADF:   throw CapsicumIoctlError.invalidDescriptor
            case EFAULT:  throw CapsicumIoctlError.badBuffer
            default:      throw CapsicumIoctlError.system(errno: errno)
            }
        }

        guard result != CAP_IOCTLS_ALL else {
            throw CapsicumIoctlError.allIoctlsAllowed
        }

        let count = Int(result)
        guard count <= rawBuffer.count else {
            throw CapsicumIoctlError.insufficientBuffer(expected: count)
        }

        return rawBuffer.prefix(count).map { IoctlCommand(rawValue: $0) }
    }

    /// Retrieves the currently permitted `fcntl` rights mask on a descriptor.
    ///
    /// - Returns: A `FcntlRights` bitmask describing the allowed commands, or `nil` if the query fails.
    public func getFcntls() -> FcntlRights? {
        var rawMask: UInt32 = 0

        // Borrow the descriptor safely for the duration of the call
        let result: Int32 = self.unsafe { fd in
            ccapsicum_get_fcntls(fd, &rawMask)
        }

        // If the call failed, return nil
        guard result >= 0 else {
            return nil
        }

        return FcntlRights(rawValue: rawMask)
    }
}