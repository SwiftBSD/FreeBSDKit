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

#include "ccapsicum.h"
#include <assert.h>

int
ccapsicum_cap_limit(int fd, const cap_rights_t* rights) {
    return cap_rights_limit(fd, rights);
}

cap_rights_t* 
ccapsicum_rights_init(cap_rights_t *rights) {
    return cap_rights_init(rights);
}

cap_rights_t*
ccapsicum_cap_rights_merge(cap_rights_t* rightA, const cap_rights_t* rightB) {
    return cap_rights_merge(rightA, rightB);
}

cap_rights_t*
ccapsicum_cap_set(cap_rights_t* rights, ccapsicum_right_bridge right) {
    return cap_rights_set(rights, ccapsicum_selector(right));
}

bool
ccapsicum_right_is_set(const cap_rights_t* rights, ccapsicum_right_bridge right) {
    return cap_rights_is_set(rights, ccapsicum_selector(right));
}

void
ccapsicum_rights_clear(cap_rights_t* rights, ccapsicum_right_bridge right) {
    cap_rights_clear(rights, ccapsicum_selector(right));
}

bool
ccapsicum_rights_valid(cap_rights_t* rights) {
    return cap_rights_is_valid(rights);
}

bool 
ccapsicum_rights_contains(const cap_rights_t *big, const cap_rights_t *little) {
    return cap_rights_contains(big, little);
}
cap_rights_t* 
ccapsicum_rights_remove(cap_rights_t *dst, const cap_rights_t *src) {
    return cap_rights_remove(dst, src);
}

int
ccapsicum_limit_ioctls(int fd, const unsigned long *cmds, size_t ncmds)
{
    return cap_ioctls_limit(fd, cmds, ncmds);
}

ssize_t
ccapsicum_get_ioctls(int fd, unsigned long *cmds, size_t maxcmds)
{
    return cap_ioctls_get(fd, cmds, maxcmds);
}

int
ccapsicum_limit_fcntls(int fd, uint32_t fcntlrights)
{
    return cap_fcntls_limit(fd, fcntlrights);
}

int
ccapsicum_get_fcntls(int fd, uint32_t *fcntlrightsp)
{
    return cap_fcntls_get(fd, fcntlrightsp);
}

