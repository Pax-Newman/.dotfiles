set -l available_scripts (ls ~/scripts/)

complete -c scripts -f
complete -c scripts -n \
   "not __fish_seen_subcommand_from $available_scripts" \
   -a "$available_scripts"

# TODO: Add descriptions for scripts in the completion prompt by reading the files and reading the first comments after the shebang?
