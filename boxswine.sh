#/usr/bin/env bash
cd ${HOME}
if [ $(id -u) != 0 ]; then sudo=sudo; fi
YELLOW="\e[33m"
RES="\e[0m"
BFSU="https://mirrors.bfsu.edu.cn/"
confirm() {
read -p "回车继续" input
case $input in
	*) echo "" ;;
esac
}
install_wine() {
echo -e "本脚本仅在bullseye与impish中完成测试\n如果安装失败，请重试\n"
sleep 2
rm -rf box64.tar.gz box64 box86.tar.gz box86
echo -e "${YELLOW}安装需要的依赖库${RES}"
sleep 1
dpkg --add-architecture armhf
apt update
$sudo apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf libncurses5:armhf -y
if [ ! $(command -v zenity) ]; then
$sudo apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf libncurses5:armhf -y
fi
$sudo apt install cmake build-essential libncurses5 libmpg123-0 git -y
if [ ! $(command -v cmake) ]; then
$sudo apt install cmake build-essential libncurses5 libmpg123-0 git -y
fi
###ubuntu专用
if grep -q ubuntu /etc/os-release; then
echo -e "\n${YELLOW}是否安装ubuntu的解码优化包${RES}
1) 安装
2) 不需要，我手机配置不算高"
read -r -p "请选择: " input
case $input in
	2) $sudo apt install zenity libstdc++6 mesa* libasound* -y ;;
	*)
echo -e "${YELLOW}请在提示过程中按tab切换光标至ok按钮回车确认${RES}"
confirm
$sudo apt install vulkan* *-mesa-* mesa* -y
$sudo apt install ubuntu-restricted-extras -y
;;
esac
fi
#zenity libstdc++6 mesa* libasound*
read -r -p "请选择你的cpu 1)默认 2)骁龙845 " input
case $input in
	2) CPU86=DSD845
		CPU64=DSD845
		;;
	*) CPU86=DRPI4ARM64
		CPU64=DARM_DYNAREC
		;;
esac
echo -e "\n${YELLOW}1)官方下载链接
2)git仓库克隆(版本较新，受网络影响)${RES}"
read -r -p '请选择编译包来源：' input
case $input in
	1) BUILD="-DNOGIT=1" ;;
esac
if [ ! $(command -v box86) ]; then
case $BUILD in
	"-DNOGIT=1")
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
;;
*) git clone https://github.com/ptitSeb/box86
mkdir box86/build
cd box86/build
;;
esac
cmake .. $BUILD -DCMAKE_BUILD_TYPE=RelWithDebInfo -${CPU86}=ON
#If you encounter some linking errors, try activating NOLOADADDR
make -j$(nproc); make install
fi

cd
if [ ! $(command -v box64) ]; then
case $BUILD in
	"-DNOGIT=1")
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
;;
*) git clone https://github.com/ptitSeb/box64
mkdir box64/build
cd box64/build
;;
esac
#cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr
cmake .. $BUILD -${CPU64}=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
#-DRPI4ARM64=1
make -j$(nproc); make install
fi

cd
rm -rf box64.tar.gz box64 box86.tar.gz box86
if [ $(command -v box64) ]; then
mkdir 桌面 2>/dev/null
mkdir Desktop 2>/dev/null
echo '[Desktop Entry]
Type=Application
Name=wine-taskmgr
Name[zh_CN]=wine-任务管理器
Icon=utilities-system-monitor
Exec="box64 wine64 taskmgr"
Terminal=true' >Desktop/wine-taskmgr.desktop
cp Desktop/wine-taskmgr.desktop 桌面/
chmod +x 桌面/wine-taskmgr.desktop
chmod +x Desktop/wine-taskmgr.desktop
fi
mkdir wine64
read -r -p "是否获取wine下载地址 1)是 2)否 " input
case $input in
	2) 
	echo -e "\n${YELLOW}解压wine的tar.gz压缩包，请用命令tar zxkvf 目录/wine包 -C /usr${RES}"
		confirm ;;
	*) 
#unset version
#version=$(curl https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/ | grep "tar.gz'" | awk -F "href='" '{print $2}' | awk -F "'>" '{print $1}' | grep 6.17)
echo -e "下载地址：\n${YELLOW}https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz${RES}\n"
read -r -p "1)下载(自动解压，下载速度很慢，除非..) 0)返回 " input
case $input in
	1)
