gitdir="$HOME/config"
# relative path from ~, i.e. the home directory
cd ~
ln -sf $gitdir/conf.d/xinitrc .xinitrc
ln -sf $gitdir/conf.d/xserverrc .xserverrc
ln -sf $gitdir/conf.d/conkyrc .conkyrc
ln -sf $gitdir/conf.d/xprofile .xprofile
ln -sf $gitdir/conf.d/Xresources .Xresources
ln -sf $gitdir/conf.d/vimrc .vimrc
ln -sf $gitdir/conf.d/bashrc .bashrc
ln -sf $gitdir/conf.d/zshrc .zshrc
sudo ln -sf $gitdir/conf.d/sunhhenv.sh /etc/profile.d/
sudo ln -sf $gitdir/conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
sudo ln -sf $gitdir/conf.d/10-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf

if [ ! -d .config/i3 ];then
	mkdir -p .config/i3
fi
ln -sf $gitdir/conf.d/i3config .config/i3/config

if [ ! -d .emacs.d ];then
	mkdir .emacs.d
fi
ln -sf $gitdir/conf.d/init.el .emacs.d/init.el
