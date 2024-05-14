
# Dotfiles

My dotfiles for some of the tools I use!

## Includes

 - [nvim](https://github.com/neovim/neovim)
 - [wezterm](https://github.com/wez/wezterm)
 - [fish](https://github.com/fish-shell/fish-shell)

## Method

I use a bare git repository to store my dotfiles. It's got a lot of great advantages over approaches
like symlinks, and doesn't require anything except for git!

If you want to read more about the approach [this](https://www.atlassian.com/git/tutorials/dotfiles) is
a good article about it.

## Setup

```sh
# Ensure you're in the homedir
cd ~

# Clone this repo
git clone --bare "https://github.com/Pax-Newman/.dotfiles" "$HOME/.dotfiles"

# Set an alias for a git command that operates using our new .dotfiles directory
alias dots='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# Checkout the repo to bring the dotfiles into your home directory
dots checkout

# Ignore untracked files to make usage a lot cleaner
config config --local status.showUntrackedFiles no

# You're done!
```

