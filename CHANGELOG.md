# Changelog

## 1.3 (2026-10-21)

A new look from GRUB onwards, the VPN helper checked twice, and SSH and the firewall tightened. Debian 13 underneath, as
before. For systems installed from 1.1 or 1.2, the same changes come as three packages: [docs/UPDATING.md](docs/UPDATING.md).

- **Look** (Debian packages and settings only): the VaeVictis-Dark icons (folders and apps drawn for VaeVictis) on top
  of Papirus-Dark; GNOME's dark style; Blur my Shell (the wallpaper behind the overview); Ptyxis is the terminal
  (GNOME Terminal is gone); Showtime, GNOME's newer video player, replaces Totem (on a test PC with an NVIDIA card
  Totem stopped with an OpenGL error); the boot menu with a large countdown, a violet bar and the dots of the
  wallpaper; the installer sets the boot screens to the monitor's own resolution (they looked enlarged on some NVIDIA
  cards). The disk passphrase screen is unchanged.
- **VPN helper:** every value of the copy that WireGuard reads is written again in its standard form, never copied
  from the file; IPv6 scope IDs are refused (1.2 copied an Address like `fe80::1%...` as it was: wg-quick does not run
  it, and only with IPv6 switched back on, but the copy was meant to hold checked values only); `ListenPort` is left
  out; a second check, independent of the parser, reads the finished copy and starts nothing if anything unexpected is
  in it. Tested with 60,000 random hostile edits of real provider configs. After an AI-assisted review (Argon by
  Google; not an independent security audit), also: one server per config (`[Peer]`), with `AllowedIPs`, and an
  `Address`; a config that sends all traffic through the tunnel must name a DNS server, and once the tunnel is up that
  server must be reached through it (1.2 accepted a config without a `DNS` line, and DNS then kept going to the DNS
  server the system already had: outside the tunnel when that is the router, as it usually is; the same for a `DNS`
  line naming an address of the local network); the DNS servers of a config for a few networks are added to the others
  instead of replacing them; while the kill switch is on, only a config that carries all traffic can connect (another
  one would have released it); tunnel addresses that would take over the computer's routing are refused, and so is a
  server whose address is inside the tunnel's own networks; a second tunnel is refused when it would take the kill
  switch off the first one or, like it, carry all traffic; after a failed first attempt, "connect again" also works
  under the kill switch with a server given by name. The VPN window has the VaeVictis colours and a dark title bar.
- **SSH** (still off by default): ed25519 keys only, no RSA; no sftp; post-quantum key exchange first (ML-KEM and sntrup
  hybrids, X25519 for older clients); at most 3 connections waiting for login from one address (`PerSourceMaxStartups 3`,
  `MaxStartups 10:30:60`).
- **Firewall:** the SSH port is open only while SSH runs; at most 4 new SSH connections a minute from one address; TCP flag
  combinations no connection uses are dropped; a commented line to allow SSH from your own network only.
- **Kernel:** the strict reverse-path filter now applies to the VPN tunnel, the virtual networks and any connection
  without a default route. 1.2 set it for "all" and "default", but systemd sets every interface to loose with a pattern,
  and the kernel uses the higher value: it was loose everywhere in practice. The connection to the internet stays loose:
  NetworkManager sets an interface with a default route back to loose on purpose (strict would break two connections at
  once).
- **Firefox ESR:** system policies: no telemetry, no studies, strict tracking protection (a user can switch it back to
  Standard), no sponsored content or recommendations.
- **Texts:** "Debian underneath, a small layer of our own, as is": the public texts say what is ours and what is Debian's,
  with the same limits as before.

## 1.2 (2026-10-18)

After 1.2, Debian keeps the system updated; VaeVictis's own tools get fixes when needed, best effort.

- **The VaeVictis APT repository is closed.** A repository that installs software as root on other people's computers is a
  responsibility a one-person hobby project cannot carry: a lost or stolen signing key, or a forgotten monthly re-signature,
  would affect every user. 1.2 has no repository configured; updates come from Debian only. Why and how:
  [docs/APT-REPOSITORY.md](docs/APT-REPOSITORY.md).
- **Systems installed from 1.1:** the last fixes are files in the [1.2 release](https://github.com/vaevictisos/vaevictis-os/releases/tag/v1.2) (`vaevictis-tools` 1.3.0,
  `vaevictis-aurora` 1.1.3, and `vaevictis-archive-keyring` 2026.10.18, which removes the repository): one command, see
  [docs/UPDATING.md](docs/UPDATING.md).
