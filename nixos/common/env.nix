{ config, lib, pkgs, ... }:

{
  environment.variables = {
    GPG_MASTER_KEY = "8139C5FCEDA73ABF";
    GPG_ENCRYPTION_KEY = "DFDCA524B0742D62";
    GPG_GIT_SIGNING_KEY = "66378DA35FF9F0FA";
    GPG_BACKUP_SIGNING_KEY = "EC1301FD757E43F7";

    TMUX_TMPDIR = lib.mkForce "/tmp";

    EDITOR = "kak";

    CUPS_SERVER = "printing.hist:80";
    PRINTER = "HP_Envy_5640";
  };
}
