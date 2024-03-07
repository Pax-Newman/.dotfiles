function vedo
	if not test -e venv
		echo "<!>---- No venv dir found ----<!>"
		exit 1
	end
	
	source "venv/bin/activate.fish"
	command $argv
	deactivate
end
