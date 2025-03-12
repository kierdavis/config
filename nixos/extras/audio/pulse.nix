{ config, lib, pkgs, ... }:

let
  # https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#No_sound_below_a_volume_cutoff
  pulseConfig = pkgs.runCommand "default.pa" { pulseaudio = config.hardware.pulseaudio.package; } ''
    substitute $pulseaudio/etc/pulse/default.pa $out --replace 'load-module module-udev-detect' 'load-module module-udev-detect ignore_dB=1'
  '';

in {
  # TODO: PipeWire is the NixOS default as of 24.11, and appears to be
  # able to emulate both a PulseAudio server and a Jack server.
  # Consider switching to it?

  services.pipewire.enable = false;
  services.pipewire.audio.enable = false;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; # Might be necessary for some Steam games.
  hardware.pulseaudio.configFile = pulseConfig;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  environment.systemPackages = [ pkgs.pavucontrol ];

  # required for fluidsynth
  security.pam.loginLimits = [
    { domain = "@audio"; type = "-"; item = "rtprio"; value = "90"; }
    { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];
}
