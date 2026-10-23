#!/usr/bin/env bash
# Publish the OPuN website and schema packs from the public spec repository.
#   website/      -> /
#   schema packs  -> /schema/<domain>/v1/{context.jsonld,vocab.jsonld,attributes.yaml}
# Builds into a new release directory, then switches the "current" symlink atomically.
# Usage: deploy.sh [ref]   (default: main)
set -euo pipefail

REPO_URL="https://github.com/enableindia-blr/opun-specification.git"
SRC_DIR="${OPUN_SITE_SRC:-/opt/opun-specification}"
WEB_ROOT="${OPUN_SITE_ROOT:-/var/www/opun.network}"
REF="${1:-main}"

if [ ! -d "$SRC_DIR/.git" ]; then
  git clone --quiet "$REPO_URL" "$SRC_DIR"
fi
git -C "$SRC_DIR" fetch --quiet --tags origin
git -C "$SRC_DIR" checkout --quiet --detach "origin/$REF" 2>/dev/null || git -C "$SRC_DIR" checkout --quiet --detach "$REF"
COMMIT="$(git -C "$SRC_DIR" rev-parse --short HEAD)"

RELEASE="$WEB_ROOT/releases/$(date -u +%Y%m%d%H%M%S)-$COMMIT"
mkdir -p "$RELEASE"
cp -R "$SRC_DIR/website/." "$RELEASE/"
rm -rf "$RELEASE/nginx" "$RELEASE/deploy.sh"

publish() {  # <domain> <source dir relative to repo>
  mkdir -p "$RELEASE/schema/$1/v1"
  for f in context.jsonld vocab.jsonld attributes.yaml; do
    cp "$SRC_DIR/$2/$f" "$RELEASE/schema/$1/v1/$f"
  done
}
publish livelihood livelihood-domain-2.0/schema/livelihood/v1/schema-extension
publish learning   learning-domain-2.0/schema/learning/v1/schema-extension
publish loan       loan/v1/schema-extension

for f in $(find "$RELEASE/schema" -name '*.jsonld'); do
  python3 -m json.tool "$f" > /dev/null || { echo "Invalid JSON: $f" >&2; rm -rf "$RELEASE"; exit 1; }
done
echo "$COMMIT" > "$RELEASE/version.txt"

ln -sfn "$RELEASE" "$WEB_ROOT/current.tmp"
mv -Tf "$WEB_ROOT/current.tmp" "$WEB_ROOT/current"

# Keep the five most recent releases
ls -1dt "$WEB_ROOT"/releases/* | tail -n +6 | xargs -r rm -rf
echo "Published $COMMIT to $WEB_ROOT/current"
