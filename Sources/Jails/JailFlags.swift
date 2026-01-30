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

import CJails

public struct JailSetFlags: OptionSet {
    public let rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }

    public static let create  = JailSetFlags(rawValue: JAIL_CREATE)
    public static let update  = JailSetFlags(rawValue: JAIL_UPDATE)
    public static let attach  = JailSetFlags(rawValue: JAIL_ATTACH)

    public static let useDesc = JailSetFlags(rawValue: JAIL_USE_DESC)
    public static let atDesc  = JailSetFlags(rawValue: JAIL_AT_DESC)
    public static let getDesc = JailSetFlags(rawValue: JAIL_GET_DESC)
    public static let ownDesc = JailSetFlags(rawValue: JAIL_OWN_DESC)
}

public struct JailGetFlags: OptionSet {
    public let rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }

    public static let dying   = JailGetFlags(rawValue: JAIL_DYING)
    public static let useDesc = JailGetFlags(rawValue: JAIL_USE_DESC)
    public static let atDesc  = JailGetFlags(rawValue: JAIL_AT_DESC)
    public static let getDesc = JailGetFlags(rawValue: JAIL_GET_DESC)
    public static let ownDesc = JailGetFlags(rawValue: JAIL_OWN_DESC)
}