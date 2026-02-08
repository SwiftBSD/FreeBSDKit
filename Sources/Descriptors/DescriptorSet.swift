/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import Glibc
import Foundation
import FreeBSDKit

public struct DescriptorSet: Sendable {
    private var descriptors: [OpaqueDescriptorRef] = []

    public init(_ desc: [OpaqueDescriptorRef]) {
        self.descriptors = desc
    }

    public
    mutating func insert(_ desc: consuming some Descriptor, kind: DescriptorKind,) {
        descriptors.append(
            OpaqueDescriptorRef(desc.take(), kind: kind)
        )
    }

    public func all(ofKind kind: DescriptorKind) -> [OpaqueDescriptorRef] {
        descriptors.filter { $0.kind == kind }
    }

    public func first(ofKind kind: DescriptorKind) -> OpaqueDescriptorRef? {
        descriptors.first { $0.kind == kind }
    }
}

extension DescriptorSet: Sequence {
    public struct Iterator: Swift.IteratorProtocol {
        private let descriptors: [OpaqueDescriptorRef]
        private var index = 0

        init(_ descriptors: [OpaqueDescriptorRef]) {
            self.descriptors = descriptors
        }

        public mutating func next() -> OpaqueDescriptorRef? {
            guard index < descriptors.count else { return nil }
            defer { index += 1 }
            return descriptors[index]
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(descriptors)
    }
}