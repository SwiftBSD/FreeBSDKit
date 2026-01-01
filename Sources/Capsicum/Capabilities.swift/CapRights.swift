import CCapsicum

/// CapabilityRights
public struct CapRight {
    private var rights: cap_rights_t

    /// Initialize from a cap_rights_t.
    public init(from rights: cap_rights_t) {
        self.rights = rights
    }
    /// Initialize from an array of `Capability`.
    public init(with capabilities: [Capability]) {
        self.rights = {
            var r = cap_rights_t()
            ccapsicum_rights_init(&r)
            for cap in capabilities {
                switch cap {
                case .read:
                    ccaspsicum_cap_set(&r, CCAP_RIGHT_READ)
                case .write:
                    ccaspsicum_cap_set(&r, CCAP_RIGHT_WRITE)
                case .seek:
                    ccaspsicum_cap_set(&r, CCAP_RIGHT_SEEK)
                }
            }
            return r
        }()
    }

    public mutating func set(capabilites: [Capability]) {
        for cap in capabilites {
            switch cap {
            case .read:
                ccaspsicum_cap_set(&rights, CCAP_RIGHT_READ)
            case .write:
                ccaspsicum_cap_set(&rights, CCAP_RIGHT_WRITE)
            case .seek:
                ccaspsicum_cap_set(&rights, CCAP_RIGHT_SEEK)
            }
        }
    }

    public mutating func clear(capabilites: [Capability]) {
        for cap in capabilites {
            switch cap {
            case .read:
                ccap_rights_clear(&rights, CCAP_RIGHT_READ)
            case .write:
                ccap_rights_clear(&rights, CCAP_RIGHT_WRITE)
            case .seek:                
                ccap_rights_clear(&rights, CCAP_RIGHT_SEEK)
            }  
        }
    }

    public mutating func isSet(_ capability: Capability) -> Bool {
        switch capability {
        case .read:
            return ccapsicum_right_is_set(&rights, CCAP_RIGHT_READ)
        case .write:
            return ccapsicum_right_is_set(&rights, CCAP_RIGHT_WRITE)
        case .seek:
            return ccapsicum_right_is_set(&rights, CCAP_RIGHT_SEEK)
        }
    }

    public mutating func valid() -> Bool {
        return ccap_rights_valid(&rights)
    }

    /// Returns a new merged `CapRight`` instance.
    public mutating func merge(with other: CapRight) {
        withUnsafePointer(to: other.rights) { srcPtr in
            _ = ccapsicum_cap_rights_merge(&rights, srcPtr)
        }
    }
    public mutating func remove(right: CapRight) {
        withUnsafePointer(to: right.rights) { srcPtr in
            _ = ccap_rights_remove(&rights, srcPtr)
        }
    }

    public mutating func contains(right other: CapRight) -> Bool {
        var contains = false
        withUnsafePointer(to: other.rights) { littlePtr in
            contains = ccap_rights_contains(&rights, littlePtr)
        }
        return contains
    }
  

    public func toCType() -> cap_rights_t {
        return rights
    }

    public mutating func limit(fd: Int32) -> Bool {
        ccapsicum_cap_limit(fd, &rights) == 0
    }
}