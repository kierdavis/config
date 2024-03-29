// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go runtime

package runtime

// For the time histogram type, we use an HDR histogram.
// Values are placed in super-buckets based solely on the most
// significant set bit. Thus, super-buckets are power-of-2 sized.
// Values are then placed into sub-buckets based on the value of
// the next timeHistSubBucketBits most significant bits. Thus,
// sub-buckets are linear within a super-bucket.
//
// Therefore, the number of sub-buckets (timeHistNumSubBuckets)
// defines the error. This error may be computed as
// 1/timeHistNumSubBuckets*100%. For example, for 16 sub-buckets
// per super-bucket the error is approximately 6%.
//
// The number of super-buckets (timeHistNumSuperBuckets), on the
// other hand, defines the range. To reserve room for sub-buckets,
// bit timeHistSubBucketBits is the first bit considered for
// super-buckets, so super-bucket indices are adjusted accordingly.
//
// As an example, consider 45 super-buckets with 16 sub-buckets.
//
//    00110
//    ^----
//    │  ^
//    │  └---- Lowest 4 bits -> sub-bucket 6
//    └------- Bit 4 unset -> super-bucket 0
//
//    10110
//    ^----
//    │  ^
//    │  └---- Next 4 bits -> sub-bucket 6
//    └------- Bit 4 set -> super-bucket 1
//    100010
//    ^----^
//    │  ^ └-- Lower bits ignored
//    │  └---- Next 4 bits -> sub-bucket 1
//    └------- Bit 5 set -> super-bucket 2
//
// Following this pattern, super-bucket 44 will have the bit 47 set. We don't
// have any buckets for higher values, so the highest sub-bucket will
// contain values of 2^48-1 nanoseconds or approx. 3 days. This range is
// more than enough to handle durations produced by the runtime.
_#timeHistSubBucketBits:   4
_#timeHistNumSubBuckets:   16
_#timeHistNumSuperBuckets: 45
_#timeHistTotalBuckets:    721

_#fInf:    0x7FF0000000000000
_#fNegInf: 0xFFF0000000000000
