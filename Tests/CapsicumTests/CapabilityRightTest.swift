import XCTest
@testable import Capsicum

final class CapabilityRightTests: XCTestCase {
    func testAllCapabilityRightsHaveValidBridgeValue() {
        for right in CapabilityRight.allCases {
            XCTAssertNotNil(right.bridged)
        }
    }
}
