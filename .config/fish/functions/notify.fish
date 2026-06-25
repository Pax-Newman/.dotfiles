function notify --description 'Send a macOS notification. Usage: notify [options] message...'
   set --local help 'usage: notify [-h] [-t title] [-S subtitle] [-s sound] [-p] [-l] message...
   h help:         Display this help message
   t title:        Set the notification title (default: fish)
   S subtitle:     Set the notification subtitle
   s sound:        Play a sound by name (see -l for the list)
   p speak:        Also read the message aloud with `say`
   l list-sounds:  List the available sound names and exit

   The message can be passed as arguments or piped in:
      notify "Build finished"
      make build; and notify -s Glass "Done" -t "Make"
      echo "Piped body" | notify -t "Heads up"

   NOTE: macOS posts these notifications as "Script Editor", not your terminal.
   If you see nothing, you must allow them in:
      System Settings > Notifications > Script Editor
   Turn on "Allow Notifications" and set the alert style to Banners or Alerts.'

   # Parse the command options
   set --local options \
      'h/help' \
      't/title=' \
      'S/subtitle=' \
      's/sound=' \
      'p/speak' \
      'l/list-sounds'
   argparse $options -- $argv
   or return 1

   # Display the help message
   if set --query _flag_help
      echo $help
      return 0
   end

   # This function only works on macOS
   if not command -q osascript
      echo 'notify: osascript not found (this function requires macOS)' >&2
      return 1
   end

   # List the available sounds and exit
   if set --query _flag_list_sounds
      for f in /System/Library/Sounds/*.aiff $HOME/Library/Sounds/*.aiff
         test -e $f; and basename $f .aiff
      end
      return 0
   end

   # Resolve the message body: arguments first, otherwise read from a pipe.
   # Note: a command substitution like (cat) can't see piped stdin in fish,
   # so we slurp the pipe with `read -z` instead.
   set --local body $argv
   if test (count $body) -eq 0; and not isatty stdin
      read --null --local piped
      set body (string trim -- $piped)
   end

   # A notification with no body is not very useful
   if test (count $body) -eq 0
      echo 'notify: no message given' >&2
      echo $help >&2
      return 1
   end
   set --local body (string join ' ' -- $body)

   # Apply defaults for the optional fields
   set --query _flag_title; or set --local _flag_title 'fish'
   set --query _flag_subtitle; or set --local _flag_subtitle ''
   set --query _flag_sound; or set --local _flag_sound ''

   # Build the AppleScript. Passing the strings as `argv` to the script avoids
   # any quoting/escaping headaches when the text contains quotes, $, &, etc.
   #
   # NOTE: macOS attributes these notifications to Script Editor
   # (com.apple.ScriptEditor2), so they only appear if Script Editor is allowed
   # in System Settings > Notifications.
   osascript \
      -e 'on run argv' \
      -e 'set theBody to item 1 of argv' \
      -e 'set theTitle to item 2 of argv' \
      -e 'set theSubtitle to item 3 of argv' \
      -e 'set theSound to item 4 of argv' \
      -e 'if theSound is "" then' \
      -e 'display notification theBody with title theTitle subtitle theSubtitle' \
      -e 'else' \
      -e 'display notification theBody with title theTitle subtitle theSubtitle sound name theSound' \
      -e 'end if' \
      -e 'end run' \
      -- "$body" "$_flag_title" "$_flag_subtitle" "$_flag_sound"
   or return $status

   # Optionally read the message aloud, without blocking the shell
   if set --query _flag_speak
      say -- $body &
      disown
   end
end
