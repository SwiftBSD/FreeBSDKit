/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Foundation
import FreeBSDKit

/// Utilities for querying socket size limits from the operating system.
public enum SocketLimits {

    /// Returns the maximum SEQPACKET message size from the kernel.
    ///
    /// Queries `net.local.seqpacket.maxseqpacket` sysctl to get the maximum
    /// message size for Unix-domain SEQPACKET sockets. Falls back to a
    /// conservative 64KB if the query fails.
    ///
    /// - Returns: Maximum message size in bytes (typically 65536)
    public static func maxSeqpacketSize() -> Int {
        do {
            let value: Int32 = try BSDSysctl.get("net.local.seqpacket.maxseqpacket")
            return Int(value)
        } catch {
            // Fallback to conservative default if sysctl fails
            return 65536
        }
    }

    /// Returns the maximum datagram size from the kernel.
    ///
    /// Queries `net.local.dgram.maxdgram` sysctl to get the maximum
    /// message size for Unix-domain DATAGRAM sockets. Falls back to a
    /// conservative 8KB if the query fails.
    ///
    /// - Returns: Maximum datagram size in bytes (typically 8192)
    public static func maxDatagramSize() -> Int {
        do {
            let value: Int32 = try BSDSysctl.get("net.local.dgram.maxdgram")
            return Int(value)
        } catch {
            // Fallback to conservative default if sysctl fails
            return 8192
        }
    }
}
