function vedo
	if test -e venv
		set -f venvdir "venv"
	else if test -e .venv
		set -f venvdir ".venv"
	else
		echo "<!>---- No venv dir found ----<!>"
		return 1
	end
	
	source "$venvdir/bin/activate.fish"
	command $argv
	deactivate
end
