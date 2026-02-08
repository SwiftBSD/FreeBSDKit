/*
 * Copyright (c) 2026 Kory Heard
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

// For the read end of a pipe
public protocol PipeReadDescriptor: Descriptor, ReadableDescriptor, ~Copyable {}

// For the write end of a pipe
public protocol PipeWriteDescriptor: Descriptor, WritableDescriptor, ~Copyable {}
