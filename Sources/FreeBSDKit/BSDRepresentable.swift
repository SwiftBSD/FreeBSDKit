import Foundation

public protocol BSDRepresentable: ~Copyable {
    associatedtype RAWBSD
    consuming func take() -> RAWBSD
    /// Tinkering with the internal state of anything with this protocol is a code smell.
    func unsafe<R>(_ block: (RAWBSD) throws -> R) rethrows -> R
}