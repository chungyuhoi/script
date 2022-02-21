#/usr/bin/env bash
cd ${HOME}
if [ $(id -u) != 0 ]; then sudo=sudo; fi
YELLOW="\e[33m"
RES="\e[0m"
confirm() {
read -p "回车继续" input
case $input in
	*) echo "" ;;
esac
}
install_wine() {
echo -e "本脚本仅在bullseye与impish中完成测试\n如果安装失败，请重试"
confirm
rm -rf box64.tar.gz box64 box86.tar.gz box86

dpkg --add-architecture armhf
apt update
$sudo apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf libncurses5:armhf -y
if [ ! $(command -v zenity) ]; then
$sudo apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf libncurses5:armhf -y
fi
$sudo apt install cmake build-essential vulkan* *-mesa-* mesa* libncurses5 -y
if [ ! $(command -v cmake) ]; then
$sudo apt install cmake build-essential vulkan* *-mesa-* mesa* libncurses5 -y
fi
if grep -q ubuntu /etc/os-release; then
echo -e "${YELLOW}即将安装ubuntu的解码优化包，请在提示过程中按tab切换光标至ok按钮回车确认${RES}"
confirm
$sudo apt install ubuntu-restricted-extras -y
fi
#zenity libstdc++6 mesa* libasound*
wget -O box86.tar.gz https://codeload.github.com/ptitSeb/box86/tar.gz/refs/tags/v0.2.4

if [ $(ls -l box86.tar.gz | awk '{print $5}') -ne 2230262 ];  then
echo -e "${YELLOW}下载的文件大小与检测的不符，检测box86最新版本，如果长时间检测不到，请尝试网络切换，中断请ctrl+c${RES}"
sleep 3
unset version
while [ -z "${version}" ]
do version=$(curl --connect-timeout 5 -m 8 https://github.com/ptitSeb/box86 | grep '/ptitSeb/box86/releases/tag/' | awk -F 'href="' '{print $2}' | cut -d '/' -f 6 | cut -d '"' -f 1)
done
echo -e "最新版本为${YELLOW}box86${version}${RES}"
sleep 1
wget -O box86.tar.gz https://codeload.github.com/ptitSeb/box86/tar.gz/refs/tags/${version}
fi
mkdir box86
tar zxvf box86.tar.gz -C box86
VERSION=`ls box86`
mkdir -p box86/$VERSION/build
cd box86/$VERSION/build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
#-DARM_DYNAREC=ON
make -j$(nproc); make install
cd
wget -O box64.tar.gz https://codeload.github.com/ptitSeb/box64/tar.gz/refs/tags/v0.1.6

if [ $(ls -l box64.tar.gz | awk '{print $5}') -ne 1711815 ];
then
echo -e "${YELLOW}下载的文件大小与检测的不符，检测box64最新版本，如果长时间检测不到，请尝试网络切换，中断请ctrl+c${RES}"
sleep 2
unset version
while [ -z "${version}" ]
do version=$(curl --connect-timeout 5 -m 8 https://github.com/ptitSeb/box64 | grep '/ptitSeb/box64/releases/tag/' | awk -F 'href="' '{print $2}' | cut -d '/' -f 6 | cut -d '"' -f 1)
done
echo -e "最新版本为${YELLOW}box64${version}${RES}"
wget -O box64.tar.gz https://codeload.github.com/ptitSeb/box64/tar.gz/refs/tags/${version}
fi
mkdir box64
tar zxvf box64.tar.gz -C box64
VERSION=`ls box64`
mkdir -p box64/$VERSION/build
cd box64/$VERSION/build
#cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr
cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
#-DRPI4ARM64=1
make -j$(nproc); make install
cd
rm -rf box64.tar.gz box64 box86.tar.gz box86

read -r -p "是否获取wine下载地址 1)是 2)否 " input
case $input in
	2) 
	echo -e "\n${YELLOW}解wine的tar.gz压缩包，请用命令tar zxvf 目录/wine包 -C /usr${RES}"
		confirm ;;
	*) 
#unset version
#version=$(curl https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/ | grep "tar.gz'" | awk -F "href='" '{print $2}' | awk -F "'>" '{print $1}' | grep 6.17)
echo -e "下载地址：\n${YELLOW}https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz${RES}\n解包命令 tar zxvf 目录/包名 -C ${HOME}wine64"
read -r -p "1)下载(速度很慢) 0)返回 " input
case $input in
	1)
