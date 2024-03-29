// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go stash.appscode.dev/apimachinery/apis/stash/v1alpha1

package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	store "kmodules.xyz/objectstore-api/api/v1"
	kmapi "kmodules.xyz/client-go/api/v1"
)

#ResourceKindRepository:     "Repository"
#ResourcePluralRepository:   "repositories"
#ResourceSingularRepository: "repository"

// +kubebuilder:object:root=true
// +kubebuilder:resource:path=repositories,singular=repository,shortName=repo,categories={stash,appscode}
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Integrity",type="boolean",JSONPath=".status.integrity"
// +kubebuilder:printcolumn:name="Size",type="string",JSONPath=".status.totalSize"
// +kubebuilder:printcolumn:name="Snapshot-Count",type="integer",JSONPath=".status.snapshotCount"
// +kubebuilder:printcolumn:name="Last-Successful-Backup",type="date",format="date-time",JSONPath=".status.lastBackupTime"
// +kubebuilder:printcolumn:name="Age",type="date",JSONPath=".metadata.creationTimestamp"
#Repository: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)
	spec?:     #RepositorySpec    @go(Spec)
	status?:   #RepositoryStatus  @go(Status)
}

#RepositorySpec: {
	// Backend specify the storage where backed up snapshot will be stored
	backend?: store.#Backend @go(Backend)

	// If true, delete respective restic repository
	// +optional
	wipeOut?: bool @go(WipeOut)

	// UsagePolicy specifies a policy of how this Repository will be used. For example, you can use `allowedNamespaces`
	// policy to restrict the usage of this Repository to particular namespaces.
	// This field is optional. If you don't provide the usagePolicy, then it can be used only from the current namespace.
	// +optional
	usagePolicy?: null | #UsagePolicy @go(UsagePolicy,*UsagePolicy)
}

#RepositoryStatus: {
	// ObservedGeneration is the most recent generation observed for this Repository. It corresponds to the
	// Repository's generation, which is updated on mutation by the API Server.
	// +optional
	observedGeneration?: int64 @go(ObservedGeneration)

	// FirstBackupTime indicates the timestamp when the first backup was taken
	firstBackupTime?: null | metav1.#Time @go(FirstBackupTime,*metav1.Time)

	// LastBackupTime indicates the timestamp when the latest backup was taken
	lastBackupTime?: null | metav1.#Time @go(LastBackupTime,*metav1.Time)

	// Integrity shows result of repository integrity check after last backup
	integrity?: null | bool @go(Integrity,*bool)

	// TotalSize show size of repository after last backup
	totalSize?: string @go(TotalSize)

	// SnapshotCount shows number of snapshots stored in the repository
	snapshotCount?: int64 @go(SnapshotCount)

	// SnapshotsRemovedOnLastCleanup shows number of old snapshots cleaned up according to retention policy on last backup session
	snapshotsRemovedOnLastCleanup?: int64 @go(SnapshotsRemovedOnLastCleanup)

	// References holds a list of resource references that using this Repository
	// +optional
	references?: [...kmapi.#TypedObjectReference] @go(References,[]kmapi.TypedObjectReference)
}

// UsagePolicy specifies a policy that restrict the usage of a resource across namespaces.
#UsagePolicy: {
	// AllowedNamespaces specifies which namespaces are allowed to use the resource
	// +optional
	allowedNamespaces?: #AllowedNamespaces @go(AllowedNamespaces)
}

// AllowedNamespaces indicate which namespaces the resource should be selected from.
#AllowedNamespaces: {
	// From indicates how to select the namespaces that are allowed to use this resource.
	// Possible values are:
	// * All: All namespaces can use this resource.
	// * Selector: Namespaces that matches the selector can use this resource.
	// * Same: Only current namespace can use the resource.
	//
	// +optional
	// +kubebuilder:default=Same
	from?: null | #FromNamespaces @go(From,*FromNamespaces)

	// Selector must be specified when From is set to "Selector". In that case,
	// only the selected namespaces are allowed to use this resource.
	// This field is ignored for other values of "From".
	//
	// +optional
	selector?: null | metav1.#LabelSelector @go(Selector,*metav1.LabelSelector)
}

// FromNamespaces specifies namespace from which namespaces are allowed to use the resource.
//
// +kubebuilder:validation:Enum=All;Selector;Same
#FromNamespaces: string // #enumFromNamespaces

#enumFromNamespaces:
	#NamespacesFromAll |
	#NamespacesFromSelector |
	#NamespacesFromSame

// NamespacesFromAll specifies that all namespaces can use the resource.
#NamespacesFromAll: #FromNamespaces & "All"

// NamespacesFromSelector specifies that only the namespace that matches the selector can use the resource.
#NamespacesFromSelector: #FromNamespaces & "Selector"

// NamespacesFromSame specifies that only the current namespace can use the resource.
#NamespacesFromSame: #FromNamespaces & "Same"

// +kubebuilder:validation:Enum=--keep-last;--keep-hourly;--keep-daily;--keep-weekly;--keep-monthly;--keep-yearly;--keep-tag
#RetentionStrategy: string // #enumRetentionStrategy

#enumRetentionStrategy:
	#KeepLast |
	#KeepHourly |
	#KeepDaily |
	#KeepWeekly |
	#KeepMonthly |
	#KeepYearly |
	#KeepTag

#KeepLast:    #RetentionStrategy & "--keep-last"
#KeepHourly:  #RetentionStrategy & "--keep-hourly"
#KeepDaily:   #RetentionStrategy & "--keep-daily"
#KeepWeekly:  #RetentionStrategy & "--keep-weekly"
#KeepMonthly: #RetentionStrategy & "--keep-monthly"
#KeepYearly:  #RetentionStrategy & "--keep-yearly"
#KeepTag:     #RetentionStrategy & "--keep-tag"

#RetentionPolicy: {
	name:         string @go(Name)
	keepLast?:    int64  @go(KeepLast)
	keepHourly?:  int64  @go(KeepHourly)
	keepDaily?:   int64  @go(KeepDaily)
	keepWeekly?:  int64  @go(KeepWeekly)
	keepMonthly?: int64  @go(KeepMonthly)
	keepYearly?:  int64  @go(KeepYearly)
	keepTags?: [...string] @go(KeepTags,[]string)
	prune:   bool @go(Prune)
	dryRun?: bool @go(DryRun)
}

#RepositoryList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items?: [...#Repository] @go(Items,[]Repository)
}
