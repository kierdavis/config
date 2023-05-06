// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go runtime

package runtime

// The background scavenger is paced according to these parameters.
//
// scavengePercent represents the portion of mutator time we're willing
// to spend on scavenging in percent.
_#scavengePercent: 1

// retainExtraPercent represents the amount of memory over the heap goal
// that the scavenger should keep as a buffer space for the allocator.
// This constant is used when we do not have a memory limit set.
//
// The purpose of maintaining this overhead is to have a greater pool of
// unscavenged memory available for allocation (since using scavenged memory
// incurs an additional cost), to account for heap fragmentation and
// the ever-changing layout of the heap.
_#retainExtraPercent: 10

// reduceExtraPercent represents the amount of memory under the limit
// that the scavenger should target. For example, 5 means we target 95%
// of the limit.
//
// The purpose of shooting lower than the limit is to ensure that, once
// close to the limit, the scavenger is working hard to maintain it. If
// we have a memory limit set but are far away from it, there's no harm
// in leaving up to 100-retainExtraPercent live, and it's more efficient
// anyway, for the same reasons that retainExtraPercent exists.
_#reduceExtraPercent: 5

// maxPagesPerPhysPage is the maximum number of supported runtime pages per
// physical page, based on maxPhysPageSize.
_#maxPagesPerPhysPage: 64

// scavengeCostRatio is the approximate ratio between the costs of using previously
// scavenged memory and scavenging memory.
//
// For most systems the cost of scavenging greatly outweighs the costs
// associated with using scavenged memory, making this constant 0. On other systems
// (especially ones where "sysUsed" is not just a no-op) this cost is non-trivial.
//
// This ratio is used as part of multiplicative factor to help the scavenger account
// for the additional costs of using scavenged memory in its pacing.
_#scavengeCostRatio: 0

// It doesn't really matter what value we start at, but we can't be zero, because
// that'll cause divide-by-zero issues. Pick something conservative which we'll
// also use as a fallback.
_#startingScavSleepRatio: 1 / 1000

// Spend at least 1 ms scavenging, otherwise the corresponding
// sleep time to maintain our desired utilization is too low to
// be reliable.
_#minScavWorkTime: 1e6
