function mkvenv --description 'Creates a new python project with a venv and pyproject.toml. Usage: mkvenv'
   set --local help 'usage: mkvenv [-h] [-n name]
   h help: Display this help message
   n name: Specify a name for the venv
   v version: Specify which version of python to use
   i interactive: Install ipython kernel
   r requirements: Install a requirements.txt file'

   # Parse the command options
   set --local options \
      'h/help' \
      'n/name=' \
      'v/version=' \
      'i/interactive' \
      'r/requirements='
   argparse $options -- $argv

   # Display the help message
   if set --query _flag_help
      echo $help
      return 0
   end

   # Set the virtual env name
   if set --query _flag_name
      set --function venv_name $_flag_name
      set --function project_name $_flag_name
   else
      set --function venv_name '.venv'
      set --function project_name (basename $PWD | tr -s '[:blank:]' '-')
   end

   # Set the python version
   if set --query _flag_version
      set --function python_version $_flag_version
   else
      set --function python_version '3'
   end

   # Get local current directory name in kebab-case

   # Create the virtual environment
   env (printf "python%s" $python_version) -m venv $venv_name

   # Activate our new environment
   source $venv_name/bin/activate.fish

   pip install --upgrade pip

   # Setup venv's jupyter kernel
   if set --query _flag_interactive
      pip install ipykernel
      # Set kernel name to the basename of the repo and replace whitespace with dashes
      python -m ipykernel install --user --name $project_name
   end

   # Install requirements
   if set --query _flag_requirements
      pip install -r $_flag_requirements
   end

   # Configure our pyproject.toml if it doesn't already exist
   if not test -e pyproject.toml
      echo "
[project]
name = \"$project_name\"
version = \"1.0.0\"

[tool.pyright]
exclude = [ \"$venv_name\" ]
venvPath = \"$(path normalize (pwd)/$venv_name)\"
venv = \"$venv_name\"
" >> pyproject.toml
   end
end
