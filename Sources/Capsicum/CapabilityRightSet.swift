/*
 * Copyright (c) 2026 Kory Heard
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import CCapsicum

/// CapabilityRightSet
public struct CapabilityRightSet {
    private var rights: cap_rights_t

    /// Initilizes an empty CapabilityRightSet
    public init() {
        var rights = cap_rights_t()
        ccapsicum_rights_init(&rights)
        self.rights = rights
    }

    /// Initialize from a cap_rights_t.
    public init(rights: cap_rights_t) {
        self.rights = rights
    }
    /// Initialize from an array of `Capability`.
    public init(rights inRights: [CapabilityRight]) {
        self.rights = {
            var rights = cap_rights_t()
            ccapsicum_rights_init(&rights)
            for right in inRights {
                ccaspsicum_cap_set(&rights, right.bridged)
            }
            return rights
        }()
    }

    public mutating func add(capability: CapabilityRight) {
        ccaspsicum_cap_set(&self.rights, capability.bridged)
    }

    public mutating func add(capabilites: [CapabilityRight]) {
        for cap in capabilites {
            ccaspsicum_cap_set(&self.rights, cap.bridged)
        }
    }

    public mutating func clear(capability: CapabilityRight) {            
        ccapsicum_rights_clear(&self.rights, capability.bridged)
    }

    public mutating func clear(capabilites: [CapabilityRight]) {
        for cap in capabilites {               
            ccapsicum_rights_clear(&self.rights, cap.bridged)
        }
    }

    public mutating func contains(capability: CapabilityRight) -> Bool {
        return ccapsicum_right_is_set(&self.rights, capability.bridged)
    }

    public mutating func contains(right other: CapabilityRightSet) -> Bool {
        var contains = false
        withUnsafePointer(to: other.rights) { otherRights in
            contains = ccapsicum_rights_contains(&self.rights, otherRights)
        }
        return contains
    }

    /// Returns a new merged `CapabilityRightSet`` instance.
    public mutating func merge(with other: CapabilityRightSet) {
        withUnsafePointer(to: other.rights) { srcPtr in
            _ = ccapsicum_cap_rights_merge(&self.rights, srcPtr)
        }
    }

    /// Removes rights matching `right`
    public mutating func remove(matching right: CapabilityRightSet) {
        withUnsafePointer(to: right.rights) { srcPtr in
            _ = ccapsicum_rights_remove(&self.rights, srcPtr)
        }
    }
    /// Validates the right.
    public mutating func validate() -> Bool {
        return ccapsicum_rights_valid(&rights)
    }

    public func asCapRightsT() -> cap_rights_t {
        return rights
    }
}