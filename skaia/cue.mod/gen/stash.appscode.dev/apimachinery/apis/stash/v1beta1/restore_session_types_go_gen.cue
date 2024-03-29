// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go stash.appscode.dev/apimachinery/apis/stash/v1beta1

package v1beta1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	kmapi "kmodules.xyz/client-go/api/v1"
	ofst "kmodules.xyz/offshoot-api/api/v1"
	prober "kmodules.xyz/prober/api/v1"
)

#ResourceKindRestoreSession:     "RestoreSession"
#ResourcePluralRestoreSession:   "restoresessions"
#ResourceSingularRestoreSession: "restoresession"

// +kubebuilder:object:root=true
// +kubebuilder:resource:path=restoresessions,singular=restoresession,shortName=restore,categories={stash,appscode,all}
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Repository",type="string",JSONPath=".spec.repository.name"
// +kubebuilder:printcolumn:name="Phase",type="string",JSONPath=".status.phase"
// +kubebuilder:printcolumn:name="Duration",type="string",JSONPath=".status.sessionDuration"
// +kubebuilder:printcolumn:name="Age",type="date",JSONPath=".metadata.creationTimestamp"
#RestoreSession: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta    @go(ObjectMeta)
	spec?:     #RestoreSessionSpec   @go(Spec)
	status?:   #RestoreSessionStatus @go(Status)
}

#RestoreSessionSpec: {
	#RestoreTargetSpec

	// Driver indicates the name of the agent to use to restore the target.
	// Supported values are "Restic", "VolumeSnapshotter".
	// Default value is "Restic".
	// +optional
	// +kubebuilder:default=Restic
	driver?: #Snapshotter @go(Driver)

	// Repository refer to the Repository crd that hold backend information
	// +optional
	repository?: kmapi.#ObjectReference @go(Repository)

	// Rules specifies different restore options for different hosts
	// +optional
	// Deprecated. Use rules section inside `target`.
	rules?: [...#Rule] @go(Rules,[]Rule)

	// TimeOut specifies the maximum duration of restore. RestoreSession will be considered Failed
	// if restore does not complete within this time limit. By default, Stash don't set any timeout for restore.
	// +optional
	timeOut?: null | metav1.#Duration @go(TimeOut,*metav1.Duration)
}

#RestoreTargetSpec: {
	// Task specify the Task crd that specifies the steps for recovery process
	// +optional
	task?: #TaskRef @go(Task)

	// Target indicates the target where the recovered data will be stored
	// +optional
	target?: null | #RestoreTarget @go(Target,*RestoreTarget)

	// RuntimeSettings allow to specify Resources, NodeSelector, Affinity, Toleration, ReadinessProbe etc.
	// +optional
	runtimeSettings?: ofst.#RuntimeSettings @go(RuntimeSettings)

	// Temp directory configuration for functions/sidecar
	// An `EmptyDir` will always be mounted at /tmp with this settings
	// +optional
	tempDir?: #EmptyDirSettings @go(TempDir)

	// InterimVolumeTemplate specifies a template for a volume to hold targeted data temporarily
	// before uploading to backend or inserting into target. It is only usable for job model.
	// Don't specify it in sidecar model.
	// +optional
	interimVolumeTemplate?: null | ofst.#PersistentVolumeClaim @go(InterimVolumeTemplate,*ofst.PersistentVolumeClaim)

	// Actions that Stash should take in response to restore sessions.
	// +optional
	hooks?: null | #RestoreHooks @go(Hooks,*RestoreHooks)
}

// Hooks describes actions that Stash should take in response to restore sessions. For the PostRestore
// and PreRestore handlers, restore process blocks until the action is complete,
// unless the container process fails, in which case the handler is aborted.
#RestoreHooks: {
	// PreRestore is called immediately before a restore session is initiated.
	// +optional
	preRestore?: null | prober.#Handler @go(PreRestore,*prober.Handler)

	// PostRestore is called according to executionPolicy after a restore session is complete.
	// +optional
	postRestore?: null | #PostRestoreHook @go(PostRestore,*PostRestoreHook)
}

#PostRestoreHook: {
	prober.#Handler

	// ExecutionPolicy specifies when to execute a hook.
	// Supported values are "Always", "OnFailure", "OnSuccess".
	// Default value: "Always".
	// +optional
	// +kubebuilder:default=Always
	// +kubebuilder:validation:Enum=Always;OnFailure;OnSuccess
	executionPolicy?: #HookExecutionPolicy @go(ExecutionPolicy)
}

#RestoreSessionList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items?: [...#RestoreSession] @go(Items,[]RestoreSession)
}

// +kubebuilder:validation:Enum=Pending;Running;Succeeded;Failed;Unknown;Invalid
#RestorePhase: string // #enumRestorePhase

#enumRestorePhase:
	#RestorePending |
	#RestoreRunning |
	#RestoreSucceeded |
	#RestoreFailed |
	#RestorePhaseUnknown |
	#RestorePhaseInvalid

#RestorePending:      #RestorePhase & "Pending"
#RestoreRunning:      #RestorePhase & "Running"
#RestoreSucceeded:    #RestorePhase & "Succeeded"
#RestoreFailed:       #RestorePhase & "Failed"
#RestorePhaseUnknown: #RestorePhase & "Unknown"
#RestorePhaseInvalid: #RestorePhase & "Invalid"

// +kubebuilder:validation:Enum=Succeeded;Failed;Running;Unknown
#HostRestorePhase: string // #enumHostRestorePhase

