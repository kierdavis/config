{ config, lib, pkgs, ... }:

let
  mkLowPriority = lib.mkOverride 200;  # 100 is the default priority

  refuse = name: (pkgs.runCommand "refuse-${name}" {} ''
    echo >&2 "If you're seeing this, your system has a dependency on ${name}, please remove it."
    exit 1
  '') // {
    bin = refuse "${name}.bin";
    dev = refuse "${name}.dev";
  };

  dummy = name: pkgs.runCommand "dummy-${name}" {} ''
    mkdir -p $out
  '';

in {
  #environment.noXlibs = mkLowPriority true;
  boot.vesa = mkLowPriority false;
  fonts.fontconfig.enable = mkLowPriority false;
  hardware.pulseaudio.enable = mkLowPriority false;
  programs.ssh.setXAuthLocation = mkLowPriority false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  services.xserver.enable = mkLowPriority false;
  sound.enable = mkLowPriority false;

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;

  # Disable optional features of some packages to reduce dependency on graphics libraries.
  nixpkgs.overlays = [(self: super: {
    beets = super.beets.override {
      enableKeyfinder = false; # pulls in mesa-noglu
    };
    boinc = (super.boinc.override {
      libGL = null;
      libGLU = null;
      libXmu = null;
      libXi = null;
      freeglut = null;
      libjpeg = null;
      wxGTK30 = null;
      xcbutil = null;
      gtk2 = null;
      libXScrnSaver = null;
      libX11 = null;
      libxcb = null;
    }).overrideDerivation (superAttrs: {
      NIX_LDFLAGS = "";
      configureFlags = ["--disable-manager"];
    });
    cairo = super.cairo.override {
      x11Support = false;
    };
    dbus = super.dbus.override {
      x11Support = false;
    };
    ghostscript = super.ghostscript.override {
      x11Support = false;
    };
    git = super.git.override {
      guiSupport = false;
    };
    gnupg22 = super.gnupg22.override {
      # 'true' removes gpg-agent, which breaks password-store.
      enableMinimal = false;
      # This option's name isn't very descriptive of what it actually does.
      # When true, gnupg uses "third-party" pinentry rather than an internal one.
      # This is fine since we configure "third-party" pinentry to build without GUI flavours.
      guiSupport = true;
    };
    ffmpeg = super.ffmpeg.override {
      sdlSupport = false;
      vdpauSupport = false;
    };
    gobject-introspection = super.gobject-introspection.override {
      x11Support = false;
    };
    gpgme = super.gpgme.override {
      qtbase = null;
    };
    gtk2 = refuse "gtk2";
    gtk2-x11 = refuse "gtk2-x11";
    gtk3 = refuse "gtk3";
    gtk3-x11 = refuse "gtk3-x11";
    hplip = super.hplip.override {
      withQt5 = false;
    };
    imagemagick = super.imagemagick.override {
      libX11 = null;
      libXext = null;
      libXt = null;
    };
    libva = (super.libva.override { minimal = true; }).overrideAttrs (superAttrs: {
      nativeBuildInputs = with self; [ meson pkg-config ninja ];
    });
    mupdf = super.mupdf.override {
      enableGL = false;
      enableX11 = false;
    };
    net-snmp = super.net-snmp.override {
      perlPackages = self.perlPackages // {
        Tk = null;
      };
    };
    openjdk = super.openjdk.override { headless = true; };
    openjdk8 = super.openjdk8.override { headless = true; };
    openjdk11 = super.openjdk11.override { headless = true; };
    openjdk14 = super.openjdk14.override { headless = true; };
    pango = (super.pango.override {
      x11Support = false;
    }).overrideAttrs (superAttrs: {
      # docs fail to build when x11Support=false.
      mesonFlags = (lib.lists.remove "-Dgtk_doc=true" superAttrs.mesonFlags) ++ ["-Dgtk_doc=false"];
      outputs = lib.lists.remove "devdoc" superAttrs.outputs;
      postInstall = "";
    });
    pass = super.pass.override {
      qrencode = null;
      x11Support = false;
      waylandSupport = false;
    };
    perlPackages = super.perlPackages // {
      Tk = refuse "perlPackages.Tk";
    };
    pinentry = super.pinentry.override {
      enabledFlavors = [ "curses" "tty" ];
    };
    # python3Packages = self.python3.pkgs;
    # python3 = super.python3.override {
    #   packageOverrides = pythonSelf: pythonSuper: {
    #   };
    # };
    qemu = super.qemu.override {
      gtkSupport = false;
      sdlSupport = false;
      spiceSupport = false;
    };
    qemu_kvm = super.qemu_kvm.override {
      gtkSupport = false;
      sdlSupport = false;
      spiceSupport = false;
    };
    qtbase = refuse "qtbase";
    SDL2 = super.SDL2.override {
      x11Support = false;
    };
    virtualbox = (super.virtualbox.override {
      headless = true;
      pulseSupport = false;
      xorgproto = null;
      libX11 = null;
      libXext = null;
      libXcursor = null;
      libXmu = null;
      libGL = null;
      # Not strictly needed for headless, but makes the dependency tree simpler.
      javaBindings = false;
    }).overrideAttrs (superAttrs: {
      configureFlags = [ "--build-headless" ];
    });
    wayland = refuse "wayland";
    xorg = super.xorg // {
      libX11 = refuse "libX11";
    };
  })];
}
