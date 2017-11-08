#!/bin/sh
set -o errexit -o pipefail -o nounset

outdir=$(dirname $(dirname $(realpath $0)))

rm -f $outdir/*.patch

echo "Generating $outdir/sphash.patch"
git diff --no-index sphash.c.{old,new} | sed -E 's,/sphash\.c\.(old|new),/src_3rd/sphash/sphash\.c,g' > $outdir/fix-sphash-printf-warnings.patch
