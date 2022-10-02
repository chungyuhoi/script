#!/usr/bin/env bash

#https://dl.winehq.org/wine-builds/ubuntu/
#默认系统盘目录export WINEPREFIX=~/.wine-new
#指定内署dll或windows dll，b=builtin，n=native
#export WINEDLLOVERRIDES=c:\\windows\\system32\\bass=n;bass=n;bass=b
#WINEDLLOVERRIDES="bass=n;z:\\sdcard\\xinhao\\games\\unplay\\zw\\bass=b"
#for i in /usr/lib/wine/winepulse.drv.so /usr/lib/wine/fakedlls/winepulse.drv /usr/lib32/wine/fakedlls/winepulse.drv /usr/lib32/wine/winepulse.drv.so; do chmod 000 "$i"; chattr +i "$i"; done
#Exec=box86 wine explorer /desktop=name,1024x768 /sdcard/xinhao/games/War3/Frozen\ Throne.exe %f
#QT_SCREEN_SCALE_FACTORS=1
#proot登录方式，可选 STANDER PRO
PROOT=PRO

#容器，可选 jammy bullseye kali sid
ROOTFS=bullseye

#box安装方式，注意：kali仅能选NOBOX，可选 REPO GIT RELEASE XB6868 NOBOX
BOX_INSTALL=XB6868

#wine安装方式，注意：REPO仅对bullseye可用，可选 REPO PLAYONLINUX XB6868 NOWINE
WINE_INSTALL=XB6868

#wine版本，仅对PLAYONLIUX可用，可选 3.9 6.17 或该网已知版本
WINE_VERSION=3.9

case $PROOT in
PRO)
START=start-wine-arm64
;;
*)
START=start-wine64
esac
case $ROOTFS in
impish|jammy)
LXC=ubuntu
DEB="main restricted universe multiverse"
;;
bullseye|sid)
LXC=debian
DEB="main contrib non-free"
;;
kali)
LXC=kali
ROOTFS=current
DEB="main contrib non-free"
WINE_INSTALL=NOWINE
esac
URL="https://mirrors.tuna.tsinghua.edu.cn"
cd

if [ $(uname -o) != Android ]; then echo -e "\e[33m仅适用于termux环境\e[0m"; sleep 1; exit 0; fi

echo -e "\e[33m检测环境..\e[0m"
sleep 1
pkg i -y $(for i in curl proot tar pulseaudio; do if [ $(command -v $i) ]; then echo $i; fi done | sed 's/\n/ /g')
unset i
while [ ! $(command -v proot) ] && [[ $i -ne 3 ]]
do
pkg i -y curl proot tar pulseaudio
i=$(( $i+1 ))
done
if [ ! $(command -v proot) ]; then
echo -e "\e[33m检测环境失败，安装中止\e[0m"
sleep 1
exit 0
fi
unset i
if [ -d .wine-arm64 ]; then echo -e "\n检测已有相关文件夹，是否删除？\n\e[33m1) 删除重装\n2) 删除\n0) 退出\e[0m\n";
read -r -p "请选择: " input
case $input in
1) rm -rf .wine-arm64 ;;
2) rm -rf .wine-arm64 ${PREFIX}/bin/start-wine*
	echo -e "\e[33m已御载wine-arm64\e[0m"
	sleep 1
	exit 0 ;;