#wget https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/$version
wget https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
tar zxkvf PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz -C /usr ;;
	*) echo -e "\n${YELLOW}解压wine的tar.gz压缩包，请用命令tar zxkvf 目录/wine包 -C /usr${RES}"
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
version=`curl ${BFSU}winehq/wine/wine-mono/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1`
wget ${BFSU}winehq/wine/wine-mono/$version/wine-mono-$version-x86.msi ;;

	2)
unset version
version=`curl ${BFSU}winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1`
wget ${BFSU}winehq/wine/wine-gecko/$version/wine-gecko-$version-x86.msi 
unset version
version=`curl ${BFSU}winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1`
wget ${BFSU}winehq/wine/wine-gecko/$version/wine-gecko-$version-x86_64.msi ;;
	*) echo "" ;;
esac
main
}
start_none() {
	unset resolution
	read -r -p "为更好体验程序全屏显示，请输分辨率(例如1027x768)，默认请回车 " resolution
	if [ -z "$resolution" ]; then
		resolution="1024x768"
	fi
echo -e "${YELLOW}启动程序时间比较长，请耐心等待，如果长时间不动，请关闭重新启动${RES}"
vncserver -kill $DISPLAY 2>/dev/null
pkill -9 Xtightvnc 2>/dev/null
pkill -9 Xtigertvnc 2>/dev/null
pkill -9 Xvnc 2>/dev/null
pkill -9 vncsession 2>/dev/null
#export USER="$(whoami)"
export PULSE_SERVER=127.0.0.1
trap "pkill Xvnc 2>/dev/null; exit" SIGINT EXIT
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -wm -alwaysshared -geometry $resolution -once -depth 16 -localhost -securitytypes None :0 &
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
#export BOX64_NOVULKAN=1
	read -r -p "1)任务管理器(运行exe程序) 2)winecfg 3)控制面板 4)注册表 5)无法正常启动 " input
case $input in
	2) 
TASK="winecfg" ;;
	3)
TASK="control" ;;
	4) 
TASK="regedit" ;;
	5)
echo -e "${YELLOW}非有效方法，建议chroot或安装更为优化的容器${RES}"
sleep 1

if [ $(echo "$(box64 wine64 --version)"|tail -1|cut -b 6) == 7 ]; then
	echo -e "你使用的是wine7版本,将为你使用特殊方式启动wine"
	sleep 2
#export WINEDEBUG="handle SIGSEGV nostop"
box64 wine64 taskmgr &
sleep 5
pkill services.exe
elif [ $(echo "$(box64 wine64 --version)"|tail -1|cut -b 6) == 6 ]; then
	echo -e "你使用的是wine6版本,将为你使用特殊方式启动wine"
	if [ ! -d ${HOME}/.wine ]; then
		box64 wine64 taskmgr
	else
		xfce4-terminal -x bash -c "box64 wine64 winecfg & { sleep 8; kill $! & }"
		sleep 3
		box64 wine64 taskmgr
		fi
	else
		box64 wine64 taskmgr
fi
	exit
;;
	6)
:<<\eof
export WINEPREFIX="${HOME}/.wine64"
export BOX86_PATH=${HOME}/wine64/bin/
export BOX86_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:/lib/i386-linux-gnu:/lib/aarch64-linux-gnu/
export BOX64_PATH=${HOME}/wine64/bin/
export BOX64_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:${HOME}/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/
if [ ! -d ${HOME}/.wine64 ]; then
box64 wine64 taskmgr
else
xfce4-terminal -x bash -c "export WINEPREFIX="${HOME}/.wine64"; export BOX86_PATH=${HOME}/wine64/bin/; export BOX86_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:/lib/i386-linux-gnu:/lib/aarch64-linux-gnu/; export BOX64_PATH=${HOME}/wine64/bin/; export BOX64_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:${HOME}/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/; box64 wine64 winecfg & { sleep 8; kill $! & }"
sleep 3
box64 wine64 taskmgr
fi
eof
exit 0

		;;
	*) 
TASK="taskmgr" ;;
esac
if [ ! -d ${HOME}/.wine ]; then
	echo -e "\n${YELLOW}进行初始配置${RES}"
	sleep 2
	box64 wine64 wineboot
	echo -e "\n${YELLOW}字体配置..${RES}"
	sleep 1
	curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/simsun.tar.gz	
	tar zxvf simsun.tar.gz -C /usr/share/wine/fonts
#	box64 wine64 regedit /usr/share/wine/fonts/simsun.reg
	rm simsun.tar.gz
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

