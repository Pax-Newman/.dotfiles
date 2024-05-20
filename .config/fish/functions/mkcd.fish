function mkcd \
  --wraps='echo $argv[1] && mkdir -p $argv[1] && c $argv[1]' \
  --description 'alias mkcd=echo $argv[1] && mkdir -p $argv[1] && c $argv[1]'
   echo $argv[1] && mkdir -p $argv[1] && c $argv[1]
end
