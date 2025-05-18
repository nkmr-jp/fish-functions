set HELP "
Usage: ghu COMMAND [keyword]

Commands:
  search      open github search page.
  init        create local and github repository.
              usage: ghu init REPOSITORY_NAME [editor]
  list        open github repositories page.
  open        open github repository page. if without [keyword] open current dir repository page.
  get         clone with a remote repository and change directory
  workspace   create workspace directory
  wind        create workspace directory and launch windsurf
"

# Helper function to display help and return
function __ghu_show_help
  echo -e $HELP
  return 1
end

# Helper function to create a workspace directory
function __ghu_create_workspace
  set -l repo_path $argv[1]

  cd (ghq root)/github.com/
  set ws_base "$repo_path-ws"
  set ws_num 1
  while test -d "$ws_base$ws_num"
    set ws_num (math $ws_num + 1)
  end
  set ws_dir "$ws_base$ws_num"
  git clone git@github.com:$repo_path.git $ws_dir
  cd (ghq root)/github.com/$ws_dir

  echo $ws_dir
end

function ghu
  if not count $argv > /dev/null
    __ghu_show_help
    return
  end
  switch $argv[1]
    case search
      open "https://github.com/search?q=$argv[2]"
    case init
      if test (count $argv) -ne 2
        __ghu_show_help
        return
      end
      cd (ghq root)/github.com/nkmr-jp
      git init $argv[2]
      cd $argv[2]
      gh repo create $argv[2] --private --confirm
      git remote add origin "git@github.com:nkmr-jp/$argv[2].git"
      git branch -M main
      echo "# $argv[2]" >> README.md
      git add README.md
      git commit -m "first commit"
      git push -u origin main
      gh repo view --web
      if test (count $e) -eq 3
        eval ($argv[3] ./)
      end
    case list
      open "https://github.com/$GITHUB_USER_NAME?tab=repositories&q=$argv[2]"
    case open
      if test (count $argv) -eq 2
        set name $argv[2]
      else
        set name (basename (pwd))
      end
      open "https://github.com/$GITHUB_USER_NAME/$name"
    case get
      ghq get -p $argv[2]
      cd (ghq root)/github.com/$argv[2]
    case workspace
      __ghu_create_workspace $argv[2]
    case wind
      __ghu_create_workspace $argv[2]
      wind .
    case rm
      set prev_dir (pwd)
      cd ../
      rm -rf $prev_dir
    case '*'
      __ghu_show_help
  end
end
