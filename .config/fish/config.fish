#Pax Newman FISH Config

if status is-interactive
    # Commands to run in interactive sessions can go here
    #set -U fish_greeting # comment out to disable the motd?
    
    # default to the manga dir if there's nothing set to MOTD_DIRS
    if test -z "$MOTD_DIRS" 
        set -a MOTD_DIRS "manga"
    end
    # add all files from each dir in MOTD_DIRS
    for dir in $MOTD_DIRS
        set -af pics (printf "%s" ~/.config/motd_pictures/$dir/)*.*
    end
    # Display a random picture from $pics
    if test -n "$ZELLIJ"
        img2sixel (random choice $pics) --height 512
    else
        itermimg (random choice $pics) --height 50%
    end

    alias c='z'

    alias gs='git status'
    alias ga='git add'
    alias gc='git commit -m'
    alias gd='git diff'


    alias dots='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

    alias dotadd='dots add'
    alias dotstat='dots status'

    fish_config theme choose 'Rosé Pine Moon'
end

set -gx EDITOR nvim

set -g fish_term24bit 1

set -gx BAT_THEME ansi

# Rust CLI App inits
zoxide init fish | source
starship init fish | source

# --- Path Setup ---

# -- Fish Paths
fish_add_path /Users/paxnewman/bin
fish_add_path /Users/paxnewman/Library/Python/3.11/bin
fish_add_path /Users/paxnewman/go/bin
fish_add_path /opt/homebrew/bin

# -- PATH
fish_add_path --path /Users/paxnewman/.cargo/bin

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

