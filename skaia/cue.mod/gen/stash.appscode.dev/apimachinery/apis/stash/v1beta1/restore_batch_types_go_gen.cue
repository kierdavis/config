// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go stash.appscode.dev/apimachinery/apis/stash/v1beta1

package v1beta1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	kmapi "kmodules.xyz/client-go/api/v1"
)

#ResourceKindRestoreBatch:     "RestoreBatch"
#ResourceSingularRestoreBatch: "restorebatch"
#ResourcePluralRestoreBatch:   "restorebatches"

// +kubebuilder:object:root=true
// +kubebuilder:resource:path=restorebatches,singular=restorebatch,categories={stash,appscode,all}
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Repository",type="string",JSONPath=".spec.repository.name"
// +kubebuilder:printcolumn:name="Phase",type="string",JSONPath=".status.phase"
// +kubebuilder:printcolumn:name="Duration",type="string",JSONPath=".status.sessionDuration"
// +kubebuilder:printcolumn:name="Age",type="date",JSONPath=".metadata.creationTimestamp"
#RestoreBatch: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta  @go(ObjectMeta)
	spec?:     #RestoreBatchSpec   @go(Spec)
	status?:   #RestoreBatchStatus @go(Status)
}

#RestoreBatchSpec: {
	// Driver indicates the name of the agent to use to restore the target.
	// Supported values are "Restic", "VolumeSnapshotter".
	// Default value is "Restic".
	// +optional
	// +kubebuilder:default=Restic
	driver?: #Snapshotter @go(Driver)

	// Repository refer to the Repository crd that holds backend information
	// +optional
	repository?: kmapi.#ObjectReference @go(Repository)

	// Members is a list of restore targets and their configuration that are part of this batch
	// +optional
	members?: [...#RestoreTargetSpec] @go(Members,[]RestoreTargetSpec)

	// ExecutionOrder indicate whether to restore the members in the sequential order as they appear in the members list.
	// The default value is "Parallel" which means the members will be restored in parallel.
	// +kubebuilder:default=Parallel
	// +optional
	executionOrder?: #ExecutionOrder @go(ExecutionOrder)

	// Hooks specifies the actions that Stash should take before or after restore.
	// Cannot be updated.
	// +optional
	hooks?: null | #RestoreHooks @go(Hooks,*RestoreHooks)

	// TimeOut specifies the maximum duration of restore. RestoreBatch will be considered Failed
	// if restore does not complete within this time limit. By default, Stash don't set any timeout for restore.
	// +optional
	timeOut?: null | metav1.#Duration @go(TimeOut,*metav1.Duration)
}

#RestoreBatchStatus: {
	// Phase indicates the overall phase of the restore process for this RestoreBatch. Phase will be "Succeeded" only if
	// phase of all members are "Succeeded". If the restore process fail for any of the members, Phase will be "Failed".
	// +optional
	phase?: #RestorePhase @go(Phase)

	// SessionDuration specify total time taken to complete restore of all the members.
	// +optional
	sessionDuration?: string @go(SessionDuration)

	// Conditions shows the condition of different steps for the RestoreBatch.
	// +optional
	conditions?: [...kmapi.#Condition] @go(Conditions,[]kmapi.Condition)

	// Members shows the restore status for the members of the RestoreBatch.
	// +optional
	members?: [...#RestoreMemberStatus] @go(Members,[]RestoreMemberStatus)

	// SessionDeadline specifies the deadline of restore process. RestoreBatch will be
	// considered Failed if restore does not complete within this deadline
	// +optional
	sessionDeadline?: null | metav1.#Time @go(SessionDeadline,*metav1.Time)
}

// +kubebuilder:validation:Enum=Pending;Succeeded;Running;Failed
#RestoreTargetPhase: string // #enumRestoreTargetPhase

#enumRestoreTargetPhase:
	#TargetRestorePending |
	#TargetRestoreRunning |
	#TargetRestoreSucceeded |
	#TargetRestoreFailed |
	#TargetRestorePhaseUnknown

#TargetRestorePending:      #RestoreTargetPhase & "Pending"
#TargetRestoreRunning:      #RestoreTargetPhase & "Running"
#TargetRestoreSucceeded:    #RestoreTargetPhase & "Succeeded"
#TargetRestoreFailed:       #RestoreTargetPhase & "Failed"
#TargetRestorePhaseUnknown: #RestoreTargetPhase & "Unknown"

#RestoreMemberStatus: {
	// Ref is the reference to the respective target whose status is shown here.
	ref: #TargetRef @go(Ref)

	// Conditions shows the condition of different steps to restore this member.
	// +optional
	conditions?: [...kmapi.#Condition] @go(Conditions,[]kmapi.Condition)

	// TotalHosts specifies total number of hosts that will be restored for this member.
	// +optional
	totalHosts?: null | int32 @go(TotalHosts,*int32)

	// Phase indicates restore phase of this member
	// +optional
	phase?: #RestoreTargetPhase @go(Phase)

	// Stats shows restore statistics of individual hosts for this member
	// +optional
	stats?: [...#HostRestoreStats] @go(Stats,[]HostRestoreStats)
}

#RestoreBatchList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items?: [...#RestoreBatch] @go(Items,[]RestoreBatch)
}

// GlobalPreRestoreHookSucceeded indicates whether the global PreRestoreHook was executed successfully or not
#GlobalPreRestoreHookSucceeded: "GlobalPreRestoreHookSucceeded"

// GlobalPostRestoreHookSucceeded indicates whether the global PostRestoreHook was executed successfully or not
#GlobalPostRestoreHookSucceeded: "GlobalPostRestoreHookSucceeded"

// GlobalPreRestoreHookExecutedSuccessfully indicates that the condition transitioned to this state because the global PreRestoreHook was executed successfully
#GlobalPreRestoreHookExecutedSuccessfully: "GlobalPreRestoreHookExecutedSuccessfully"

// GlobalPreRestoreHookExecutionFailed indicates that the condition transitioned to this state because the Stash was unable to execute global PreRestoreHook
#GlobalPreRestoreHookExecutionFailed: "GlobalPreRestoreHookExecutionFailed"

// GlobalPostRestoreHookExecutedSuccessfully indicates that the condition transitioned to this state because the global PostRestoreHook was executed successfully
#GlobalPostRestoreHookExecutedSuccessfully: "GlobalPostRestoreHookExecutedSuccessfully"

// GlobalPostRestoreHookExecutionFailed indicates that the condition transitioned to this state because the Stash was unable to execute global PostRestoreHook
#GlobalPostRestoreHookExecutionFailed: "GlobalPostRestoreHookExecutionFailed"