tar_wine() {
echo -e "${YELLOW}为保证搜索包的准确度，请把wine压缩包放置手机主目录，并保证wine包的名字是以PlayOnLinux开头，tar.gz结尾${RES}"
confirm
echo -e "\n即将扫描手机主目录相关压缩包...\n"
LIST=`find /sdcard/ -name "PlayOnLinux*.tar.gz" 2>/dev/null | awk '{printf("%d) %s\n" ,NR,$0)}'
echo ""`
if [ -z "$LIST" ]; then
echo "未扫描到任何tar.gz包，请查找原因"
sleep 2
else
echo -e "$LIST\n"
read -r -p "请选择要解压的tar.gz包: " input
TAR=`echo "$LIST" | grep -w "${input})" | awk '{print $2}'`
tar zxvf "${TAR}" -C /usr
if [ $(command -v wine64) ]; then
	echo -e "${YELLOW}解压成功${RES}"
else
	echo -e "${YELLOW}解压失败，请查找原因${RES}"
fi
sleep 2
fi
}

rootfs_down() {
echo -e "\n${YELLOW}下载容器编译安装box86+box64+wine${RES}\n"
read -r -p "请选择要下载的容器 1)bullseye 2)impish 0)退出 " input
case $input in
	1) rootfs=bullseye
		name=debian ;;
	2) rootfs=impish
		name=ubuntu ;;
	0) exit 0 ;;
	*) echo -e "选择有误"
		sleep 1
		main ;;
esac
echo -e "\e[33m即将下载系统,本脚本是进行全新安装,非恢复包\e[0m"
sleep 1
rm rootfs.tar.xz 2>/dev/null
curl -O ${BFSU}lxc-images/images/${name}/${rootfs}/arm64/default/$(curl ${BFSU}lxc-images/images/${name}/${rootfs}/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
mkdir ${rootfs}swine
tar xvf rootfs.tar.xz -C ${rootfs}swine
rm rootfs.tar.xz
echo -e "\e[33m系统已下载,文件夹名为${rootfs}swine\e[0m"
sleep 2
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >${rootfs}swine/proc/version
if [ ! -f "${rootfs}swine/usr/bin/perl" ]; then
        cp ${rootfs}swine/usr/bin/perl* ${rootfs}swine/usr/bin/perl
fi
sed -i "3i\rm -rf \/tmp\/.X\*" ${rootfs}swine/etc/profile
sed -i "/zh_CN.UTF/s/#//" ${rootfs}swine/etc/locale.gen
rm ${rootfs}swine/etc/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >${rootfs}swine/etc/resolv.conf
case $rootfs in
	bullseye)
BFSU=`echo $BFSU | sed 's/https/http/g'`
DEB="debian/ bullseye main contrib non-free"
DEB2="debian/ bullseye-updates main contrib non-free"
DEB3="debian/ bullseye-backports main contrib non-free"
DEB4="debian-security bullseye-security main contrib non-free"
		;;
	impish)
touch "${rootfs}swine/root/.hushlogin"
DEB="ubuntu-ports/ impish main restricted universe multiverse"
DEB2="ubuntu-ports/ impish-updates main restricted universe multiverse"
DEB3="ubuntu-ports/ impish-backports main restricted universe multiverse"
DEB4="ubuntu-ports/ impish-security main restricted universe multiverse"
		;;
esac
echo "deb ${BFSU}${DEB}
deb ${BFSU}${DEB2}
deb ${BFSU}${DEB3}
deb ${BFSU}${DEB4}" >${rootfs}swine/etc/apt/sources.list

