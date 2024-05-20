function slideshow
   for dir in $MOTD_DIRS
      set -af pics (printf "%s" ~/.config/motd_pictures/$dir/)*.*
   end

   while true
      clear
      itermimg --width 100% (random choice $pics)
      sleep (math $argv[1] \* 60)
   end
end
