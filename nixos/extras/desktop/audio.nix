{ config, lib, pkgs, ... }:

let
  # https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#No_sound_below_a_volume_cutoff
  pulseConfig = pkgs.runCommand "default.pa" { pulseaudio = config.hardware.pulseaudio.package; } ''
    substitute $pulseaudio/etc/pulse/default.pa $out --replace 'load-module module-udev-detect' 'load-module module-udev-detect ignore_dB=1'
  '';

in {
  # Enable pulseaudio.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; # Might be necessary for some Steam games.
  hardware.pulseaudio.configFile = pulseConfig;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
}
