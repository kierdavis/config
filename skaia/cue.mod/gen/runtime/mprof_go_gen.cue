// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go runtime

package runtime

// profile types
_#memProfile:   _#bucketType & 1
_#blockProfile: _#bucketType & 2
_#mutexProfile: _#bucketType & 3

// size of bucket hash table
_#buckHashSize: 179999

// max depth of stack to record in bucket
_#maxStack: 32

_#bucketType: int

_#mProfCycleWrap: uint32 & 100663296

// A StackRecord describes a single execution stack.
#StackRecord: {
	Stack0: 32 * [uint64] @go(,[32]uintptr)
}

// A MemProfileRecord describes the live objects allocated
// by a particular call sequence (stack trace).
#MemProfileRecord: {
	AllocBytes:   int64
	FreeBytes:    int64
	AllocObjects: int64
	FreeObjects:  int64
	Stack0:       32 * [uint64] @go(,[32]uintptr)
}

// BlockProfileRecord describes blocking events originated
// at a particular call sequence (stack trace).
#BlockProfileRecord: {
	Count:       int64
	Cycles:      int64
	StackRecord: #StackRecord
}

_#go119ConcurrentGoroutineProfile: true

// goroutineProfileState indicates the status of a goroutine's stack for the
// current in-progress goroutine profile. Goroutines' stacks are initially
// "Absent" from the profile, and end up "Satisfied" by the time the profile is
// complete. While a goroutine's stack is being captured, its
// goroutineProfileState will be "InProgress" and it will not be able to run
// until the capture completes and the state moves to "Satisfied".
//
// Some goroutines (the finalizer goroutine, which at various times can be
// either a "system" or a "user" goroutine, and the goroutine that is
// coordinating the profile, any goroutines created during the profile) move
// directly to the "Satisfied" state.
_#goroutineProfileState: uint32

_#goroutineProfileAbsent:     _#goroutineProfileState & 0
_#goroutineProfileInProgress: _#goroutineProfileState & 1
_#goroutineProfileSatisfied:  _#goroutineProfileState & 2
