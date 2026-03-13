#!/usr/bin/env bash
set -euo pipefail

gitdir="$HOME/config"

cd ~

# X11
for f in xinitrc xserverrc xprofile Xresources; do
  ln -sf "$gitdir/conf.d/$f" ".$f"
done

# 系统级 (Xorg)
sudo ln -sf "$gitdir/conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
sudo ln -sf "$gitdir/conf.d/10-monitor.conf" /etc/X11/xorg.conf.d/10-monitor.conf

# i3
mkdir -p .config/i3
ln -sf "$gitdir/conf.d/i3config" .config/i3/config
ln -sf "$gitdir/conf.d/conkyrc" ".conkyrc"

# sway
mkdir -p .config/sway
ln -sf "$gitdir/conf.d/swayconfig" .config/sway/config
mkdir -p .config/swaylock
ln -sf "$gitdir/conf.d/swaylock" .config/swaylock/config

# rofi
mkdir -p .config/rofi
ln -sf "$gitdir/conf.d/rofi/config.rasi" .config/rofi/config.rasi

# waybar
mkdir -p .config/waybar
ln -sf "$gitdir/conf.d/waybar/config" .config/waybar/config
ln -sf "$gitdir/conf.d/waybar/style.css" .config/waybar/style.css

# zsh
for f in zprofile zshrc; do
  ln -sf "$gitdir/conf.d/$f" ".$f"
done

# vim
ln -sf "$gitdir/conf.d/vimrc" ".vimrc"

# emacs
mkdir -p .emacs.d
ln -sf "$gitdir/conf.d/init.el" .emacs.d/init.el

# alacritty
mkdir -p .config/alacritty
ln -sf "$gitdir/conf.d/alacritty.toml" .config/alacritty/alacritty.toml

# paru
mkdir -p .config/paru
ln -sf "$gitdir/conf.d/paru.conf" .config/paru/paru.conf
