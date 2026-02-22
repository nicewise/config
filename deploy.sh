#!/usr/bin/env bash
set -euo pipefail

gitdir="$HOME/config"

cd ~

# 普通文件
for f in xinitrc xserverrc conkyrc xprofile Xresources vimrc bashrc zshrc; do
  ln -sf "$gitdir/conf.d/$f" ".$f"
done

# i3
mkdir -p .config/i3
ln -sf "$gitdir/conf.d/i3config" .config/i3/config

# emacs
mkdir -p .emacs.d
ln -sf "$gitdir/conf.d/init.el" .emacs.d/init.el

# paru
mkdir -p .config/paru
ln -sf "$gitdir/conf.d/paru.conf" .config/paru/paru.conf

# 系统级
sudo ln -sf "$gitdir/conf.d/sunhhenv.sh" /etc/profile.d/
sudo ln -sf "$gitdir/conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
sudo ln -sf "$gitdir/conf.d/10-monitor.conf" /etc/X11/xorg.conf.d/10-monitor.conf
