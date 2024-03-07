function mkvenv --description 'Creates a new python project with a venv and pyproject.toml. Usage: mkvenv'
	set --local help 'usage: mkvenv [-h] [-n name]
	h help: Display this help message
	n name: Specify a name for the venv'
	
	# Parse the command options
	set --local options 'h/help' 'n/name='
	argparse $options -- $argv

	# Display the help message
	if set --query _flag_help
		echo $help
		return 0
	end

	# Set the virtual env name
	if set --query _flag_name
		set --function venv_name $_flag_name
	else
		set --function venv_name '.venv'
	end

	# Create the virtual environment
	python3 -m venv $venv_name

	# Activate our new environment
	source $venv_name/bin/activate.fish

	# Install project dependencies

	pip install --upgrade pip

	# pip install pyright

	# TODO have a line here that maybe auto-installs a requirements.txt?

	# Configure our pyproject.toml if it doesn't already exist
	if not test -e pyproject.toml
		echo "
[tool.pyright]
exclude = [ \"$venv_name\" ]
venvPath = \".\"
venv = \"$venv_name\"
" >> pyproject.toml
	end

end
