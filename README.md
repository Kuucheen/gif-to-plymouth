# gif-to-plymouth

Convert an animated GIF into a Plymouth boot splash theme.

`gif-to-plymouth` extracts GIF frames, renders them into PNGs, writes a Plymouth script theme, saves it under `/usr/share/plymouth/themes`, and can optionally set it as the active boot theme.

## Install

From a cloned checkout:

```bash
./install.sh
```

Or with curl:

```bash
curl -fsSL https://raw.githubusercontent.com/Kuucheen/gif-to-plymouth/main/install.sh | bash
```

If your GitHub repo name or owner is different, change the URL, or pass the repo to the shell running the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/owner/repo/main/install.sh | GIF_TO_PLYMOUTH_REPO=owner/repo bash
```

The installer copies the CLI to:

```text
~/.local/bin/gif-to-plymouth
```

Make sure `~/.local/bin` is in your `PATH`.

## Dependencies

Runtime commands:

```text
magick
identify
tar
pkexec
plymouth-set-default-theme
```

Package hints:

```bash
# Fedora
sudo dnf install ImageMagick plymouth plymouth-scripts polkit

# Debian / Ubuntu / Linux Mint
sudo apt install imagemagick plymouth policykit-1

# Arch / EndeavourOS / Manjaro
sudo pacman -S imagemagick plymouth polkit

# openSUSE
sudo zypper install ImageMagick plymouth polkit
```

The tool is primarily tested on Fedora. It should work on distributions that use Plymouth, store themes in `/usr/share/plymouth/themes`, and provide `plymouth-set-default-theme -R`.

## Usage

```bash
gif-to-plymouth INPUT.gif THEME_NAME [options]
```

Generate and save a theme:

```bash
gif-to-plymouth ~/Downloads/startup-world.gif world
```

Generate, save, set as default, and rebuild initramfs:

```bash
gif-to-plymouth ~/Downloads/startup-world.gif world --install
```

Switch to an already-generated theme later:

```bash
pkexec plymouth-set-default-theme -R world
```

The `-R` matters on Fedora-like systems because boot Plymouth is loaded from initramfs.

## Options

```text
--install
    Also set the theme as default and rebuild initramfs.

--output-dir DIR
    Also keep a user-owned generated copy under DIR.

--size WIDTHxHEIGHT
    Canvas size for generated frames.
    Default: 1280x720

--size-divisor N
    Use the GIF's resolution divided by N as the canvas.
    Example: 1280x480 with N=2 becomes 640x240.

--fit contain|cover|none
    Resize behavior.
    Default: contain

--background COLOR
    Canvas background.
    Default: black

--hold N
    Plymouth refresh ticks per frame.
    Default: 3

--ping-pong
    Loop forward, then backward, for a smoother seam.

--remove-leading-black
    Remove dark/blank frames at the start.

--black-threshold N
    Leading-black cutoff using max brightness.
    Default: 0.01
```

## Examples

Preserve the GIF canvas exactly:

```bash
gif-to-plymouth boot.gif MyTheme --size-divisor 1 --fit none
```

Scale down a large GIF by half:

```bash
gif-to-plymouth boot.gif MyTheme --size-divisor 2
```

Make a seamless ping-pong loop:

```bash
gif-to-plymouth boot.gif MyTheme --ping-pong
```

Fill a 1920x1080 splash:

```bash
gif-to-plymouth boot.gif MyTheme --size 1920x1080 --fit cover
```

Use a slower animation:

```bash
gif-to-plymouth boot.gif MyTheme --hold 5
```

## Existing Themes

If a theme with the same name already exists, the script asks before replacing it:

```text
Theme already exists: /usr/share/plymouth/themes/MyTheme
Replace it? [y/N]
```

Any answer except `y`, `Y`, `yes`, `YES`, or `Yes` aborts without changing the existing theme.

## Notes

Plymouth does not play GIFs directly. This tool converts the GIF into PNG frames and generates a Plymouth `script` plugin theme.

GIF frame delays are not preserved. Playback uses a fixed hold value controlled by `--hold`.

Shutdown can show a newly selected theme from `/usr/share/plymouth/themes`, while boot may still show the old theme until initramfs is rebuilt with:

```bash
pkexec plymouth-set-default-theme -R THEME_NAME
```

## Uninstall

Remove the CLI:

```bash
./uninstall.sh
```

Generated Plymouth themes are not removed automatically.