#wget https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/$version
wget https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
tar zxvf PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz -C /usr ;;
	*) echo -e "\n${YELLOW}解压wine的tar.gz压缩包，请用命令tar zxvf 目录/wine包 -C /usr${RES}"
		confirm ;;
esac ;;
esac
#tar zxvf /sdcard/BaiduNetdisk/PlayOnLinux-wine-6.14-upstream-linux-amd64.tar.gz -C wine64

main
}
add_msi() {
#box64 wine64 msiexec -i *.msi
echo -e "
1) 获取mono最新版下载
2) 获取gecko最新版下载
0) 返回\n"
read -r -p "请选择: " input
case $input in
	1)
unset version
version=`curl https://mirrors.bfsu.edu.cn/winehq/wine/wine-mono/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1`
wget https://mirrors.bfsu.edu.cn/winehq/wine/wine-mono/$version/wine-mono-$version-x86.msi ;;

	2)
unset version
version=`curl https://mirrors.bfsu.edu.cn/winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1`
wget https://mirrors.bfsu.edu.cn/winehq/wine/wine-gecko/$version/wine-gecko-$version-x86.msi 
unset version
version=`curl https://mirrors.bfsu.edu.cn/winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1`
wget https://mirrors.bfsu.edu.cn/winehq/wine/wine-gecko/$version/wine-gecko-$version-x86_64.msi ;;
	*) echo "" ;;
esac
main
}
start_none() {
echo -e "${YELLOW}启动程序时间比较长，请耐心等待，如果长时间不动，请关闭重新启动${RES}"
vncserver -kill $DISPLAY 2>/dev/null
pkill -9 Xtightvnc 2>/dev/null
pkill -9 Xtigertvnc 2>/dev/null
pkill -9 Xvnc 2>/dev/null
pkill -9 vncsession 2>/dev/null
#export USER="$(whoami)"
export PULSE_SERVER=127.0.0.1
trap "pkill Xvnc 2>/dev/null; exit" SIGINT EXIT
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -wm -alwaysshared -geometry 1024x768 -once -depth 16 -localhost -securitytypes None :0 &
export DISPLAY=:0
:<<\eof
export BOX86_PATH=${HOME}/wine64/bin/
export BOX86_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:/lib/i386-linux-gnu:/lib/aarch64-linux-gnu/
export BOX64_PATH=${HOME}/wine64/bin/
export BOX64_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:${HOME}/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/
#export WINEPREFIX="${HOME}/.wine"
#export WINEARCH=win32
#bash -c "export BOX86_PATH=${HOME}/wine64/bin/; export BOX86_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:/lib/i386-linux-gnu:/lib/aarch64-linux-gnu/; export BOX64_PATH=${HOME}/wine64/bin/; export BOX64_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:${HOME}/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/; box64 wine64 winecfg & { sleep 8; kill $! & }"
eof
box64 wine64 taskmgr
}
start_wine() {
echo -e "${YELLOW}启动程序时间比较长，请耐心等待，如果长时间不动，请关闭重新启动${RES}"
if [ ! -d ${HOME}/.wine ]; then
	echo -e "\n${YELLOW}进行初始配置${RES}"
	sleep 2
	TASK="box64 wine64 wineboot"
else
	read -r -p "1)任务管理器(运行exe程序) 2)winecfg 3)控制面板 4)注册表" input
case $input in
	2) 
TASK="winecfg" ;;
	3)
TASK="control" ;;
	4) 
TASK="regedit" ;;
	*) 
TASK="taskmgr" ;;
esac
#xfce4-terminal -x bash -c "export BOX64_NOPULSE=1; export BOX64_NOGTK=1; export BOX64_NOVULKAN=1; export BOX64_JITGDB=1; export BOX86_PATH=${HOME}/wine64/bin/; export BOX86_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:/lib/i386-linux-gnu:/lib/aarch64-linux-gnu/; export BOX64_PATH=${HOME}/wine64/bin/; export BOX64_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:${HOME}/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/; box64 wine64 winecfg & { sleep 8; kill $! & }"
#sleep 3
fi
box64 wine64 $TASK

exit 0
}
fix_() {
echo -e "由于proot环境原因，此次操作将删除wine配置文件(主目录.wine)\n"
confirm
#echo 'rm -rf ${HOME}/.wine' >>.bashrc
rm -rf ${HOME}/.wine
main
}

