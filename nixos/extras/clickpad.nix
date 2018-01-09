# synaptics config for ThinkPad clickpad
# http://www.thinkwiki.org/wiki/Buttonless_Touchpad

{ config, lib, pkgs, ... }:

{
  services.xserver.synaptics = {
    enable = true;
    additionalOptions = ''
      Option "SoftButtonAreas" "60% 0 0 2400 40% 60% 0 2400"
      Option "AreaTopEdge" "2400"

      Option "VertHysteresis" "50"
      Option "HorizHysteresis" "50"

      Option "LockedDrags" "1"

      Option "FingerLow" "50"
      Option "FingerHigh" "55"

      Option "AccelerationProfile" "2"
      Option "ConstantDeceleration" "4"
    '';

    tapButtons = false;
    #fingersMap = [ 1 3 2 ];

    horizontalScroll = true;
    vertEdgeScroll = true;
    horizEdgeScroll = true;
    vertTwoFingerScroll = false;
    horizTwoFingerScroll = false;
    scrollDelta = 30;

    palmDetect = true;
    palmMinWidth = 5;
    palmMinZ = 40;

    minSpeed = "0.5";
    maxSpeed = "1.5";
  };
}
