{ config, lib, pkgs, ... }:

let
  nvidiaGpuConfig = if config.machine.gpu.nvidia then ''
    [vram]
    interval=5

    [gpu]
    interval=5
  '' else "";

  batteryConfig = lib.concatMapStrings (name: ''
    [bat]
    interval=5
    instance=${name}
  '') config.machine.i3blocks.batteries;

in {
  environment.etc."xdg/i3blocks/config".text = ''
    command=/run/current-system/sw/bin/i3blocks-$BLOCK_NAME

    [disk]
    interval=10
    instance=/

    [disk]
    interval=10
    instance=/home

    [eth]
    interval=10
    instance=${config.machine.i3blocks.ethInterface}

    [wlan]
    interval=10
    instance=${config.machine.i3blocks.wlanInterface}

    [mem]
    interval=5

    [swap]
    interval=5

    [cpu]
    interval=5
    instance=${config.machine.i3blocks.cpuThermalZone}

    ${nvidiaGpuConfig}

    ${batteryConfig}

    [load]
    interval=5

    [time]
    interval=5
  '';
}