*) exit 0
esac
fi
echo -e "\n\n\e[33m本脚本为支持proot容器运行windows exe的32位与64位程序\n\n即将下载系统,本脚本是进行全新安装,非恢复包\e[0m"
sleep 3
rm rootfs.tar.xz 2>/dev/null
echo -e "\n检测最新更新的容器${LXC}-${ROOTFS}\e[0m\n"
sleep 1
curl -O ${URL}/lxc-images/images/${LXC}/${ROOTFS}/arm64/default/$(curl ${URL}/lxc-images/images/${LXC}/${ROOTFS}/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
if [ ! -f rootfs.tar.xz ]; then echo -e "\e[31m下载错误，请检查网络\e[0m"; sleep 1; exit 0; fi
mkdir .wine-arm64
tar xvf rootfs.tar.xz -C .wine-arm64
#if [ $? != 0 ]; then echo -e "\e[31m下载错误，请检查网络\e[0m"; sleep 1; exit 0; fi
rm rootfs.tar.xz
echo 'for i in /var/run/dbus/pid /tmp/.X*-lock /tmp/.X11-unix/X*; do if [ -e "${i}" ]; then rm -vf ${i}; fi done' >>.wine-arm64/etc/profile
#伪proc文件
mkdir .wine-arm64/etc/proc/ -p
printf ' 52 memory_bandwidth! 53 network_throughput! 54 network_latency! 55 cpu_dma_latency! 56 xt_qtaguid! 57 vndbinder! 58 hwbinder! 59 binder! 60 ashmem!239 uhid!236 device-mapper!223 uinput!  1 psaux!200 tun!237 loop-control! 61 lightnvm!228 hpet!229 fuse!242 rfkill! 62 ion! 63 vga_arbiter\n' | sed 's/!/\n/g' >.wine-arm64/etc/proc/misc
printf "%-1s %-1s %-1s %8s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s\n" Node 0, zone DMA 3 2 2 4 3 3 2 1 2 2 0 Node 0, zone DMA32 1774 851 511 220 67 3 2 0 0 1 0 >.wine-arm64/etc/proc/buddyinfo
echo "0.03 0.03 0.00 1/116 17521" >.wine-arm64/etc/proc/loadavg
touch .wine-arm64/etc/proc/kmsg
echo 'tty0                 -WU (EC p  )    4:7' >.wine-arm64/etc/proc/consoles
echo '0-0     Linux                   [kernel]' >.wine-arm64/etc/proc/execdomains
echo '0 EFI VGA' >.wine-arm64/etc/proc/fb
echo '    0:     9 8/8 3/1000000 27/25000000' >.wine-arm64/etc/proc/key-users
echo '285490.46 1021963.95' >.wine-arm64/etc/proc/uptime
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >.wine-arm64/etc/proc/version
touch .wine-arm64/etc/proc/vmstat
echo 'Character devices:!  1 mem!  4 /dev/vc/0!  4 tty!  4 ttyS!  5 /dev/tty!  5 /dev/console!  5 /dev/ptmx!  7 vcs! 10 misc! 13 input! 21 sg! 29 fb! 81 video4linux!128 ptm!136 pts!180 usb!189 usb_device!202 cpu/msr!203 cpu/cpuid!212 DVB!244 hidraw!245 rpmb!246 usbmon!247 nvme!248 watchdog!249 ptp!250 pps!251 media!252 rtc!253 dax!254 gpiochip!!Block devices:!  1 ramdisk!  7 loop!  8 sd! 11 sr! 65 sd! 66 sd! 67 sd! 68 sd! 69 sd! 70 sd! 71 sd!128 sd!129 sd!130 sd!131 sd!132 sd!133 sd!134 sd!135 sd!179 mmc!253 device-mapper!254 virtblk!259 blkext' | sed 's/!/\n/g' >.wine-arm64/etc/proc/devices
echo "cpu  0 0 0 0 0 0 0 0 0 0
cpu0 0 0 0 0 0 0 0 0 0 0
intr 1
ctxt 0
btime 0
processes 0
procs_running 1
procs_blocked 0
softirq 0 0 0 0 0 0 0 0 0 0 0" >.wine-arm64/etc/proc/stat
cpus=`cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1 | awk '{print $1}'`
if [ -n $cpus ]; then
while [[ $cpus -ne 1 ]]
do
cpus=$(( $cpus-1 ))
sed -i "2a cpu${cpus} 0 0 0 0 0 0 0 0 0 0" .wine-arm64/etc/proc/stat
done
fi

sed -i '3i export MOZ_FAKE_NO_SANDBOX=1' .wine-arm64/etc/profile

sed -i "/zh_CN.UTF/s/#//" .wine-arm64/etc/locale.gen
rm .wine-arm64/etc/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >.wine-arm64/etc/resolv.conf
case $ROOTFS in
impish|jammy)
echo "deb ${URL}/ubuntu-ports/ ${ROOTFS} ${DEB}
deb ${URL}/ubuntu-ports/ ${ROOTFS}-updates ${DEB}
deb ${URL}/ubuntu-ports/ ${ROOTFS}-backports ${DEB}
deb ${URL}/ubuntu-ports/ ${ROOTFS}-security ${DEB}" >.wine-arm64/etc/apt/sources.list
;;
bullseye|sid)
echo "deb ${URL}/debian/ ${ROOTFS} ${DEB}" >.wine-arm64/etc/apt/sources.list
case $ROOTFS in
bullseye)
echo "deb ${URL}/debian/ bullseye-updates ${DEB}
deb ${URL}/debian/ bullseye-backports ${DEB}
deb ${URL}/debian-security bullseye-security ${DEB}" >>.wine-arm64/etc/apt/sources.list
;;
sid)
curl ${URL}/kali/pool/main/o/openssl/$(curl ${URL}/kali/pool/main/o/openssl/|grep libssl1.1_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o .wine-arm64/root/libssl.deb
esac
curl ${URL}/debian/pool/main/c/ca-certificates/$(curl ${URL}/debian/pool/main/c/ca-certificates/|grep all.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o .wine-arm64/root/ca.deb
curl ${URL}/debian/pool/main/o/openssl/$(curl ${URL}/debian/pool/main/o/openssl/|grep openssl_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o .wine-arm64/root/openssl.deb
;;
current)
echo "deb ${URL}/kali kali-rolling ${DEB}" >.wine-arm64/etc/apt/sources.list
curl ${URL}/debian/pool/main/c/ca-certificates/$(curl ${URL}/debian/pool/main/c/ca-certificates/|grep all.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o .wine-arm64/root/ca.deb
curl ${URL}/debian/pool/main/o/openssl/$(curl ${URL}/debian/pool/main/o/openssl/|grep openssl_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o .wine-arm64/root/openssl.deb
#curl ${URL}/kali/pool/main/o/openssl/libssl1.1_1.1.1o-1_arm64.deb -o .wine-arm64/root/libssl.deb
curl ${URL}/kali/pool/main/o/openssl/$(curl ${URL}/kali/pool/main/o/openssl/|grep libssl1.1_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o .wine-arm64/root/libssl.deb
esac
mkdir .wine-arm64/usr/share/doc/wine/ -p


echo -e "\e[33m系统已下载,文件夹名为.wine-arm64\e[0m"
echo -e "登录命令为\e[33m${START}\e[0m"
sleep 5

cat >.wine-arm64/root/firstrun<<-'eof'
#!/usr/bin/env bash

URL="https://mirrors.tuna.tsinghua.edu.cn"
echo -e "\n\e[33m正在配置首次运行\n安装常用应用\e[0m"
sleep 1
export LANG=C.UTF-8
cd
if [ ! -f "/usr/bin/perl" ]; then
ln -sv /usr/bin/perl* /usr/bin/perl
fi
DEPENDS="apt-utils python3 git busybox curl wget tar vim fonts-wqy-microhei gnupg2 dbus-x11 libxinerama1 libxrandr2 libxcomposite1 libxcursor1 libncurses5 libgtk2.0-0 tigervnc-standalone-server tigervnc-viewer pulseaudio axel x11vnc xvfb psmisc procps onboard xfwm4 whiptail"

DEPENDS0="zenity:armhf libegl-mesa0:armhf libgl1-mesa-dri:armhf libglapi-mesa:armhf libglx-mesa0:armhf libasound*:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf sl:armhf -y"

#zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf libncurses5:armhf libgtk2.0-0:armhf libsdl2-image-2.0-0:armhf gstreamer1.0-plugins-*:armhf

case $BOX_INSTALL in
GIT|RELEASE)
#编译安装
DEPENDS1="cmake build-essential libc6-dev-armhf-cross"
;;
esac

#jammy安装
if grep jammy /etc/apt/sources.list; then
DEPENDS2="ubuntu-restricted-extras chromium-codecs-ffmpeg-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi libavcodec-extra"
fi

case $LXC in
debian)
dpkg -l ca-certificates | grep ii
if [ $? == 1 ]; then
dpkg -i libssl.deb 2>/dev/null
dpkg -i openssl.deb
dpkg -i ca.deb
fi
;;
kali)
dpkg -l ca-certificates | grep ii
if [ $? == 1 ]; then
dpkg -i libssl.deb
dpkg -i openssl.deb
dpkg -i ca.deb
fi
;;
ubuntu)
#touch .hushlogin
for i in $(groups 2>/dev/null|sed "s/$(whoami)//"); do if ! grep -q "$i" /etc/group; then echo "$i:x:$i:" >>/etc/group; fi done
echo ""
esac

dpkg --add-architecture armhf
apt update

i=0
apt install ${DEPENDS0} --no-install-recommends -y
while [ ! -f /usr/games/sl  ] && [[ $i -ne 3 ]]
do
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
i=$(( $i+1 ))
sleep 1
apt --fix-broken install -y && apt install ${DEPENDS0} --no-install-recommends -y
done
if [ ! -f /usr/games/sl  ]; then
echo -e "\e[31m似乎安装出错,退出安装\e[0m"
return 0
fi

i=0
apt install -y && apt install ${DEPENDS} ${DEPENDS1} ${DEPENDS2} --no-install-recommends -y
while [ ! $(command -v dbus-launch) ] && [[ $i -ne 3 ]]
do
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
i=$(( $i+1 ))
sleep 2
apt --fix-broken install -y && apt install ${DEPENDS} ${DEPENDS1} ${DEPENDS2}  --no-install-recommends -y
done
if [ ! $(command -v dbus-launch) ]; then
echo -e "\e[31m似乎安装出错,退出安装\e[0m"
return 0
fi


if [ ! -f /var/lib/dbus/machine-id ]; then
dbus-uuidgen > /var/lib/dbus/machine-id
fi

mkdir temp
cd temp
if [ ! $(command -v busybox) ]; then
echo -e "\e[33m优化部分命令\e[0m"
sleep 1
wget -O busybox.apk ${URL}/alpine/latest-stable/main/aarch64/$(curl ${URL}/alpine/latest-stable/main/aarch64/ | grep busybox | sed -n 1p | awk -F 'href="' '{print $2}' | cut -d '"' -f 1)
tar zxvf busybox.apk bin 2>/dev/null
mv bin/busybox /usr/local/bin/busybox
wget -O musl.apk ${URL}/alpine/latest-stable/main/aarch64/$(curl ${URL}/alpine/latest-stable/main/aarch64/ | grep musl | sed -n 1p | awk -F 'href="' '{print $2}' | cut -d '"' -f 1)
tar zxvf musl.apk lib
mv lib/* /usr/lib/
fi
if [ $(command -v busybox) ]; then
for i in ps uptime killall egrep top; do if [ $(command -v $i) ]; then ln -svf $(command -v busybox) $(command -v $i); else ln -svf $(command -v busybox) /usr/bin/$i; fi done
fi
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo /usr/bin/sudo
chmod 4711 /usr/bin/su

case $ROOTFS in
impish)
RUN_VER=`curl ${URL}/debian/pool/main/v/vim/|grep vim-runtime|awk -F 'title="' '{print $2}'|cut -d '"' -f 1|tail -n 1`
#RUN_VER=`grep "^Pack.*vim-runtime" \/var\/lib\/dpkg\/status -A10 | grep ^Version | awk -F ':' '{print $3}' | awk -F "u" '{print $1}'`
wget ${URL}/debian/pool/main/v/vim/${RUN_VER} -O vim_runtime.deb
VERSION=`grep '^Pack.*vim-runtime' \/var\/lib\/dpkg\/status -A10 | grep ^Version`
apt purge vim-tiny -y
dpkg -i vim_runtime.deb
sed -i "s/$(grep '^Pack.*vim-runtime' \/var\/lib\/dpkg\/status -A10|grep ^Version)/${VERSION}/" /var/lib/dpkg/status
;;
jammy)
VERSION=`grep '^Pack.*vim-runtime' \/var\/lib\/dpkg\/status -A10 | grep ^Version | awk '{print $2}'`
apt purge vim* -y
wget ${URL}/debian/pool/main/v/vim/$(curl ${URL}/debian/pool/main/v/vim/|grep vim_.*.deb|awk -F 'title="' '{print $2}'|cut -d '"' -f 1|grep arm64|tail -n 1) -O vim.deb
wget ${URL}/debian/pool/main/v/vim/$(curl ${URL}/debian/pool/main/v/vim/|grep vim-common.*.deb|awk -F 'title="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -O vim-common.deb
wget ${URL}/debian/pool/main/v/vim/$(curl ${URL}/debian/pool/main/v/vim/|grep vim-runtime.*.deb|awk -F 'title="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -O vim-runtime.deb
dpkg -i vim-runtime.deb && dpkg -i vim-common.deb && dpkg -i vim.deb && rm vim*
VERSION_=`grep '^Pack.*vim-runtime' \/var\/lib\/dpkg\/status -A10 | grep ^Version | awk '{print $2}'`
sed -i "s/$VERSION_/$VERSION/g" /var/lib/dpkg/status
esac

:<<LIBC6
if dpkg -l libc6:armhf | grep 2.34; then
echo ""
else
sed -i "s@$(grep 'Pack.* locales' /var/lib/dpkg/status -A10|grep '^Version'|awk '{print $2}')@2.34@" /var/lib/dpkg/status
rm ./*.deb 2>/dev/null
wget -O libc6.deb ${URL}/debian/pool/main/g/glibc/libc6_2.34-0experimental4_arm64.deb
wget -O libc6_armhf.deb ${URL}/debian/pool/main/g/glibc/libc6_2.34-0experimental4_armhf.deb
wget -O libc_bin.deb ${URL}/debian/pool/main/g/glibc/libc-bin_2.34-0experimental4_arm64.deb
wget ${URL}/debian/pool/main/g/glibc/locales_2.34-0experimental3_all.deb
wget ${URL}/debian/pool/main/g/glibc/libc-l10n_2.34-0experimental3_all.deb
dpkg -i libc*.deb
dpkg -i locales*.deb
apt --fix-broken install
fi
LIBC6
cd && rm -rf temp

export LANG=zh_CN.UTF-8

#优化库
#apt install zenity libstdc++6 libasound* libncurses5 vulkan* *mesa* libmpg123-0 libsdl2-image-2.0-0 -y
#apt install ubuntu-restricted-extras chromium-codecs-ffmpeg-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi libavcodec-extra --no-install-recommends

cat >/usr/local/bin/box64wine64<<-'BOXWINE'
#!/usr/bin/env bash
export WINEDEBUG=-all
if [[ $(id -u) = 0 ]];then
if [ ! -d /tmp/runtime-$(id -u) ]; then
#mkdir -pv "/var/run/user/$(id -u)"
mkdir -pv /tmp/runtime-$(id -u)
fi
chmod -R 1777 "/tmp/runtime-$(id -u)"
service dbus start
else
if [ ! -d /tmp/runtime-$(id -u) ]; then
sudo mkdir -pv "/tmp/runtime-$(id -u)"
fi
sudo chmod -R 1777 "/tmp/runtime-$(id -u)"
sudo service dbus start
fi
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
#if [ ! $(command -v box64) ] || [ ! $(command -v box64) ] || [ ! $(command -v wine) ]; then echo -e "\e[33m你尚未安装全应用，中止启动\e[0m"; sleep 1; exit 1; fi
if ! grep '"SimSun"="wqy-microhei.ttc"' .wine/system.reg; then
sed -i '/\[Environment/i \[Software\\\\Wine\\\\Explorer\]\n"Desktop"="Default"\n\n\[Software\\\\Wine\\\\Explorer\\\\Desktops\]\n"Default"="800x600"\n\n\[Software\\\\Wine\\\\X11 Driver\]\n"Decorated"="N"\n"Managed"="N"\n\n' .wine/user.reg
sed -i '/FontMapper/i \[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontLink\\\\SystemLink\]\n"Arial"="wqy-microhei.ttc"\n"Arial Black"="wqy-microhei.ttc"\n"Lucida Sans Unicode"="wqy-microhei.ttc"\n"MS Sans Serif"="wqy-microhei.ttc"\n"SimSun"="wqy-microhei.ttc"\n"Tahoma"="wqy-microhei.ttc"\n"Tahoma Bold"="wqy-microhei.ttc"\n\n' .wine/system.reg
fi
trap "killall Xvnc 2>/dev/null; killall x11vnc 2>/dev/null; killall Xvfb 2>/dev/null; exit" SIGINT EXIT
box64 wine64 taskmgr
exit 0
BOXWINE

cp /usr/local/bin/box64wine64 /usr/local/bin/box64wine64de
sed -E -i '/trap/d;s/(^box.*$)/\1 \&\nsleep 5\npkill services/' /usr/local/bin/box64wine64de

echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
export PULSE_SERVER=127.0.0.1
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 800x600 -once -depth 16 -localhost -securitytypes None :0 &
export DISPLAY=:0
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
#dbus-launch xfwm4 &
#onboard &
box64wine64 >/dev/null 2>wine_log &
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
exit 0' >/usr/local/bin/startwine
rm /usr/local/bin/startvsdl /usr/local/bin/startxsdl 2>/dev/null
#vnc转xsdl对于用物理鼠标玩即时战略游戏较vnc更为贴近电脑，但运行效率也会相对降低。
cp /usr/local/bin/startwine /usr/local/bin/startvsdl
sed -i 's/:0/:1/g;/^echo.*vncviewer/d;/am/d;/exit 0/d' /usr/local/bin/startvsdl
echo 'echo -e "\e[33m请先打开xsdl在地址栏输127.0.0.1:1\e[0m\n"
sleep 3
export PULSE_SERVER=127.0.0.1
export DISPLAY=127.0.0.1:0
xvncviewer &
exit 0' >>/usr/local/bin/startvsdl

#纯xsdl不支持的太多了，不推荐，不过有些游戏还是可以用这个运行。
echo '#!/usr/bin/env bash
echo -e "\n\e[33m请先打开xsdl\e[0m\n"
sleep 3
export PULSE_SERVER=127.0.0.1
export DISPLAY=127.0.0.1:0
#dbus-launch xfwm4 &
#onboard &
box64wine64 >/dev/null 2>wine_log &
#直接启动游戏：box64 wine64 start /unix *.exe
exit 0' >>/usr/local/bin/startxsdl

cat >/usr/local/bin/startxwine<<-'X11'
#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
#export X11VNC_REVERSE_CONNECTION_NO_AUTH=1
export PULSE_SERVER=127.0.0.1
export DISPLAY=:233
Xvfb ${DISPLAY} -screen 0 800x600x16 -once -ac +extension GLX +render -deferglyphs 16 -br -retro -noreset 2>&1 2>/dev/null &
sleep 1
x11vnc -nopw -nocursor -localhost -ncache_cr -xkb -noxrecord -noxdamage -display ${DISPLAY} -forever -bg -rfbport 5900 -noshm -shared -nothreads 2>&1 2>/dev/null &
#dbus-launch xfwm4 &
#onboard &
box64wine64 >/dev/null 2>wine_log &
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
sleep 1
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
X11

#修改分辨率
cat >/usr/local/bin/fbl<<-'FBL'
#!/usr/bin/env bash
echo -e "\n\n\e[33m修改分辨率\e[0m\n为适配游戏应用显示，可修改分辨率达最佳显示效果"
echo -e "你现在的分辨率是\e[33m$(sed -n 's/^Xvnc.*geometry \(.*.\) -once.*/\1/'p /usr/local/bin/startwine)\e[0m\n"
read -r -p "请输长度，例如1080 : " LENGTH
read -r -p "请输宽度，例如768 : " WIDTH
#if [ -z "$LENGTH" ] && [ -z "$WIDTH" ]; then
if [[ "$LENGTH" -gt 0 ]] && [[ "$WIDTH" -gt 0 ]] 2>/dev/null ;then
echo -e "你输入的分辨率为 \e[33m$LENGTH\e[0m x \e[33m$WIDTH\e[0m"
sed -i "s/^\"Default.*$/\"Default\"=\"${LENGTH}x${WIDTH}\"/" ${HOME}/.wine/user.reg
sed -i "s/-geometry .* -once/-geometry ${LENGTH}x${WIDTH} -once/" /usr/local/bin/startwine
sed -i "s/-geometry .* -once/-geometry ${LENGTH}x${WIDTH} -once/" /usr/local/bin/startvsdl
sed -i "s/screen.*x16/screen 0 ${LENGTH}x${WIDTH}x16/" /usr/local/bin/startxwine
else
echo -e "输入无效，请重新输用本命令"
fi
sleep 1
FBL
#关虚拟桌面
cat >/usr/local/bin/gg<<-'DEG'
#!/usr/bin/env bash
sed -i '/Desktop/s/^/#/' /usr/local/bin/box64wine64
i=0
pstree | grep -q "services"
while [ $? == 0 ] && [[ $i -ne 6 ]]
do
echo -ne ".\r"
i=$(( $i+1 ))
sleep 1
pstree | grep -q "services"
done
if [[ $i -eq 6 ]]; then
echo -e "操作失败，请确认已关闭wine"
sleep 1
fi
if grep '^"Desktop"="Default' ${HOME}/.wine/user.reg; then
sed -E -i 's/("Desktop"="Default")/#\1/' ${HOME}/.wine/user.reg
sed -E -i 's/(\[Software\\\\Wine\\\\Explorer\])/#\1/' ${HOME}/.wine/user.reg
fi
echo -e "\e[33m已关闭虚拟桌面\e[0m"
DEG

#开虚拟桌面
cat >/usr/local/bin/kk<<'DEK'
#!/usr/bin/env bash
sed -i '/Desktop/s/#//' /usr/local/bin/box64wine64
pstree | grep -q "services"
while [ $? == 0 ] && [[ $i -ne 6 ]]
do
echo -ne ".\r"
i=$(( $i+1 ))
sleep 1
pstree | grep -q "services"
done
if [[ $i -eq 6 ]]; then
echo -e "操作失败，请确认已关闭wine"
sleep 1
fi
if grep '#"Desktop"="Default' ${HOME}/.wine/user.reg; then
sed -E -i 's/^.*("Desktop"="Default")/\1/' ${HOME}/.wine/user.reg
sed -E -i 's/^.*(\[Software\\\\Wine\\\\Explorer\])/\1/' ${HOME}/.wine/user.reg
elif
grep '^"Desktop"="Default' ${HOME}/.wine/user.reg; then
echo ""
else
if ! grep Desktops .wine/user.reg; then
sed -i '/\[Environment/i \[Software\\\\Wine\\\\Explorer\\\\Desktops\]\n"Default"="800x600"' ${HOME}/.wine/user.reg
fi
if ! grep '^"Desktop"="Default' ${HOME}/.wine/user.reg; then
sed -i '/\[Software\\\\Wine\\\\Explorer\\\\Desktops\]/i \[Software\\\\Wine\\\\Explorer\]\n"Desktop"="Default"\n\n' ${HOME}/.wine/user.reg
fi
fi
echo -e "\e[33m已开启虚拟桌面\e[0m"
DEK

#提高游戏优先级
cat >/usr/local/bin/yy<<-'yyy'
#!/usr/bin/env bash
echo -e ""
pstree
echo -e "\n尝试筛选出exe应用，仅供参考\e[33m\n"
pstree | grep -i '.exe' | egrep -v 'explorer|plugplay|services|winedevice' | awk -F '-|-+-' '{print $NF,$2}' | awk -F '{' '{print $2}' | cut -d '}' -f 1
echo -e "\e[0m"
read -r -p "请输进程树中游戏的关键名(区分大小写): " PID
renice -18 $(pstree -p | grep $PID | awk -F '(' '{print $2}' | cut -d ')' -f 1)
yyy


cat >/usr/local/bin/wine_menu<<-'menu'
#!/usr/bin/env bash
cd
URL="https://mirrors.tuna.tsinghua.edu.cn"
export NEWT_COLORS='
root=,blue'
if [ ! $(command -v kali-undercover) ]; then
KALI="安装仿windows桌面"
KALI_UNDERCOVER="bash ${HOME}/undercover"
else
KALI="启动仿windows桌面"
KALI_UNDERCOVER="startvnc"
fi
if [ ! $(command -v wine) ]; then
WINE="你尚未安装wine"
else
if [[ $(echo "$(box64 wine64 --version)"|tail -1|cut -b 6) == [6-9] ]]; then
WINE="安装wine3.9"
else
WINE="安装wine6.17(proot运行高版本wine有bug)"
fi
fi
if grep ^onboard /usr/local/bin/startwine; then
KB="关闭桌面键盘"
else
KB="开启桌面键盘"
fi
list=$(whiptail --title "运行菜单" --menu "请上下滑动选择\n\n" 0 0 0 \
"1" "开启vnc wine" \
"2" "开启xsdl wine" \
"3" "使用虚拟桌面" \
"4" "关闭虚拟桌面" \
"5" "修改分辨率" \
"6" "提高程序优先级" \
"7" "${KALI}" \
"8" "${KB}" \
"9" "重新进行首次安装firstrun" \
"10" "安装gecko，mono" \
"11" "${WINE}" \
"12" "安装linux版firefox浏览器和vlc播放器" \
"0" "退出" \
3>&1 1>&2 2>&3)
if [ -n "$list" ]; then
case $list in
1) startwine ;;
2) startvsdl ;;
3) kk ;;
4) gg ;;
5) fbl ;;
6) yy ;;
7) ${KALI_UNDERCOVER}
exit 0 ;;
8) kb ;;
9) bash ${HOME}/firstrun ;;
10)
rm *.msi
case $WINE in
	*3.9*)