- **VaeVictis PDF removed:** Debian's own PDF viewer is there, maintained with Debian's security updates. Less code of our
  own, written with AI and not independently audited.
- **NVIDIA driver launcher** in the menu and on the desktop: it shows the graphics cards, then installs the optional
  proprietary driver or undoes it (`vv-nvidia`, as before).
- **Welcome window:** a line saying it is a hobby project written by AI, never audited, without warranty and not designed for
  high-risk use; no promises in the VPN and login texts; no PDF Tool.
- Everything below (fixes for the apps) and in the 2026-10-17 entry is in the 1.2 image.

### Fixes for the apps (in 1.2; for 1.1: `vaevictis-tools` 1.3.0, `vaevictis-aurora` 1.1.3)

Fixes found with an AI-assisted review of the three programs that open files from anywhere (Argon by Google), each one
checked against the code and with a test where possible. This is **not an independent security audit**. The review found
no way out of the sandbox; what it found are crashes, lost settings and writes that could follow a link, inside what the
sandbox already allows.

- **Aurora:** a file that declares an impossible duration (huge, infinite, not a number) is stored with no duration (in 1.1
  it crashed the player at every start, until the library was deleted; a library that already holds one opens again); notifications use the icon from the system theme,
  never a file in `~/.aurora`; it never writes a launcher of its own in `~/.local` (one would start it outside the sandbox);
  only regular files are opened.
- **VaeVictis PDF:** adding pages from a password-protected PDF asks whether to protect the whole document with that password
  (in 1.1 the result was saved unprotected, without a word); a PDF with permission restrictions only says that saving does not
  keep them; extract, split and PNG export write through a temporary file, so a link at the target name is replaced, not
  followed; pages 0 wide or high, or huge, no longer crash it or fill the memory; the file name in the status bar is plain
  text.
- **LinPaint+:** images larger than 8000 x 8000 are refused before they are decoded; the zoomed view and the undo steps
  are capped in memory; saving goes through a temporary file; cancelling the screenshot dialog no longer opens a second one.
- **All three, and `vv-sandbox`:** the commands they run are taken only from the system folders.
- **Aurora, VaeVictis PDF:** the window has its close button again (in 1.1 it could be closed only from the menu).
- **VPN manager:** the server list is readable (light text on a white background in 1.1).
- **Packages (for 1.1):** `vaevictis-tools` 1.3.0 now also carries VaeVictis PDF and LinPaint+ (same rule: a copy is
  replaced only if it is exactly a version VaeVictis shipped); `vaevictis-aurora` 1.1.3.

## 2026-10-17: fixes for 1.1 (package `vaevictis-tools` 1.2.0; the next ISO will include them)

Fixes found with AI-assisted reviews of the code (Lumo 2.0 Max by Proton, Argon by Google), each one checked against the
code and, where possible, with a test. This is **not an independent security audit**: AI reviews miss problems and report
problems that do not exist. Systems installed from 1.1 get these fixes as the package **`vaevictis-tools`** from the
VaeVictis APT repository (`sudo apt update && sudo apt full-upgrade`).

- **Sandbox (`vv-sandbox`):** only regular files given as arguments, checked after following links; a file reached through a
  link is made visible alone and read-only; hidden files, files in hidden folders and in `~/bin` are read-only; nothing of
  `/run` (except `/run/media`), `/proc`, `/sys` or `/dev`; never a folder. In 1.1, a crafted link opened with one of the three
  programs could make `~/.bashrc`, the whole home folder or the session's runtime folder writable inside the sandbox.
  Secrets moved elsewhere behind a link are now hidden at their real place.
- **VPN:** `Table` other than `auto` and `FwMark` are refused (with `Table = off` the tunnel showed as connected while the
  traffic left outside it, when the kill switch was off); every `[Peer]` needs an `Endpoint`; the password is asked at every
  action (it was kept for about five minutes, during which any program of the session could switch the kill switch off);
  disconnecting a tunnel never releases the kill switch of another one; the kill switch flag is readable by root only.
- **Installer:** refuses to finish if an account of the live session is still there; no separate partition for anything
  under `/usr`, nor for `/var`, `/var/lib` or APT's state.
- **v-snap:** refuses a system snapshot or restore when `/usr`, `/usr/local`, `/var` or `/var/lib` are separate partitions (the
  snapshot would leave them out); never copies or deletes another snapshot store.
