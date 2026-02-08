/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

/// Standard signals for process descriptors.
public enum BSDSignal: Int32, Sendable {
    case hup    = 1
    case int    = 2
    case quit   = 3
    case ill    = 4
    case trap   = 5
    case abrt   = 6
    case bus    = 7
    case fpe    = 8
    case kill   = 9      // non-catchable
    case usr1   = 10
    case segv   = 11
    case usr2   = 12
    case pipe   = 13
    case alrm   = 14
    case term   = 15
    case chld   = 20
    case cont   = 19
    case stop   = 17     // non-catchable
    case ttin   = 21
    case ttou   = 22
    case io     = 23
    case xcpu   = 24
    case xfsz   = 25
    case vtAlrm = 26
    case prof   = 27
    case winch  = 28

    public var isCatchable: Bool {
        switch self {
        case .kill, .stop:
            return false
        default:
            return true
        }
    }
}