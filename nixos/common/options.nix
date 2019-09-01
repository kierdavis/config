{ lib, ... }:

with lib;

{
  options = {
    machine.name = mkOption {
      type = types.string;
      description = ''The machine's hostname.'';
    };

    machine.wifi = mkOption {
      type = types.bool;
      description = ''Whether to enable wireless networking.'';
    };

    machine.ipv6-internet = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''Whether the machine has access to the Internet over IPv6 as well as IPv4.'';
    };

    machine.cpu.cores = mkOption {
      type = types.int;
      description = ''Number of processor cores (specifically, max number of Nix jobs to run in parallel).'';
    };

    machine.cpu.intel = mkOption {
      type = types.bool;
      default = false;
      description = ''Whether the machine has an Intel CPU, and so should enable Intel microcode updates.'';
    };

    machine.gpu.nvidia = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''Whether the machine has an NVIDIA graphics card, and so should enable the corresponding graphics driver.'';
    };

    machine.i3blocks.cpuThermalZone = mkOption {
      type = types.string;
      example = "thermal_zone2";
      description = ''Subdirectory of /sys/class/thermal representing the CPU temperature sensor.'';
    };

    machine.i3blocks.ethInterface = mkOption {
      type = types.string;
      example = "enp4s0";
      description = ''Name of the Ethernet network interface.'';
    };

    machine.i3blocks.wlanInterface = mkOption {
      type = types.string;
      example = "wlp3s0";
      description = ''Name of the WiFi network interface.'';
    };

    machine.i3blocks.batteries = mkOption {
      type = types.listOf types.string;
      default = [];
      example = ''[ "BAT0" "BAT1" ]'';
      description = ''Subdirectories of /sys/class/power_supply representing batteries whose charge level should be displayed.'';
    };

    machine.backup.tempDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/var/cache/duplicity/tmp";
      description = ''Location of the duplicity scratch directory.'';
    };

    machine.backup.archiveDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/var/cache/duplicity/archive";
      description = ''Location of the duplicity archive directory.'';
    };

    machine.backup.volumes = let
      volumeType = types.submodule {
        options = {
          name = mkOption {
            type = types.string;
            description = ''Name of the volume (e.g. archive-0) to be used in destination URLs.'';
          };
          path = mkOption {
            type = types.path;
            description = ''Location of the volume on disk.'';
          };
          before = mkOption {
            type = types.string;
            default = "";
            description = ''Script to run before performing the backup.'';
          };
          after = mkOption {
            type = types.string;
            default = "";
            description = ''Script to run after performing the backup.'';
          };
        };
      };
    in mkOption {
      type = types.listOf volumeType;
      default = [];
      example = ''[ { name = "archive-0"; path = "/data/archive"; } ]'';
      description = ''Backup volumes.'';
    };
  };
}
