set HELP "
Usage: ghu COMMAND [keyword]

Commands:
  search      open github search page.
  init        create local and github repository.
              usage: ghu init REPOSITORY_NAME [editor]
  list        open github repositories page.
  open        open github repository page. if without [keyword] open current dir repository page.
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
      if not count $argv > /dev/null
        echo -e $HELP
        return
      end
      cd (ghq root)/github.com/nkmr-jp
      git init $argv[2]
      cd $argv[2]
      hub create -p
      echo "# $argv[2]" >> README.md
      git add README.md
      git commit -m "first commit"
      git push -u origin main
      hub browse
      if test (count $e) -eq 3
        eval ($argv[3] ./)
      end
      # charm ./
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
    case '*'
      echo -e $HELP
  end
end
