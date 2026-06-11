#!/usr/bin/env bash
# vim: et ts=2 syn=bash
#
# Komodo Periphery sysext.
#

RELOAD_SERVICES_ON_MERGE="true"

function list_available_versions() {
  list_github_releases "moghtech" "komodo"
}
# --

function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  local rel_arch="$(arch_transform "x86-64" "amd64" "$arch")"

  local url="https://github.com/moghtech/komodo/releases/download/${version}/periphery-${rel_arch}"
  local bin="periphery-${rel_arch}"

  curl --parallel --fail --silent --show-error --location --remote-name "${url}"

  mkdir -p "${sysextroot}/usr/bin"
  install -m 0755 "${bin}" "${sysextroot}/usr/bin/periphery"
}
# --
