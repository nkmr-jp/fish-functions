# fish-functions

<details>
<summary>ghu</summary>

this is github util command.
This command uses [ghq](https://github.com/motemen/ghq) and [gh](https://cli.github.com/).

please install these in advance.

## Install

### For Fish Shell

Requires [fish-shell](https://github.com/fish-shell/fish-shell).

```sh
$ ghq get -p nkmr-jp/fish-functions
$ cd ~/ghq/github.com/nkmr-jp/fish-functions
$ ln -s (pwd)/ghu.fish ~/.config/fish/functions/ghu.fish
```

add setting `~/.config/fish/config.fish`
```fish
set -x GITHUB_USER_NAME [your github user name]
```

reload config.fish
```sh
$ . ~/.config/fish/config.fish
```

### For Zsh Shell

```sh
$ ghq get -p nkmr-jp/fish-functions
$ cd ~/ghq/github.com/nkmr-jp/fish-functions
```

add the following to `.zshrc`:

```zsh
source ~/ghq/github.com/nkmr-jp/fish-functions/ghu.zsh
```

Add the following to `.zshrc`:

```zsh
export GITHUB_USER_NAME=[your github user name]
```

reload zshrc

```sh
$ source ~/.zshrc
```

## Usage
```sh
$ ghu
Usage: ghu COMMAND [keyword]

Commands:
  search      open github search page.
  init        create local and github repository.
              usage: ghu init REPOSITORY_NAME [editor]
  list        open github repositories page.
  open        open github repository page. if without [keyword] open current dir repository page.
  get         clone with a remote repository and change directory
```

</details>
