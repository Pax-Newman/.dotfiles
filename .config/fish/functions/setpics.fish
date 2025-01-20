function setpics
   # Clear the current env var
   set --erase MOTD_DIRS

   # If we received any arguments then put them in the env var
   if test (count $argv) -gt 0
      set -Ua MOTD_DIRS $argv
   end
end
