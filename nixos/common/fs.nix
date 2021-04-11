{ config, lib, pkgs, ... }:

{
  # mount a tmpfs on /tmp
  boot.tmpOnTmpfs = true;

  # Don't forcibly import ZFS pools during boot.
  boot.zfs = {
    forceImportAll = false;
    forceImportRoot = false;
  };
  boot.loader.grub.zfsSupport = true;

#  # ZFS auto-snapshotting
#  services.zfs.autoSnapshot = {
#    enable = true;
#    frequent = 4; # every 15 minutes
#    hourly = 4;
#    daily = 7;
#    weekly = 4;
#    monthly = 6;
#  };

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

  # boot.supportedFilesystems = ["nfs"];
}
