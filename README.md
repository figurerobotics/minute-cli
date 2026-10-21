# minute

Command-line client for the Minute partner platform. This repository holds the installer and the release archives; the source lives elsewhere.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/figurerobotics/minute-cli/HEAD/install.sh | bash
```

The script picks the archive for your machine (macOS and Linux, Apple Silicon and Intel), checks its SHA-256 against the release's `checksums.txt`, and puts `minute` in `~/.local/bin`. It never asks for sudo. Run the same command again to upgrade.

Once a day, a command run at a terminal checks this repository for a newer release and, when there is one, says so after its output, with the command above to run. The check is skipped when output is piped, in CI, and when `MINUTE_NO_UPDATE_NOTIFIER` is set.

| Variable | Effect |
| --- | --- |
| `MINUTE_INSTALL_DIR` | Install somewhere else, e.g. `curl -fsSL … \| MINUTE_INSTALL_DIR=/usr/local/bin bash` |
| `MINUTE_VERSION` | Pin a version, e.g. `curl -fsSL … \| MINUTE_VERSION=1.2.0 bash` |

On Windows, download the `windows_amd64` zip from the [latest release](https://github.com/figurerobotics/minute-cli/releases/latest) and put `minute.exe` on your `PATH`.

Then sign in:

```sh
minute login
```

`minute --help` lists the commands. `minute completion zsh --help` explains shell completion.

## Uninstall

```sh
minute logout
rm -rf ~/.local/bin/minute ~/.config/minute
```
