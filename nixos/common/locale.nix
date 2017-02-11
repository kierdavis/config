{ config, lib, pkgs, ... }:

{
  # Locale.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Console font.
  i18n.consoleFont = "Lat2-Terminus16";

  # Keyboard layout.
  i18n.consoleKeyMap = "uk";
  services.xserver.layout = "gb";

  # Time zone.
  time.timeZone = "Europe/London";
}
