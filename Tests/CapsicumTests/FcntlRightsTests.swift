//
//  FcntlRightsTests.swift
//  FreeBSDKitTests
//
//  Created by Kory Heard on 2026-01-03.
//

import XCTest
@testable import Capsicum
@testable import CCapsicum

final class FcntlRightsTests: XCTestCase {

    // MARK: - Single Flag Initialization
    func testSingleFlagInitialization() {
        let rights = FcntlRights.getFlags
        XCTAssertEqual(rights.rawValue, UInt32(CAP_FCNTL_GETFL))
        
        let ownerRights = FcntlRights.setOwner
        XCTAssertEqual(ownerRights.rawValue, UInt32(CAP_FCNTL_SETOWN))
    }

    // MARK: - Combining Flags
    func testCombiningFlags() {
        let rights: FcntlRights = [.getFlags, .setFlags]
        XCTAssertTrue(rights.contains(.getFlags))
        XCTAssertTrue(rights.contains(.setFlags))
        XCTAssertFalse(rights.contains(.getOwner))
    }

    // MARK: - OptionSet Operations
    func testOptionSetOperations() {
        var rights: FcntlRights = []
        XCTAssertFalse(rights.contains(.getOwner))
        
        rights.insert(.getOwner)
        XCTAssertTrue(rights.contains(.getOwner))
        
        rights.remove(.getOwner)
        XCTAssertFalse(rights.contains(.getOwner))
        
        rights.formUnion([.getFlags, .setOwner])
        XCTAssertTrue(rights.contains(.getFlags))
        XCTAssertTrue(rights.contains(.setOwner))
        
        rights.subtract([.getFlags])
        XCTAssertFalse(rights.contains(.getFlags))
        XCTAssertTrue(rights.contains(.setOwner))
    }

    // MARK: - Raw Value Round-Trip
    func testRawValueRoundTrip() {
        let raw: UInt32 = UInt32(CAP_FCNTL_GETFL | CAP_FCNTL_SETOWN)
        let rights = FcntlRights(rawValue: raw)
        XCTAssertTrue(rights.contains(.getFlags))
        XCTAssertTrue(rights.contains(.setOwner))
        XCTAssertFalse(rights.contains(.setFlags))
        XCTAssertFalse(rights.contains(.getOwner))
    }
}
