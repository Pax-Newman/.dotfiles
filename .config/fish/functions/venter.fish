function venter
   if test -e venv
      set -f venvdir "venv"
   else if test -e .venv
      set -f venvdir ".venv"
   else if set -q argv
      set -f venvdir $argv
   else
      echo "<!>---- No venv dir found ----<!>"
      return 1
   end

   source "$venvdir/bin/activate.fish"
end
