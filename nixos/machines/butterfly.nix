# Butterfly is a server running kubernetes.
# It is named after the song Butterfly by Swingrowers.

let
  network = import ../../network.nix;

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "butterfly";
    wifi = false;
    ipv6-internet = true;
    cpu = {
      cores = 8;
      intel = true;
    };
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-label/bfy_root";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-label/bfy_home";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-label/bfy_docker";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems.efi.device = "/dev/disk/by-label/bfy_efi";
  boot.loader.grub.device = "/dev/disk/by-id/usb-Generic_Flash_Disk_FEB9E43C-0:0";

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "45f7886d";

  boot.initrd.availableKernelModules = [ "ahci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # XXX hack, this should be made optional
  services.syncthing.enable = lib.mkForce false;

  networking.wireguard = {
    enable = true;
    interfaces.wg-k8s = let
      localAddr = network.byName."k8s-vpn.butterfly.cascade".address;
      remoteAddr = network.byName."k8s-vpn.beagle2.cascade".address;
      prefixLength = network.byName."k8s-vpn.network.cascade".prefixLength;
      endpointAddr = network.byName."pub4.beagle2.cascade".address;
      endpointPort = 14137;
    in {
      ips = [ "${localAddr}/${builtins.toString prefixLength}" ];
      privateKey = (import ../../secret/passwords.nix).butterfly-k8s-vpn-priv-key;
      peers = [ {
        endpoint = "${endpointAddr}:${builtins.toString endpointPort}";
        publicKey = "mYnDERLKGuwmWSS6PkAdTuBnjnqr+hzg9n0VlnLJd3Q=";
        allowedIPs = [ "${remoteAddr}/32" ];
        persistentKeepalive = 25;
      } ];
    };
  };
  networking.firewall.interfaces.wg-k8s = {
    allowedTCPPorts = [
      10250  # kubelet
    ];
  };

  services.kubernetes = let
    kubeconfig = {
      caFile = ../../k8s-ca.pem;
      certFile = ../../secret/butterfly-kubelet.crt;
      keyFile = ../../secret/butterfly-kubelet.key;
    };
  in {
    kubelet = {
      enable = true;
      unschedulable = false;
      nodeIp = network.byName."k8s-vpn.butterfly.cascade".address;
      networkPlugin = "cni";
      cni.configDir = "/etc/cni/net.d";  # weave-net pod writes into this directory
      clusterDns = "10.96.0.10";
      inherit kubeconfig;
    };
    dataDir = "/var/lib/kubelet";  # must be consistent across all nodes in the cluster, else things break e.g. csi mounting
    masterAddress = network.byName."pub4.beagle2.cascade".address;
    inherit (kubeconfig) caFile;
  };
}
