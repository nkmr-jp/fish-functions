set HELP "
Usage: ghu COMMAND [keyword]

Commands:
  search      open github search page.
  init        create local and github repository.
              usage: ghu init REPOSITORY_NAME [editor]
  list        open github repositories page.
  open        open github repository page. if without [keyword] open current dir repository page.
  get         clone with a remote repository and change directory
"

function ghu
  if not count $argv > /dev/null
    echo -e $HELP
    return
  end
  switch $argv[1]
    case search
      open "https://github.com/search?q=$argv[2]"
    case init
      if test (count $argv) -ne 2
        echo -e $HELP
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
      git branch -M main
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
      cd (ghq root)/github.com/
      set ws_base "$argv[2]-ws"
      set ws_num 1
      while test -d "$ws_base$ws_num"
        set ws_num (math $ws_num + 1)
      end
      set ws_dir "$ws_base$ws_num"
      git clone git@github.com:$argv[2].git $ws_dir
      cd (ghq root)/github.com/$ws_dir
    case '*'
      echo -e $HELP
  end
end