- **Panic button, VPN manager:** the commands they run are taken only from the system folders.
- **Packages:** new `vaevictis-tools` 1.2.0; `vaevictis-aurora` 1.1.2 depends on it (the player is unchanged).

## 1.1 (2026-10-16)

Systems installed from 1.0 still need the [2026-10-12 security notice](docs/SECURITY-NOTICE-2026-10-12.md);
what else of 1.1 they can apply (removing the HIDS, the APT repository, two kernel settings): [docs/FROM-1.0.md](docs/FROM-1.0.md).

- **HIDS removed.** The file-integrity daemon was the largest piece of this project's code always running as root; the
  protections below replace it. `vv-branding` removes it from older build trees.
- **Boot menu password (GRUB)**, always set by the installer: starting needs none; editing the start options or the GRUB console
  needs user `grub` and that password (PBKDF2, 210000 rounds), which must differ from the other passwords and use only keys
  that GRUB's US keyboard reads the same. `sudo vv-grub-password` changes it.
- **New boot screens** (style A, minimal, violet): GRUB menu with the logo, and a Plymouth screen with a thin progress bar and the
  disk passphrase box (any length, the keyboard in use, error messages shown). `Esc` still shows every boot message. The
  password prompt, the editor and the start messages of GRUB stay black (no leftover picture behind them). New wallpaper in the
  same style, the default for desktop and lock screen (every user can choose another one).
- **Installer:** free space shown before every size question and each size checked; the root partition must hold the system;
  whole disks only; mount points checked; the live session switches to your keyboard layout and a typing test, with its reason
  explained, checks it;
  SSD TRIM before partitioning; `/boot` and EFI `nosuid,nodev,noexec`, `/home` and data partitions `nosuid,nodev`; the disk
  passphrase is cleared from memory after use; no "Install" launcher on installed systems.
