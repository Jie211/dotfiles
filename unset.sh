#!/bin/bash

# Stop script if errors occur
trap 'echo Error: $0:$LINENO stopped; exit 1' ERR INT
set -eu


# Get the dotfiles directory's absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

dir=~/test-dotfile                        # dotfiles directory
dir_backup=~/dotfiles_old             # old dotfiles backup directory

# Get current dir (so run this script from anywhere)
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# read functions
. "$DOTFILES_DIR"/etc/func.sh

while true; do
  print_question "Warning: this will remove your current dotfiles. Continue? [y/n] "
  read yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done

declare -a FILES_TO_SYMLINK=(
  'src/tmux.conf'
  'src/vimrc'
  'src/zshrc'
)

for i in ${FILES_TO_SYMLINK[@]}; do
  Source_File="$(pwd)/$i"
  Target_File="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"
  if [ ! -e $Target_File ]; then
    print_info "$Target_File not found"
    continue
  fi
  if [ "$(readlink "$Target_File")" == "$Source_File" ]; then
    unlink $Target_File
    print_success "unlink $Target_File"
  else
    ask_for_confirmation "'$Target_File' is not link from DOTFILEs, do you want to REMOVE it?"
    if answer_is_yes; then
      if [ -L "$Target_File" ]; then
        unlink $Target_File
        print_success "unlink $Target_File"
      else
        rm -rf "$Target_File"
        print_success "remove $Target_File"
      fi
    fi
  fi
done
unset FILES_TO_SYMLINK
