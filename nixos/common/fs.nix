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

  fileSystems."/net/skaia/torrent-downloads" = {
    fsType = "ceph";
    device = "10.88.234.14,10.88.200.103,10.88.225.6:/volumes/csi/csi-vol-d2f2e43d-6926-11ed-b262-a6adf78fc049/7ab73f0e-d778-4c28-ac8b-041f63381ff1";
    options = [
      "name=${config.networking.hostName}"
      "secretfile=/etc/ceph-client-secret"
      "ro"
    ];
  };

  users.groups.cephfsdata = {
    #gid = config.hist5.sharedFilesystemUid;
  };
  users.users.cephfsdata = {
    createHome = false;
    description = "Owner of data on shared filesystems";
    group = "cephfsdata";
    isNormalUser = false;
    isSystemUser = true;
    #uid = config.hist5.sharedFilesystemUid;
    useDefaultShell = true;
  };
  users.users.kier.extraGroups = ["cephfsdata"];

  # For the partprobe command.
  environment.systemPackages = [ pkgs.parted ];
}
