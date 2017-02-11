source $stdenv/setup

destDir="$out/bin"
install -d -m 0755 "$destDir"

for src in $srcDir/*; do
  dest="$destDir/$(basename "$src")"
  install -m 0755 "$src" "$dest"
  wrapProgram "$dest" --suffix PATH : "$extraPath"
done
