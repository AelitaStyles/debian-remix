# debian-remix
These are a set of scripts for producing a custom Debian live CD. Useful if you
wish to produce a Debian remix or create a specialised live CD.

## Configuring
You may want to adjust the configuration in `config.sh` to change target or
base build of Debian. You may also want to customise `grub.cfg` to adjust boot
options or add branding.

You'll also need to change `setup/setup.sh` to run any customisations you wish
within the live CD. Everything within the `setup` directory is copied **temporarily**
to the CD during the build process, so you can copy stuff into their correct
locations.

## Building
Run `build.sh`, sit back, have a coffee, and the output should be `build/build.iso`.

## License & Contributions
See [LICENSE.md](https://github.com/AelitaStyles/debian-remix/blob/main/LICENSE.md).
Contributions welcome. I'd like to add support for more architectures than just
amd64.