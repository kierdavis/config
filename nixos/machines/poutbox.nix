{ config, lib, pkgs, ... }:

let
  baseI3Config = ../../i3;

  extraI3Config = pkgs.writeText "extra-i3config" ''
    for_window [class="poutbox-pout"] fullscreen enable

    exec /run/current-system/sw/bin/bash -c "/run/current-system/sw/bin/systemd-notify --ready SWAYSOCK=$SWAYSOCK WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
  '';

  i3Config = pkgs.runCommand "i3config" {} "cat ${baseI3Config} ${extraI3Config} > $out";

in {
  imports = [
    ../common
    ../extras/platform/raspberry-pi-3.nix
    ../extras/wifi.nix
  ];

  machine = {
    name = "poutbox";
    wifi = false;
    ipv6-internet = false;
    cpu = {
      cores = 1;
      intel = false;
    };
  };

  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };

  # XXX hack, this should be made optional
  services.syncthing.enable = lib.mkForce false;

  boot.plymouth.enable = true;

  # Complicated boot process incoming...
  # The entry point is the default unit, which is what systemd starts once the root filesystem is mounted.
  systemd.defaultUnit = "graphical.target";
  # graphical.target pulls in the system service that wraps the graphical session, auto-graphical-session.service.
  systemd.services.auto-graphical-session.wantedBy = [ "graphical.target" ];
  # The system service needs general system functionality before it can be started.
  systemd.services.auto-graphical-session.requires = [ "multi-user.target" ];
  systemd.services.auto-graphical-session.after = [ "multi-user.target" ];
  # The system service kicks getty off of the terminal that we want to eventually start the compositor on.
  systemd.services.auto-graphical-session.conflicts = [ "getty@tty1.service" ];
  # Configure the user/group that the PAM/logind session will be opened for,
  # and that the service will later drop privileges to execute as.
  systemd.services.auto-graphical-session.serviceConfig.User = "kier";
  systemd.services.auto-graphical-session.serviceConfig.Group = "users";
  # The system service opens a PAM session.
  systemd.services.auto-graphical-session.serviceConfig.PAMName = "auto-graphical-session";
  # The PAM session opens a logind session. These env vars are consumed by pam_systemd
  # and control the attributes of the logind session.
  systemd.services.auto-graphical-session.environment.XDG_SESSION_TYPE = "wayland";
  systemd.services.auto-graphical-session.environment.XDG_SESSION_CLASS = "user";
  systemd.services.auto-graphical-session.environment.XDG_SESSION_DESKTOP = "sway";
  systemd.services.auto-graphical-session.environment.XDG_SEAT = "seat0";
  systemd.services.auto-graphical-session.environment.XDG_VTNR = "1";
  security.pam.services.auto-graphical-session.startSession = true;
  # pam_systemd has now set XDG_SESSION_ID and XDG_RUNTIME_DIR in our environment.
  # Next, the startup script of the system service will execute.
  # We need to inject the variables given to us by pam_systemd into the shared
  # environment of the user bus.
  # Then we pass control to the user-mode systemd bus by telling it to start graphical-session.target.
  # `systemctl --user start` will return once the compositor is started.
  # The PAM session we created earlier will get closed when the service's main process
  # (the shell executing this script) exits, hence the `sleep infinity` to keep the session alive.
  systemd.services.auto-graphical-session.serviceConfig.Type = "simple";
  systemd.services.auto-graphical-session.script = ''
    /run/current-system/sw/bin/systemctl --user import-environment XDG_SESSION_ID XDG_RUNTIME_DIR
    /run/current-system/sw/bin/systemctl --user start graphical-session.target
    exec sleep infinity
  '';
  # The user-mode graphical target pulls in the compositor.
  systemd.user.services.sway = {
    description = "Sway compositor";
    requiredBy = [ "graphical-session.target" ];
    requires = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    script = ''
      export PATH=$PATH:/run/current-system/sw/bin
      exec /run/current-system/sw/bin/sway --config ${i3Config}
    '';
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
    };
  };
  programs.sway.enable = true;
  # Pout is also pulled in as part of a graphical session, and depends on sway.
  systemd.user.services.pout = {
    description = "Pout photo studio";
    wantedBy = [ "graphical-session.target" ];
    requires = [ "sway.service" ];
    after = [ "sway.service" ];
    script = ''
      exec ${pkgs.pout}/bin/pout
    '';
  };

  # When auto-graphical-session.service is stopped, the main process (sleep infinity) is killed.
  # A helper process known as "(sd-pam)" notices that the main process has died and cleans up the PAM+logind sessions.
  # If auto-graphical-session.service is stopped, also stop graphical-session.target.
  systemd.services.auto-graphical-session.postStop = ''
    /run/current-system/sw/bin/systemctl --user stop graphical-session.target
    /run/current-system/sw/bin/systemctl --user unset-environment XDG_SESSION_ID XDG_RUNTIME_DIR
  '';
  # If graphical-session.target is stopped/restarted, also stop/restart sway.
  systemd.user.services.sway.partOf = [ "graphical-session.target" ];

  # Metadata
  systemd.services.auto-graphical-session.description = "Auto-start graphical session for user kier";
  
  services.mingetty.autologinUser = "kier";
  environment.systemPackages = [ pkgs.pout pkgs.terminator pkgs.xwayland ];
}
