# Updating VaeVictis

## Everything updates from Debian

Security fixes are installed automatically every day (`unattended-upgrades`), and `sudo apt update && sudo apt full-upgrade`
brings the rest up to date. You do **not** need a new ISO for this: the ISO is only the way to install the system the first time.

VaeVictis has **no APT repository of its own** any more: it was closed with 1.2 ([why](APT-REPOSITORY.md)). A fix of
VaeVictis's own tools, when one is needed, is published as a file in a release.

## Installed from 1.1 or 1.2: what 1.3 brings, as three packages

The [1.3 release](https://github.com/vaevictisos/vaevictis-os/releases/tag/v1.3) has them. Download them with
`SHA256SUMS`, `SHA256SUMS.asc` and `vaevictis-release-key.asc` into one folder, then in that folder:

```bash
gpg --show-keys vaevictis-release-key.asc        # the fingerprint must be 0A41158C1DD6718D3D3FFED068486B39B2A99993
gpg --import vaevictis-release-key.asc
gpg --verify SHA256SUMS.asc SHA256SUMS           # must say: Good signature
sha256sum --ignore-missing -c SHA256SUMS         # each package: OK
sudo apt install ./vaevictis-tools_1.4.0_all.deb ./vaevictis-hardening_1.3.0_all.deb ./vaevictis-desktop_1.3.0_all.deb
```

Then log out and back in. Read what they print: each one says what it changed and what it left alone.

- **`vaevictis-tools` 1.4.0**: the VPN helper fixes of 1.3 (every value of the copy WireGuard reads written again and
  checked a second time; one server per config; a config that sends all traffic through the tunnel must have a DNS server reached
  through it)
  and the VPN window in the VaeVictis colours. Same rules as before: a copy is replaced only if it is exactly
  a version VaeVictis shipped.
- **`vaevictis-hardening` 1.3.0**: the SSH, firewall, kernel and Firefox settings of 1.3, each file replaced only if it is
  exactly the one the 1.1 or 1.2 image installed (a file you changed is left alone, with a message):
  SSH accepts **ed25519 keys only** (no RSA), without sftp, post-quantum key exchange first; the firewall opens the SSH port
  only while SSH runs, at most 4 new SSH connections a minute from one address; the strict reverse-path filter applies
  to the VPN tunnel and the virtual networks (NetworkManager keeps the connection to the internet loose, on purpose); Firefox gets the system policies, only if it has none. **If any authorized key on the computer is not ed25519,
  the SSH settings are not changed** (nor with certificates or an `AuthorizedKeysCommand`), so nobody is locked out: make an ed25519 key on the computer you connect from
  (`ssh-keygen -t ed25519`, do not use RSA), put it in `authorized_keys` in place of the old one, then
  `sudo dpkg-reconfigure vaevictis-hardening`. Replaced files: `/var/lib/vaevictis-hardening/backup/`.
- **`vaevictis-desktop` 1.3.0**: the look of 1.3, from Debian packages it installs (Papirus icons, Blur my Shell, Ptyxis):
  the VaeVictis-Dark icons and GNOME's dark style as defaults (a choice a user already made in Settings stays), Blur my
  Shell switched on by default, the new boot menu and the boot screens at the monitor's own resolution if the menu is still
  the one VaeVictis installed (a resolution setting of your own in `/etc/default/grub` is kept). GNOME Terminal stays until you remove it (`sudo apt remove gnome-terminal`). Removing this
  package removes the icons and the defaults; the boot menu stays.

What the packages cannot change: the boot options and the partitions chosen when you installed. Those are the same in 1.3.

## Installed from 1.1: the last fixes, and removing the repository

1.1 trusts the closed repository. Its last fixes are three packages in the
[1.2 release](https://github.com/vaevictisos/vaevictis-os/releases/tag/v1.2). Download them with `SHA256SUMS`,
`SHA256SUMS.asc` and `vaevictis-release-key.asc` into one folder, then in that folder:

```bash
gpg --show-keys vaevictis-release-key.asc        # the fingerprint must be 0A41158C1DD6718D3D3FFED068486B39B2A99993
gpg --import vaevictis-release-key.asc
gpg --verify SHA256SUMS.asc SHA256SUMS           # must say: Good signature
sha256sum --ignore-missing -c SHA256SUMS         # each package: OK
sudo apt install ./vaevictis-tools_1.3.0_all.deb ./vaevictis-aurora_1.1.3_all.deb ./vaevictis-archive-keyring_2026.10.18_all.deb
sudo apt purge vaevictis-archive-keyring         # the package is empty now: remove it too
```

What they do:

- **`vaevictis-tools` 1.3.0** puts the fixed VaeVictis tools in place of the copies the 1.1 image installed, at the same paths
  (the launchers, the polkit rule and the sudo rule expect them there): the app sandbox, the VPN manager and its helper, the VPN
  polkit rule, v-snap, the panic button, VaeVictis PDF and LinPaint+. A copy is replaced **only if it is exactly a version
  VaeVictis shipped**: a copy you changed is left alone (the package says so) and a missing tool is not added. The replaced
  copies are kept in `/var/lib/vaevictis-tools/backup/`; removing the package does not restore them.
- **`vaevictis-aurora` 1.1.3**: the fixed music player.
- **`vaevictis-archive-keyring` 2026.10.18** removes the repository's source entry, pin and key, so `apt update` no longer
  contacts it.

Only want to stop using the repository: `sudo apt purge vaevictis-archive-keyring` (**purge**, not remove: remove would leave
the source entry without its key, and `apt update` would report an error).

VaeVictis PDF is not in 1.2 (Debian's PDF viewer is there). On 1.1 it stays, fixed by `vaevictis-tools` 1.3.0. To remove it:

```bash
sudo rm /usr/local/bin/vv-pdf /usr/local/lib/vaevictis/vv-pdf /usr/share/applications/vv-pdf.desktop
```

A `.deb` file is not signed by itself: the signed `SHA256SUMS` of the release is what proves it is the published one. To look
inside before installing: `dpkg-deb -I FILE.deb` (description, dependencies) and `dpkg-deb -c FILE.deb` (the files).

## On 1.0 / 1.0.1, if you added the repository by hand

```bash
sudo apt purge vaevictis-archive-keyring         # only if you installed it ("is not installed" is fine)
sudo rm -f /etc/apt/sources.list.d/vaevictis.sources /etc/apt/sources.list.d/vaevictis-bootstrap.sources /etc/apt/keyrings/vaevictis.gpg
sudo apt update
```

What else of the newer releases you can apply yourself: [FROM-1.0.md](FROM-1.0.md).

## Build the packages yourself

```bash
bash packaging/tools/build.sh                 # from the repository root; each writes dist/
bash packaging/aurora/build.sh
bash packaging/archive-keyring/build.sh
```

The builds are repeatable: with the same `SOURCE_DATE_EPOCH` the files are byte for byte the same (without it the date of the
last commit is used, so the contents are the same but the file differs). For example the published Aurora 1.1.0:
`SOURCE_DATE_EPOCH=1791624000 bash packaging/aurora/build.sh` gives SHA-256
`6b81d6973b155c6db153fca629e419e5149071ec5768aedc86547387fd49b37b` (checked on Ubuntu 24.04 and Debian 13).

## A new ISO

Only for fresh installs. Existing installations do not need it: Debian keeps them up to date.
