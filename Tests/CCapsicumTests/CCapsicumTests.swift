import XCTest
@testable import CCapsicum

final class CCapsicumTests: XCTestCase {
    
    func testRightsInitSetClear() {
        var rights = cap_rights_t()
        
        // Initialize
        ccapsicum_rights_init(&rights)
        XCTAssertTrue(ccapsicum_rights_valid(&rights))
        
        // Set a right
        ccapsicum_cap_set(&rights, CCAP_RIGHT_READ)
        XCTAssertTrue(ccapsicum_right_is_set(&rights, CCAP_RIGHT_READ))
        
        // Clear the right
        ccapsicum_rights_clear(&rights, CCAP_RIGHT_READ)
        XCTAssertFalse(ccapsicum_right_is_set(&rights, CCAP_RIGHT_READ))
    }
    
    func testRightsMergeContains() {
        var a = cap_rights_t()
        var b = cap_rights_t()
        
        ccapsicum_rights_init(&a)
        ccapsicum_rights_init(&b)
        
        ccapsicum_cap_set(&a, CCAP_RIGHT_READ)
        ccapsicum_cap_set(&b, CCAP_RIGHT_WRITE)
        
        ccapsicum_cap_rights_merge(&a, &b)
        
        XCTAssertTrue(ccapsicum_right_is_set(&a, CCAP_RIGHT_READ))
        XCTAssertTrue(ccapsicum_right_is_set(&a, CCAP_RIGHT_WRITE))
        XCTAssertTrue(ccapsicum_rights_contains(&a, &b))
    }
    
    func testRightsRemove() {
        var a = cap_rights_t()
        var b = cap_rights_t()
        
        ccapsicum_rights_init(&a)
        ccapsicum_rights_init(&b)
        
        ccapsicum_cap_set(&a, CCAP_RIGHT_READ)
        ccapsicum_cap_set(&a, CCAP_RIGHT_WRITE)
        ccapsicum_cap_set(&b, CCAP_RIGHT_WRITE)
        
        ccapsicum_rights_remove(&a, &b)
        
        XCTAssertTrue(ccapsicum_right_is_set(&a, CCAP_RIGHT_READ))
        XCTAssertFalse(ccapsicum_right_is_set(&a, CCAP_RIGHT_WRITE))
    }
    
   func testLimitFcntlsAndIoctls() throws {
        var pipeFDs: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&pipeFDs), 0)

        let readFD = pipeFDs[0]
        let writeFD = pipeFDs[1]
        defer {
            close(readFD)
            close(writeFD)
        }

        XCTAssertEqual(ccapsicum_limit_fcntls(readFD, UInt32(CAP_FCNTL_GETFL)), 0)

        try cap_enter()

        // Allowed
        XCTAssertNotEqual(fcntl(readFD, F_GETFL), -1)

        // Forbidden
        XCTAssertEqual(fcntl(readFD, F_SETFL, O_NONBLOCK), -1)
        XCTAssertEqual(errno, ENOTCAPABLE)
    }
}
