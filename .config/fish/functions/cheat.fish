function cheat --description 'Display a cheat sheet using cheat.sh'
	set --local help 'usage: cheat [-h] topic_url
	h help: Display this help message
	  api:  Display the help message from the cheat.sh API'

	# TODO: --no-cache option for disabling caching a page
	
	# Parse the command options
	set --local options 'h/help' 'api'
	if not argparse \
			-N 0 \
			-X 1 \
			$options -- $argv
		echo $help
		return $status
	end

	# Display the help message
	if set --query _flag_help
		echo $help
		return 0
	# Display the API help message
	else if set --query _flag_api
		set --function argv ':help'
	# Otherise, if there's no arguments, display the help message
	else if test (count $argv) -eq 0
		echo $help
		return 1
	end

	if not test -e $HOME/.cheat/$argv[1].txt
		mkdir -p (path dirname $HOME/.cheat/$argv[1])
		curl --silent cheat.sh/$argv[1] --output $HOME/.cheat/$argv[1].txt
	end
	bat $HOME/.cheat/$argv[1].txt \
		--paging always \
		--decorations never
end