#最新版本
#wget ${URL}/winehq/wine/wine-mono/$(curl ${URL}/winehq/wine/wine-mono/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)/wine-mono-$(curl ${URL}/winehq/wine/wine-mono/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)-x86.msi
wget ${URL}/winehq/wine/wine-gecko/$(curl ${URL}/winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)/wine-gecko-$(curl ${URL}/winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)-x86.msi
wget ${URL}/winehq/wine/wine-gecko/$(curl ${URL}/winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)/wine-gecko-$(curl ${URL}/winehq/wine/wine-gecko/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)-x86_64.msi
;;
	*)
#wine3.9
wget https://mirrors.tuna.tsinghua.edu.cn/winehq/wine/wine-mono/4.7.2/wine-mono-4.7.2.msi
wget https://mirrors.tuna.tsinghua.edu.cn/winehq/wine/wine-gecko/2.47/wine_gecko-2.47-x86.msi
wget https://mirrors.tuna.tsinghua.edu.cn/winehq/wine/wine-gecko/2.47/wine_gecko-2.47-x86_64.msi
esac
echo -e "\n\e[33m即将安装，请确认已关闭wine\n如长时间没反应，请按回车并通过control确认是否安装成功\n如不成功可自行安装已下载的msi包\e[0m\n"
read -p "确认请回车" input
unset input
for i in ./wine*.msi;do box64 wine64 start /i $i; done
pstree | grep -q "services"
while [ $? == 0 ]
do
sleep 1
pstree | grep -q "services"
done
echo -e "\e[33m处理完成\e[0m"
exit 0
;;
11)
echo -e "\e[33m正在检测已安装wine版本并进行清除(仅对/usr目录下的wine文件有效)\e[0m"
for i in $(sed 's@\./@/usr/@g' /usr/share/doc/wine/postrm | sed ':a;N;s/\n/ /g;ta'); do if [ -f "$i" ]; then rm -v $i; fi done
#for i in $(sed ':a;N;s/\n/ /g;ta' /usr/share/doc/wine/postrm|sed 's@\./@/usr/@g'); do if [ -f "$i" ]; then rm -v $i; fi done
case $WINE in
*6.17*)
wget https://shell.xb6868.com/wine/PlayOnLinux-wine-6.17-upstream-linux-amd64.tar.gz
cp /usr/share/applications/wine.desktop ${HOME}/Desktop/wine.desktop 2>/dev/null
sed -i 's/^Exec.*$/Exec=box64wine64de %f/' ${HOME}/Desktop/wine.desktop 2>/dev/null
cp /usr/share/applications/wine.desktop ${HOME}/桌面/wine.desktop 2>/dev/null
sed -i 's/^Exec.*$/Exec=box64wine64de %f/' ${HOME}/桌面/wine.desktop 2>/dev/null
;;
*)
wget https://shell.xb6868.com/wine/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
cp /usr/share/applications/wine.desktop ${HOME}/Desktop/wine.desktop 2>/dev/null
cp /usr/share/applications/wine.desktop ${HOME}/桌面/wine.desktop 2>/dev/null

