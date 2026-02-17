/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
@testable import BPC
import Capabilities
import Descriptors

// MARK: - Example Messages

struct PingMessage: Message {
    static let messageType = "ping"
    let timestamp: Date
}

struct PongMessage: Message {
    static let messageType = "pong"
    let originalTimestamp: Date
    let responseTimestamp: Date
}

struct EchoRequest: Message {
    static let messageType = "echo.request"
    let text: String
}

struct EchoResponse: Message {
    static let messageType = "echo.response"
    let echoed: String
}

struct FileTransferRequest: Message {
    static let messageType = "file.transfer"
    let filename: String
    let size: Int
}

struct FileTransferResponse: Message {
    static let messageType = "file.ack"
    let received: Bool
}



// MARK: - Tests

final class BPCTests: XCTestCase {

    func testMessageEnvelopeEncoding() throws {
        let message = PingMessage(timestamp: Date())
        let envelope = try MessageEnvelope(message: message)

        XCTAssertEqual(envelope.messageType, PingMessage.messageType)
        XCTAssertTrue(envelope.descriptors.isEmpty)

        let decoded = try envelope.decode(as: PingMessage.self)
        XCTAssertEqual(decoded.timestamp.timeIntervalSince1970,
                       message.timestamp.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    func testMessageTypeMismatch() throws {
        let message = PingMessage(timestamp: Date())
        let envelope = try MessageEnvelope(message: message)

        XCTAssertThrowsError(try envelope.decode(as: PongMessage.self)) { error in
            guard case BPCError.messageTypeMismatch(let expected, let got) = error else {
                XCTFail("Expected messageTypeMismatch error")
                return
            }
            XCTAssertEqual(expected, PongMessage.messageType)
            XCTAssertEqual(got, PingMessage.messageType)
        }
    }

    func testUnixSocketConnection() async throws {
        let socketPath = "/tmp/bpc-test-\(UUID().uuidString).sock"
        defer {
            try? FileManager.default.removeItem(atPath: socketPath)
        }


        // Create a simple echo handler
        let echoHandler: MessageHandler = { envelope in
            // If it's an echo request, send back a response
            if envelope.messageType == EchoRequest.messageType {
                let request = try envelope.decode(as: EchoRequest.self)
                let response = EchoResponse(echoed: request.text)
                return try MessageEnvelope(message: response)
            }
            return nil
        }

        // Start listener in background
        let listener = try BSDListener.unix(path: socketPath, handler: echoHandler)

        Task {
            try await listener.start()
        }

        // Give listener time to start
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Connect as client
        let connection = try BPCConnection.connect(path: socketPath)

        // Send echo request
        let request = EchoRequest(text: "Hello, BPC!")
        let requestEnvelope = try MessageEnvelope(message: request)

        let responseEnvelope = try await connection.sendAndReceive(requestEnvelope)

        XCTAssertEqual(responseEnvelope.messageType, EchoResponse.messageType)

        let response = try responseEnvelope.decode(as: EchoResponse.self)
        XCTAssertEqual(response.echoed, "Hello, BPC!")

        // Clean up
        await connection.close()
        await listener.stop()
    }

    // func testPingPongPattern() async throws {
    //     let socketPath = "/tmp/bpc-ping-\(UUID().uuidString).sock"
    //     defer {
    //         try? FileManager.default.removeItem(atPath: socketPath)
    //     }

    //     // Ping-pong handler
    //     let pingPongHandler: MessageHandler = { envelope in
    //         if envelope.messageType == PingMessage.messageType {
    //             let ping = try envelope.decode(as: PingMessage.self)
    //             let pong = PongMessage(
    //                 originalTimestamp: ping.timestamp,
    //                 responseTimestamp: Date()
    //             )
    //             return try MessageEnvelope(message: pong)
    //         }
    //         return nil
    //     }

    //     let listener = try BSDListener.unix(path: socketPath, handler: pingPongHandler)

    //     Task {
    //         try await listener.start()
    //     }

    //     try await Task.sleep(nanoseconds: 100_000_000)

    //     let connection = try BSDConnection.connectUnix(path: socketPath)

    //     // Send multiple pings
    //     for _ in 0..<5 {
    //         let ping = PingMessage(timestamp: Date())
    //         let envelope = try MessageEnvelope(message: ping)

    //         let response = try await connection.sendAndReceive(envelope)
    //         let pong = try response.decode(as: PongMessage.self)

    //         XCTAssertTrue(pong.responseTimestamp >= pong.originalTimestamp)
    //     }

    //     await connection.close()
    //     await listener.stop()
    // }

}

