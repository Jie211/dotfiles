#!/bin/bash

############################################
##    Pre
############################################

# Stop script if errors occur
trap 'echo Error: $0:$LINENO stopped; exit 1' ERR INT
set -eu

# Get the dotfiles directory's absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

dir=~/dotfiles                        # dotfiles directory
dir_backup=~/dotfiles_old             # old dotfiles backup directory

# Get current dir (so run this script from anywhere)

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# read functions
. "$DOTFILES_DIR"/etc/func.sh

if [ $(get_os) == 'osx' ]; then
  print_info "Running on macOS"
elif [ $(get_os) == 'centos' ]; then
  print_info "Running on CentOS"
else
  print_error "Running on unsupport OS -> exit"
  exit
fi

# Warn user this script will overwrite current dotfiles
while true; do
  print_question "Warning: this will overwrite your current dotfiles. Continue? [y/n] "
  read yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done

# Create dotfiles_old in homedir
if [ ! -e ${dir_backup} ];then
  echo  "Creating $dir_backup for backup of any existing dotfiles"
  mkdir -p $dir_backup
fi

# Change to the dotfiles directory
if [ $(pwd) != ${dir} ]; then
  echo  "Changing to the $dir directory..."
  cd $dir
fi

declare -a FILES_TO_SYMLINK=(
  'src/tmux.conf'
  'src/vimrc'
  'src/zshrc'
)

############################################
##    Main Jobs
############################################

Do_PRE(){
# Move any existing dotfiles in homedir to dotfiles_old directory,
# then create symlinks from the homedir to any files in the ~/dotfiles
# directory specified in $files
  print_info "Backup old file or unlink old symlink"
  for i in ${FILES_TO_SYMLINK[@]}; do
    if [ -e ~/.${i##*/} ]; then
      if [ ! -L ~/.${i##*/} ];then
        echo "backup ${i##*/} ~ to $dir_backup"
        mv -v ~/.${i##*/} ~/dotfiles_old/
      else
        echo "unlink ${i##*/} "
        # unlink ~/.${i##*/}
        execute "unlink ~/.${i##*/}" "unlink ~/.${i##*/}" "Failed to unlink ~/.${i##*/}"
      fi
    fi
  done
}

Do_Link(){
  print_info "Link dotfiles to local"
  # Do link file
  for i in ${FILES_TO_SYMLINK[@]}; do
    Source_File="$(pwd)/$i"
    Target_File="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$Target_File" ]; then
      # ln -s $Source_File $Target_File
      # print_success "$Source_File -> $Target_File"
      execute "ln -fs $Source_File $Target_File" "$Source_File → $Target_File" "Failed to link $Source_File → $Target_File"
    elif [ "$(readlink "$Target_File")" == "$Source_File" ]; then
      print_success "$Source_File -> $Target_File"
      echo " $Target_File already linked "
    else
      ask_for_confirmation "'$Target_File' already exists, do you want to OVERWRITE it?"
      if answer_is_yes; then
        rm -rf "$Target_File"
        # ln -s $Source_File $Target_File
        # print_success "$Source_File -> $Target_File"
        execute "ln -fs $Source_File $Target_File" "$Source_File → $Target_File" "Failed to link $Source_File → $Target_File"
      else
        print_error "$Source_File -> $Target_File"
      fi
    fi
  done

  unset FILES_TO_SYMLINK
}

Do_SUFFIX(){
  print_info  "Suffix works"
  if [ ! -e $HOME/.zsh-local ];then
    # print_info  "Make a local zsh setting file .zsh-local"
    touch $HOME/.zsh-local
  fi
  # source $HOME/.zshrc
  print_info "Run tmux and do Prefix+I to install tmux-plugins"
  print_info "Run vim to install vim-plugins"
}

Do_brew(){
  print_info "Install homebrew and packages"
  if ! type "brew" > /dev/null; then
    # print_info "Install homebrew"
    execute "/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"" "Installed brew" "Cannot install brew"
  else
    :
  fi

  execute "brew update" "brew update" "Cannot update brew"

  for pkg in wget w3m lynx zsh vim tmux git ; do
    if ! command_exist ${pkg}; then
      print_info "Installing $pkg"
      if [ $pkg == vim ]; then
        execute "brew install vim --with-lua --with-luajit" "Install vim" "Cannot install vim"
      fi
      execute "brew install vim --with-lua --with-luajit" "Install vim" "Cannot install vim"
    fi
  done

  for pkg in reattach-to-user-namespace ; do
    if brew list -1 | grep -q "^${pkg}\$"; then
      :
    else
      print_info "Installing $pkg"
      execute "brew install $pkg" "Install $pkg" "Cannot install $pkg"
    fi
  done

}

Do_yum(){
  print_error "You need install those packages by yourself"
  print_error "w3m lynx"
}

Do_log(){
  dotfiles_logo='
        | |     | |  / _(_) |
      __| | ___ | |_| |_ _| | ___  ___
     / _` |/ _ \| __|  _| | |/ _ \/ __|
    | (_| | (_) | |_| | | | |  __/\__ \
     \__,_|\___/ \__|_| |_|_|\___||___/
           *** by jie211 ***

  '
  echo "$dotfiles_logo"
}

Do_log
print_info "job start"

Do_PRE
Do_Link
if [ $(get_os) == 'osx' ]; then
  Do_brew
elif [ $(get_os) == 'centos' ]; then
  Do_yum
fi
Do_brew
Do_SUFFIX

print_info "job done"
