/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Foundation
import Descriptors
import Capabilities

// MARK: - BPCClient Protocol

/// A protocol for connecting to BPC servers and obtaining endpoints.
///
/// Conforming types handle the connection establishment and socket creation,
/// then return a configured ``BSDEndpoint`` ready for use.
public protocol BPCClient {
    /// Connects to a BPC server and returns a configured endpoint.
    ///
    /// - Parameters:
    ///   - path: The Unix-domain socket path to connect to
    ///   - ioQueue: Optional custom DispatchQueue for I/O operations
    /// - Returns: A new, unstarted ``BSDEndpoint``. Call ``start()`` before use.
    /// - Throws: A system error if the connection fails
    static func connect(path: String, ioQueue: DispatchQueue?) throws -> BSDEndpoint
}

// MARK: - BSDClient

/// A BPC client that connects to SEQPACKET servers.
///
/// This client establishes a connection-oriented, message-boundary-preserving
/// Unix-domain socket connection and returns a ``BSDEndpoint`` for communication.
///
/// ## Example
/// ```swift
/// let endpoint = try BSDClient.connect(path: "/tmp/bpc.sock")
/// await endpoint.start()
/// try await endpoint.send(message)
/// ```
public struct BSDClient: BPCClient {

    /// Connects to a SEQPACKET BPC server.
    ///
    /// Creates a Unix-domain SEQPACKET socket, connects to the server at the given
    /// path, and returns a ``BSDEndpoint`` wrapping the connected socket.
    ///
    /// - Parameters:
    ///   - path: The filesystem path of the server's socket
    ///   - ioQueue: Optional custom DispatchQueue for I/O operations. If `nil`, a default queue is created.
    /// - Returns: A new, unstarted ``BSDEndpoint``. Call ``start()`` before use.
    /// - Throws: A system error if the socket cannot be created or the connection is refused
    public static func connect(path: String, ioQueue: DispatchQueue? = nil) throws -> BSDEndpoint {
        let socket = try SocketCapability.socket(
            domain: .unix,
            type: [.seqpacket, .cloexec],
            protocol: .default
        )
        let address = try UnixSocketAddress(path: path)
        try socket.connect(address: address)
        return BSDEndpoint(socket: socket, ioQueue: ioQueue)
    }
}
