{ ffmpeg }:

ffmpeg.overrideAttrs (oldAttrs: {
  pname = "ffmpeg-tools";
  buildFlags = (oldAttrs.buildFlags or []) ++ ["alltools"];
  installPhase = ''
    install -D -m 0755 $(find tools -type f -executable -print) -t $out/bin
  '';
})