- **Sandbox for the programs that open files from anywhere:** Aurora, LinPaint+ and VaeVictis PDF run in bubblewrap with no
  network, a read-only system and home (except the data folders, their settings and the opened file's folder), hidden keys and
  browser profiles, filtered D-Bus.
- **VPN with least privilege:** configs read with a whitelist (commands refused at import and at connect); WireGuard runs in a
  systemd sandbox with only `CAP_NET_ADMIN` and a read-only system; the helper sets DNS itself. **Kill switch:** designed to also block
  virtual machines (forward chain) and to stay on during a reconnect and after a failed one; no DNS lookup while it blocks.
- **v-snap:** snapshots only on encrypted disks (or the system disk of an unencrypted system), in a root-only folder pinned with
  a private bind mount; system snapshots include the kernels in `/boot`, and a restore puts back matching kernels and runs
  `update-grub`; a 1.0 snapshot is restored only if it has the modules of the installed kernels.
- **Programs:** VaeVictis PDF keeps the password of a protected PDF in extracted and split files, warns before exporting a
  protected page as PNG and caps its size; dialogs show plain text. Aurora 1.1.1: song tags escaped, single-instance socket file,
  works with a read-only home. LinPaint+: Copy really copies to the clipboard; licence shown as GPL. Panic: the passwordless rule
  is limited to administrators (`%sudo`).
- **Kernel:** `dev.tty.legacy_tiocsti=0` (no typing into other terminals), `kernel.io_uring_disabled=2`.
- **APT repository trusted by default, with limits:** package `vaevictis-archive-keyring` (key for this source only, a pin that
  allows only `vaevictis-*` packages from it), index signed with an expiry date (`vv-apt-publish`), procedures in
  [docs/APT-REPOSITORY.md](docs/APT-REPOSITORY.md).
- **Signed release:** `SHA256SUMS.asc`, signed with the key of the APT repository (`0A41 158C 1DD6 718D 3D3F  FED0 6848 6B39 B2A9 9993`).
- **Build:** every VaeVictis file in the image now comes from a script (`vv-apps`, `vv-boot-theme`); `vv-verify-iso` compares
  them byte for byte with the repository; `vv-release --key` signs with one named key and checks it; `vv-usb` reads the stick
  back without the page cache; tests in `tests/`. Links point to vaevictisos.org.

## 1.0.1 (2026-10-12): security release

Fixes found in an audit of the VaeVictis code. Systems installed from 1.0 need the four commands of the
[security notice](docs/SECURITY-NOTICE-2026-10-12.md); the 1.0.1 installer does all of it by itself.
- **Installer:** removes the polkit rule that the live session writes for its user (`user`): copied into an installed system it
  gave administrator rights without a password to a user with that name. The installer refuses to finish if such a rule is left.
- **Installer:** no longer adds the user to the `libvirt` group (administrator-equivalent without a password); virt-manager asks
  for the password instead.
- **Image and installer:** root is locked with no password hash at all (1.0 kept a locked hash from the build system); every
  installed system creates its own `ssl-cert-snakeoil` TLS key; `/root` is emptied (build caches and an obsolete script).
- **HIDS 2.1.1:** file names with control characters can no longer forge lines in the log or break the dashboard.
- **Debian security updates** included in the image: ghostscript, xz-utils/liblzma.
- **Build:** `vv-chroot seal`, `vv-release` and `vv-verify-iso` check all of the above, so it cannot come back unnoticed.
- `vv-panic-action` (the root part of the panic button) and the shipped version of VaeVictis PDF are now in the repository too.

## APT repository (2026-10-10)

A signed APT repository at <https://apt.linuxtuts.online/> (files: the `vaevictis-apt` repository, private since 2026-11-12),
so that `apt upgrade` can update the VaeVictis programs. It is not enabled by default: you add it yourself.
- Holds `vaevictis-aurora` 1.1.0, byte for byte the file of the `aurora-v1.1.0` release (same SHA-256).
- Index files signed with an ed25519 key, fingerprint `0A41 158C 1DD6 718D 3D3F  FED0 6848 6B39 B2A9 9993`. The private key stays on
  the author's encrypted disk, not on any server. Checked with `apt` on Debian 13: valid signature accepted, altered index or
  signature rejected.
- Hosted on GitHub Pages; a published package version is never changed.

## Aurora 1.1.0 (2026-10-10)

A release of its own (`aurora-v1.1.0`): the first VaeVictis program shipped as a Debian package (`vaevictis-aurora`). It is
**not** in the 1.0 ISO, which carries the first version of Aurora.
- The spectrum analyses the audio that is playing (it used random numbers before): full-width strip, 64 bands, frequency
  read-out when you hover a bar.
- Sharper text (real bold instead of weight 600, better contrast).
- `QT_QPA_PLATFORM` can be set from the shell (for example `xcb`) to test X11.
- `.deb` built from the repository with `packaging/aurora/build.sh`; it replaces a hand-copied `/usr/local/bin/aurora`.

## 1.0 (2026-10-09)

First public release. Debian 13 (trixie), kernel 6.12, GNOME. Hybrid BIOS + UEFI live ISO (Secure Boot not supported).

**Installer**
- LUKS2 disk encryption (root, optional separate `/home`), encrypted swap with a random key, `/boot` unencrypted.
- Shows what is on the disk before it erases anything; saves the firmware boot list before and after; stops with the failing
  command and line if something goes wrong; refuses to finish if an automatic or timed login is left active.

**Security**
- nftables: input drop, forward drop (virtual machines only), output not blocked.
- Hardened sshd and fail2ban, switched off by default (port 2299, keys only).
- Kernel and sysctl hardening, hardened boot options (live and installer), IPv6 off by default.
- HIDS 2.1: real-time file-integrity tripwire (inotify, standard library only), watches programs, services, cron, PAM, shell
  startup files, SSH keys and `/boot`; alerts on content, mode or owner change and on new SETUID files; random-interval full
  re-check; warns when the watcher stops; popups through `hids-notify` in the user's session; sandboxed systemd unit.
- VPN manager: WireGuard front-end with a kill switch; configs with IPv6 work on systems where IPv6 is off.
- uBlock Origin installed for Firefox ESR; KeePassXC, mat2, Panic Mode, Lynis, hard-link snapshots (`v-snap`).

**Look and boot**
- VaeVictis wallpaper, GRUB theme with cyan menu entries on the live ISO and the installed system, loading messages shown
  directly on the wallpaper, boot messages visible (no `quiet`).

**Build tools**
- `vv-iso`, `vv-chroot`, `vv-secure`, `vv-harden`, `vv-branding`, `vv-hids`, `vv-liveuser`, `vv-verify-iso`, `vv-release`, `vv-usb`.

**Known limits**
- No Secure Boot; `/boot` not encrypted; not an anonymity system; Panic Mode is not a secure erase; the proprietary NVIDIA
  driver is optional (`vv-nvidia`). See [THREAT-MODEL.md](THREAT-MODEL.md).
