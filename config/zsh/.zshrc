# ~/.zshrc
# translated from nixos-config/home/zsh.nix (+ shell bits of vscode.nix)

###############################################################################
# oh-my-zsh
###############################################################################

export ZSH="$HOME/.oh-my-zsh"

# bootstrap oh-my-zsh if it is not present (replaces the nix-managed install)
if [ ! -d "$ZSH" ]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
fi

ZSH_THEME="af-magic"

plugins=(
  command-not-found
  git
  history
  sudo
)

source "$ZSH/oh-my-zsh.sh"

###############################################################################
# Environment
###############################################################################

export VSCODE_WORKSPACE_LOCATION="$HOME/.vscode-workspaces"

###############################################################################
# Aliases
###############################################################################

alias code="codium"

# rebuild/sync this machine from the dotfiles (arch equivalent of nix-rebuild)
alias sys-update="$HOME/arch-config/scripts/update.sh"

###############################################################################
# Functions
###############################################################################

# yazi shell wrapper that cd's into the directory you quit in
# (replaces programs.yazi.enableZshIntegration)
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

vscode() {
  yy
  code . && exit
}

###############################################################################
# Syntax highlighting (must be sourced last)
###############################################################################

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
