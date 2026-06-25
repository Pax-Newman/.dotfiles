# Completions for the `notify` function (see functions/notify.fish)

# The message body is free text, so don't offer file completions
complete -c notify -f

complete -c notify -s h -l help        -d 'Display this help message'
complete -c notify -s t -l title       -x -d 'Set the notification title'
complete -c notify -s S -l subtitle    -x -d 'Set the notification subtitle'
complete -c notify -s s -l sound       -x -d 'Play a sound by name' -a '(notify --list-sounds)'
complete -c notify -s p -l speak       -d 'Read the message aloud with say'
complete -c notify -s l -l list-sounds -d 'List the available sound names'