esac
chmod a+x ${HOME}/桌面 ${HOME}/Desktop -R 2>/dev/null
tar zxvf PlayOnLinux-wine-*-upstream-linux-amd64.tar.gz -C /usr >/usr/share/doc/wine/postrm 2>&1
rm PlayOnLinux-wine-*-upstream-linux-amd64.tar.gz ${HOME}/桌面/explorer.desktop ${HOME}/Desktop/explorer.desktop 2>/dev/null

bash firstrun
exit 0
;;
12)
if grep -q ID=ubuntu /etc/os-release ; then
DEPENDS="firefox firefox-locale-zh-hans"
else
DEPENDS="firefox-esr firefox-esr-l10n-zh-cn"
fi
apt install --no-install-recommends vlc $DEPENDS -y
i=0
while [ ! $(command -v vlc)  ] && [[ $i -ne 3 ]]
do
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
i=$(( $i+1 ))
sleep 1
apt --fix-broken install -y && apt install $DEPENDS vlc --no-install-recommends -y
done
sed -i 's/geteuid/getppid/' /usr/bin/vlc
cp /usr/share/applications/firefox*.desktop ${HOME}/Desktop
cp /usr/share/applications/vlc.desktop ${HOME}/Desktop
cp /usr/share/applications/firefox*.desktop ${HOME}/桌面
cp /usr/share/applications/vlc.desktop ${HOME}/桌面
chmod a+x ${HOME}/桌面 ${HOME}/Desktop -R
;;
0) exit 0
esac
sleep 1.5
wine_menu
else
echo  -e "\e[33m你已取消选择\e[0m"
sleep 1
exit 0
fi
menu

