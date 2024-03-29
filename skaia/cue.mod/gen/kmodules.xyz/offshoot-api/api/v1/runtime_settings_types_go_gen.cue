// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go kmodules.xyz/offshoot-api/api/v1

package v1

import core "k8s.io/api/core/v1"

#RuntimeSettings: {
	pod?:       null | #PodRuntimeSettings       @go(Pod,*PodRuntimeSettings) @protobuf(1,bytes,opt)
	container?: null | #ContainerRuntimeSettings @go(Container,*ContainerRuntimeSettings) @protobuf(2,bytes,opt)
}

#PodRuntimeSettings: {
	// PodAnnotations are the annotations that will be attached with the respective Pod
	// +optional
	podAnnotations?: {[string]: string} @go(PodAnnotations,map[string]string) @protobuf(1,bytes,rep)

	// NodeSelector is a selector which must be true for the pod to fit on a node.
	// Selector which must match a node's labels for the pod to be scheduled on that node.
	// More info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
	// +optional
	nodeSelector?: {[string]: string} @go(NodeSelector,map[string]string) @protobuf(2,bytes,rep)

	// ServiceAccountName is the name of the ServiceAccount to use to run this pod.
	// More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
	// +optional
	serviceAccountName?: string @go(ServiceAccountName) @protobuf(3,bytes,opt)

	// ServiceAccountAnnotations are the annotations that will be attached with the respective ServiceAccount
	// +optional
	serviceAccountAnnotations?: {[string]: string} @go(ServiceAccountAnnotations,map[string]string) @protobuf(4,bytes,rep)

	// AutomountServiceAccountToken indicates whether a service account token should be automatically mounted.
	// +optional
	automountServiceAccountToken?: null | bool @go(AutomountServiceAccountToken,*bool) @protobuf(5,varint,opt)

	// NodeName is a request to schedule this pod onto a specific node. If it is non-empty,
	// the scheduler simply schedules this pod onto that node, assuming that it fits resource
	// requirements.
	// +optional
	nodeName?: string @go(NodeName) @protobuf(6,bytes,opt)

	// Security options the pod should run with.
	// More info: https://kubernetes.io/docs/concepts/policy/security-context/
	// More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	// +optional
	securityContext?: null | core.#PodSecurityContext @go(SecurityContext,*core.PodSecurityContext) @protobuf(7,bytes,opt)

	// ImagePullSecrets is an optional list of references to secrets in the same namespace to use for pulling any of the images used by this PodRuntimeSettings.
	// If specified, these secrets will be passed to individual puller implementations for them to use. For example,
	// in the case of docker, only DockerConfig type secrets are honored.
	// More info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod
	// +optional
	imagePullSecrets?: [...core.#LocalObjectReference] @go(ImagePullSecrets,[]core.LocalObjectReference) @protobuf(8,bytes,rep)

	// If specified, the pod's scheduling constraints
	// +optional
	affinity?: null | core.#Affinity @go(Affinity,*core.Affinity) @protobuf(9,bytes,opt)

	// If specified, the pod will be dispatched by specified scheduler.
	// If not specified, the pod will be dispatched by default scheduler.
	// +optional
	schedulerName?: string @go(SchedulerName) @protobuf(10,bytes,opt)

	// If specified, the pod's tolerations.
	// +optional
	tolerations?: [...core.#Toleration] @go(Tolerations,[]core.Toleration) @protobuf(11,bytes,rep)

	// If specified, indicates the pod's priority. "system-node-critical" and
	// "system-cluster-critical" are two special keywords which indicate the
	// highest priorities with the former being the highest priority. Any other
	// name must be defined by creating a PriorityClass object with that name.
	// If not specified, the pod priority will be default or zero if there is no
	// default.
	// +optional
	priorityClassName?: string @go(PriorityClassName) @protobuf(12,bytes,opt)

	// The priority value. Various system components use this field to find the
	// priority of the pod. When Priority Admission Controller is enabled, it
	// prevents users from setting this field. The admission controller populates
	// this field from PriorityClassName.
	// The higher the value, the higher the priority.
	// +optional
	priority?: null | int32 @go(Priority,*int32) @protobuf(13,varint,opt)

	// If specified, all readiness gates will be evaluated for pod readiness.
	// A pod is ready when all its containers are ready AND
	// all conditions specified in the readiness gates have status equal to "True"
	// More info: https://git.k8s.io/enhancements/keps/sig-network/0007-pod-ready%2B%2B.md
	// +optional
	readinessGates?: [...core.#PodReadinessGate] @go(ReadinessGates,[]core.PodReadinessGate) @protobuf(14,bytes,rep)

	// RuntimeClassName refers to a RuntimeClass object in the node.k8s.io group, which should be used
	// to run this pod.  If no RuntimeClass resource matches the named class, the pod will not be run.
	// If unset or empty, the "legacy" RuntimeClass will be used, which is an implicit class with an
	// empty definition that uses the default runtime handler.
	// More info: https://git.k8s.io/enhancements/keps/sig-node/runtime-class.md
	// This is an alpha feature and may change in the future.
	// +optional
	runtimeClassName?: null | string @go(RuntimeClassName,*string) @protobuf(15,bytes,opt)

	// EnableServiceLinks indicates whether information about services should be injected into pod's
	// environment variables, matching the syntax of Docker links.
	// Optional: Defaults to true.
	// +optional
	enableServiceLinks?: null | bool @go(EnableServiceLinks,*bool) @protobuf(16,varint,opt)

	// TopologySpreadConstraints describes how a group of pods ought to spread across topology
	// domains. Scheduler will schedule pods in a way which abides by the constraints.
	// All topologySpreadConstraints are ANDed.
	// +optional
	// +patchMergeKey=topologyKey
	// +patchStrategy=merge
	// +listType=map
	// +listMapKey=topologyKey
	// +listMapKey=whenUnsatisfiable
	topologySpreadConstraints?: [...core.#TopologySpreadConstraint] @go(TopologySpreadConstraints,[]core.TopologySpreadConstraint) @protobuf(17,bytes,rep)
}

#ContainerRuntimeSettings: {
	// Compute Resources required by container.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
	// +optional
	resources?: core.#ResourceRequirements @go(Resources) @protobuf(1,bytes,opt)

	// Periodic probe of container liveness.
	// Container will be restarted if the probe fails.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	// +optional
	livenessProbe?: null | core.#Probe @go(LivenessProbe,*core.Probe) @protobuf(2,bytes,opt)

	// Periodic probe of container service readiness.
	// Container will be removed from service endpoints if the probe fails.
	// Cannot be updated.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	// +optional
	readinessProbe?: null | core.#Probe @go(ReadinessProbe,*core.Probe) @protobuf(3,bytes,opt)

	// Actions that the management system should take in response to container lifecycle events.
	// Cannot be updated.
	// +optional
	lifecycle?: null | core.#Lifecycle @go(Lifecycle,*core.Lifecycle) @protobuf(4,bytes,opt)

	// Security options the pod should run with.
	// More info: https://kubernetes.io/docs/concepts/policy/security-context/
	// More info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	// +optional
	securityContext?: null | core.#SecurityContext @go(SecurityContext,*core.SecurityContext) @protobuf(5,bytes,opt)

	// Settings to configure `nice` to throttle the load on cpu.
	// More info: http://kennystechtalk.blogspot.com/2015/04/throttling-cpu-usage-with-linux-cgroups.html
	// More info: https://oakbytes.wordpress.com/2012/06/06/linux-scheduler-cfs-and-nice/
	// +optional
	nice?: null | #NiceSettings @go(Nice,*NiceSettings) @protobuf(6,bytes,opt)

	// Settings to configure `ionice` to throttle the load on disk.
	// More info: http://kennystechtalk.blogspot.com/2015/04/throttling-cpu-usage-with-linux-cgroups.html
	// More info: https://oakbytes.wordpress.com/2012/06/06/linux-scheduler-cfs-and-nice/
	// +optional
	ionice?: null | #IONiceSettings @go(IONice,*IONiceSettings) @protobuf(7,bytes,opt)

	// List of sources to populate environment variables in the container.
	// The keys defined within a source must be a C_IDENTIFIER. All invalid keys
	// will be reported as an event when the container is starting. When a key exists in multiple
	// sources, the value associated with the last source will take precedence.
	// Values defined by an Env with a duplicate key will take precedence.
	// Cannot be updated.
	// +optional
	envFrom?: [...core.#EnvFromSource] @go(EnvFrom,[]core.EnvFromSource) @protobuf(8,bytes,rep)

	// List of environment variables to set in the container.
	// Cannot be updated.
	// +optional
	// +patchMergeKey=name
	// +patchStrategy=merge
	env?: [...core.#EnvVar] @go(Env,[]core.EnvVar) @protobuf(9,bytes,rep)
}

// https://linux.die.net/man/1/nice
#NiceSettings: {
	adjustment?: null | int32 @go(Adjustment,*int32) @protobuf(1,varint,opt)
}

// https://linux.die.net/man/1/ionice
#IONiceSettings: {
	class?:     null | int32 @go(Class,*int32) @protobuf(1,varint,opt)
	classData?: null | int32 @go(ClassData,*int32) @protobuf(2,varint,opt)
}
