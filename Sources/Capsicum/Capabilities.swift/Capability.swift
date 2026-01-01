import CCapsicum

public enum Capability: CaseIterable {
    case read
    case write
    case seek

    @inline(__always)
    var cValue: ccapsicum_right_map {
        switch self {
        case .read:  return CCAP_RIGHT_READ
        case .write: return CCAP_RIGHT_WRITE
        case .seek:  return CCAP_RIGHT_SEEK
        }
    }
}