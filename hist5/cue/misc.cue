package hist5

// Cheapest in Europe as of Aug 2022.
gcpRegion: "europe-west1"

gcpOrganisationId: string
gcpBillingAccountId: string

versions: talos: "1.2.1"

// UID/GID used for files on CephFS filesystems where permissioning doesn't matter.
sharedFilesystemUid: 2000
