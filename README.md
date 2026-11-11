# oikos

A cross-platform Nix setup for macOS (nix-darwin + home-manager) and non-NixOS Linux (standalone home-manager).

No usernames or other personal details live in this repository. Commands read them from the environment, so you
supply them on the command line.

## Layout

| File | What it configures | Used by |
|---|---|---|
| `flake.nix` | Inputs, and one builder each for macOS and Linux | all |
| `darwin.nix` | macOS system: defaults, Touch ID sudo, Nix settings, Homebrew casks | every Mac |
| `darwin-ergon.nix` | Extra Homebrew casks for work | work Mac |
| `home.nix` | GUI apps: Firefox, Thunderbird, VS Code, Obsidian, Bitwarden, VeraCrypt, ... | all |
| `cli.nix` | Shell and terminal: zsh, Ghostty, Starship, atuin, fzf, bat, eza, ... | all (via `home.nix`) |
| `ergon.nix` | Work tooling: cloud CLIs, Kubernetes (+ k9s, `k` aliases), Go, Terraform, Firefox Entra SSO | work Mac |

## Configurations

| Flake output | Machine | Tool |
|---|---|---|
| `macos-aarch64` | Personal Apple Silicon Mac | nix-darwin |
| `macos-work` | Work Apple Silicon Mac | nix-darwin |
| `linux` | x86_64 Linux, not NixOS | home-manager |
| `linux-aarch64` | aarch64 Linux (e.g. Raspberry Pi), not NixOS | home-manager |

## Prerequisites

- Nix installed in multi-user (daemon) mode. Flakes don't have to be enabled yet: the commands below turn them on
  for each run, and on macOS `darwin.nix` enables them permanently.
- macOS only: [Homebrew](https://brew.sh), for casks with no usable nixpkgs build (VeraCrypt, plus Claude on the
  work Mac). Without it the switch still succeeds, but it prints an error and skips the casks.

## macOS

```sh
sudo env NIX_USER="<your-mac-username>" \
  nix run nix-darwin \
  --extra-experimental-features "nix-command flakes" \
  -- switch --flake ".#macos-aarch64" --impure
```

On the work Mac use `.#macos-work`. Use the same command for every update.

Why both are needed:

- **`sudo`**: nix-darwin activates system-level settings (`/etc`, launchd, PAM, Homebrew), so `switch` must run as root.
- **`--impure` + `NIX_USER`**: the username is read with `builtins.getEnv`, which returns an empty string in pure
  evaluation. `sudo` also resets the environment, so the variable has to go through `sudo env`. If it's missing,
  evaluation stops with an error saying so.

Gotchas:

- Don't use plain `sudo darwin-rebuild switch --flake ...`: it drops `NIX_USER`. Always use the `sudo env ...` form.
- `mac-app-util` is disabled for the home-manager user on purpose: its trampolines conflict with device management on
  the work Mac. Apps are symlinked into `~/Applications/Home Manager Apps` instead.
- Files that clash with home-manager are renamed to `<file>.backup` instead of failing the switch.

## Linux (non-NixOS)

```sh
nix run home-manager \
  --extra-experimental-features "nix-command flakes" \
  -- switch --flake ".#linux" --impure
```

On the Raspberry Pi use `.#linux-aarch64`.

Unlike on macOS:

- **No `sudo`**: standalone home-manager only writes to your home directory and your Nix profile, so it runs as you.
  Running it with `sudo` would configure root's home instead.
- **`--impure` is still needed** to read the username, but no variable has to be set: it comes from `$USER`, which
  your login shell already sets.

Gotchas:

- `targets.genericLinux.enable` is on, which also sets up GPU driver integration for GUI apps. After the first
  switch, and again whenever the host's graphics drivers change, run this once (this one does need root):

  ```sh
  sudo "$(readlink -f ~/.nix-profile/bin/non-nixos-gpu-setup)"
  ```

  Without it, GUI apps (Ghostty, Firefox, VS Code, Obsidian, ...) can't find the host GPU drivers.
- Ghostty needs OpenGL 4.3. A Raspberry Pi's GPU only supports about GL 3.1, so Ghostty may not start there. Try
  `LIBGL_ALWAYS_SOFTWARE=1 ghostty` or use another terminal.
- zsh is installed but isn't made the login shell. Add it to `/etc/shells` and run `chsh -s "$(command -v zsh)"`.
- The Linux configs have only been evaluated, not tested on real hardware.

## VeraCrypt

- **macOS**: Homebrew cask `veracrypt-fuse-t`, which pulls in [FUSE-T](https://www.fuse-t.org/). FUSE-T needs no
  kernel extension, so it doesn't need lowered security settings, and it's the build VeraCrypt recommends for Apple
  Silicon. The installer may ask for your password during the switch.
- **Linux**: `pkgs.veracrypt` from nixpkgs. Mounting a volume needs root: VeraCrypt asks for your password and runs
  `sudo` itself. On non-NixOS it relies on the host's FUSE and device-mapper. If mounting fails, install the
  distribution's `fuse`/`fuse3` package.

## Firefox profile

home-manager owns `profiles.ini` and creates a profile in a folder named `default`. A profile you had before isn't
picked up automatically. If you don't use Firefox Sync, copy your old data over **once**, with Firefox closed, after
the first switch:

```sh
# macOS
cd ~/Library/Application\ Support/Firefox/Profiles
# Linux
cd ~/.mozilla/firefox

ls                                   # find the old <random>.default-release folder
cp -R <random>.default-release/. default/
```

## Updating

```sh
nix flake update
```

Then rerun the switch command for the machine. To bump a single input, run `nix flake update <input>`, for example
`nix flake update home-manager`.

## Notes

- Work-only settings go in `ergon.nix` (home-manager) or `darwin-ergon.nix` (system). home-manager merges options
  across files, so `ergon.nix` can add to a program configured in `home.nix` (as it does with the Firefox policy) without
  editing it. Only the macOS builder has an `isWork` switch; to get the work tools on Linux, add `./ergon.nix` to `mkHome`'s modules in `flake.nix`.
- Unfree packages are allowed (VS Code, Obsidian, Terraform, ...).
- Don't bump `home.stateVersion` (`24.11`) or `system.stateVersion` (`6`) as part of an update. They record the
  release the config was first written for, not the current version.

## Extras

[Wallpapers](https://github.com/orangci/walls-catppuccin-mocha?tab=readme-ov-file)
