// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go runtime

package runtime

_#pollNoError:        0
_#pollErrClosing:     1
_#pollErrTimeout:     2
_#pollErrNotPollable: 3

_#pdReady: uint64 & 1
_#pdWait:  uint64 & 2

_#pollBlockSize: 4096

// pollInfo is the bits needed by netpollcheckerr, stored atomically,
// mostly duplicating state that is manipulated under lock in pollDesc.
// The one exception is the pollEventErr bit, which is maintained only
// in the pollInfo.
_#pollInfo: uint32

_#pollClosing:              1
_#pollEventErr:             2
_#pollExpiredReadDeadline:  4
_#pollExpiredWriteDeadline: 8
