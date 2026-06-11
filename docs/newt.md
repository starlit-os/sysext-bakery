# Newt sysext

This sysext ships [Newt](https://github.com/fosrl/newt), the Pangolin tunnel client.
Newt is published by the same maintainer (fosrl) and built as a `CGO_ENABLED=0` Go static binary,
so it is shipped as a host-agnostic `ID=_any` sysext.

The extension provides the `newt` binary at `/usr/bin/newt`.

## Usage

Download and merge the sysext at provisioning time using the below butane snippet.

The snippet includes automated updates via systemd-sysupdate.
Sysupdate will stage updates and request a reboot by creating a flag file at `/run/reboot-required`.
You can deactivate updates by changing `enabled: true` to `enabled: false` in `systemd-sysupdate.timer`.

Note that the snippet is for the x86-64 version of Newt v1.13.0.

Check out the metadata release at https://github.com/flatcar/sysext-bakery/releases/tag/newt for a list of all versions available in the bakery.

```yaml
variant: flatcar
version: 1.0.0

storage:
  files:
    - path: /opt/extensions/newt/newt-v1.13.0-x86-64.raw
      mode: 0644
      contents:
        source: https://extensions.flatcar.org/extensions/newt-v1.13.0-x86-64.raw
    - path: /etc/sysupdate.newt.d/newt.conf
      contents:
        source: https://extensions.flatcar.org/extensions/newt.conf
    - path: /etc/sysupdate.d/noop.conf
      contents:
        source: https://extensions.flatcar.org/extensions/noop.conf
  links:
    - target: /opt/extensions/newt/newt-v1.13.0-x86-64.raw
      path: /etc/extensions/newt.raw
      hard: false
systemd:
  units:
    - name: systemd-sysupdate.timer
      enabled: true
    - name: systemd-sysupdate.service
      dropins:
        - name: newt.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/newt.raw > /tmp/newt"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C newt update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/newt.raw > /tmp/newt-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/newt /tmp/newt-new; then touch /run/reboot-required; fi"
```