rootfs_down() {
echo -e "\e[33m即将下载系统,本脚本是进行全新安装,非恢复包\e[0m"
sleep 1
rm rootfs.tar.xz 2>/dev/null
curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/impish/arm64/default/$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/impish/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
mkdir impibox
tar xvf rootfs.tar.xz -C impibox
rm rootfs.tar.xz
echo -e "\e[33m系统已下载,文件夹名为impibox\e[0m"
sleep 2
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >impibox/proc/version
if [ ! -f "impibox/usr/bin/perl" ]; then
        cp impibox/usr/bin/perl* impibox/usr/bin/perl
fi
sed -i "3i\rm -rf \/tmp\/.X\*" impibox/etc/profile
sed -i "/zh_CN.UTF/s/#//" impibox/etc/locale.gen
rm impibox/etc/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >impibox/etc/resolv.conf
echo 'deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish main restricted universe multiverse
deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-updates main restricted universe multiverse
deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-backports main restricted universe multiverse
deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-security main restricted universe multiverse' >impibox/etc/apt/sources.list
touch "impibox/root/.hushlogin"
echo ". firstrun" >>impibox/etc/profile
cat >impibox/root/firstrun<<-'eof'
echo -e "\e[33m正在配置首次运行\n安装常用应用\e[0m"
sleep 1
apt update
apt install -y && apt install curl wget vim fonts-wqy-zenhei tar xfce4 xfce4-terminal ristretto lxtask dbus-x11 python3 pulseaudio -y
apt install tigervnc-standalone-server tigervnc-viewer -y
if [ ! $(command -v dbus-launch) ] || [ ! $(command -v tigervncserver) ] || [ ! $(command -v xfce4-session) ]; then
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
sleep 2
apt --fix-broken install -y && apt install curl wget vim fonts-wqy-zenhei tar xfce4 xfce4-terminal ristretto lxtask dbus-x11 tigervnc-standalone-server tigervnc-viewer pulseaudio python3 -y
fi
apt purge --allow-change-held-packages gvfs udisks2 -y
echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
killall -9 Xtightvnc 2>/dev/null
killall -9 Xtigertvnc 2>/dev/null
killall -9 Xvnc 2>/dev/null
killall -9 vncsession 2>/dev/null
export USER="$(whoami)"
export PULSE_SERVER=127.0.0.1
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -wm -alwaysshared -geometry 800x600 -once -depth 16 -localhost -securitytypes None :0 &
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
curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/impibox.sh
if [ -f "${HOME}/impibox.sh" ]; then
echo "bash impibox.sh" >>${HOME}/.bashrc
fi
echo -e "打开vnc请输\e[33measyvnc\e[0m\nvnc viewer地址输127.0.0.1:0\nvnc的退出,在系统输exit即可\n启动wine请输\e[33mbash impibox.sh\e[0m
如果启动失败,请输\e[33mbash firstrun\e[0m重新安装"
read -r -p "按回车键继续" input
case $input in
*) ;; esac
export LANG=zh_CN.UTF-8
eof

echo "killall -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S impibox --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b impibox/proc/version:/proc/version -b impibox/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 TZ=Asia/Shanghai /bin/bash --login" >start-impibox.sh && chmod +x start-impibox.sh
echo -e "已创建root用户系统登录脚本,登录方式为\e[33m./start-impibox.sh\e[0m"
}
main(){                                                       clear
echo -e "
${YELLOW}欢迎使用BOX+WINE自编译配置脚本 (测试版)${RES}"
echo -e "本脚本为编译安装，可运行x86与x86_64的exe程序。\n运行exe的效率会比qemu高很多，特别是3d游戏，同时bug也多"
uname -a | grep 'Android' -q
if [ $? == 0 ]; then
echo -e "
请在容器中使用本脚本\n
1)      下载容器编译安装box86+box64+wine
0)      退出\n"
read -r -p "请选择: " input
case $input in
	1) rootfs_down ;;
	*) exit 0 ;;
esac
else
echo -e "
1)      编译安装box86+box64+wine(由于涉及两种架构的包，系统极容崩掉，请做好备份，系统崩溃恕不负责!)
2)      启动wine(需先进入桌面，桌面运行)
3)      启动wine(非桌面环境，不建议)
4)      退出容器后无法再次启动
5)      下载mono与gecko插件"
if [ $(command -v easyvnc) ]; then
echo -e "6)	easyvnc(打开桌面)"
fi
echo -e "0)      退出\n"
read -r -p "请选择: " input
case $input in
	1) install_wine ;;
	2) start_wine ;;
	3) start_none ;;
	4) fix_ ;;
	5) add_msi ;;
	6) if [ $(command -v easyvnc) ]; then
		easyvnc
	else
		exit 0
	fi ;;
	*) exit 0 ;;
esac
fi
}
main "$@"
