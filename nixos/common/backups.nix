{ config, pkgs, lib, ... }:

let
  backblazeSecrets = (import ../../secret/passwords.nix).backblaze;

  volumes = config.machine.backup.volumes;
  dests = [
    {
      name = "beagle2";
      urlFor = volumeName: "sftp://kier@beagle2.h.cascade//home/kier/backup/${volumeName}";
      options = [ "--asynchronous-upload" ];
    }
    {
      name = "backblaze";
      urlFor = volumeName: "b2://${backblazeSecrets.accountID}:${backblazeSecrets.appKey}@KierBackup/duplicity-0/${volumeName}";
      options = [];
    }
  ];

  baseDuplicityCommand = [
    "${pkgs.duplicity}/bin/duplicity"
    "--verbosity" "info"
    "--encrypt-key" config.environment.variables.GPG_MASTER_KEY
    "--sign-key" config.environment.variables.GPG_BACKUP_SIGNING_KEY
    "--use-agent"
    (lib.optionals (config.machine.backup.tempDir != null) [ "--tempdir" config.machine.backup.tempDir ])
    (lib.optionals (config.machine.backup.archiveDir != null) [ "--archive-dir" config.machine.backup.archiveDir ])
  ];

  mkBackupCommand = volume: dest: lib.flatten [
    baseDuplicityCommand
    dest.options
    volume.path
    (dest.urlFor volume.name)
  ];

  mkCleanupCommand = volume: dest: lib.flatten [
    baseDuplicityCommand
    dest.options
    "cleanup"
    "--force"
    (dest.urlFor volume.name)
  ];

  mkScript = volume: dest: pkgs.writeShellScriptBin "backup-${volume.name}-${dest.name}" ''
    set -o errexit -o nounset -o pipefail
    if [ "''${1:-}" = "-c" ]; then
      echo "Cleaning up..." >&2
      ${lib.escapeShellArgs (mkCleanupCommand volume dest)}
    else
      echo "Backing up..." >&2
      ${volume.before}
      ${lib.escapeShellArgs (mkBackupCommand volume dest)}
      ${volume.after}
    fi
  '';

  scripts = lib.flatten (map (volume: map (dest: mkScript volume dest) dests) volumes);

in {
  environment.systemPackages = scripts;
}
