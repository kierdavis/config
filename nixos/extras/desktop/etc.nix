{ config, lib, pkgs, ... }:

{
  environment.etc."i3blocks.conf".text = ''
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

    [vram]
    interval=5

    [cpu]
    interval=5
    instance=${config.machine.i3blocks.cpuThermalZone}

    [gpu]
    interval=5

    [load]
    interval=5

    [time]
    interval=5
  '';
}
