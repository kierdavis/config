{ ansible
, coreutils
, fetchFromGitHub
, fetchurl
, git
, lib
, lzma
, openssl
, perl
, stdenv
, wimboot

, withMenus ? true
, withLegacyDisks ? true
, withLinuxDisks ? true
, withEFIDisks ? true
}:

let
  withARMDisks = false;  # cross-compiling not supported yet
  withRPiDisks = false;

  withDisks = withLegacyDisks || withLinuxDisks || withEFIDisks || withARMDisks || withRPiDisks;

  ipxe = fetchFromGitHub {
    owner = "ipxe";
    repo = "ipxe";
    rev = "70995397e5bdfd3431e12971aa40630c7014785f";
    leaveDotGit = true;
    postFetch = ''
      sed -i s,/bin/echo,echo,g $out/src/Makefile.housekeeping
    '';
    hash = "sha256-9SR6oj62fFcz1CVHX07rj0iuigVHzz3n/fIM9Cu5QCE=";
  };
  ipxeCA = fetchurl {
    url = "https://ca.ipxe.org/ca.crt";
    hash = "sha256-DXVHxibSR53rA0Vf/EflY4VbuVZdjT00irctHun4fJY=";
  };
  pciids = fetchFromGitHub {
    owner = "netbootxyz";
    repo = "pciids";
    rev = "6307c4e18138cbc0487219c215e0d65dd755a49c";
    hash = "sha256-iGS2vszXAUCDDJHFTtabgE/NQA+5IUpkKiTj1tro1O4=";
  };
in

stdenv.mkDerivation rec {
  pname = "netboot.xyz";
  version = "2.0.59";

  src = fetchFromGitHub {
    owner = "netbootxyz";
    repo = "netboot.xyz";
    rev = version;
    hash = "sha256-P08vmEw56HITYH2IwnYbxoKyF4V4MIh4fG6YWYoih84";
  };

  nativeBuildInputs = [
    ansible
  ] ++ lib.optionals withDisks [
    git
    openssl  # for ipxe build
    perl     # for ipxe build
    lzma     # for ipxe build
    #apache2
    #binutils-dev
    #dosfstools
    #genisoimage
    #httpd
    #isolinux
    #libslirp-dev
    #libslirp-devel
    #minizip-devel
    #syslinux
    #syslinux-common
    #toilet
    #xz-devel
  ];

  configurePhase = ''
    # Configurability.
    echo "generate_menus: ${if withMenus then "true" else "false"}" >> var-overrides.yml
    echo "generate_disks: ${if withDisks then "true" else "false"}" >> var-overrides.yml
    echo "generate_disks_legacy: ${if withLegacyDisks then "true" else "false"}" >> var-overrides.yml
    echo "generate_disks_linux: ${if withLinuxDisks then "true" else "false"}" >> var-overrides.yml
    echo "generate_disks_efi: ${if withEFIDisks then "true" else "false"}" >> var-overrides.yml
    echo "generate_disks_arm: ${if withARMDisks then "true" else "false"}" >> var-overrides.yml
    echo "generate_disks_rpi: ${if withRPiDisks then "true" else "false"}" >> var-overrides.yml
  
    # Set the directory to write the build products to.
    echo "netbootxyz_root: $out" >> var-overrides.yml

    # These default to various hardcoded directories that aren't writable in the Nix build sandbox.
    export ANSIBLE_LOCAL_TEMP=$NIX_BUILD_TOP/.ansible/tmp
    echo "cert_dir: $NIX_BUILD_TOP/certs" >> var-overrides.yml
    echo "ipxe_source_dir: $NIX_BUILD_TOP/ipxe" >> var-overrides.yml

    # The playbook searches for a vars file named '{{ansible_distribution|lower}}.yml',
    # which is expected to define the list of dependencies to install.
    # We have already ensure all the dependencies are available via nativeBuildInputs etc,
    # so we can set this to the empty list.
    # ansible_distribution reports as 'OtherLinux' in the Nix build sandbox.
    echo 'netbootxyz_packages: []' > roles/netbootxyz/vars/otherlinux.yml

  '' + lib.optionalString withMenus ''

    # As-is, the playbook tries to download these, but that's prohibited in the Nix build sandbox.
    # So we download them using standard Nix fetchers and override the URLs to point to the Nix store paths.
    echo "pciids_url: file://${pciids}/pciids.ipxe" >> var-overrides.yml

  '' + lib.optionalString withDisks ''

    # As-is, the playbook tries to download these, but that's prohibited in the Nix build sandbox.
    # So we download them using standard Nix fetchers and override the URLs to point to the Nix store paths.
    echo "ipxe_branch: ${ipxe.rev}" >> var-overrides.yml
    echo "ipxe_ca_url: file://${ipxeCA}" >> var-overrides.yml
    echo "ipxe_repo: file://${ipxe}" >> var-overrides.yml
    echo "wimboot_upstream_url: file://${wimboot}/share/wimboot/wimboot.x86_64.efi" >> var-overrides.yml

    # ipxe build may fail due to -Werror with NixOS's current gcc version.
    export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:-} -w"

  '';

  buildPhase = ''
    ansible-playbook -i inventory --extra-vars @var-overrides.yml site.yml
  '';
}
