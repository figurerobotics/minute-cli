#!/usr/bin/env bash
# Installs minute, the command-line client for the Minute partner platform, from the
# releases of github.com/figurerobotics/minute-cli.
#
#   curl -fsSL https://raw.githubusercontent.com/figurerobotics/minute-cli/HEAD/install.sh | bash
#
# Environment:
#   MINUTE_VERSION       version to install, e.g. 1.2.0 (default: the latest release)
#   MINUTE_INSTALL_DIR   directory the binary goes in (default: ~/.local/bin)
#   MINUTE_RELEASE_REPO  release repository URL (default: https://github.com/figurerobotics/minute-cli)
set -euo pipefail

TMP_DIR=""
cleanup() {
  [ -z "$TMP_DIR" ] || rm -rf "$TMP_DIR"
}
trap cleanup EXIT

main() {
  local repo="${MINUTE_RELEASE_REPO:-https://github.com/figurerobotics/minute-cli}"
  local install_dir="${MINUTE_INSTALL_DIR:-$HOME/.local/bin}"

  need curl
  need tar
  need mktemp

  local os arch
  os="$(detect_os)"
  arch="$(detect_arch)"

  local version
  version="$(resolve_version "$repo")"

  if [ -x "$install_dir/minute" ] && [ "$("$install_dir/minute" version 2>/dev/null || true)" = "$version" ]; then
    echo "minute $version is already installed at $install_dir/minute"
    path_hint "$install_dir"
    return 0
  fi

  if ! mkdir -p "$install_dir" 2>/dev/null || [ ! -w "$install_dir" ]; then
    die "cannot write to $install_dir (set MINUTE_INSTALL_DIR to a directory you own)"
  fi

  TMP_DIR="$(mktemp -d)"
  local tmp="$TMP_DIR"

  local asset="minute_${version}_${os}_${arch}.tar.gz"
  local base="$repo/releases/download/v$version"
  echo "Downloading minute $version for $os/$arch"
  fetch "$base/$asset" "$tmp/$asset" "no release v$version with a $os/$arch build at $repo/releases"
  fetch "$base/checksums.txt" "$tmp/checksums.txt"
  verify_checksum "$tmp/$asset" "$tmp/checksums.txt" "$asset"

  tar -xzf "$tmp/$asset" -C "$tmp"
  local binary="$tmp/minute_${version}_${os}_${arch}/minute"
  [ -f "$binary" ] || die "archive $asset does not contain minute"

  chmod 0755 "$binary"
  mv -f "$binary" "$install_dir/minute"

  local installed
  installed="$("$install_dir/minute" version)" || die "$install_dir/minute does not run on this machine"
  echo "Installed minute $installed to $install_dir/minute"
  path_hint "$install_dir"
  echo "Run 'minute login' to sign in."
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required but not installed"
}

die() {
  echo "error: $*" >&2
  exit 1
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo darwin ;;
    Linux) echo linux ;;
    MINGW* | MSYS* | CYGWIN* | Windows_NT)
      die "on Windows, download the windows_amd64 zip from ${MINUTE_RELEASE_REPO:-https://github.com/figurerobotics/minute-cli}/releases/latest" ;;
    *) die "unsupported operating system: $(uname -s)" ;;
  esac
}

detect_arch() {
  local machine
  machine="$(uname -m)"
  if [ "$(uname -s)" = Darwin ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
    machine=arm64
  fi
  case "$machine" in
    x86_64 | amd64) echo amd64 ;;
    arm64 | aarch64) echo arm64 ;;
    *) die "unsupported architecture: $machine" ;;
  esac
}

resolve_version() {
  local repo="$1" version
  if [ -n "${MINUTE_VERSION:-}" ]; then
    version="${MINUTE_VERSION#v}"
  else
    local final_url
    final_url="$(curl -fsSL --proto '=https' --tlsv1.2 --retry 3 -o /dev/null -w '%{url_effective}' "$repo/releases/latest")" \
      || die "could not look up the latest release at $repo/releases/latest"
    version="${final_url##*/tag/v}"
    [ "$version" != "$final_url" ] || die "no release found at $repo/releases/latest"
  fi
  case "$version" in
    *[!0-9A-Za-z.+-]* | "") die "invalid version: $version" ;;
  esac
  echo "$version"
}

fetch() {
  local url="$1" out="$2" reason="${3:-download failed: $1}"
  curl -fsSL --proto '=https' --tlsv1.2 --retry 3 -o "$out" "$url" 2>/dev/null || die "$reason"
}

verify_checksum() {
  local file="$1" checksums="$2" name="$3" expected actual
  expected="$(awk -v name="$name" '$2 == name { print $1 }' "$checksums")"
  [ -n "$expected" ] || die "$name is not listed in checksums.txt"
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$file" | awk '{ print $1 }')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$file" | awk '{ print $1 }')"
  else
    die "sha256sum or shasum is required to verify the download"
  fi
  [ "$actual" = "$expected" ] || die "checksum mismatch for $name (expected $expected, got $actual)"
}

path_hint() {
  local dir="$1"
  case ":$PATH:" in
    *":$dir:"*) return 0 ;;
  esac
  local rc
  case "$(basename "${SHELL:-}")" in
    zsh) rc="$HOME/.zshrc" ;;
    bash) rc="$HOME/.bashrc" ;;
    *) rc="your shell's startup file" ;;
  esac
  echo
  echo "$dir is not on your PATH. Add this line to $rc, then open a new terminal:"
  echo
  echo "  export PATH=\"$dir:\$PATH\""
  echo
}

main "$@"
