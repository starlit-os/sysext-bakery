# Pangolin sysext

This sysext ships the [Pangolin CLI](https://github.com/fosrl/cli), the official command-line client
for the Pangolin tunnel/reverse-proxy project. The `pangolin` binary is a `CGO_ENABLED=0` Go static
binary, so it is shipped as a host-agnostic `ID=_any` sysext.

The extension provides the `pangolin` binary at `/usr/bin/pangolin`.

## Usage

Download and merge the sysext at provisioning time using the below butane snippet.

The snippet includes automated updates via systemd-sysupdate.
Sysupdate will stage updates and request a reboot by creating a flag file at `/run/reboot-required`.
You can deactivate updates by changing `enabled: true` to `enabled: false` in `systemd-sysupdate.timer`.

Note that the snippet is for the x86-64 version of Pangolin CLI v0.9.0.

Check out the metadata release at https://github.com/flatcar/sysext-bakery/releases/tag/pangolin for a list of all versions available in the bakery.

```yaml
variant: flatcar
version: 1.0.0

storage:
  files:
    - path: /opt/extensions/pangolin/pangolin-v0.9.0-x86-64.raw
      mode: 0644
      contents:
        source: https://extensions.flatcar.org/extensions/pangolin-v0.9.0-x86-64.raw
    - path: /etc/sysupdate.pangolin.d/pangolin.conf
      contents:
        source: https://extensions.flatcar.org/extensions/pangolin.conf
    - path: /etc/sysupdate.d/noop.conf
      contents:
        source: https://extensions.flatcar.org/extensions/noop.conf
  links:
    - target: /opt/extensions/pangolin/pangolin-v0.9.0-x86-64.raw
      path: /etc/extensions/pangolin.raw
      hard: false
systemd:
  units:
    - name: systemd-sysupdate.timer
      enabled: true
    - name: systemd-sysupdate.service
      dropins:
        - name: pangolin.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/pangolin.raw > /tmp/pangolin"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C pangolin update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/pangolin.raw > /tmp/pangolin-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/pangolin /tmp/pangolin-new; then touch /run/reboot-required; fi"
```
