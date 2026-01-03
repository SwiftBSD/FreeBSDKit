import CProcessDescriptor
import Glibc
import Foundation

struct ProcessDescriptor: Capability, ~Copyable {
    public typealias RAWBSD = Int32
    private var fd: RAWBSD

    init(_ fd: RAWBSD) { self.fd = fd }

    static func fork(flags: Int32 = 0) throws -> ProcessDescriptor {
        var fd: Int32 = 0

        let ret = pdfork(&fd, flags)
        guard ret == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno)!) }

        return ProcessDescriptor(fd)
    }

    deinit { 
        if fd >= 0 { 
            Glibc.close(fd)
        }
    }

    consuming func close() {
        if fd >= 0 { 
            Glibc.close(fd); fd = -1 
        }
    }

    consuming func take() -> RAWBSD {
        let raw = fd; 
        fd = -1; 
        return raw
    }

    func unsafe<R>(_ block: (RAWBSD) throws -> R) rethrows -> R {
        return try block(fd)
    }

    /// Waits for the process to exit using `waitpid` on the PID
    func wait() throws -> Int32 {
        let pid = try getPID()
        var status: Int32 = 0
        let ret = Glibc.waitpid(pid, &status, 0)
        guard ret >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno)!) }
        return status
    }

    func kill(signal: Int32) throws {
        guard pdkill(fd, signal) >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno)!) }
    }

    func getPID() throws -> pid_t {
        var pid: pid_t = 0
        let ret = pdgetpid(fd, &pid)
        guard ret >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno)!) }
        return pid
    }
}
