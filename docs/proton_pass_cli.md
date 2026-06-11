# Proton Pass CLI sysext

This sysext ships the [Proton Pass CLI](https://github.com/protonpass/pass-cli) (`pass-cli`),
the official command-line tool for the Proton Pass password manager.

## Portability caveat

The upstream `pass-cli` Linux binary is **dynamically linked** against the host's
`libstdc++` and `glibc`. It has only been smoke-tested on a Dakota bootc host.
`ID=_any` is the bakery default, but consumers should validate that
`pass-cli --help` runs successfully on their target glibc/libstdc++ baseline
before relying on this sysext as fully host-agnostic.

The extension provides the `pass-cli` binary at `/usr/bin/pass-cli`.

## Usage

Download and merge the sysext at provisioning time using the below butane snippet.

The snippet includes automated updates via systemd-sysupdate.
Sysupdate will stage updates and request a reboot by creating a flag file at `/run/reboot-required`.
You can deactivate updates by changing `enabled: true` to `enabled: false` in `systemd-sysupdate.timer`.

Note that the snippet is for the x86-64 version of `pass-cli` v2.1.2.

Check out the metadata release at https://github.com/flatcar/sysext-bakery/releases/tag/proton-pass-cli for a list of all versions available in the bakery.

```yaml
variant: flatcar
version: 1.0.0

storage:
  files:
    - path: /opt/extensions/proton-pass-cli/proton-pass-cli-v2.1.2-x86-64.raw
      mode: 0644
      contents:
        source: https://extensions.flatcar.org/extensions/proton-pass-cli-v2.1.2-x86-64.raw
    - path: /etc/sysupdate.proton-pass-cli.d/proton-pass-cli.conf
      contents:
        source: https://extensions.flatcar.org/extensions/proton-pass-cli.conf
    - path: /etc/sysupdate.d/noop.conf
      contents:
        source: https://extensions.flatcar.org/extensions/noop.conf
  links:
    - target: /opt/extensions/proton-pass-cli/proton-pass-cli-v2.1.2-x86-64.raw
      path: /etc/extensions/proton-pass-cli.raw
      hard: false
systemd:
  units:
    - name: systemd-sysupdate.timer
      enabled: true
    - name: systemd-sysupdate.service
      dropins:
        - name: proton-pass-cli.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/proton-pass-cli.raw > /tmp/proton-pass-cli"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C proton-pass-cli update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/proton-pass-cli.raw > /tmp/proton-pass-cli-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/proton-pass-cli /tmp/proton-pass-cli-new; then touch /run/reboot-required; fi"
```
