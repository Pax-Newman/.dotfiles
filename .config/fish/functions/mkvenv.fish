function mkvenv --description 'Creates a new python project with a venv and pyproject.toml. Usage: mkvenv'
	set --local help 'usage: mkvenv [-h] [-n name]
	h help: Display this help message
	n name: Specify a name for the venv
	v version: Specify which version of python to use'
	
	# Parse the command options
	set --local options 'h/help' 'n/name=' 'v/version='
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

	# Set the python version
	if set --query _flag_version
		set --function python_version $_flag_version
	else
		set --function python_version '3'
	end

	# Create the virtual environment
	env (printf "python%s" $python_version) -m venv $venv_name

	# Activate our new environment
	source $venv_name/bin/activate.fish

	# Install project dependencies

	pip install --upgrade pip

	# Setup venv jupyter kernel
	pip install ipykernel
	# Set kernel name to the basename of the repo and replace whitespace with dashes
	python -m ipykernel install --user --name (basename $PWD | tr -s '[:blank:]' '-')

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
