function refresh --description 'Refreshes the current shell environment'

   # Parse command arguments
   set --local options 'h/help'
   argparse $options -- $argv

   if set --query _flag_help
      echo "usage: refresh [-h] [-k]
      h help: Display this help message
      "
      return 0
   end

   # Deactivate any active python virtual environments 
   if set --query VIRTUAL_ENV
      deactivate
   end

   # Wipe the screen
   clear

   # Re-execute the shell
   exec fish
end
