{ config, lib, pkgs, ... }:

{
  fileSystems."/net/gyroscope" = {
    device = "gyroscope:/net/gyroscope";
    fsType = "nfs";
    options = [
      "vers=4"      # NFS version 4.
      "timeo=20"    # Timeout on requests before retransmission is attempted, in tenths of a second.
      "retrans=1"   # Number of times retransmission will be attempted before reporting failure.
      "soft"        # If all retransmissions fail, report an I/O error rather than continuing to retry forever.
      "noatime"     # Don't update file access times.
      "nodiratime"  # Don't update directory access times.
      "noauto"      # Don't mount at boot.
      "x-systemd.automount"          # Mount automatically when accessed.
      "x-systemd.idle-timeout=10min" # Unmount automatically when not used for 10 minutes.
    ];
  };
}
