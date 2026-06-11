#!/usr/bin/env bash
# vim: et ts=2 syn=bash
#
# Proton Pass CLI extension.

RELOAD_SERVICES_ON_MERGE="false"

function list_available_versions() {
  list_github_releases "protonpass" "pass-cli"
}
# --

function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  local rel_arch="$(arch_transform "x86-64" "x86_64" "$arch")"
  rel_arch="$(arch_transform "arm64" "aarch64" "$rel_arch")"

  local url="https://github.com/protonpass/pass-cli/releases/download/${version}/pass-cli-linux-${rel_arch}"
  local bin="pass-cli-linux-${rel_arch}"

  curl --parallel --fail --silent --show-error --location --remote-name "${url}"

  mkdir -p "${sysextroot}/usr/bin"
  install -m 0755 "${bin}" "${sysextroot}/usr/bin/pass-cli"
}
# --
