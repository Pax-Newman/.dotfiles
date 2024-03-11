function cheat
	if not test -e $HOME/.cheat/$argv[1].txt
		mkdir -p (path dirname $HOME/.cheat/$argv[1])
		curl --silent cheat.sh/$argv[1] --output $HOME/.cheat/$argv[1].txt
	end
	bat $HOME/.cheat/$argv[1].txt \
		--paging=always \
		--file-name $argv[1] \
		--decorations never
end