cat >/usr/local/bin/kb<<-'jp_'
#!/usr/bin/env bash
if grep ^onboard /usr/local/bin/startwine; then
echo -e "\e[33m关闭桌面键盘\e[0m"
sleep 1
sed -i '/onboard/s/^/#/;/xfwm4/s/^/#/' /usr/local/bin/startwine
sed -i '/onboard/s/^/#/;/xfwm4/s/^/#/' /usr/local/bin/startxwine
sed -i '/onboard/s/^/#/;/xfwm4/s/^/#/' /usr/local/bin/startxsdl
sed -i '/onboard/s/^/#/;/xfwm4/s/^/#/' /usr/local/bin/startvsdl
else
echo -e "\e[33m启动桌面键盘\e[0m"
sleep 1
sed -i '/onboard/s/#//g;/xfwm4/s/#//g' /usr/local/bin/startwine
sed -i '/onboard/s/#//g;/xfwm4/s/#//g' /usr/local/bin/startxwine
sed -i '/onboard/s/#//g;/xfwm4/s/#//g' /usr/local/bin/startxsdl
sed -i '/onboard/s/#//g;/xfwm4/s/#//g' /usr/local/bin/startvsdl
fi
jp_

cat >/usr/local/bin/aboutwine<<-'ABOUTWINE'
#!/usr/bin/env bash
clear
echo -e "\e[33m关于box64+wine\e[0m\n"
echo -e "由于box64+wine的bug比较多，所以大多数exe并不能运行，本脚本用的是proot容器更是如此。\n"
echo -e "如果游戏只有声音没画面，请尝试用命令startxsdl，通过xsdl显示。\n"
echo -e "如果觉得字体很难看，可以自行把windows的字体simsun.ttf放到/usr/share/wine/fonts文件夹内。\n"
echo -e "本容器支持wine7，请自行从 https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-x86/ 网页下载并解压到/usr文件夹内。"

ABOUTWINE

chmod +x /usr/local/bin/ -R
apt purge --allow-change-held-packages gvfs udisks2 -y 2>/dev/null
sed -i "/zh_CN.UTF/s/#//" /etc/locale.gen
sed -i '/^SUPPORTED/s/^/#/;/^ALIASES/s/^/#/' /usr/sbin/locale-gen
locale-gen
#sed -i -e '/GBK/,/^}/s/^/#/' /usr/share/X11/locale/zh_CN.UTF-8/XLC_LOCALE
sed -i '/LANG=zh_CN.UTF-8/d' /etc/profile && sed -i '2i export LANG=zh_CN.UTF-8' /etc/profile
sed -i "/firstrun/d" /etc/profile
sed -i "/return/d" ${HOME}/firstrun

if [ ! $(command -v box64) ] || [ ! $(command -v box86) ]; then
rm box86.tar.gz box64.tar.gz 2>/dev/null
case $BOX_INSTALL in
XB6868)
echo -e "\e[33m下载box86与box64\e[0m"
sleep 2
wget https://shell.xb6868.com/wine/box86.tar.gz
tar zxvf box86.tar.gz -C /
rm box86.tar.gz
;;
REPO)
#github源安装
echo -e "\e[33m下载编译box86与box64\e[0m"
sleep 2
mv /usr/bin/systemctl /usr/bin/systemctl.bak
ln -s /usr/bin/echo /usr/bin/systemctl
i=0
while [ ! $(command -v box86) ] && [[ $i -ne 3 ]]
do
i=$(( i+1 ))
if [ ! -f /etc/apt/sources.list.d/box86.list ]; then
wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list
fi
wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | sudo apt-key add -
apt update && apt install box86 -y
done
i=0
while [ ! $(command -v box64) ] && [[ $i -ne 3 ]]
do
i=$(( i+1 ))
if [ ! -f /etc/apt/sources.list.d/box64.list ]; then
wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
fi
#wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo apt-key add -
wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg 2>&1 >/dev/null
if [ ! -f /usr/share/keyrings/box64-debs-archive ]; then
wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg
fi
apt update && apt install box64 -y
done
mv /usr/bin/systemctl.bak /usr/bin/systemctl
;;

GIT)
#git仓库下载
echo -e "\e[33m下载编译box86与box64\e[0m"
sleep 2
while [ ! -d box86 ]
do git clone https://github.com/ptitSeb/box86
done
mkdir box86/build
cd box86/build

#box86编译安装
cmake .. $GIT -DRPI4ARM64=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j$(nproc) && make install


while [ ! -d box64 ]
do git clone https://github.com/ptitSeb/box64
done
mkdir box64/build
cd box64/build

#box64编译安装
cmake .. $GIT -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j$(nproc) && make install
;;

