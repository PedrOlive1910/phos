#!/bin/sh
# Apply phos identity and install Chrome inside an ISO build tree, never on the host.
set -eu
R=${1:?usage: phos-customize.sh ROOT VERSION}
VERSION=${2:?usage: phos-customize.sh ROOT VERSION}
[ "$(id -u)" = 0 ] || { echo 'phos-customize: requires root' >&2; exit 1; }
R=$(realpath "$R")
[ "$R" != / ] && [ -f "$R/etc/debian_version" ] && [ -x "$R/usr/bin/dpkg" ] || {
    echo 'phos-customize: expected a Debian build tree, not the host root' >&2; exit 1;
}
case "$VERSION" in ''|*[!0-9A-Za-z.+~-]*) echo 'Invalid version' >&2; exit 1 ;; esac
in_ch() { chroot "$R" env DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 PATH=/usr/sbin:/usr/bin:/sbin:/bin "$@"; }

# Replace the os-release symlink, preserving Debian's vendor file and dpkg ownership.
rm -f "$R/etc/os-release"
cat > "$R/etc/os-release" <<EOF
NAME="phos"
PRETTY_NAME="phos $VERSION (based on Debian 13)"
ID=phos
ID_LIKE=debian
VERSION_ID="$VERSION"
VERSION="$VERSION"
VERSION_CODENAME=trixie
DEBIAN_CODENAME=trixie
EOF
printf 'phos %s \\n \\l\n' "$VERSION" > "$R/etc/issue"

ARCH=$(in_ch dpkg --print-architecture)
if [ "$ARCH" != amd64 ]; then
    echo "phos: Chrome integration targets amd64; keeping Chromium on $ARCH."
    exit 0
fi

# Trust Google's signing key only for Google's repository; apt verifies the package.
in_ch apt-get install -y --no-install-recommends ca-certificates curl gnupg
in_ch install -d -m 755 /etc/apt/keyrings
in_ch curl --fail --show-error --silent --location --proto '=https' --proto-redir '=https' \
    https://dl.google.com/linux/linux_signing_key.pub -o /tmp/phos-google-signing-key.asc
in_ch gpg --batch --show-keys --with-colons /tmp/phos-google-signing-key.asc \
    > "$R/tmp/phos-google-key-info"
grep -q '^fpr:::::::::EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796:' "$R/tmp/phos-google-key-info" || {
    echo 'phos: unexpected Google primary signing key; review key rotation before building.' >&2; exit 1;
}
in_ch install -m 644 /tmp/phos-google-signing-key.asc /etc/apt/keyrings/phos-google.asc
write_source() {
    cat > "$R/etc/apt/sources.list.d/google-chrome.list" <<'EOF'
deb [arch=amd64 signed-by=/etc/apt/keyrings/phos-google.asc] https://dl.google.com/linux/chrome/deb/ stable main
EOF
}
write_source
in_ch apt-get update
in_ch apt-get install -y --no-install-recommends google-chrome-stable
# The vendor postinst can rewrite its source file; retain HTTPS and scoped trust.
write_source
in_ch dpkg-query -W -f='${Package} ${Version}\n' google-chrome-stable
[ -f "$R/usr/share/applications/google-chrome.desktop" ] || {
    echo 'phos: Chrome desktop entry missing' >&2; exit 1;
}
rm -f "$R/tmp/phos-google-signing-key.asc" "$R/tmp/phos-google-key-info"
echo 'phos: Google Chrome installed in the ISO filesystem.'
