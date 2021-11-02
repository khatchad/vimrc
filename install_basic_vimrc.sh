#!/bin/sh
set -e

sudo apt update
sudo apt install vim-scripts

cd ~/.vim_runtime
cat ~/.vim_runtime/vimrcs/basic.vim > ~/.vimrc
echo "Installed the Basic Vim configuration successfully! Enjoy :-)"
