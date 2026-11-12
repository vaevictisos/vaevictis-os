# The VaeVictis APT repository: closed

From October 2026 VaeVictis had a signed APT repository, <https://apt.linuxtuts.online/> (files:
[`vaevictis-apt`](https://github.com/linuxtuts-website/vaevictis-apt)), trusted by default by the 1.1 image through the package
`vaevictis-archive-keyring`. **It was closed with release 1.2.**

## Why

A repository that installs software as root on other people's computers is a responsibility a one-person hobby project cannot
carry:

- whoever holds the signing key can run code as root on every system that updates from it. The key was kept offline on an
  encrypted disk, but it was used on the maintainer's own computer to sign, and the packages were built there: a compromised
  computer, a lost or stolen key, or a stolen GitHub or Cloudflare account would have reached every user;
- the index had to be re-signed at least every 30 days (it carried an expiry date, so that an old index could not hide a fix);
  a re-signature forgotten once means an error at every `apt update` on every system;
- VaeVictis's own tools are a small layer: they rarely need a fix, and everything else updates from Debian anyway.

Less to trust is better: 1.2 has no repository of its own, and a fix, if one is ever needed, is a file in a release, checked with
the signed `SHA256SUMS` of that release.

## What was done

1. No more publications. The last signed index is not renewed: it expires on **2026-11-16** and apt then reports the repository as
   expired (Debian's updates are not affected).
2. The last fixes for 1.1 are published as files of the [1.2 release](https://github.com/vaevictisos/vaevictis-os/releases/tag/v1.2),
   with the last `vaevictis-archive-keyring` (2026.10.18): it removes the source entry, the pin and the key from the system
   (`dpkg-maintscript-helper rm_conffile`; a copy changed locally is kept as `.dpkg-bak`, which apt ignores). How to install them:
   [UPDATING.md](UPDATING.md).
3. After 1.2 is out, the DNS record `apt.linuxtuts.online` is deleted **first**, and only then GitHub Pages is switched off for
   `vaevictis-apt` (in the other order somebody else could serve files under that name). The `vaevictis-apt` repository is
   archived, not deleted, so its history stays readable.

A system installed from 1.1 that never installs the last packages keeps trusting the key for that name only; once the name is
gone there is nothing left to download from it, and `sudo apt purge vaevictis-archive-keyring` removes it (not `remove`: it
would leave the source entry without its key, and `apt update` would report an error).

## The key

`0A41 158C 1DD6 718D 3D3F  FED0 6848 6B39 B2A9 9993` still signs the checksums of the releases (`SHA256SUMS.asc`). Its signing
subkey `AEAB52A05F132CF78D85364486DF1E428F666F06` expires on 2028-10-09 (the primary key on 2031-10-09). If it were ever lost or
stolen: revoke it (`gpg --import` of the revocation certificate kept offline, then publish the revoked public key), announce it
on the site and on GitHub, and sign the next release with a new key published through several channels.

## How it was protected (1.1, for the record)

The index was signed and expired after 30 days; the key was valid for this source only (`Signed-By`); a pin let it provide only
packages named `vaevictis-*`; a published version was never replaced (`build/vv-apt-publish`, still in the repository); the
GitHub and Cloudflare accounts used two-factor login. None of this removed the risks above: it made them smaller.