uint64_t
ccapsicum_selector(ccapsicum_right_bridge r)
{
    switch (r) {
    case CCAP_RIGHT_READ:            return CAP_READ;
    case CCAP_RIGHT_WRITE:           return CAP_WRITE;
    case CCAP_RIGHT_SEEK:            return CAP_SEEK;
    case CCAP_RIGHT_ACCEPT:          return CAP_ACCEPT;
    case CCAP_RIGHT_ACL_CHECK:       return CAP_ACL_CHECK;
    case CCAP_RIGHT_ACL_DELETE:      return CAP_ACL_DELETE;
    case CCAP_RIGHT_ACL_GET:         return CAP_ACL_GET;
    case CCAP_RIGHT_ACL_SET:         return CAP_ACL_SET;
    case CCAP_RIGHT_BIND:            return CAP_BIND;
    case CCAP_RIGHT_BINDAT:          return CAP_BINDAT;
    case CCAP_RIGHT_CHFLAGSAT:       return CAP_CHFLAGSAT;
    case CCAP_RIGHT_CONNECT:         return CAP_CONNECT;
    case CCAP_RIGHT_CONNECTAT:       return CAP_CONNECTAT;
    case CCAP_RIGHT_CREATE:          return CAP_CREATE;
    case CCAP_RIGHT_EVENT:           return CAP_EVENT;
    case CCAP_RIGHT_EXTATTR_DELETE:  return CAP_EXTATTR_DELETE;
    case CCAP_RIGHT_EXTATTR_GET:     return CAP_EXTATTR_GET;
    case CCAP_RIGHT_EXTATTR_LIST:    return CAP_EXTATTR_LIST;
    case CCAP_RIGHT_EXTATTR_SET:     return CAP_EXTATTR_SET;
    case CCAP_RIGHT_FCHDIR:          return CAP_FCHDIR;
    case CCAP_RIGHT_FCHFLAGS:        return CAP_FCHFLAGS;
    case CCAP_RIGHT_FCHMOD:          return CAP_FCHMOD;
    case CCAP_RIGHT_FCHMODAT:        return CAP_FCHMODAT;
    case CCAP_RIGHT_FCHOWN:          return CAP_FCHOWN;
    case CCAP_RIGHT_FCHOWNAT:        return CAP_FCHOWNAT;
    case CCAP_RIGHT_FCHROOT:         return CAP_FCHROOT;
    case CCAP_RIGHT_FCNTL:           return CAP_FCNTL;
    case CCAP_RIGHT_FEXECVE:         return CAP_FEXECVE;
    case CCAP_RIGHT_FLOCK:           return CAP_FLOCK;
    case CCAP_RIGHT_FPATHCONF:       return CAP_FPATHCONF;
    case CCAP_RIGHT_FSCK:            return CAP_FSCK;
    case CCAP_RIGHT_FSTAT:           return CAP_FSTAT;
    case CCAP_RIGHT_FSTATAT:         return CAP_FSTATAT;
    case CCAP_RIGHT_FSTATFS:         return CAP_FSTATFS;
    case CCAP_RIGHT_FSYNC:           return CAP_FSYNC;
    case CCAP_RIGHT_FTRUNCATE:       return CAP_FTRUNCATE;
    case CCAP_RIGHT_FUTIMES:         return CAP_FUTIMES;
    case CCAP_RIGHT_FUTIMESAT:       return CAP_FUTIMESAT;
    case CCAP_RIGHT_GETPEERNAME:     return CAP_GETPEERNAME;
    case CCAP_RIGHT_GETSOCKNAME:     return CAP_GETSOCKNAME;
    case CCAP_RIGHT_GETSOCKOPT:      return CAP_GETSOCKOPT;
    case CCAP_RIGHT_INOTIFY_ADD:     return CAP_INOTIFY_ADD;
    case CCAP_RIGHT_INOTIFY_RM:      return CAP_INOTIFY_RM;
    case CCAP_RIGHT_IOCTL:           return CAP_IOCTL;
    case CCAP_RIGHT_KQUEUE:          return CAP_KQUEUE;
    case CCAP_RIGHT_KQUEUE_CHANGE:   return CAP_KQUEUE_CHANGE;
    case CCAP_RIGHT_KQUEUE_EVENT:    return CAP_KQUEUE_EVENT;
    case CCAP_RIGHT_LINKAT_SOURCE:   return CAP_LINKAT_SOURCE;
    case CCAP_RIGHT_LINKAT_TARGET:   return CAP_LINKAT_TARGET;
    case CCAP_RIGHT_LISTEN:          return CAP_LISTEN;
    case CCAP_RIGHT_LOOKUP:          return CAP_LOOKUP;
    case CCAP_RIGHT_MAC_GET:         return CAP_MAC_GET;
    case CCAP_RIGHT_MAC_SET:         return CAP_MAC_SET;
    case CCAP_RIGHT_MKDIRAT:         return CAP_MKDIRAT;
    case CCAP_RIGHT_MKFIFOAT:        return CAP_MKFIFOAT;
    case CCAP_RIGHT_MKNODAT:         return CAP_MKNODAT;
    case CCAP_RIGHT_MMAP:            return CAP_MMAP;
    case CCAP_RIGHT_MMAP_R:          return CAP_MMAP_R;
    case CCAP_RIGHT_MMAP_RW:         return CAP_MMAP_RW;
    case CCAP_RIGHT_MMAP_RWX:        return CAP_MMAP_RWX;
    case CCAP_RIGHT_MMAP_RX:         return CAP_MMAP_RX;
    case CCAP_RIGHT_MMAP_W:          return CAP_MMAP_W;
    case CCAP_RIGHT_MMAP_WX:         return CAP_MMAP_WX;
    case CCAP_RIGHT_MMAP_X:          return CAP_MMAP_X;
    case CCAP_RIGHT_PDGETPID:        return CAP_PDGETPID;
    case CCAP_RIGHT_PDKILL:          return CAP_PDKILL;
    case CCAP_RIGHT_PEELOFF:         return CAP_PEELOFF;
    case CCAP_RIGHT_PREAD:           return CAP_PREAD;
    case CCAP_RIGHT_PWRITE:          return CAP_PWRITE;
    case CCAP_RIGHT_SEM_GETVALUE:    return CAP_SEM_GETVALUE;
    case CCAP_RIGHT_SEM_POST:        return CAP_SEM_POST;
    case CCAP_RIGHT_SEM_WAIT:        return CAP_SEM_WAIT;
    case CCAP_RIGHT_SEND:            return CAP_SEND;
    case CCAP_RIGHT_SETSOCKOPT:      return CAP_SETSOCKOPT;
    case CCAP_RIGHT_SHUTDOWN:        return CAP_SHUTDOWN;
    case CCAP_RIGHT_SYMLINKAT:       return CAP_SYMLINKAT;
    case CCAP_RIGHT_TTYHOOK:         return CAP_TTYHOOK;
    case CCAP_RIGHT_UNLINKAT:        return CAP_UNLINKAT;
    default:
        fprintf(stderr, "Error: Invalid ccapsicum_right_bridge value: %d\n", r);
        return UINT64_MAX; // Indicates an error
    }
}