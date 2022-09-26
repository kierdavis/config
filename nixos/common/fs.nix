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

  fileSystems."/net/hist5/torrent-downloads" = {
    fsType = "ceph";
    device = "10.181.9.32,10.181.12.17,10.181.11.232:/volumes/csi/csi-vol-9551265a-3c76-11ed-859d-b2fd75dbc430/19c5abc3-c6b0-4ada-99e3-28857b4ff777";
    options = [
      "name=${config.hist5.ceph.auth.mountUniversal.clientName}"
      "secret=${config.hist5.ceph.auth.mountUniversal.secretKey}"
      "ro"
    ];
  };
}