RELEASE)
#release下载
echo -e "\e[33m下载编译box86与box64\e[0m"
sleep 2
GIT="-DNOGIT=1"
#echo -e "${YELLOW}获取最新版本box64，如果长时间没反应，请尝试切换网络${RES}"
while [ -z "${version}" ]
do version=$(curl --connect-timeout 5 -m 8 https://github.com/ptitSeb/box86 | grep '/ptitSeb/box86/releases/tag/' | awk -F 'href="' '{print $2}' | cut -d '/' -f 6 | cut -d '"' -f 1)
done
echo -e "最新版本为${YELLOW}box86${version}${RES}"
sleep 1
wget -O box86.tar.gz https://codeload.github.com/ptitSeb/box86/tar.gz/refs/tags/${version}
mkdir box86
tar zxvf box86.tar.gz -C box86
VERSION=`ls box86`
mkdir -p box86/$VERSION/build
cd box86/$VERSION/build

#box86编译安装
cmake .. $GIT -DRPI4ARM64=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j$(nproc) && make install

unset version
while [ -z "${version}" ]
do version=$(curl --connect-timeout 5 -m 8 https://github.com/ptitSeb/box64 | grep '/ptitSeb/box64/releases/tag/' | awk -F 'href="' '{print $2}' | cut -d '/' -f 6 | cut -d '"' -f 1)
done
echo -e "最新版本为${YELLOW}box64${version}${RES}"
wget -O box64.tar.gz https://codeload.github.com/ptitSeb/box64/tar.gz/refs/tags/${version}
mkdir box64
tar zxvf box64.tar.gz -C box64
VERSION=`ls box64`
mkdir -p box64/$VERSION/build
cd box64/$VERSION/build

#box64编译安装
cmake .. $GIT -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j$(nproc) && make install

;;
*) echo ""
esac
fi

cd
#安装wine
if [ ! $(command -v wine) ]; then
rm PlayOnLinux-wine-*-upstream-linux-amd64.tar.gz 2>/dev/null
case $WINE_INSTALL in
XB6868)
wget https://shell.xb6868.com/wine/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
echo -e "解压中"
tar zxvf PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz -C /usr >/usr/share/doc/wine/postrm 2>&1
rm PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
;;
REPO)

case $ROOTFS in
impish|jammy)
URL="https://mirrors.tuna.tsinghua.edu.cn"
DEB="main restricted universe multiverse"
if ! grep -q i386 /etc/apt/sources.list; then
sed -E -i 's/(^deb)/\1 [arch=armhf,arm64]/' /etc/apt/sources.list
echo "deb [arch=i386,amd64] ${URL}/ubuntu/ ${ROOTFS} ${DEB}
deb [arch=i386,amd64] ${URL}/ubuntu/ ${ROOTFS}-updates ${DEB}
deb [arch=i386,amd64] ${URL}/ubuntu/ ${ROOTFS}-backports ${DEB}
deb [arch=i386,amd64] ${URL}/ubuntu/ ${ROOTFS}-security ${DEB}" >>/etc/apt/sources.list
fi
esac
mkdir wine_tmp
cd wine_tmp
rm *.deb
#WINE_URL="https://dl.winehq.org"
WINE_URL="https://mirrors.tuna.tsinghua.edu.cn"
dpkg --add-architecture i386
dpkg --add-architecture amd64
apt update
apt install libstdc++6:amd64 --no-install-recommends -y
apt install libstdc++6:i386 --no-install-recommends -y
axel -o wine-devel-i386.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-i386/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-i386/|grep wine-devel-i386_7|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
i=0
while [ ! $(command -v wine) ] && [[ $i -ne 3 ]]
do
i=$(( $i+1 ))
apt --fix-broken install -y && apt install ./wine-devel-i386.deb --no-install-recommends -y
done
axel -o wine-devel-amd64.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep wine-devel-amd64_7|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
i=0
while [ ! $(command -v wine64) ] && [[ $i -ne 3 ]]
do
i=$(( $i+1 ))
apt --fix-broken install -y && apt install ./wine-devel-amd64.deb --no-install-recommends -y
done
axel -o wine-devel.deb  ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep wine-devel_7|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
dpkg -i --force-overwrite wine-devel.deb 
axel -o winehq-devel.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep winehq-devel_7|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
dpkg -i --force-overwrite winehq-devel.deb
cd && rm -rf wine_tmp
;;

PLAYONLINUX)
echo -e "\n\e[33m下载wine 4.0.3版本，如果下载速度慢，请ctrl+c中止下载，并输bash firstrun重新初始化安装\e[0m"
sleep 3

rm wine.tar.gz 2>/dev/null
i=0
while [ ! -f wine.tar.gz ] && [[ $i -ne 3 ]]
do
#axel -o wine.tar.gz https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
axel -o wine.tar.gz https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-$WINE_VERSION-upstream-linux-amd64.tar.gz
#tar zxvf /sdcard/BaiduNetdisk/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz -C /usr
i=$(( i+1 ))
done

tar zxvf wine.tar.gz -C /usr
;;

*)
echo ""
esac
fi

if [ $(command -v wine) ] && [ $(command -v box64) ] && [ $(command -v box86) ]; then
echo -e "\e[33m进行wine初始化配置\e[0m"
sleep 1
rm -rf .wine 2>/dev/null
sleep 5
if [[ $(echo "$(box64 wine64 --version)"|tail -1|cut -b 6) == [6-7] ]]; then
export BOX86_DYNAREC=0
box64 wine64 wineboot 2>/dev/null &
pkill services
sed -i "/box64wine64/a sleep 5\npkill services" /usr/local/bin/start*
else
box64 wine64 wineboot 2>/dev/null
fi
pstree | grep -q "services"
while [ $? == 0 ]
do
sleep 1
pstree | grep -q "services"
done

while [ ! -f .wine/user.reg ]
do
sleep 1
done
while ! grep Desktops .wine/user.reg
do
sleep 1

sed -i '/\[Environment/i \[Software\\\\Wine\\\\Explorer\]\n"Desktop"="Default"\n\n\[Software\\\\Wine\\\\Explorer\\\\Desktops\]\n"Default"="800x600"\n\n\[Software\\\\Wine\\\\X11 Driver\]\n"Decorated"="N"\n"Managed"="N"' .wine/user.reg
done

#cp /usr/share/fonts/truetype/wqy/wqy-zenhei.ttc .wine/drive_c/windows/Fonts/
cp /usr/share/fonts/truetype/wqy/wqy-microhei.ttc .wine/drive_c/windows/Fonts/

sed -i '/FontMapper/i \[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontLink\\\\SystemLink\]\n"Arial"="wqy-microhei.ttc"\n"Arial Black"="wqy-microhei.ttc"\n"Lucida Sans Unicode"="wqy-microhei.ttc"\n"MS Sans Serif"="wqy-microhei.ttc"\n"SimSun"="wqy-microhei.ttc"\n"Tahoma"="wqy-microhei.ttc"\n"Tahoma Bold"="wqy-microhei.ttc"\n\n' .wine/system.reg
:<<\FONT
cat >wqy.reg<<-'FONTS'
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink]
"Lucida Sans Unicode"="wqy-microhei.ttc"
"Microsoft Sans Serif"="wqy-microhei.ttc"
"MS Sans Serif"="wqy-microhei.ttc"
"Tahoma"="wqy-microhei.ttc"
"Tahoma Bold"="wqy-microhei.ttc"
"SimSun"="wqy-microhei.ttc"
"Arial"="wqy-microhei.ttc"
"Arial Black"="wqy-microhei.ttc"
FONTS
box64 wine64 regedit wqy.reg
FONT
#echo -e "\n\e[33m配置完毕\e[0m\n"
else
case $WINE_INSTALL in
NOWINE)
echo ""
;;
*)echo -e "\nwine安装出错，请重新执行bash firstrun\n如果wine多次下载失败，请自行用浏览器下载，然后放至手机主目录，输命令：
tar zxvf /sdcard/包名 -C /usr\n
wine3.9下载地址：https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz

wine6.14下载地址: https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-6.14-upstream-linux-amd64.tar.gz\n"

return 0
esac
fi
rm -rf box86* box64* wqy.reg wine.tar.gz PlayOnLinux-wine*.tar.gz ca.deb openssl.deb libssl.deb wine_tmp 2>/dev/null

#解决错误提示:preloader: Warning: failed to reserve range 00000000-60000000 or winevdm: unable to exec 'application name': DOS memory range unavailable
if [ ! -f /etc/sysctl.conf ] || ! grep -q vm /etc/sysctl.conf; then
echo 'vm.mmap_min_addr=0' >>/etc/sysctl.conf
fi
if [ -f /usr/lib/wine/winepulse.drv.so ]; then
mv /usr/lib/wine/winepulse.drv.so /usr/lib/wine/winepulse.drv.so.bak
fi
if [ -f /usr/lib64/wine/winepulse.drv.so ]; then
mv /usr/lib64/wine/winepulse.drv.so /usr/lib64/wine/winepulse.drv.so.bak
fi

