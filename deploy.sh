gitdir="config"
# relative path from ~, i.e. the home directory
id=" "
#CAUTION!! FILL THIS BLANK!!
cd ~
ln -sf $gitdir/conf.d/xinitrc .xinitrc
ln -sf $gitdir/conf.d/xserverrc .xserverrc
ln -sf $gitdir/conf.d/conkyrc .conkyrc
ln -sf $gitdir/conf.d/xprofile .xprofile
ln -sf $gitdir/conf.d/Xresources .Xresources
ln -sf $gitdir/conf.d/vimrc .vimrc

if [ ! -d .config/i3 ];then
	mkdir -p .config/i3
fi
#ln -sf $gitdir/conf.d/i3config_laptop .config/i3/config
#ln -sf $gitdir/conf.d/i3config_workstation .config/i3/config
#choose one according to tour situation and uncomment it.

if [ ! -d .emacs ];then
	mkdir .emacs
fi
ln -sf $gitdir/conf.d/init.el .emacs/init.el

#sudo ln -sf $gitdir/conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
#uncomment this if necessary

if [ ! -d $gitdir/$id ];then
	mkdir $gitdir/$id
else
	echo "$gitdir/$id already exists!"
fi
cp $gitdir/conf.d/bashrc $gitdir/$id/bashrc
ln -sf $gitdir/$id/bashrc .bashrc
