import XCTest
@testable import Capsicum

final class CapsicumHelperTests: XCTestCase {

    func testCacheTZDataDoesNotCrash() {
        Capsicum.cacheTZData()
        // Nothing to assert, just ensuring no crash
    }

    func testCacheCatPagesDoesNotCrash() {
        Capsicum.cacheCatPages()
        // Again, safe to call
    }
}