pstree | grep -q "services"
if [ $? == 0 ]; then
pkill services
fi
echo -e "\e[33m配置中，请稍候..\e[0m"
pstree | grep -q "wineboot"
while [ $? == 0 ]
do
sleep 3
du -sh ${HOME}/.wine
pstree | grep -q "wineboot"
done
echo -e "\n\e[33m配置完毕\e[0m\n"
echo -e "\n如果上面的安装失败,请输\e[33mbash firstrun\e[0m重新安装"
echo -e "登录容器\e[33m${START}\e[0m\n退出容器,在termux输\e[33mexit\e[0m即可\e[0m\n安装仿windows界面，输\e[33mbash undercover\e[0m\n多功能菜单\e[33mwine_menu\e[0m"
if [ $(command -v wine) ] && [ $(command -v box64) ] && [ $(command -v box86) ]; then
echo -e "vnc打开wine请输\e[33mstartwine\e[0m，vnc viewer地址输127.0.0.1:0\nxsdl打开wine\e[33m请先打开xsdl\e[0m，再输\e[33mstartvsdl\e[0m，在xsdl中地址输127.0.0.1:1\n修改分辨率适配游戏，请输\e[33mfbl\e[0m\n提高游戏优先级，游戏中在这界面回车出现光标输\e[33myy\e[0m\n"
fi
eof

#If no 'isolated_environment', the following host directories will be available:


cat >.wine-arm64/root/undercover<<-'eof'
#!/usr/bin/env bash
cd
#精简安装
#:<<\eof
if [ ! $(command -v xfce4-session) ]; then
apt install xfce4 xfce4-terminal ristretto lxtask dbus-x11 tigervnc-standalone-server tigervnc-viewer pulseaudio xserver-xorg x11-utils python3 tumbler python-gi-dev --no-install-recommends -y
fi
i=0
while [ ! $(command -v xfce4-session) ] && [[ $i -ne 3 ]]
do
apt --fix-broken install -y
i=$(( i+1 ))
done

if [ ! $(command -v xfce4-session) ]; then
echo -e "\e[33m安装出错，退出安装\e[0m"
exit 0
fi
#eof

if [ ! $(command -v kali-undercover) ]; then
rm undercover.deb 2>/dev/null
wget -O undercover.deb https://mirrors.tuna.tsinghua.edu.cn/kali/pool/main/k/kali-undercover/$(curl https://mirrors.tuna.tsinghua.edu.cn/kali/pool/main/k/kali-undercover/ | grep all.deb | cut -d '"' -f 4)
apt install ./undercover.deb -y
if [ ! $(command -v kali-undercover) ]; then
apt --fix-broken install -y
fi
sed -i '/Depends/s/xfce4-power-manager-plugins, //' /var/lib/dpkg/status
apt purge xfce4-power* -y
fi

if [ ! -e /etc/X11/xinit/Xsession ]; then
mkdir -p /etc/X11/xinit 2>/dev/null
fi
echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
if [[ $(id -u) = 0 ]];then
if [ ! -d /tmp/runtime-$(id -u) ]; then
#mkdir -pv "/var/run/user/$(id -u)"
mkdir -pv /tmp/runtime-$(id -u)
fi
chmod -R 1777 "/tmp/runtime-$(id -u)"
service dbus start
else
if [ ! -d /tmp/runtime-$(id -u) ]; then
sudo mkdir -pv "/tmp/runtime-$(id -u)"
fi
sudo chmod -R 1777 "/tmp/runtime-$(id -u)"
sudo service dbus start
fi
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
if [ $(command -v xfce4-session) ]; then
dbus-launch xfce4-session
else
dbus-launch startxfce4
fi' >/etc/X11/xinit/Xsession && chmod +x /etc/X11/xinit/Xsession

cat >/usr/local/bin/startvnc<<-'eom'
#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
export PULSE_SERVER=127.0.0.1
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 1024x768 -once -depth 24 -localhost -securitytypes None :0 &
export DISPLAY=:0
. /etc/X11/xinit/Xsession >/dev/null 2>&1 &
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
sleep 1
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
eom

rm /usr/share/xfce4/panel/plugins/power-manager-plugin.desktop undercover.deb 2>/dev/null

if [ $(command -v wine) ]; then
sed -i 's/^Exec=wine/Exec=box64 wine64/' /usr/share/applications/wine.desktop
sed -i 's/^Icon.*$/Icon=utilities-system-monitor/' /usr/share/applications/wine.desktop
sed -i 's/^Name=Wine Windows Program Loader/Name=wine任务管理器/' /usr/share/applications/wine.desktop
sed -i 's/^MimeType.*$/Categories=GTK;System;Monitor;/' /usr/share/applications/wine.desktop
fi

chmod +x /usr/local/bin/startvnc
sed -i '/exit/s/^/#/' $(command -v kali-undercover)
sed -E -i 's/(\$USER_PROFILE \])/\1 || grep undercover ~\/.bashrc/' $(command -v kali-undercover)
cp $(command -v kali-undercover) /usr/bin/kali-undercover.bak
sed -i 's/disable_undercover()/disable()/' $(command -v kali-undercover)
sed -i 's/disable_undercover/enable_undercover/' $(command -v kali-undercover)
mkdir ${HOME}/Desktop 2>/dev/null
mkdir ${HOME}/桌面 2>/dev/null
cp /usr/share/applications/kali-undercover.desktop /etc/xdg/autostart/
cat >>$(command -v kali-undercover)<<-'kali'
if [ -f /etc/xdg/autostart/kali-undercover.desktop ]; then
rm /etc/xdg/autostart/kali-undercover.desktop
fi
kali
bash -c "$(sed '/am start/d' /usr/local/bin/startvnc)" >/dev/null 2>&1 &
sleep 5
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
cp /usr/bin/kali-undercover.bak $(command -v kali-undercover) 

if [ $(command -v wine) ]; then
cp /usr/share/applications/xfce4-terminal.desktop ${HOME}/Desktop/rscreen.desktop
sed -i 's/xfce4-terminal/xrandr \-s 0/;s/Xfce\ Terminal/恢复屏幕/;/\]=/d;/=T/d;/preferences\]/,$d' ${HOME}/Desktop/rscreen.desktop
cp /usr/share/applications/xfce4-file-manager.desktop Desktop/explorer.desktop
sed -E -i 's/Name=File\ Manager/Name=wine资源管理器/;s/(^Exec=).*$/\1box64 wine64 explorer %U/;/\]=/d' Desktop/explorer.desktop
cp /usr/share/applications/wine.desktop ${HOME}/Desktop/
sed -i 's/^Exec.*$/Exec=box64 wine64 taskmgr %f/' ${HOME}/Desktop/wine.desktop

