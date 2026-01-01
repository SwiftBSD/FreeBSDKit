import CCapsicum
import Glibc

public enum CapsicumError: Error {
    /// Thrown when the system is not compiled with Capsicum support.
    case capsicumUnsupported
}

public struct IoctlCommand {
    public let rawValue: UInt
}

public enum CapsicumIoctlError: Error {
    /// The file descriptor is invalid (EBADF).
    case invalidDescriptor
    
    /// The commands buffer pointer was invalid (EFAULT).
    case badBuffer
    
    /// The buffer was too small for the allowed ioctl list.
    case insufficientBuffer(expected: Int)
    
    /// All ioctls are explicitly allowed (no limit applied).
    case allIoctlsAllowed
    
    /// Some other underlying errno error.
    case system(errno: Int32)
}


public struct FcntlRights: OptionSet {
    public let rawValue: UInt32
    // The API calls for unsigned types.
    public static let getFlags = FcntlRights(rawValue: UInt32(CAP_FCNTL_GETFL))
    public static let setFlags = FcntlRights(rawValue: UInt32(CAP_FCNTL_SETFL))
    public static let getOwner = FcntlRights(rawValue: UInt32(CAP_FCNTL_GETOWN))
    public static let setOwner = FcntlRights(rawValue: UInt32(CAP_FCNTL_SETOWN))

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}


/// An interface for FreeBSD Capsicum.
/// man: capsicum
public enum Capsicum {
    /// Enters capability mode.
    /// `man cap_enter`
    public static func enter() throws {
        guard cap_enter() == 0 else {
            throw CapsicumError.capsicumUnsupported
        }
    }
    /// Returns `true` if the process is in Capability mode.
    /// `man cap_getmode`
    public static func status() throws -> Bool {
        var mode: UInt32 = 0
        guard cap_getmode(&mode) == 0 else {
            throw CapsicumError.capsicumUnsupported
        }
        return mode == 1
    }
    // TODO: Integrate with common Swift file representations
    public static func limit(fd: Int32, rights: CapabilityRightSet) -> Bool {
        var cRights = rights.asCapRightsT()
        return ccapsicum_cap_limit(fd, &cRights) == 0
    }

    public static func limitIoctls(fd: Int32, commands: [IoctlCommand]) -> Int32 {
        let values = commands.map { $0.rawValue }
        return values.withUnsafeBufferPointer { cmdArray in
            ccapsicum_limit_ioctls(fd, cmdArray.baseAddress, cmdArray.count)
        }
    }

    public static func limitFcntls(fd: Int32, rights: FcntlRights) -> Int32 {
        return ccapsicum_limit_fcntls(fd, rights.rawValue)
    }

    /// Fetch the allowed ioctl commands for a descriptor.
    /// - Parameters:
    ///   - fd: The file descriptor to query.
    ///   - maxCount: A buffer size hint for the maximum number of ioctl commands to fetch.
    /// - Throws: `CapsicumIoctlError` on failure or special conditions.
    /// - Returns: An array of `IoctlCommand` representing allowed ioctl requests.
    public static func getIoctls(fd: Int32, maxCount: Int = 32) throws -> [IoctlCommand] {
        // Prepare a local buffer for up to maxCount values
        var rawBuffer = [UInt](repeating: 0, count: maxCount)
        
        // Call the C wrapper for cap_ioctls_get
        let result = ccapsicum_get_ioctls(fd, &rawBuffer, rawBuffer.count)
        
        // Check for errors (‑1, with errno set)
        if result < 0 {
            switch errno {
            case EBADF:
                throw CapsicumIoctlError.invalidDescriptor
            case EFAULT:
                throw CapsicumIoctlError.badBuffer
            default:
                throw CapsicumIoctlError.system(errno: errno)
            }
        }
        
        // If all ioctls are allowed, C returns the special constant CAP_IOCTLS_ALL.
        // On FreeBSD, CAP_IOCTLS_ALL is returned when cap_ioctls_limit was never called
        // on this descriptor. :contentReference[oaicite:1]{index=1}
        if result == CAP_IOCTLS_ALL {
            throw CapsicumIoctlError.allIoctlsAllowed
        }
        
        // result is the actual number of allowed ioctls
        let count = Int(result)
        
        // If count is larger than our buffer, the buffer was insufficient
        // According to manpage, cap_ioctls_get always returns the total number
        // allowed, even if greater than maxcmds. :contentReference[oaicite:2]{index=2}
        if count > rawBuffer.count {
            throw CapsicumIoctlError.insufficientBuffer(expected: count)
        }
        
        // Map the raw values into typed IoctlCommand
        let allowedCommands: [IoctlCommand] = rawBuffer.prefix(count).map {
            IoctlCommand(rawValue: $0)
        }
        
        return allowedCommands
    }
  

    /// Query the current fcntl rights bitmask for a descriptor.
    ///
    /// - Parameter fd: The file descriptor whose fcntl rights to read.
    /// - Returns: A FcntlRights bitmask of allowed fcntl operations,
    ///            or nil on error (check errno).
    public static func getFcntls(fd: Int32) -> FcntlRights? {
        var rawMask: UInt32 = 0
        let result = ccapsicum_get_fcntls(fd, &rawMask)

        guard result >= 0 else {
            return nil
        }
        return FcntlRights(rawValue: rawMask)
    }
}