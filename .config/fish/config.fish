#Pax Newman FISH Config

# ---- EnvVars ----
set -gx XDG_DATA_HOME {$HOME}/.local/share
set -gx XDG_CONFIG_HOME {$HOME}/.config

set -gx EDITOR nvim

set -g fish_term24bit 1

set -gx BAT_THEME ansi


# ---- Interactive Settings ----
if status is-interactive

   # ---- Greeting

   # Remove the default greeting
   set -U fish_greeting

   # If we have picture directories set then display a pic
   if not set --query NVIM; and set --query MOTD_DIRS
      # add all files from each dir in MOTD_DIRS
      for dir in $MOTD_DIRS
         set -af pics (printf "%s" ~/.config/motd_pictures/$dir/)*.*
      end
      # Display a random picture from $pics
      if test -n "$ZELLIJ"
         img2sixel (random choice $pics) --height 512
      else
         wezterm imgcat (random choice $pics) --height 50%
      end

   # Otherwise display a text message with the weather
   else
      weather
   end

   # ---- Aliases

   alias c='z'

   alias gs='git status'
   alias ga='git add'
   alias gc='git commit'
   alias gd='git diff'

   alias dots='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
   alias dotadd='dots add'
   alias dotstat='dots status'

   # ---- Theme

   fish_config theme choose 'Rosé Pine Moon'

   # ---- Prompt
   # tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time='12-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=No

end


# Rust CLI App inits
zoxide init fish | source

fish_add_path ~/.local/bin/

if status is-interactive
  mise activate fish | source
else
  mise activate fish --shims | source
end

# ---- Path Setup ----

# ---- Fish Path
fish_add_path /Users/paxnewman/bin
fish_add_path /Users/paxnewman/Library/Python/3.11/bin
fish_add_path /Users/paxnewman/go/bin
fish_add_path /opt/homebrew/bin

# ---- PATH
fish_add_path --path /Users/paxnewman/.cargo/bin

# ---- Shell Integrations ----

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

