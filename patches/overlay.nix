self: super: {
  jemalloc = super.callPackage ./jemalloc { };
  openvpn23 = super.callPackage ./openvpn23 { };
}
