function scripts \
   --description "Runs a script from `~/scripts/`. Run it without any arguments to list the available scripts" \

   # Parse command arguments
   set --local help 'usage: scripts script_name [-h]
      h help: Display this help message'

   if test (count $argv) -eq 0
      ls ~/scripts/
      return 0
   end

   # Parse the command options
   set --local options \
      'h/help' \
   argparse $options -- $argv[1]
   or return 1

   # Display the help message
   if set --query _flag_help
      echo $help
      return 0
   end

   set --local available_scripts (find ~/scripts/ -perm +111 -type f -or -type l -maxdepth 1 | sed 's:^.*/scripts/::g')

   if contains $argv[1] $available_scripts
      ~/scripts/$argv[1] $argv[2..-1]
   else
      echo "No known script with the name `$argv[1]`"
   end
end