#enumHostRestorePhase:
	#HostRestoreSucceeded |
	#HostRestoreFailed |
	#HostRestoreRunning |
	#HostRestoreUnknown

#HostRestoreSucceeded: #HostRestorePhase & "Succeeded"
#HostRestoreFailed:    #HostRestorePhase & "Failed"
#HostRestoreRunning:   #HostRestorePhase & "Running"
#HostRestoreUnknown:   #HostRestorePhase & "Unknown"

#RestoreSessionStatus: {
	// Phase indicates the overall phase of the restore process for this RestoreSession. Phase will be "Succeeded" only if
	// phase of all hosts are "Succeeded". If any of the host fail to complete restore, Phase will be "Failed".
	// +optional
	phase?: #RestorePhase @go(Phase)

	// TotalHosts specifies total number of hosts that will be restored for this RestoreSession
	// +optional
	totalHosts?: null | int32 @go(TotalHosts,*int32)

	// SessionDuration specify total time taken to complete current restore session (sum of restore duration of all hosts)
	// +optional
	sessionDuration?: string @go(SessionDuration)

	// Stats shows statistics of individual hosts for this restore session
	// +optional
	stats?: [...#HostRestoreStats] @go(Stats,[]HostRestoreStats)

	// Conditions shows current restore condition of the RestoreSession.
	// +optional
	conditions?: [...kmapi.#Condition] @go(Conditions,[]kmapi.Condition)

	// SessionDeadline specifies the deadline of restore process. RestoreSession will be
	// considered Failed if restore does not complete within this deadline
	// +optional
	sessionDeadline?: null | metav1.#Time @go(SessionDeadline,*metav1.Time)
}

#HostRestoreStats: {
	// Hostname indicate name of the host that has been restored
	// +optional
	hostname?: string @go(Hostname)

	// Phase indicates restore phase of this host
	// +optional
	phase?: #HostRestorePhase @go(Phase)

	// Duration indicates total time taken to complete restore for this hosts
	// +optional
	duration?: string @go(Duration)

	// Error indicates string value of error in case of restore failure
	// +optional
	error?: string @go(Error)
}

// RestoreTargetFound indicates whether the restore target was found
#RestoreTargetFound: "RestoreTargetFound"

// StashInitContainerInjected indicates whether stash init-container was injected into the targeted workload
// This condition is applicable only for sidecar model
#StashInitContainerInjected: "StashInitContainerInjected"

// RestoreJobCreated indicates whether the restore job was created
#RestoreJobCreated: "RestoreJobCreated"

// RestoreCompleted condition indicates whether the restore process has been completed or not.
// This condition is particularly helpful when the restore addon require some additional operations to perform
// before marking the RestoreSession Succeeded/Failed.
#RestoreCompleted: "RestoreCompleted"

// RestoreExecutorEnsured condition indicates whether the restore job / init-container was ensured or not.
#RestoreExecutorEnsured: "RestoreExecutorEnsured"

// MetricsPushed whether the metrics for this backup session were pushed or not
#MetricsPushed: "MetricsPushed"

// PreRestoreHookExecutionSucceeded indicates whether the preRestore hook was executed successfully or not
#PreRestoreHookExecutionSucceeded: "PreRestoreHookExecutionSucceeded"

// PostRestoreHookExecutionSucceeded indicates whether the postRestore hook was executed successfully or not
#PostRestoreHookExecutionSucceeded: "PostRestoreHookExecutionSucceeded"

// InitContainerInjectionSucceeded indicates that the condition transitioned to this state because stash init-container
// was injected successfully into the targeted workload
#InitContainerInjectionSucceeded: "InitContainerInjectionSucceeded"

// InitContainerInjectionFailed indicates that the condition transitioned to this state because operator was unable
// to inject stash init-container into the targeted workload
#InitContainerInjectionFailed: "InitContainerInjectionFailed"

// RestoreJobCreationSucceeded indicates that the condition transitioned to this state because restore job was created successfully
#RestoreJobCreationSucceeded: "RestoreJobCreationSucceeded"

// RestoreJobCreationFailed indicates that the condition transitioned to this state because operator was unable to create restore job
#RestoreJobCreationFailed: "RestoreJobCreationFailed"

// SuccessfullyPushedMetrics indicates that the condition transitioned to this state because the metrics was successfully pushed to the pushgateway
#SuccessfullyPushedMetrics: "SuccessfullyPushedMetrics"

// FailedToPushMetrics indicates that the condition transitioned to this state because the Stash was unable to push the metrics to the pushgateway
#FailedToPushMetrics:                 "FailedToPushMetrics"
#SuccessfullyEnsuredRestoreExecutor:  "SuccessfullyEnsuredRestoreExecutor"
#FailedToEnsureRestoreExecutor:       "FailedToEnsureRestoreExecutor"
#SuccessfullyExecutedPreRestoreHook:  "SuccessfullyExecutedPreRestoreHook"
#FailedToExecutePreRestoreHook:       "FailedToExecutePreRestoreHook"
#SuccessfullyExecutedPostRestoreHook: "SuccessfullyExecutedPostRestoreHook"
#FailedToExecutePostRestoreHook:      "FailedToExecutePostRestoreHook"
#PostRestoreTasksExecuted:            "PostRestoreTasksExecuted"
#PostRestoreTasksNotExecuted:         "PostRestoreTasksNotExecuted"
