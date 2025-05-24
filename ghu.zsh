#!/bin/zsh

HELP="
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
  rm          remove current directory (only works for directories ending with '-ws*')
  rmall       remove all directories ending with '-ws*'
"

# Helper function to display help and return
__ghu_show_help() {
  echo -e $HELP
  return 1
}

# Helper function to create a workspace directory
__ghu_create_workspace() {
  local repo_path=$1

  cd $(ghq root)/github.com/
  local ws_base="${repo_path}-ws"
  local ws_num=1
  while [[ -d "${ws_base}${ws_num}" ]]; do
    ((ws_num++))
  done
  local ws_dir="${ws_base}${ws_num}"
  git clone git@github.com:${repo_path}.git $ws_dir
  cd $(ghq root)/github.com/$ws_dir

  # ブランチ自動生成機能
  # developブランチがあればそこから、なければmain、さらになければmasterから作成
  local branch_prefix="feature/"
  local timestamp=$(date +"%Y%m%d%H%M%S")
  local new_branch="${branch_prefix}${timestamp}"
  
  # 優先順位の高い順にブランチを確認
  local base_branches=("develop" "main" "master")
  local base_branch=""
  
  for branch in "${base_branches[@]}"; do
    if git rev-parse --verify $branch >/dev/null 2>&1 || 
       git rev-parse --verify origin/$branch >/dev/null 2>&1; then
      base_branch=$branch
      echo "ベースブランチとして '$branch' を使用します"
      break
    fi
  done
  
  if [[ -n "$base_branch" ]]; then
    # リモートブランチが存在するか確認
    if git rev-parse --verify origin/$base_branch >/dev/null 2>&1; then
      git checkout -b $new_branch origin/$base_branch
    else
      git checkout -b $new_branch $base_branch
    fi
    echo "新しいブランチ '$new_branch' を作成しました"
  else
    echo "ブランチの自動生成ができませんでした。develop、main、masterのいずれも見つかりません。"
  fi

  echo $ws_dir
}

ghu() {
  if [[ $# -eq 0 ]]; then
    __ghu_show_help
    return
  fi

  case "$1" in
    search)
      open "https://github.com/search?q=$2"
      ;;
    init)
      if [[ $# -ne 2 ]]; then
        __ghu_show_help
        return
      fi
      cd $(ghq root)/github.com/nkmr-jp
      git init $2
      cd $2
      gh repo create $2 --private --confirm
      git remote add origin "git@github.com:nkmr-jp/$2.git"
      git branch -M main
      echo "# $2" >> README.md
      git add README.md
      git commit -m "first commit"
      git push -u origin main
      gh repo view --web
      if [[ $# -eq 3 ]]; then
        eval "$3 ./"
      fi
      ;;
    list)
      open "https://github.com/$GITHUB_USER_NAME?tab=repositories&q=$2"
      ;;
    open)
      if [[ $# -eq 2 ]]; then
        local name=$2
      else
        local name=$(basename $(pwd))
      fi
      open "https://github.com/$GITHUB_USER_NAME/$name"
      ;;
    get)
      ghq get -p $2
      cd $(ghq root)/github.com/$2
      ;;
    workspace)
      __ghu_create_workspace $2
      ;;
    wind)
      __ghu_create_workspace $2
      wind .
      ;;
    land)
      __ghu_create_workspace $2
      land .
      ;;
    charm)
      __ghu_create_workspace $2
      charm .
      ;;
    rm)
      local prev_dir=$(pwd)
      local dir_name=$(basename $prev_dir)
      if [[ $dir_name == *-ws* ]]; then
        cd ../
        rm -rf $prev_dir
      else
        echo "Error: The rm command is only effective for directories ending with '-ws*'."
        echo "Current directory: $dir_name"
      fi
      ;;
    rmall)
      local current_dir=$(pwd)
      cd $(ghq root)/github.com/
      local ws_dirs=($(find . -maxdepth 2 -type d -name "*-ws*" | sort))
      if [[ ${#ws_dirs[@]} -eq 0 ]]; then
        echo "No workspace directories found."
      else
        echo "Found the following workspace directories:"
        for dir in "${ws_dirs[@]}"; do
          echo "  $dir"
        done
        read "confirm?Do you want to remove all these directories? [y/N] "
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
          for dir in "${ws_dirs[@]}"; do
            echo "Removing $dir..."
            rm -rf $dir
          done
          echo "All workspace directories have been removed."
        else
          echo "Operation cancelled."
        fi
      fi
      cd $current_dir
      ;;
    *)
      __ghu_show_help
      ;;
  esac
}
