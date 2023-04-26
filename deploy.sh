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

if [ ! -d .config/i3 ];then
	mkdir -p .config/i3
fi
#ln -sf $gitdir/conf.d/i3config_laptop .config/i3/config
#ln -sf $gitdir/conf.d/i3config_workstation .config/i3/config
#choose one according to tour situation and uncomment it.

if [ ! -d .emacs.d ];then
	mkdir .emacs.d
fi
ln -sf $gitdir/conf.d/init.el .emacs.d/init.el

#sudo ln -sf $gitdir/conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
#uncomment this if necessary

#sudo cp $gitdir/conf.d/config.json /etc/v2ray/
#uncomment this if necessary
