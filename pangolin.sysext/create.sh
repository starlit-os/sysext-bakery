#!/usr/bin/env bash
# vim: et ts=2 syn=bash
#
# Pangolin CLI extension.

RELOAD_SERVICES_ON_MERGE="false"

function list_available_versions() {
  list_github_releases "fosrl" "cli"
}
# --

function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  local rel_arch="$(arch_transform "x86-64" "amd64" "$arch")"

  local url="https://github.com/fosrl/cli/releases/download/${version}/pangolin-cli_linux_${rel_arch}"
  local bin="pangolin-cli_linux_${rel_arch}"

  echo "Downloading ${url}"
  curl --parallel --fail --silent --show-error --location --remote-name "${url}"

  mkdir -p "${sysextroot}/usr/bin"
  install -m 0755 "${bin}" "${sysextroot}/usr/bin/pangolin"
}
# --
