// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go runtime

package runtime

_#traceEvNone:              0
_#traceEvBatch:             1
_#traceEvFrequency:         2
_#traceEvStack:             3
_#traceEvGomaxprocs:        4
_#traceEvProcStart:         5
_#traceEvProcStop:          6
_#traceEvGCStart:           7
_#traceEvGCDone:            8
_#traceEvGCSTWStart:        9
_#traceEvGCSTWDone:         10
_#traceEvGCSweepStart:      11
_#traceEvGCSweepDone:       12
_#traceEvGoCreate:          13
_#traceEvGoStart:           14
_#traceEvGoEnd:             15
_#traceEvGoStop:            16
_#traceEvGoSched:           17
_#traceEvGoPreempt:         18
_#traceEvGoSleep:           19
_#traceEvGoBlock:           20
_#traceEvGoUnblock:         21
_#traceEvGoBlockSend:       22
_#traceEvGoBlockRecv:       23
_#traceEvGoBlockSelect:     24
_#traceEvGoBlockSync:       25
_#traceEvGoBlockCond:       26
_#traceEvGoBlockNet:        27
_#traceEvGoSysCall:         28
_#traceEvGoSysExit:         29
_#traceEvGoSysBlock:        30
_#traceEvGoWaiting:         31
_#traceEvGoInSyscall:       32
_#traceEvHeapAlloc:         33
_#traceEvHeapGoal:          34
_#traceEvTimerGoroutine:    35
_#traceEvFutileWakeup:      36
_#traceEvString:            37
_#traceEvGoStartLocal:      38
_#traceEvGoUnblockLocal:    39
_#traceEvGoSysExitLocal:    40
_#traceEvGoStartLabel:      41
_#traceEvGoBlockGC:         42
_#traceEvGCMarkAssistStart: 43
_#traceEvGCMarkAssistDone:  44
_#traceEvUserTaskCreate:    45
_#traceEvUserTaskEnd:       46
_#traceEvUserRegion:        47
_#traceEvUserLog:           48
_#traceEvCPUSample:         49
_#traceEvCount:             50

// Timestamps in trace are cputicks/traceTickDiv.
// This makes absolute values of timestamp diffs smaller,
// and so they are encoded in less number of bytes.
// 64 on x86 is somewhat arbitrary (one tick is ~20ns on a 3GHz machine).
// The suggested increment frequency for PowerPC's time base register is
// 512 MHz according to Power ISA v2.07 section 6.2, so we use 16 on ppc64
// and ppc64le.
// Tracing won't work reliably for architectures where cputicks is emulated
// by nanotime, so the value doesn't matter for those architectures.
_#traceTickDiv: 64

// Maximum number of PCs in a single stack trace.
// Since events contain only stack id rather than whole stack trace,
// we can allow quite large values here.
_#traceStackSize: 128

// Identifier of a fake P that is used when we trace without a real P.
_#traceGlobProc: -1

// Maximum number of bytes to encode uint64 in base-128.
_#traceBytesPerNumber: 10

// Shift of the number of arguments in the first event byte.
_#traceArgCountShift: 6

// Flag passed to traceGoPark to denote that the previous wakeup of this
// goroutine was futile. For example, a goroutine was unblocked on a mutex,
// but another goroutine got ahead and acquired the mutex before the first
// goroutine is scheduled, so the first goroutine has to block again.
// Such wakeups happen on buffered channels and sync.Mutex,
// but are generally not interesting for end user.
_#traceFutileWakeup: 128

// traceBufPtr is a *traceBuf that is not traced by the garbage
// collector and doesn't have write barriers. traceBufs are not
// allocated from the GC'd heap, so this is safe, and are often
// manipulated in contexts where write barriers are not allowed, so
// this is necessary.
//
// TODO: Since traceBuf is now go:notinheap, this isn't necessary.
_#traceBufPtr: uint64

_#traceStackPtr: uint64

// TODO: Since traceAllocBlock is now go:notinheap, this isn't necessary.
_#traceAllocBlockPtr: uint64
