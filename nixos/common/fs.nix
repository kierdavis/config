{ config, lib, pkgs, ... }:

{
  # mount a tmpfs on /tmp
  boot.tmpOnTmpfs = lib.mkDefault true;

  # Don't forcibly import ZFS pools during boot.
  boot.zfs = {
    forceImportAll = false;
    forceImportRoot = false;
  };
  boot.loader.grub.zfsSupport = true;

  # Hard disk spin-down time / Advanced Power Management.
  # https://wiki.archlinux.org/index.php/hdparm#Tips_and_tricks
  # Match only devices named by the kernel as sd[a-z].
  # Match only devices for which /sys/block/<name>/queue/rotational contains "1".
  # Run hdparm to set the Advanced Power Management level (-B) and the spindown time (-S).
  # APM levels:
  #   1 is most power efficient, 254 gives best I/O performance.
  #   1-127 allow spindown, 128-254 do not.
  # Spindown time:
  #   See 'man hdparm'.
  #   Generally, -S n means n*5 seconds.
  services.udev.extraRules = ''
    KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"
  '';

  # By default this is in /etc, which is not very NixOS-friendly.
  environment.variables.LVM_SYSTEM_DIR = "/var/lvm";

  boot.supportedFilesystems = ["ceph"];
  systemd.mounts = [
    {
      what = "10.88.231.188,10.88.217.59,10.88.229.207:/volumes/csi/csi-vol-23cf9906-f0f6-11ed-b9cc-3e0e69dd55bf/1f476827-8983-451a-af71-3b7a29e1b6be";
      where = "/net/skaia/media";
      type = "ceph";
      options = "fs=fs-media0,name=${config.networking.hostName},secretfile=/etc/ceph-client-secret";
      requires = ["skaia-connectivity-test.service"];
      after = ["skaia-connectivity-test.service"];
      wantedBy = ["remote-fs.target"];
      before = ["remote-fs.target"];
    }
    {
      what = "10.88.231.188,10.88.217.59,10.88.229.207:/volumes/csi/csi-vol-e75ccde2-f0ba-11ed-b9cc-3e0e69dd55bf/2cbd7c57-2bcc-45b8-bef2-cd5092a302ee";
      where = "/net/skaia/torrent-downloads";
      type = "ceph";
      options = "fs=fs-media0,name=${config.networking.hostName},secretfile=/etc/ceph-client-secret,ro";
      requires = ["skaia-connectivity-test.service"];
      after = ["skaia-connectivity-test.service"];
      wantedBy = ["remote-fs.target"];
      before = ["remote-fs.target"];
    }
  ];

  # UID/GID used for files on CephFS filesystems where permissioning doesn't matter.
  users.groups.cephfsdata = {
    gid = 2000;
  };
  users.users.cephfsdata = {
    createHome = false;
    description = "Owner of data on shared filesystems";
    group = "cephfsdata";
    isNormalUser = false;
    isSystemUser = true;
    uid = 2000;
    useDefaultShell = true;
  };
  users.users.kier.extraGroups = ["cephfsdata"];

  # For the partprobe command.
  environment.systemPackages = [ pkgs.parted ];
}
