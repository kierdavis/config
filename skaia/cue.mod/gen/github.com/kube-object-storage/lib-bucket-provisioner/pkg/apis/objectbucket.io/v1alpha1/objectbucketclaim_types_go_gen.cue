// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/kube-object-storage/lib-bucket-provisioner/pkg/apis/objectbucket.io/v1alpha1

package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

#ObjectBucketClaimKind: "ObjectBucketClaim"

// ObjectBucketClaimSpec defines the desired state of ObjectBucketClaim
#ObjectBucketClaimSpec: {
	// StorageClass names the StorageClass object representing the desired provisioner and parameters
	storageClassName: string @go(StorageClassName)

	// BucketName (not recommended) the name of the bucket.  Caution!
	// In-store bucket names may collide across namespaces.  If you define
	// the name yourself, try to make it as unique as possible.
	// +optional
	bucketName: string @go(BucketName)

	// GenerateBucketName (recommended) a prefix for a bucket name to be
	// followed by a hyphen and 5 random characters. Protects against
	// in-store name collisions.
	// +optional
	generateBucketName?: string @go(GenerateBucketName)

	// AdditionalConfig gives providers a location to set
	// proprietary config values (tenant, namespace, etc)
	// +optional
	additionalConfig?: {[string]: string} @go(AdditionalConfig,map[string]string)

	// ObjectBucketName is the name of the object bucket resource. This is the authoritative
	// determination for binding.
	objectBucketName?: string @go(ObjectBucketName)
}

// ObjectBucketClaimStatusPhase is set by the controller to save the state of the provisioning process.
#ObjectBucketClaimStatusPhase: string

// ObjectBucketClaimStatusPhasePending indicates that the provisioner has begun handling the request and that it is
// still in process
#ObjectBucketClaimStatusPhasePending: "Pending"

// ObjectBucketClaimStatusPhaseBound indicates that provisioning has succeeded, the objectBucket is marked bound, and
// there is now a configMap and secret containing the appropriate bucket data in the namespace of the claim
#ObjectBucketClaimStatusPhaseBound: "Bound"

// ObjectBucketClaimStatusPhaseReleased TODO this would likely mean that the OB was deleted. That situation should never
// happen outside of the claim being deleted.  So this state shouldn't naturally arise out of automation.
#ObjectBucketClaimStatusPhaseReleased: "Released"

// ObjectBucketClaimStatusPhaseFailed indicates that provisioning failed.  There should be no configMap, secret, or
// object bucket and no bucket should be left hanging in the object store
#ObjectBucketClaimStatusPhaseFailed: "Failed"

// ObjectBucketClaimStatus defines the observed state of ObjectBucketClaim
#ObjectBucketClaimStatus: {
	phase?: #ObjectBucketClaimStatusPhase @go(Phase)
}

// ObjectBucketClaim is the Schema for the objectbucketclaims API
#ObjectBucketClaim: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta       @go(ObjectMeta)
	spec?:     #ObjectBucketClaimSpec   @go(Spec)
	status?:   #ObjectBucketClaimStatus @go(Status)
}

// ObjectBucketClaimList contains a list of ObjectBucketClaim
#ObjectBucketClaimList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#ObjectBucketClaim] @go(Items,[]ObjectBucketClaim)
}