echo ". firstrun" >>${rootfs}swine/etc/profile
cat >${rootfs}swine/root/firstrun<<-'eof'
echo -e "\e[33m正在配置首次运行\n安装常用应用\e[0m"
sleep 1
apt update
if ! grep -q https /etc/apt/sources.list; then
apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update
fi
apt install -y && apt install curl wget vim fonts-wqy-zenhei tar xfce4 xfce4-terminal ristretto lxtask dbus-x11 python3 pulseaudio xserver-xorg x11-utils elementary-xfce-icon-theme --no-install-recommends -y
apt install tigervnc-standalone-server tigervnc-viewer -y
if [ ! $(command -v dbus-launch) ] || [ ! $(command -v tigervncserver) ] || [ ! $(command -v xfce4-session) ]; then
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
sleep 2
apt --fix-broken install -y && apt install curl wget vim fonts-wqy-zenhei tar xfce4 xfce4-terminal ristretto lxtask dbus-x11 tigervnc-standalone-server tigervnc-viewer pulseaudio xserver-xorg x11-utils python3 elementary-xfce-icon-theme --no-install-recommends -y
fi
if grep -q ubuntu /etc/os-release; then
echo ""
else
ICONS="/usr/share/icons"
if [ ! -d "$ICONS/Tango" ]; then
mkdir -p $ICONS/Tango/16x16/apps
mkdir -p $ICONS/Tango/22x22/apps
mkdir -p $ICONS/Tango/24x24/apps
mkdir -p $ICONS/Tango/32x32/apps
mkdir -p $ICONS/Tango/48x48/apps
mkdir -p $ICONS/Tango/64x64/apps
cp $ICONS/elementary-xfce/apps/16/utilities-system-monitor.png $ICONS/Tango/16x16/apps/
cp $ICONS/elementary-xfce/apps/16/utilities-system-monitor.png $ICONS/Tango/22x22/apps/
cp $ICONS/elementary-xfce/apps/24/utilities-system-monitor.png $ICONS/Tango/24x24/apps/
cp $ICONS/elementary-xfce/apps/32/utilities-system-monitor.png $ICONS/Tango/32x32/apps/
cp $ICONS/elementary-xfce/apps/48/utilities-system-monitor.png $ICONS/Tango/48x48/apps/
cp $ICONS/elementary-xfce/apps/64/utilities-system-monitor.png $ICONS/Tango/64x64/apps/
fi
fi
#echo 'load-module module-udev-detect tsched=0' >>/etc/pulse/default.pa
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
curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/boxswine.sh
if [ -f "${HOME}/boxswine.sh" ]; then
echo "bash boxswine.sh" >>${HOME}/.bashrc
fi
echo -e "打开vnc请输\e[33measyvnc\e[0m\nvnc viewer地址输127.0.0.1:0\nvnc的退出,在系统输exit即可\n启动wine请输\e[33mbash boxswine.sh\e[0m
如果启动失败,请输\e[33mbash firstrun\e[0m重新安装"
read -r -p "按回车键继续" input
case $input in
*) ;; esac
export LANG=zh_CN.UTF-8
eof

echo "killall -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S ${rootfs}swine --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b ${rootfs}swine/proc/version:/proc/version -b ${rootfs}swine/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 TZ=Asia/Shanghai /bin/bash --login" >start-${rootfs}swine.sh && chmod +x start-${rootfs}swine.sh
echo -e "已创建root用户系统登录脚本,登录方式为\e[33m./start-${rootfs}swine.sh\e[0m"
}
main(){                                                       clear
echo -e "
${YELLOW}欢迎使用BOX+WINE自编译配置脚本 (测试版)${RES}"
echo -e "本脚本为编译安装，可运行x86与x86_64的exe程序。\n运行exe的效率会比qemu高很多，特别是3d游戏，同时bug也多"
uname -a | grep 'Android' -q
if [ $? == 0 ]; then
rootfs_down
else
echo -e "
1)      编译安装box86+box64+wine(由于涉及两种架构的包，系统极容崩掉，请做好备份，系统崩溃恕不负责!)
2)      启动wine(需先进入桌面，桌面运行)
3)      启动wine(非桌面环境，不建议)
4)      退出容器后无法再次启动
5)      下载mono与gecko插件
6)	搜索解压wine包"
if [ $(command -v easyvnc) ]; then
echo -e "7)	easyvnc(打开桌面)\n8)	修改easyvnc分辨率"
fi
echo -e "0)      退出\n"
read -r -p "请选择: " input
case $input in
	1) install_wine ;;
	2) start_wine ;;
	3) start_none ;;
	4) fix_ ;;
	5) add_msi ;;
	6) tar_wine ;;
	7) if [ $(command -v easyvnc) ]; then
		easyvnc
	else
		exit 0
	fi ;;
	8) if [ $(command -v easyvnc) ]; then
		unset resolution
	read -r -p "请输分辨率(例如1027x768)，默认请回车 " resolution
	if [ -z "$sresolution" ]; then
		resolution=1024x768
	fi
		sed -i "s/\(geometry\) .* \(-once\)/\1 ${resolution} \2/" /usr/local/bin/easyvnc
	echo -e "\n${YELLOW}你输入的分辨率为${resolution}${RES}"
	sleep 1
	main
	else
		exit 0
	fi ;;
	*) exit 0 ;;
esac
fi
}
main "$@"
