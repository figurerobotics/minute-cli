# minute

Command-line client for the Minute partner platform. This repository holds the installer and the release archives; the source lives elsewhere.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/figurerobotics/minute-cli/HEAD/install.sh | bash
```

The script picks the archive for your machine (macOS and Linux, Apple Silicon and Intel), checks its SHA-256 against the release's `checksums.txt`, and puts `minute` in `~/.local/bin`. It never asks for sudo.

| Variable | Effect |
| --- | --- |
| `MINUTE_INSTALL_DIR` | Install somewhere else, e.g. `curl -fsSL … \| MINUTE_INSTALL_DIR=/usr/local/bin bash` |
| `MINUTE_VERSION` | Pin a version, e.g. `curl -fsSL … \| MINUTE_VERSION=1.2.0 bash` |

On Windows, download the `windows_amd64` zip from the [latest release](https://github.com/figurerobotics/minute-cli/releases/latest) and put `minute.exe` on your `PATH`; `minute upgrade` does not run there, so upgrade the same way.

Then sign in:

```sh
minute login
```

`minute --help` lists the commands. `minute completion zsh --help` explains shell completion.

## Upgrade

```sh
minute upgrade
```

This replaces the installed binary with the latest release, verified the same way; `minute upgrade --version 1.2.0` installs that release instead, older than the current one or not. Running the install command again does the same.

Once a day, a command run at a terminal checks this repository for a newer release and, when there is one, says so after its output and names `minute upgrade`. The check is skipped when output is piped, in CI, and when `MINUTE_NO_UPDATE_NOTIFIER` is set.

## Uninstall

```sh
minute logout
rm -rf ~/.local/bin/minute ~/.config/minute
```
