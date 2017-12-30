#!/bin/sh
set -o errexit -o pipefail -o nounset

name=$1

dir=$PWD/containers/$name
remote=beagle2

echo "***** Building image"
image=$(nix-build --no-out-link $dir/dockerimage.nix)
echo "***** Uploading image to beagle2"
pv $image | ssh $remote 'docker load'

imagename=campanella-$name
containername=campanella-$name-c

servicedir=/home/kier/.config/systemd/user
servicename=campanella-$name.service
servicefile=$servicedir/$servicename
dockerflags=$(cat $dir/dockerflags.txt)

echo "***** Restarting service"
ssh $remote bash << EOF1
systemctl --user stop $servicename || true
mkdir -p $servicedir
cat > $servicefile << EOF2
[Service]
Type=simple
ExecStartPre=-/usr/bin/docker kill $containername
ExecStartPre=-/usr/bin/docker rm --force $containername
ExecStart=/usr/bin/docker run --name=$containername $dockerflags $imagename
ExecStop=/usr/bin/docker stop $containername
ExecStopPost=/usr/bin/docker rm --force $containername
Restart=on-abnormal
[Install]
WantedBy=default.target
EOF2
systemctl --user daemon-reload
systemctl --user start $servicename
EOF1
