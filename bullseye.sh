#!/usr/bin/env bash
echo -e "\e[33m即将下载系统,本脚本是进行全新安装,非恢复包\e[0m"
sleep 1
rm rootfs.tar.xz 2>/dev/null
curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/arm64/default/$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
mkdir bullseye
tar xvf rootfs.tar.xz -C bullseye
rm rootfs.tar.xz
echo -e "\e[33m系统已下载,文件夹名为bullseye\e[0m"
sleep 2
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >bullseye/proc/version
if [ ! -f "bullseye/usr/bin/perl" ]; then
        cp bullseye/usr/bin/perl* bullseye/usr/bin/perl
fi
sed -i "3i\rm -rf \/tmp\/.X\*" bullseye/etc/profile
sed -i "/zh_CN.UTF/s/#//" bullseye/etc/locale.gen
rm bullseye/etc/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >bullseye/etc/resolv.conf
echo 'deb http://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free
deb http://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free
deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free
#deb http://mirrors.ustc.edu.cn/debian-security/ bullseye/updates main contrib non-free
deb http://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib non-free' >bullseye/etc/apt/sources.list
echo ". firstrun" >>bullseye/etc/profile
cat >bullseye/root/firstrun<<-'eof'
echo -e "\e[33m正在配置首次运行\n安装常用应用\e[0m"
sleep 1
apt update
if ! grep -q https /etc/apt/sources.list; then
apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update
fi
apt install -y && apt install curl wget vim fonts-wqy-zenhei tar chromium mpv xfce4 xfce4-terminal ristretto lxtask dbus-x11 -y
apt install tigervnc-standalone-server tigervnc-viewer -y
if [ ! $(command -v dbus-launch) ] || [ ! $(command -v tigervncserver) ] || [ ! $(command -v xfce4-session) ]; then
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
sleep 2
apt --fix-broken install -y && apt install curl wget vim fonts-wqy-zenhei tar chromium mpv xfce4 xfce4-terminal ristretto lxtask dbus-x11 tigervnc-standalone-server tigervnc-viewer -y
fi
if [ $(command -v chromium) ]; then
sed -i "s/Exec=\/usr\/bin\/chromium %U/Exec=\/usr\/bin\/chromium --no-sandbox \%U/g" /usr/share/applications/chromium.desktop
fi
if [ ! -f ${HOME}/.vnc/passwd ]; then
echo -e "请设置vnc密码,6到8位\n\e[32m输完请按提示输y再设置一遍\e[0m"
vncpasswd
fi
echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
killall -9 Xtightvnc 2>/dev/null
killall -9 Xtigertvnc 2>/dev/null
killall -9 Xvnc 2>/dev/null
killall -9 vncsession 2>/dev/null
export USER="$(whoami)"
export PULSE_SERVER=127.0.0.1
set -- "${@}" "-ZlibLevel=1"
set -- "${@}" "-securitytypes" "vncauth,tlsvnc"
set -- "${@}" "-verbose"
set -- "${@}" "-ImprovedHextile"
set -- "${@}" "-CompareFB" "1"
set -- "${@}" "-br"
set -- "${@}" "-retro"
set -- "${@}" "-a" "5"
set -- "${@}" "-wm"
set -- "${@}" "-alwaysshared"
set -- "${@}" "-geometry" "1080x2320"
set -- "${@}" "-once"
set -- "${@}" "-depth" "16"
set -- "${@}" "-deferglyphs" "16"
set -- "${@}" "-rfbauth" "${HOME}/.vnc/passwd"
set -- "${@}" ":0"
set -- "Xvnc" "${@}"
"${@}" &
export DISPLAY=:0
. /etc/X11/xinit/Xsession 2>/dev/null &
exit 0' >/usr/local/bin/easyvnc && chmod +x /usr/local/bin/easyvnc
mkdir -p /etc/X11/xinit 2>/dev/null
echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
if [ $(command -v xfce4-session) ]; then
xfce4-session
else
startxfce4
fi' >/etc/X11/xinit/Xsession && chmod +x /etc/X11/xinit/Xsession
locale-gen
sed -i "2i\export LANG=zh_CN.UTF-8" /etc/profile
sed -i "/firstrun/d" /etc/profile
curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/PSTREE.tar.gz
tar zxvf PSTREE.tar.gz && bash bash_me
rm -rf PSTREE.tar.gz bash_me
curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/PKILL.tar.gz
tar zxvf PKILL.tar.gz && bash PKILL/bash_me
rm -rf PKILL*
echo -e "打开vnc请输\e[33measyvnc\e[0m\nvnc viewer地址输127.0.0.1:0\nvnc的退出,在系统输exit即可
如果启动失败,请输\e[33mbash firstrun\e[0m重新安装"
read -r -p "按回车键继续" input
case $input in
*) ;; esac
export LANG=zh_CN.UTF-8
eof

echo "killall -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S bullseye --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b bullseye/proc/version:/proc/version -b bullseye/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 TZ=Asia/Shanghai /bin/bash --login" >start-bullseye.sh && chmod +x start-bullseye.sh
echo -e "已创建root用户系统登录脚本,登录方式为\e[33m./start-bullseye.sh\e[0m"
