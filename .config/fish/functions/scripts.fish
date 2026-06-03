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

   ~/scripts/$argv[1] $argv[2..-1]
end
