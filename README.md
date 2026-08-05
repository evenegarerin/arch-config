# arch-config

An Arch Linux re-creation of the setup in `../nixos-config` (Hyprland desktop on
a ThinkPad). Where NixOS describes the whole machine declaratively, here the
work is split into three concerns: **programs to install**, **config to link**,
and **scripts that do the work**.

## Layout

```
config/      configuration that gets symlinked into ~/.config (and a few other
             places) by configure.sh
programs/    one file per "repository", each a plain list of packages
scripts/     the four scripts described below
```

### config/

| source                      | linked to                                   |
|-----------------------------|---------------------------------------------|
| `hypr/`                     | `~/.config/hypr/` (hyprland, lock, idle, paper) |
| `waybar/`, `wofi/`, `kitty/`| `~/.config/<name>/`                         |
| `swaync/`, `yazi/`, `nvim/` | `~/.config/<name>/`                         |
| `qutebrowser/`              | `~/.config/qutebrowser/`                    |
| `gtk-3.0/`, `gtk-4.0/`      | `~/.config/<name>/`                         |
| `wallpapers/`               | `~/.config/wallpapers/`                     |
| `zsh/.zshrc`                | `~/.zshrc`                                  |
| `vscodium/settings.json`    | `~/.config/VSCodium/User/settings.json`     |
| `firefox/policies.json`     | `/etc/firefox/policies/policies.json` (sudo)|

### programs/

| file          | repository          | installed with                  |
|---------------|---------------------|---------------------------------|
| `pacman.txt`  | official repos      | `pacman -S --needed`            |
| `aur.txt`     | AUR                 | `yay -S --needed`               |
| `npm.txt`     | npm (global)        | `npm install -g`                |
| `vscode.txt`  | open-vsx (VSCodium) | `codium --install-extension`    |

## Scripts

| script         | does                                                            |
|----------------|----------------------------------------------------------------|
| `setup.sh`     | bare-metal Arch install: partition, bootloader, locale, users, services, prerequisites. Run from the live ISO. |
| `install.sh`   | installs every program in `programs/` that isn't already installed (does not upgrade existing ones). Bootstraps `yay` if missing. |
| `configure.sh` | symlinks everything in `config/` into place.                   |
| `update.sh`    | upgrades the system + repo/AUR/npm packages + VSCodium extensions. |

## Bootstrapping a new machine

```sh
# 1. from the Arch live ISO (edit the variables at the top first):
bash setup.sh
reboot

# 2. after first boot, on a TTY as 'castle':
git clone <this-repo> ~/arch-config
~/arch-config/scripts/install.sh
~/arch-config/scripts/configure.sh
sudo systemctl enable --now greetd      # starts the Hyprland session

# optional, for virt-manager:
sudo usermod -aG libvirt castle
sudo systemctl enable --now libvirtd
```

## Notes / things to double-check

- **AUR names** in `aur.txt` are best-effort translations of the nix packages
  (`-bin` vs source variants etc.); verify any that fail to build.
- A few apps (`devtoolbox`, `keypunch`, `appflowy`) are flatpak-first upstream;
  the AUR packages are used here to keep everything in one repository, but
  flatpak is a fine alternative if a build breaks.
- **Pylance** (`ms-python.vscode-pylance`) is not on open-vsx, so it is left out
  of `vscode.txt`.
- `nvim/lazy.lua` was switched to let lazy.nvim install plugins itself (on NixOS
  they were provided by nix), and a couple of plugins required by the lua config
  (`LuaSnip`, `neodev`) were added to the spec.
- The TLP charge thresholds, greetd session, locale and German `LC_*` settings
  mirror `configuration.nix`.
- NixOS opened firewall port 53317 for LocalSend; Arch ships no firewall by
  default, so nothing needs opening unless you install one.
