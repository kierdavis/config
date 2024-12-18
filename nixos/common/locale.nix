{ config, lib, pkgs, ... }:

{
  # Locale.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Console font.
  console.font = "Lat2-Terminus16";

  # Keyboard layout.
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb";

  # Time zone.
  time.timeZone = "Europe/London";

  # Location (used by redshift).
  location = {
    latitude = 53.48;
    longitude = -2.25;
  };
}
