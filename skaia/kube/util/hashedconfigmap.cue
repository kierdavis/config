package util

import (
	"crypto/md5"
	"encoding/json"
	"encoding/hex"
	"strings"
)

HashedConfigMap: {
	namespace:  string
	namePrefix: string
	metadata: {}
	data: {}
	dataHash:     hex.Encode(strings.ByteSlice(md5.Sum(json.Marshal(data)), 0, 5))
	computedName: "\(namePrefix)-\(dataHash)"
	resources: configmaps: "\(namespace)": "\(computedName)": {
		"metadata": metadata
		"data":     data
	}
}
