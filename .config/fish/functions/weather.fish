function weather
   set -l wttr_data $XDG_DATA_HOME/weather/data

   function __fetch
      curl \
         --silent \
         'wttr.in/?format=%l\n%t+%c\nprecipitation:%20%p\n' \
         -o $wttr_data
   end

   if not test -e $wttr_data
      echo "Heyo"
      mkdir -p $XDG_DATA_HOME/weather/
      __fetch
   end

   # Check if it's been 15 minutes since we last checked the weather
   if test (math (date +%s) - (date -r $wttr_data +%s)) -gt 900

      # Update the weather
      __fetch
   end

   date +'%A %b. %d'
   cat $wttr_data
end