if [[ $(echo "$(box64 wine64 --version)"|tail -1|cut -b 6) == [6-9] ]]; then
cp /usr/local/bin/box64wine64 /usr/local/bin/box64wine64de
sed -E -i '/trap/d;s/(^box.*$)/\1 \&\nsleep 5\npkill services/' /usr/local/bin/box64wine64de
sed -i 's/^Exec.*$/Exec=box64wine64de %f/' ${HOME}/Desktop/wine.desktop
rm ${HOME}/Desktop/explorer.desktop ${HOME}/桌面/explorer.desktop
fi
cp ${HOME}/Desktop/* ${HOME}/桌面/
chmod a+x ${HOME}/Desktop/ -R
chmod a+x ${HOME}/桌面/ -R
fi
gg
echo -e "\n已安装，启动命令\e[33mstartvnc\e[0m\n\n如果kali-undercover不完整(如桌面时间、部分图标壁纸未显示)，请重新执行本脚本\e[33mbash undercover\e[0m\n如果需要用回ubuntu桌面，请点击：开始--其他--kali-undercover进行切换\e[0m\n"
read -r -p "确定请回车 " input
unset input
echo -e "\n\e[33m正在进行自动首次登录...\e[0m"
startvnc >/dev/null 2>&1
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
eof
sed -i "2i WINE_VERSION=$WINE_VERSION" .wine-arm64/root/firstrun
sed -i "2i ROOTFS=$ROOTFS" .wine-arm64/root/firstrun
sed -i "2i BOX_INSTALL=$BOX_INSTALL" .wine-arm64/root/firstrun
sed -i "2i LXC=$LXC" .wine-arm64/root/firstrun
sed -i "2i WINE_INSTALL=$WINE_INSTALL" .wine-arm64/root/firstrun
sed -i "2i START=$START" .wine-arm64/root/firstrun
echo '#!/usr/bin/env bash
cd
pkill -9 pulseaudio 2>/dev/null
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 
unset LD_PRELOAD
proot --kill-on-exit -b /sdcard:/root/sdcard -b /sdcard -b /dev/null:/proc/sys/kernel/cap_last_cap -b /data/dalvik-cache -b /data/data/com.termux/cache -b /proc/self/fd/2:/dev/stderr -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/0:/dev/stdin -b /proc/self/fd:/dev/fd -b .wine-arm64/tmp:/dev/shm -b /data/data/com.termux/files/usr/tmp:/tmp -b /dev/urandom:/dev/random --sysvipc --link2symlink -S .wine-arm64 -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TZ='Asia/Shanghai' LANG=C.UTF-8 /bin/bash --login' >${PREFIX}/bin/start-wine64 && chmod +x ${PREFIX}/bin/start-wine64
for i in version misc buddyinfo kmsg consoles execdomains stat fb loadavg key-users uptime devices vmstat; do if [ ! -r /proc/"${i}" ]; then sed -E -i "s@(cap_last_cap)@\1 -b .wine-arm64/etc/proc/${i}:/proc/${i}@" ${PREFIX}/bin/start-wine64; fi done

#高级proot登录
case $PROOT in
PRO)
if [ -z $ANDROID_RUNTIME_ROOT ]; then
export ANDROID_RUNTIME_ROOT=/apex/com.android.runtime
fi

cat >>${HOME}/.wine-arm64/etc/profile<<-EOF
export ANDROID_ART_ROOT=${ANDROID_ART_ROOT-}
export ANDROID_DATA=${ANDROID_DATA-}
export ANDROID_I18N_ROOT=${ANDROID_I18N_ROOT-}
export ANDROID_ROOT=${ANDROID_ROOT-}
export ANDROID_RUNTIME_ROOT=${ANDROID_RUNTIME_ROOT-}
export ANDROID_TZDATA_ROOT=${ANDROID_TZDATA_ROOT-}
export BOOTCLASSPATH=${BOOTCLASSPATH-}
export COLORTERM=${COLORTERM-}
export DEX2OATBOOTCLASSPATH=${DEX2OATBOOTCLASSPATH-}
export EXTERNAL_STORAGE=${EXTERNAL_STORAGE-}
export PATH=\${PATH}:/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin
export PREFIX=${PREFIX-/data/data/com.termux/files/usr}
export TERM=${TERM-xterm-256color}
export TMPDIR=/tmp
export PULSE_SERVER=tcp:127.0.0.1:4713
EOF
:<<\eof
if [[ $(id -u) = 0 ]];then
#mkdir -pv "/var/run/user/$(id -u)"
mkdir -pv /tmp/runtime-$(id -u)
else
    sudo mkdir -pv "/tmp/runtime-$(id -u)"
    sudo chmod -Rv 1777 "/tmp/runtime-$(id -u)"
fi
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
eof
sed -i '/=$/d' ${HOME}/.wine-arm64/etc/profile
:<<\gcc
cd ${HOME}/.wine-arm64
GCC=$(find -name libgcc_s.so.1 2>/dev/null | sed 's/.//')
if [ "$GCC" != "/" ]; then
echo $GCC >>${HOME}/.wine-arm64/etc/ld.so.preload
chmod 644 "${HOME}/.wine-arm64/etc/ld.so.preload"
fi
cd -
gcc
cat >${PREFIX}/bin/start-wine-arm64<<eof
#!/usr/bin/env bash
cd
pkill -9 pulseaudio 2>/dev/null
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &
unset LD_PRELOAD
proot --kill-on-exit -b /vendor -b /system -b /sdcard -b /sdcard:/root/sdcard -b /data/data/com.termux/files -b /data/data/com.termux/cache -b /data/data/com.termux/files/usr/tmp:/tmp -b /dev/null:/proc/sys/kernel/cap_last_cap -b /data/dalvik-cache -b .wine-arm64/tmp:/dev/shm -b /proc/self/fd/2:/dev/stderr -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/0:/dev/stdin -b /proc/self/fd:/dev/fd -b /dev/urandom:/dev/random --sysvipc --link2symlink -S .wine-arm64 -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=zh_CN.UTF-8 TZ=Asia/Shanghai TERM=xterm-256color USER=root /bin/bash --login
eof
for i in version misc buddyinfo kmsg consoles execdomains stat fb loadavg key-users uptime devices vmstat; do if [ ! -r /proc/"${i}" ]; then sed -E -i "s@(cap_last_cap)@\1 -b .wine-arm64/etc/proc/${i}:/proc/${i}@" ${PREFIX}/bin/start-wine-arm64; fi done
for i in /linkerconfig/ld.config.txt /plat_property_contexts /property_contexts /apex; do if [ -e $i ]; then sed -i "s@shm@shm \-b ${i}@" ${PREFIX}/bin/start-wine-arm64; fi done

#for i in /proc/$(ls ./etc/proc/|sed 's/ /\n/g'|grep -v bus); do i=$(echo $i|sed 's@/proc/@@'); if [ ! -r /proc/$i ]; then cp ./etc/proc/$i ${HOME}/${name}/etc/proc/ ;sed -i "s@shm@shm \-b ${HOME}/${name}/etc/proc/$i:/proc/$i@" ${PREFIX}/bin/start-${name}; fi done
#for i in ./etc/proc/* ; do if [ ! -r /proc/${i##*/} ]; then cp $i ${HOME}/${name}/etc/proc/ ;sed -i "s@shm@shm \-b ${HOME}/${name}/etc/proc/${i##*/}:/proc/${i##*/}@" ${PREFIX}/bin/start-${name}; fi done

chmod a+x ${PREFIX}/bin/start-wine-arm64
#${HOME}/.wine-arm64/usr/bin/ps

:<<\termux_user
echo "aid_$(id -un):x:$(id -u):$(id -g):Android user:/:/sbin/nologin" >> "${HOME}/.wine-arm64/etc/passwd"
echo "aid_$(id -un):*:18446:0:99999:7:::" >> "${HOME}/.wine-arm64/etc/shadow"

:<<\old
for g in $(id -G); do
echo "aid_$(id -gn "$g"):x:${g}:root,aid_$(id -un)" >> "${HOME}/.wine-arm64/etc/group"
if [ -f ".wine-arm64/etc/gshadow" ]; then
echo "aid_$(id -gn "$g"):*::root,aid_$(id -un)" >> "${HOME}/.wine-arm64/etc/gshadow"
fi
done
old

#local group_name group_id
while read -r group_name group_id; do
echo "aid_${group_name}:x:${group_id}:root,aid_$(id -un)" >> ${HOME}/.wine-arm64/etc/group
if [ -f ".wine-arm64/etc/gshadow" ]; then
echo "aid_${group_name}:*::root,aid_$(id -un)" >> ${HOME}/.wine-arm64/etc/gshadow
fi
done < <(paste <(id -Gn | tr ' ' '\n') <(id -G | tr ' ' '\n'))
termux_user

esac
echo "bash firstrun" >>${HOME}/.wine-arm64/etc/profile
proot --help | grep -q sysvipc
if [ $? == 1 ]; then
sed -i 's/--sysvipc//' ${PREFIX}/bin/start-wine64
sed -i 's/--sysvipc//' ${PREFIX}/bin/start-wine-arm64
fi
case $PROOT in
PRO)
. ${PREFIX}/bin/start-wine-arm64
;;
*)
. ${PREFIX}/bin/start-wine64
esac
