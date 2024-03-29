function forest --description 'Wraps git-subtree in a more user-friendly interface'
   set --local help 'usage: forest [-h] [-a add=URL] [-u update=[subtree]] [-r remove=subtree]
      h help: Display this help message
      a add: Add a subtree
      u update: Update a subtree, or all subtrees if no subtree is specified
      r remove: Remove a subtree
'

   if test (count $argv) -eq 0
      echo $help
      return 1
   end

   # Parse the command options
   set --local options \
      'h/help' \
      'a/add=' \
      'u/update=?' \
      'r/remove='
   argparse $options -- $argv

   # Display the help message
   if set --query _flag_help
      echo $help
      return 0
   end

   # Check if the current directory is a git repository
   if not git rev-parse --is-inside-work-tree > /dev/null
      return 1
   end

   # Check for uncommitted changes
   if git status --porcelain | grep -qv '^??'
      echo "Uncommitted changes in the repository"
      echo "Please commit or stash changes before running forest"
      return 1
   end

   # Add a subtree
   if set --query _flag_add
      # Name the subtree after the repository as author-repo
      string match -gr '\\.com\/(.+?)(\\.git|$)' $_flag_add \
         | tr '/' '-' \
         | read --local name

      # Create a remote to track changes
      git remote add -f $name $_flag_add
      # Add the subtree
      git subtree add --prefix forest/$name $_flag_add main --squash

      # Save the subtree to the forest file
      echo $name $_flag_add main >> forest/.forest

      return $status
   end

   # Update a subtree
   if set --query _flag_update

      # Check if a subtree is specified
      if string match --quiet '*' $_flag_update

         # Find the subtree in the forest file
         set --local tree (cat forest/.forest | grep $_flag_update)

         if test -z $tree
            echo "Subtree $_flag_update not found"
            return 1
         else
            read --local name url branch
         end

         # Update the specified subtree
         get fetch $_flag_update
         git subtree pull --prefix forest/$name $name main --squash
         return $status
      else
         # Otherwise update all subtrees
         for line in (cat forest/.forest)
            echo $line | read --local name url branch
            git fetch $name
            git subtree pull --prefix forest/$name $name main --squash
         end
         return $status
      end
   end

   # Remove a subtree
   if set --query _flag_remove
      # Find the subtree in the forest file
      set --local tree (cat forest/.forest | grep $_flag_remove)

      if test -z $tree
         echo "Subtree $_flag_remove not found"
         return 1
      else
         echo $tree | read --function name url branch
      end

      # Remove the subtree from the forest file
      grep -v $_flag_remove forest/.forest > forest/.forest.tmp
      mv forest/.forest.tmp forest/.forest

      # Remove subtree from repository
      git rm -r forest/$name
      git commit -m "Removed $name subtree"
      git remote remove $name

      return $status
   end

end
