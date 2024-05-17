function weather
   set -l wttr_last $XDG_DATA_HOME/weather/last
   set -l wttr_data $XDG_DATA_HOME/weather/data

   if not test -e $wttr_last
      mkdir -p $XDG_DATA_HOME/weather/
      echo 0 > $wttr_last
   end

   # Check if it's been 15 minutes since we last checked the weather
   if test (math (date +%s) - (cat $wttr_last)) -gt 900
      date +%s > $wttr_last

      # Update the weather
      curl --silent 'wttr.in/?format=%l\n%t+%c\nprecipitation:%20%p\n' \
         -o $wttr_data
   end

   date +'%A %b. %d'
   cat $wttr_data
end
