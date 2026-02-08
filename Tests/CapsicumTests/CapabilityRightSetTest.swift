/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import XCTest
import CCapsicum
@testable import Capsicum

final class CapsicumRightSetTests: XCTestCase {

    // MARK: - Single Rights

    func testAddingSingleRight() {
        var set = CapsicumRightSet()
        set.add(capability: .read)
        
        XCTAssertTrue(set.contains(capability: .read))
        XCTAssertFalse(set.contains(capability: .write))
    }

    func testRemovingSingleRight() {
        var set = CapsicumRightSet(rights: [.read, .write])
        set.clear(capability: .read)
        
        XCTAssertFalse(set.contains(capability: .read))
        XCTAssertTrue(set.contains(capability: .write))
    }

    // MARK: - Multiple Rights

    func testAddingMultipleRights() {
        var set = CapsicumRightSet()
        set.add(capabilities: [.read, .write, .seek])
        
        XCTAssertTrue(set.contains(capability: .read))
        XCTAssertTrue(set.contains(capability: .write))
        XCTAssertTrue(set.contains(capability: .seek))
        XCTAssertFalse(set.contains(capability: .accept))
    }


    func testRemovingMultipleRights() {
        var set = CapsicumRightSet(rights: [.read, .write, .seek])
        set.clear(capabilities: [.read, .seek])
        
        XCTAssertFalse(set.contains(capability: .read))
        XCTAssertTrue(set.contains(capability: .write))
        XCTAssertFalse(set.contains(capability: .seek))
    }

    // MARK: - Merging Sets

    func testMergeSets() {
        var set1 = CapsicumRightSet(rights: [.read, .write])
        let set2 = CapsicumRightSet(rights: [.seek, .accept])
        
        set1.merge(with: set2)
        
        XCTAssertTrue(set1.contains(capability: .read))
        XCTAssertTrue(set1.contains(capability: .write))
        XCTAssertTrue(set1.contains(capability: .seek))
        XCTAssertTrue(set1.contains(capability: .accept))
    }

    func testRemoveMatchingSet() {
        var set1 = CapsicumRightSet(rights: [.read, .write, .seek])
        let set2 = CapsicumRightSet(rights: [.write, .seek])
        
        set1.remove(matching: set2)
        
        XCTAssertTrue(set1.contains(capability: .read))
        XCTAssertFalse(set1.contains(capability: .write))
        XCTAssertFalse(set1.contains(capability: .seek))
    }

    // MARK: - Validation

    func testValidation() {
        var set = CapsicumRightSet(rights: [.read, .write])
        XCTAssertTrue(set.validate())
    }

    // MARK: - Copying / Containment

    func testContainsOtherSet() {
        let set1 = CapsicumRightSet(rights: [.read, .write, .seek])
        let set2 = CapsicumRightSet(rights: [.write, .seek])
        
        XCTAssertTrue(set1.contains(right: set2))
        
        let set3 = CapsicumRightSet(rights: [.write, .accept])
        XCTAssertFalse(set1.contains(right: set3))
    }

    func testInitFromArray() {
        let set = CapsicumRightSet(rights: [.read, .write, .seek])
        
        XCTAssertTrue(set.contains(capability: .read))
        XCTAssertTrue(set.contains(capability: .write))
        XCTAssertTrue(set.contains(capability: .seek))
        XCTAssertFalse(set.contains(capability: .accept))
    }

    func testInitFromOtherSet() {
        let original = CapsicumRightSet(rights: [.read, .write])
        let copy = CapsicumRightSet(from: original)
        
        XCTAssertTrue(copy.contains(capability: .read))
        XCTAssertTrue(copy.contains(capability: .write))
    }

    func testInitWithRawRights() {
        // Create a raw cap_rights_t and add a right manually
        var rawRights = cap_rights_t()
        ccapsicum_rights_init(&rawRights)
        ccapsicum_cap_set(&rawRights, CapsicumRight.read.bridged)
        ccapsicum_cap_set(&rawRights, CapsicumRight.write.bridged)
        
        // Initialize CapsicumRightSet with the raw struct
        let set = CapsicumRightSet(rights: rawRights)
        
        // Assert that the rights are present
        XCTAssertTrue(set.contains(capability: .read))
        XCTAssertTrue(set.contains(capability: .write))
        XCTAssertFalse(set.contains(capability: .seek))
    }

    func testTakeReturnsUnderlyingRights() {
        var set = CapsicumRightSet()
        set.add(capability: .read)
        set.add(capability: .write)
        
        let raw = set.rawBSD
        
        // Create a new set from the raw struct and check it contains same rights
        let newSet = CapsicumRightSet(rights: raw)
        XCTAssertTrue(newSet.contains(capability: .read))
        XCTAssertTrue(newSet.contains(capability: .write))
        XCTAssertFalse(newSet.contains(capability: .seek))
    }
}