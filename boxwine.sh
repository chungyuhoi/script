#!/usr/bin/env bash

#常用变量
#指定内署dll或windows dll，b=builtin(wine)，n=native(windows)
#export WINEDLLOVERRIDES="bass=n,z:\\sdcard\\xinhao\\games\\unplay\\zw\\bass=b"
#for i in /usr/lib/wine/winepulse.drv.so /usr/lib/wine/fakedlls/winepulse.drv /usr/lib32/wine/fakedlls/winepulse.drv /usr/lib32/wine/winepulse.drv.so; do chmod 000 "$i"; chattr +i "$i"; done
#Exec=box86 wine explorer /desktop=name,1024x768 /sdcard/xinhao/games/War3/Frozen\ Throne.exe %f
#QT_SCREEN_SCALE_FACTORS=1
#BOX86_PATH=
#BOX86_LD_LIBRARY_PATH=
#export BOX64_PATH=${HOME}/wine64/bin/
#export BOX64_LD_LIBRARY_PATH=${HOME}/wine64/lib/wine/i386-unix/:${HOME}/wine64/lib/wine/x86_64-unix/:/lib/i386-linux-gnu/:/lib/x86_64-linux-gnu:/lib/aarch64-linux-gnu/
#默认系统盘目录export WINEPREFIX="${HOME}/.wine"
#opengl的驱动路径 LIBGL_DRIVERS_PATH=${HOME}/wine/usr/lib/i386-linux-gnu/dri
#GALLIUM_DRIVER=llvmpipe,zink
#export LIBGL_ALWAYS_SOFTWARE=1
#native用的是arm的lib
#DXVK_ASYNC=1 WINE_FULLSCREEN_FSR=1
:<<-eof
高位色运行低位色
Xephyr :1 -ac -screen 640x480x16 -reset -terminate &
DISPLAY=:1 openbox &
DISPLAY=:1 box86 wine start /unix /sdcard/xinhao/games/samurai2/SAMURAI2.EXE
eof
#SIGILL: 执行了非法指令. 通常是因为可执行文件本身出现错误, 或者试图执行数据段. 堆栈溢出时也有可能产生这个信号。
#SIGSEGV(Segment fault)意味着指针所对应的地址是无效地址，没有物理内存对应该地址，由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.

case $(dpkg --print-architecture) in
        aarch64|arm64) echo "" ;;
	*) echo -e "\e[31m不支持你的架构\e[0m"
                sleep 2
                exit 0
esac

#proot登录方式，可选 STANDER PRO
PROOT=PRO

#普通用户 TRUE
NOR_USER=

#镜像站检测
MIRROR=TRUE

#容器，可选 jammy bullseye kali sid kali_org
ROOTFS=bullseye

#box安装方式，可选 REPO GIT RELEASE XB6868 NOBOX
BOX_INSTALL=XB6868
#box_update box86最后更新时间:20230507
#box_update box64最后更新时间:20230322

#wine安装方式，注意：REPO仅对bullseye可用，可选 REPO PLAYONLINUX XB6868 NOWINE
WINE_INSTALL=XB6868

#wine版本，仅对PLAYONLIUX可用，可选 3.9 6.17 或该网已知版本
WINE_VERSION=3.9

CONTAINER=".wine-arm64"

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
WINE_INSTALL=XB6868
;;
kali_org)
LXC=kali
DEB="main contrib non-free"
WINE_INSTALL=PLAYONLINUX
esac
URL="https://mirrors.tuna.tsinghua.edu.cn"
cd

if [ $(uname -o) != Android ]; then echo -e "\e[33m仅适用于termux环境\e[0m"; sleep 1; exit 0; fi

echo -e "\e[33m检测环境..\e[0m"
sleep 1
clear
unset i
while [ ! $(command -v proot) ] && [[ $i -ne 3 ]]
do
pkg up -y && yes|pkg upgrade && pkg i -y curl proot tar pulseaudio
i=$(( $i+1 ))
done
if [ ! $(command -v proot) ]; then
echo -e "\e[33m检测环境失败，安装中止\e[0m"
sleep 1
exit 0
fi
unset i
if [ -d ${CONTAINER} ]; then echo -e "\n检测已有相关文件夹，是否删除？\n\e[33m1) 删除重装\n2) 删除\n0) 退出\e[0m\n";
read -r -p "请选择: " input
case $input in
1) rm -rf ${CONTAINER} ;;
2) rm -rf ${CONTAINER} ${PREFIX}/bin/start-wine*
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

case $ROOTFS in
kali_org)
curl https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-minimal.tar.xz -o rootfs.tar.xz
tar Jxvf rootfs.tar.xz
mv -v kali-arm64 ${CONTAINER}
ROOTFS=current
;;
*)
mkdir ${CONTAINER}

case $MIRROR in
TRUE)
echo -e "源地址检测中…"
TUNA=`echo $(ping -w5 -W5 -c5 -q mirrors.tuna.tsinghua.edu.cn)|awk -F '/' '{print $NF}'|cut -d '.' -f 1`; if [ -z $TUNA ]; then echo -e "清华源网络不通"; TUNA=999; fi
BFSU=`echo $(ping -w5 -W5 -c5 -q mirrors.bfsu.edu.cn)|awk -F '/' '{print $NF}'|cut -d '.' -f 1`; if [ -z $BFSU ]; then echo -e "北外源网络不通"; BFSU=999; fi
if (( $TUNA == 999 )) && (( $BFSU == 999 )); then
echo -e "源地址网络不通，中止安装"
sleep 2
exit 0
elif (( $BFSU > $TUNA )); then
echo -e "\e[33m清华源网络比较稳定，将使用清华源\e[0m"
URL="https://mirrors.tuna.tsinghua.edu.cn"
else
URL="https://mirrors.bfsu.edu.cn"
echo -e "\e[33m北外源网络比较稳定，将使用北外源\e[0m"
fi
sleep 2
esac

curl -O ${URL}/lxc-images/images/${LXC}/${ROOTFS}/arm64/default/$(curl ${URL}/lxc-images/images/${LXC}/${ROOTFS}/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
echo -e "\e[33m检测包下载完整性\e[0m"
if [[ $(du -b rootfs.tar.xz|awk '{print $1}') != $(curl -I ${URL}/lxc-images/images/${LXC}/${ROOTFS}/arm64/default/$(curl ${URL}/lxc-images/images/${LXC}/${ROOTFS}/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz|grep -i length|awk '{print $2}'|sed "s/\r//") ]]; then echo -e "\e[31m下载的包并不完整，但不会中止此次操作，如果安装失败，建议切换网络重新执行此脚本，\e[0m"; read -p "回车键继续"; fi

tar xvf rootfs.tar.xz -C ${CONTAINER}
esac
rm rootfs.tar.xz
echo 'for i in /var/run/dbus/pid /tmp/.X*-lock /tmp/.X11-unix/X*; do if [ -e "${i}" ]; then rm -vf ${i}; fi done' >>${CONTAINER}/etc/profile
#伪proc文件
mkdir ${CONTAINER}/etc/proc/ -p
printf ' 52 memory_bandwidth! 53 network_throughput! 54 network_latency! 55 cpu_dma_latency! 56 xt_qtaguid! 57 vndbinder! 58 hwbinder! 59 binder! 60 ashmem!239 uhid!236 device-mapper!223 uinput!  1 psaux!200 tun!237 loop-control! 61 lightnvm!228 hpet!229 fuse!242 rfkill! 62 ion! 63 vga_arbiter\n' | sed 's/!/\n/g' >${CONTAINER}/etc/proc/misc
printf "%-1s %-1s %-1s %8s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s\n" Node 0, zone DMA 3 2 2 4 3 3 2 1 2 2 0 Node 0, zone DMA32 1774 851 511 220 67 3 2 0 0 1 0 >${CONTAINER}/etc/proc/buddyinfo
rm ${CONTAINER}/etc/proc/filesystems 2>/dev/null
for i in sysfs rootfs ramfs bdev proc cpuset cgroup cgroup2 tmpfs configfs debugfs tracefs sockfs dax bpf pipefs devpts fuse fusectl selinuxfs oprofilefs pstore sdcardfs; do echo "nodev	$i" >>${CONTAINER}/etc/proc/filesystems; done
for i in fuseblk v7 sysv iso9660 msdos vfat squashfs ext2 ext4 ext3; do sed -i "/devpts/a\	$i" ${CONTAINER}/etc/proc/filesystems; done

echo "0.03 0.03 0.00 1/116 17521" >${CONTAINER}/etc/proc/loadavg
touch ${CONTAINER}/etc/proc/kmsg
echo 'tty0                 -WU (EC p  )    4:7' >${CONTAINER}/etc/proc/consoles
echo '0-0     Linux                   [kernel]' >${CONTAINER}/etc/proc/execdomains
echo '0 EFI VGA' >${CONTAINER}/etc/proc/fb
echo '    0:     9 8/8 3/1000000 27/25000000' >${CONTAINER}/etc/proc/key-users
echo '285490.46 1021963.95' >${CONTAINER}/etc/proc/uptime
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >${CONTAINER}/etc/proc/version
touch ${CONTAINER}/etc/proc/vmstat
echo 'Character devices:!  1 mem!  4 /dev/vc/0!  4 tty!  4 ttyS!  5 /dev/tty!  5 /dev/console!  5 /dev/ptmx!  7 vcs! 10 misc! 13 input! 21 sg! 29 fb! 81 video4linux!128 ptm!136 pts!180 usb!189 usb_device!202 cpu/msr!203 cpu/cpuid!212 DVB!244 hidraw!245 rpmb!246 usbmon!247 nvme!248 watchdog!249 ptp!250 pps!251 media!252 rtc!253 dax!254 gpiochip!!Block devices:!  1 ramdisk!  7 loop!  8 sd! 11 sr! 65 sd! 66 sd! 67 sd! 68 sd! 69 sd! 70 sd! 71 sd!128 sd!129 sd!130 sd!131 sd!132 sd!133 sd!134 sd!135 sd!179 mmc!253 device-mapper!254 virtblk!259 blkext' | sed 's/!/\n/g' >${CONTAINER}/etc/proc/devices
echo "cpu  0 0 0 0 0 0 0 0 0 0
cpu0 0 0 0 0 0 0 0 0 0 0
intr 1
ctxt 0
btime 0
processes 0
procs_running 1
procs_blocked 0
softirq 0 0 0 0 0 0 0 0 0 0 0" >${CONTAINER}/etc/proc/stat
cpus=`cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1 | awk '{print $1}'`
if [ -n $cpus ]; then
while [[ $cpus -ne 1 ]]
do
cpus=$(( $cpus-1 ))
sed -i "2a cpu${cpus} 0 0 0 0 0 0 0 0 0 0" ${CONTAINER}/etc/proc/stat
done
fi

sed -i '3i export MOZ_FAKE_NO_SANDBOX=1' ${CONTAINER}/etc/profile

sed -i "/#.*zh_CN.UTF-8 UTF-8/s/#//;/#.*zh_TW.UTF-8 UTF-8/s/#//;/#.*ja_JP.UTF-8 UTF-8/s/#//" ${CONTAINER}/etc/locale.gen
rm ${CONTAINER}/etc/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >${CONTAINER}/etc/resolv.conf
case $ROOTFS in
impish|jammy)
echo "deb ${URL}/ubuntu-ports/ ${ROOTFS} ${DEB}
deb ${URL}/ubuntu-ports/ ${ROOTFS}-updates ${DEB}
deb ${URL}/ubuntu-ports/ ${ROOTFS}-backports ${DEB}
deb ${URL}/ubuntu-ports/ ${ROOTFS}-security ${DEB}" >${CONTAINER}/etc/apt/sources.list
;;
bullseye|sid)
echo "deb ${URL}/debian/ ${ROOTFS} ${DEB}" >${CONTAINER}/etc/apt/sources.list
case $ROOTFS in
bullseye)
echo "deb ${URL}/debian/ bullseye-updates ${DEB}
deb ${URL}/debian/ bullseye-backports ${DEB}
deb ${URL}/debian-security bullseye-security ${DEB}" >>${CONTAINER}/etc/apt/sources.list
;;
sid)
curl ${URL}/kali/pool/main/o/openssl/$(curl ${URL}/kali/pool/main/o/openssl/|grep libssl1.1_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o ${CONTAINER}/root/libssl.deb
esac
curl ${URL}/debian/pool/main/c/ca-certificates/$(curl ${URL}/debian/pool/main/c/ca-certificates/|grep all.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o ${CONTAINER}/root/ca.deb
curl ${URL}/debian/pool/main/o/openssl/$(curl ${URL}/debian/pool/main/o/openssl/|grep openssl_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o ${CONTAINER}/root/openssl.deb
;;
current)
echo "deb ${URL}/kali kali-rolling ${DEB}" >${CONTAINER}/etc/apt/sources.list
curl ${URL}/debian/pool/main/c/ca-certificates/$(curl ${URL}/debian/pool/main/c/ca-certificates/|grep all.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o ${CONTAINER}/root/ca.deb
curl ${URL}/debian/pool/main/o/openssl/$(curl ${URL}/debian/pool/main/o/openssl/|grep openssl_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o ${CONTAINER}/root/openssl.deb
#curl ${URL}/kali/pool/main/o/openssl/libssl1.1_1.1.1o-1_arm64.deb -o ${CONTAINER}/root/libssl.deb
curl ${URL}/kali/pool/main/o/openssl/$(curl ${URL}/kali/pool/main/o/openssl/|grep libssl1.1_1.*arm64.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1) -o ${CONTAINER}/root/libssl.deb
esac
mkdir ${CONTAINER}/usr/share/doc/wine/ -p


echo -e "\e[33m系统已下载,文件夹名为${CONTAINER}\e[0m"
echo -e "登录命令为\e[33m${START}\e[0m"
sleep 5

cat >${CONTAINER}/root/firstrun<<-'eof'
#!/usr/bin/env bash

URL="https://mirrors.tuna.tsinghua.edu.cn"
echo -e "\n\e[33m正在配置首次运行\n安装常用应用\e[0m"
sleep 1
export LANG=C.UTF-8
cd
if [ ! -f /usr/bin/perl ]; then
#ln -sv /usr/bin/perl* /usr/bin/perl
rm perl-base*.deb 2>/dev/null
case $ROOTFS in
	bullseye)
curl -O https://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/p/perl/$(curl https://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/p/perl/|grep arm64|grep base|grep 5.32|awk -F 'title="' '{print $2}'|cut -d '"' -f 1)
;;
	current)
curl -O https://mirrors.tuna.tsinghua.edu.cn/kali/pool/main/p/perl/$(curl https://mirrors.tuna.tsinghua.edu.cn/kali/pool/main/p/perl/|grep perl-base|grep arm64|awk -F 'title="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
;;
*)
ln -sv /usr/bin/perl* /usr/bin/perl
esac
	dpkg -i perl-base*.deb
	rm perl-base*.deb 2>/dev/null
#ln -sv /usr/bin/perl*aarch64* /usr/bin/perl
fi
DEPENDS="apt-utils python3 git busybox curl wget tar vim fonts-wqy-microhei gnupg2 dbus-x11 libxinerama1 libxrandr2 libxcomposite1 libxcursor1 libncurses5 libgtk2.0-0 tigervnc-standalone-server tigervnc-viewer pulseaudio axel x11vnc xvfb psmisc procps onboard xfwm4 whiptail libtcmalloc-minimal4 xserver-xephyr mesa-utils cabextract"

DEPENDS0="zenity:armhf libegl-mesa0:armhf libgl1-mesa-dri:armhf libglapi-mesa:armhf libglx-mesa0:armhf libasound*:armhf libstdc++6:armhf libtcmalloc-minimal4:armhf gcc-arm-linux-gnueabihf sl:armhf -y"

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

cd && rm -rf temp

export LANG=zh_CN.UTF-8

#优化库
#apt install zenity libstdc++6 libasound* libncurses5 vulkan* *mesa* libmpg123-0 libsdl2-image-2.0-0 -y
#apt install ubuntu-restricted-extras chromium-codecs-ffmpeg-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi libavcodec-extra --no-install-recommends

cat >/usr/local/bin/boxwine<<-'BOXWINE'
#!/usr/bin/env bash
export WINEDEBUG=fixme-all
#WINEDEBUG=-all
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
#if [ ! $(command -v box64) ] || [ ! $(command -v box64) ] || [ ! $(command -v wine_original) ]; then echo -e "\e[33m你尚未安装全应用，中止启动\e[0m"; sleep 1; exit 1; fi
if ! grep '"SimSun"="wqy-microhei.ttc"' .wine/system.reg; then
sed -i '/\[Environment/i \[Software\\\\Wine\\\\Explorer\]\n"Desktop"="Default"\n\n\[Software\\\\Wine\\\\Explorer\\\\Desktops\]\n"Default"="800x600"\n\n\[Software\\\\Wine\\\\X11 Driver\]\n"Decorated"="N"\n"Managed"="Y"\n\n' .wine/user.reg
#"GrabFullscreen"="y"
sed -i '/FontMapper/i \[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontLink\\\\SystemLink\]\n"Arial"="wqy-microhei.ttc"\n"Arial Black"="wqy-microhei.ttc"\n"Lucida Sans Unicode"="wqy-microhei.ttc"\n"MS Sans Serif"="wqy-microhei.ttc"\n"SimSun"="wqy-microhei.ttc"\n"Tahoma"="wqy-microhei.ttc"\n"Tahoma Bold"="wqy-microhei.ttc"\n\n' .wine/system.reg
fi
trap "killall Xvnc 2>/dev/null; killall x11vnc 2>/dev/null; killall Xvfb 2>/dev/null; exit" SIGINT EXIT
wine64 taskmgr
exit 0
BOXWINE

cp /usr/local/bin/boxwine /usr/local/bin/boxwinede
sed -E -i '/trap/d;s/(^box.*$)/\1 \&\nsleep 5\npkill services/' /usr/local/bin/boxwinede

echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 800x600 -depth 16 -once -localhost -securitytypes None :0 &
export DISPLAY=:0
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
#dbus-launch xfwm4 &
#onboard &
boxwine >/dev/null 2>wine_log &
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
exit 0' >/usr/local/bin/startwine
rm /usr/local/bin/startvsdl /usr/local/bin/startxsdl 2>/dev/null
#vnc转xsdl对于用物理鼠标玩即时战略游戏较vnc更为贴近电脑，但运行效率也会相对降低。
cp /usr/local/bin/startwine /usr/local/bin/startvsdl
sed -i 's/:0/:1/g;/^echo.*vncviewer/d;/am/d;/exit 0/d' /usr/local/bin/startvsdl
sed -i '/Zlib/i echo -e "\\e[33m请先打开xsdl\\e[0m\n"\nread -p "已打开请回车"' /usr/local/bin/startvsdl
echo 'am start -n x.org.server/x.org.server.MainActivity 2>/dev/null
DISPLAY=127.0.0.1:0 xvncviewer -fullscreen 127.0.0.1:1 &
exit 0' >>/usr/local/bin/startvsdl

:<<\xsdl
#纯xsdl不支持的太多了，不推荐，不过有些游戏还是可以用这个运行。
echo '#!/usr/bin/env bash
echo -e "\n\e[33m请先打开xsdl\e[0m\n"
sleep 2
am start -n x.org.server/x.org.server.MainActivity 2>/dev/null
read -p "已打开请按回车"
export DISPLAY=127.0.0.1:0
#dbus-launch xfwm4 &
#onboard &
boxwine >/dev/null 2>wine_log &
#直接启动游戏：box64 wine64 start /unix *.exe
exit 0' >>/usr/local/bin/startxsdl
xsdl

#Exec=env WINEDEBUG=fixme-all bash -c "Xephyr :1 -ac -screen 640x480x16 & { env DISPLAY=:1 box86 wine start /unix /sdcard/xinhao/games/zuma/Zuma.exe & }"

echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
echo -e "\e[33m请先打开xsdl\e[0m\n"
read -p "已打开请回车"
am start -n x.org.server/x.org.server.MainActivity 2>/dev/null
DISPLAY=localhost:0 Xephyr :1 -reset -terminate -fullscreen &
DISPLAY=:1 boxwine >/dev/null 2>wine_log &
exit 0' >>/usr/local/bin/startxsdl

cat >/usr/local/bin/startxwine<<-'X11'
#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
#export X11VNC_REVERSE_CONNECTION_NO_AUTH=1
export DISPLAY=:233
Xvfb ${DISPLAY} -screen 0 800x600x16 -once -ac +extension GLX +render -deferglyphs 16 -br -retro -noreset 2>&1 2>/dev/null &
sleep 1
x11vnc -nopw -nocursor -localhost -ncache_cr -xkb -noxrecord -noxdamage -display ${DISPLAY} -forever -bg -rfbport 5900 -noshm -shared -nothreads 2>&1 2>/dev/null &
#dbus-launch xfwm4 &
#onboard &
boxwine >/dev/null 2>wine_log &
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
sleep 1
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
X11

#修改分辨率
cat >/usr/local/bin/fbl<<-'FBL'
#!/usr/bin/env bash
echo -e "\n\n\e[33m修改分辨率\e[0m\n为适配游戏应用显示，可修改分辨率达最佳显示效果"
echo -e "你现在的分辨率是\e[33m$(sed -n 's/^Xvnc.*geometry \(.*.\) -depth.*/\1/'p /usr/local/bin/startwine)\e[0m\n"
read -r -p "请输长度，例如1080 : " LENGTH
read -r -p "请输宽度，例如768 : " WIDTH
#if [ -z "$LENGTH" ] && [ -z "$WIDTH" ]; then
if [[ "$LENGTH" -gt 0 ]] && [[ "$WIDTH" -gt 0 ]] 2>/dev/null ;then
echo -e "你输入的分辨率为 \e[33m$LENGTH\e[0m x \e[33m$WIDTH\e[0m"
sed -i "s/^\"Default.*$/\"Default\"=\"${LENGTH}x${WIDTH}\"/" ${HOME}/.wine/user.reg
sed -i "s/-geometry .* -depth/-geometry ${LENGTH}x${WIDTH} -depth/" /usr/local/bin/startwine /usr/local/bin/startvsdl
sed -i "s/screen.*x16/screen 0 ${LENGTH}x${WIDTH}x16/" /usr/local/bin/startxwine
else
echo -e "输入无效，请重新输用本命令"
fi
sleep 1
FBL
#关虚拟桌面
cat >/usr/local/bin/gg<<-'DEG'
#!/usr/bin/env bash
sed -i '/Desktop/s/^/#/' /usr/local/bin/boxwine
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
sed -i '/Desktop/s/#//g' /usr/local/bin/boxwine
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

#创建winetricks启动脚本
cat >/usr/local/bin/startricks<<-'tricks'
#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
gg
export WINEDEBUG=fixme-all
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -background -retro -a 5 -alwaysshared -geometry 1024x768 -depth 16 -once -localhost -securitytypes None :0 &
export DISPLAY=:0
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
dbus-launch xfwm4 &
winetricks --gui &
wine64 explorer &
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
exit 0
tricks
chmod a+x /usr/local/bin/startricks
cat >/usr/local/bin/wine_menu<<-'menu'
#!/usr/bin/env bash
WINE_MENU(){
if [[ $(id -u) != 0 ]];then echo -e "\e[33m请使用root用户运行本脚本\e[0m"; sleep 2; exit 0; fi
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
if [ ! $(command -v wine_original) ]; then
WINE="你尚未安装wine，请选执行选项9"
else
if [[ $(echo "$(wine64 --version)"|tail -1|cut -b 6) == [4-9] ]]; then
WINE="安装wine3.9"
else
WINE="安装wine-8.5"
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
"5" "修改分辨率(非仿windows桌面)" \
"6" "提高程序优先级" \
"7" "${KALI}" \
"8" "${KB}" \
"9" "重新进行首次安装firstrun" \
"10" "安装gecko，mono" \
"11" "${WINE}" \
"12" "安装linux版firefox浏览器、qq和vlc播放器" \
"13" "32位wine4.0.3(该版本仅配置于仿windows桌面)" \
"14" "检测更新box86 box64版本" \
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
rm *.msi 2>/dev/null
#gecko ie相关
#mono .net程序相关
case $WINE in
	*3.9*)
#最新版本
wget ${URL}/winehq/wine/wine-mono/$(curl ${URL}/winehq/wine/wine-mono/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)/wine-mono-$(curl ${URL}/winehq/wine/wine-mono/ | grep href | tail -1 | awk -F 'href="' '{print $2}' | cut -d '/' -f 1)-x86.msi
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
for i in ./wine*.msi;do wine64 start /i $i; done
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
echo -e "\e[33m正在检测已安装wine版本并进行清除(仅对本脚本安装的wine文件有效)\e[0m"
sleep 3
rm PlayOnLinux* wine-8.5.tar.gz* 2>/dev/null
case $WINE_INSTALL in
PLAYONLINUX)
for i in $(sed 's@\./@/@g' /usr/share/doc/wine/postrm | sed ':a;N;s/\n/ /g;ta'); do if [ -f "$i" ]; then rm -v $i; fi done
rm /opt/wine-devel/bin/wine.*original /usr/bin/wine.*original 2>/dev/null
;;
*)
for i in $(sed 's@\./@/usr/@g' /usr/share/doc/wine/postrm | sed ':a;N;s/\n/ /g;ta'); do if [ -f "$i" ]; then rm -v $i; fi done
rm /opt/wine-devel/bin/wine.*original /usr/bin/wine.*original 2>/dev/null
esac
#for i in $(sed ':a;N;s/\n/ /g;ta' /usr/share/doc/wine/postrm|sed 's@\./@/usr/@g'); do if [ -f "$i" ]; then rm -v $i; fi done
case $WINE in
*8.5*)

case $WINE_INSTALL in
PLAYONLINUX)
axel https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-6.17-upstream-linux-amd64.tar.gz
tar zxvf sdcard/xinhao/PlayOnLinux-wine-6.17-upstream-linux-amd64.tar.gz -C /usr/ ./lib >/usr/share/doc/wine/postrm 2>&1
LXC=debian ROOTFS=bullseye WINE_URL="https://dl.winehq.org"; axel -o wine-devel-i386.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-i386/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-i386/|grep wine-devel-i386_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1); axel -o wine-devel-amd64.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep wine-devel-amd64_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1); axel -o wine-devel.deb  ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep wine-devel_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1); axel -o winehq-devel.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep winehq-devel_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1); for i in wine-devel-amd64.deb  winehq-devel.deb wine-devel.deb wine-devel-i386.deb; do dpkg -X $i / >>/usr/share/doc/wine/postrm 2>&1; done
sed -i 's@^./lib@./usr/lib@' /usr/share/doc/wine/postrm
;;
*)
wget https://shell.xb6868.com/wine/wine-8.5.tar.gz
tar zxvf wine-8.5.tar.gz -C / >/usr/share/doc/wine/postrm 2>&1
rm wine-8.5.tar.gz 2>/dev/null
mv /opt/wine-devel/bin/wineserver /opt/wine-devel/bin/wineserver_original
echo '#!/bin/sh
box64 /opt/wine-devel/bin/wineserver_original "$@"' >/opt/wine-devel/bin/wineserver
mv /opt/wine-devel/bin/wine /opt/wine-devel/bin/wine_original
echo '#!/bin/sh
box86 /opt/wine-devel/bin/wine_original "$@"' >/opt/wine-devel/bin/wine
mv /opt/wine-devel/bin/wine64 /opt/wine-devel/bin/wine64_original
echo '#!/bin/sh
box64 /opt/wine-devel/bin/wine64_original "$@"' >/opt/wine-devel/bin/wine64
chmod a+x /opt/wine-devel/bin/wine /opt/wine-devel/bin/wine64 /opt/wine-devel/bin/wineserver
esac
;;
*)
for i in $(sed 's@^\.@@g' /usr/share/doc/wine/postrm | sed ':a;N;s/\n/ /g;ta'); do if [ -f "$i" ]; then rm -v $i; fi done
rm /opt/wine-devel/bin/wine.*original /usr/bin/wine.*original 2>/dev/null
wget https://shell.xb6868.com/wine/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
tar zxvf PlayOnLinux-wine-*-upstream-linux-amd64.tar.gz -C /usr >/usr/share/doc/wine/postrm 2>&1
mv /usr/bin/wineserver /usr/bin/wineserver_original
echo '#!/bin/sh                                               box64 /usr/bin/wineserver_original "$@"' >/usr/bin/wineserver
mv /usr/bin/wine /usr/bin/wine_original
echo '#!/bin/sh
box86 /usr/bin/wine_original "$@"' >/usr/bin/wine
mv /usr/bin/wine64 /usr/bin/wine64_original
echo '#!/bin/sh
box64 /usr/bin/wine64_original "$@"' >/usr/bin/wine64
chmod a+x /usr/bin/wine /usr/bin/wine64 /usr/bin/wineserver

rm PlayOnLinux-wine-*-upstream-linux-amd64.tar.gz box86.tar.gz box64.tar.gz
esac

rm ${HOME}/桌面/explorer.desktop ${HOME}/Desktop/explorer.desktop 2>/dev/null
cp /usr/share/applications/xfce4-file-manager.desktop ${HOME}/Desktop/explorer.desktop 2>/dev/null
cp /usr/share/applications/xfce4-file-manager.desktop ${HOME}/桌面/explorer.desktop 2>/dev/null
sed -E -i 's/Name=File\ Manager/Name=wine explorer/;s/(^Exec=).*$/\1wine64 explorer %U/;/\]=/d;/wine explorer/a Name[zh_CN]=wine资源管理器' ${HOME}/Desktop/explorer.desktop ${HOME}/桌面/explorer.desktop
sed -i 's/^Icon.*$/Icon=utilities-system-monitor/' /usr/share/applications/wine.desktop
cp /usr/share/applications/wine.desktop ${HOME}/Desktop/wine.desktop 2>/dev/null
sed -i 's/^Exec.*$/Exec=boxwinede %f/' ${HOME}/Desktop/wine.desktop 2>/dev/null
cp /usr/share/applications/wine.desktop ${HOME}/桌面/wine.desktop 2>/dev/null
sed -i 's/^Exec.*$/Exec=boxwinede %f/' ${HOME}/桌面/wine.desktop 2>/dev/null
sed -i 's/^Exec=wine/Exec=wine64/' /usr/share/applications/wine.desktop 2>/dev/null
chmod a+x ${HOME}/桌面 ${HOME}/Desktop -R 2>/dev/null

bash firstrun
exit 0
;;
12)
if [ ! $(command -v kali-undercover) ]; then
echo -e "\e[33m请先安装仿windows桌面\e[0m"
sleep 3
WINE_MENU
fi
if grep -q ID=ubuntu /etc/os-release ; then
DEPENDS="firefox firefox-locale-zh-hans"
else
DEPENDS="firefox-esr firefox-esr-l10n-zh-cn"
fi
apt update
cd
apt install --no-install-recommends vlc $DEPENDS -y
i=0
while [ ! $(command -v vlc) ] || [ ! $(command -v firefox) ] && [[ $i -ne 3 ]]
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
rm linuxqq_*_arm64.deb 2>/dev/null
if [ ! $(command -v qq) ]; then
echo -e "\e[33m检测最新版本qq\e[0m"
sleep 1
wget $(curl https://aur.archlinux.org/packages/linuxqq|grep arm64|cut -d '"' -f2)
apt install ./linuxqq_*_arm64.deb -y
if [ $(command -v qq) ]; then
echo 'export GDK_NATIVE_WINDOWS=true' >>/etc/profile
cp /usr/share/applications/qq.desktop ${HOME}/Desktop
cp /usr/share/applications/qq.desktop ${HOME}/桌面
fi
fi
chmod a+x ${HOME}/桌面 ${HOME}/Desktop -R
;;
13) 
if [ ! $(command -v kali-undercover) ] || [ ! $(command -v box86) ]; then
echo -e "你尚未安装box86或仿windows桌面"
sleep 3
WINE_MENU
fi
read -p "本wine4.0将集中在主目录下一个wine文件夹内，且仅对仿windows桌面进行配置并创建桌面快捷，确认请回车"
cd && mkdir wine4 2>/dev/null
rm PlayOnLinux-wine-4.0.3-upstream-linux-x86.tar.gz 2>/dev/null

case $WINE_INSTALL in
PLAYONLINUX)
axel https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-x86/PlayOnLinux-wine-4.0.3-upstream-linux-x86.tar.gz
;;
*)
wget https://shell.xb6868.com/wine/PlayOnLinux-wine-4.0.3-upstream-linux-x86.tar.gz
esac
if [ ! -f PlayOnLinux-wine-4.0.3-upstream-linux-x86.tar.gz ]; then
echo -e "\e[31m下载失败，请重试\e[0m"
sleep 3
WINE_MENU
fi
tar zxvf PlayOnLinux-wine-4.0.3-upstream-linux-x86.tar.gz -C wine4
rm -rf wine4/.wine 2>/dev/null
WINEDEBUG=fixme-all WINEPREFIX="/root/wine4/.wine" box86 /root/wine4/bin/wine wineboot
pstree | grep -q "services"
while [ $? == 0 ]
do
sleep 1
pstree | grep -q "services"
done
cp ${HOME}/Desktop/wine.desktop ${HOME}/Desktop/wine4.desktop
sed -i 's@Exec.*@Exec=env BOX86_NOPULSE=1 WINEDEBUG=fixme-all WINEPREFIX="/root/wine4/.wine" box86 /root/wine4/bin/wine explorer /desktop,640x480 taskmgr %f@' ${HOME}/Desktop/wine4.desktop
sed -i 's/=wine/=wine4/' ${HOME}/Desktop/wine4.desktop
chmod a+x ${HOME}/Desktop/wine4.desktop
rm PlayOnLinux-wine-4.0.3-upstream-linux-x86.tar.gz*
;;
14)
if [ ! $(command -v box86) ]||[ ! $(command -v box64) ]; then
echo -e "你尚未安装box86或box64"
sleep 2
else
echo -e "检验中…"
curl -s https://shell.xb6868.com/wine/boxwine.sh|grep '^#box_update'|awk '{print $2}'
echo -e "\n你目前版本的时间是\nbox86 $(date -d "$(LANG=c.UTF_8 box86 --version|awk -F ' on ' '{print $2}'|awk '{print $1,$2,$3}')" +%Y%m%d)\nbox64 $(date -d "$(LANG=c.UTF_8 box64 --version|awk -F ' on ' '{print $2}'|awk '{print $1,$2,$3}')" +%Y%m%d)\n\n是否更新安装"
read -r -p '1) 是 2) 返回: ' input
case $input in
1)
rm box86.tar.gz* box64.tar.gz* 2>/dev/null
wget https://shell.xb6868.com/wine/box86.tar.gz
wget https://shell.xb6868.com/wine/box64.tar.gz
tar zxvf box86.tar.gz -C /
tar zxvf box64.tar.gz -C /
box86 --version
box64 --version
sleep 3
esac
fi
WINE_MENU
;;
0) exit 0
esac
sleep 1.5
WINE_MENU
else
echo  -e "\e[33m你已取消选择\e[0m"
sleep 1
exit 0
fi
}
WINE_MENU "$@"
#VERSION=`curl https://kgithub.com/doitsujin/dxvk/releases|grep tag.*Version|sed -n 1p|awk -F 'Version ' '{print $2}'|cut -d '<' -f 1`; wget https://kgithub.com/doitsujin/dxvk/releases/download/v$VERSION/dxvk-$VERSION.tar.gz
#cp dxvk-2.2/x64/* .wine/drive_c/windows/system32/
#cp dxvk-2.2/x32/* .wine/drive_c/windows/syswow64/            #sed -i '/DllOverrides/a"d3d10core"="native"\n"d3d11"="native"\n"d3d9"="native"\n"dxgi"="native"' .wine/user.reg
menu
sed -i "4i WINE_INSTALL=$WINE_INSTALL" /usr/local/bin/wine_menu

cat >/usr/local/bin/kb<<-'jp_'
#!/usr/bin/env bash
if grep ^onboard /usr/local/bin/startwine; then
echo -e "\e[33m关闭桌面键盘\e[0m"
sleep 1
sed -i '/onboard/s/^/#/;/xfwm4/s/^/#/' /usr/local/bin/startwine /usr/local/bin/startxwine /usr/local/bin/startxsdl /usr/local/bin/startvsdl
else
echo -e "\e[33m启动桌面键盘\e[0m"
sleep 1
sed -i '/onboard/s/#//g;/xfwm4/s/#//g' /usr/local/bin/startwine /usr/local/bin/startxwine /usr/local/bin/startxsdl /usr/local/bin/startvsdl
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
ln -sf /usr/share/zoneinfo/Etc/GMT-8 /etc/localtime
sed -i "/zh_CN.UTF/s/#//" /etc/locale.gen
sed -i '/^SUPPORTED/s/^/#/;/^ALIASES/s/^/#/' /usr/sbin/locale-gen
locale-gen
#sed -i -e '/GBK/,/^}/s/^/#/' /usr/share/X11/locale/zh_CN.UTF-8/XLC_LOCALE
sed -i '/LANG=zh_CN.UTF-8/d' /etc/profile && sed -i '2i export LANG=zh_CN.UTF-8' /etc/profile
sed -i "/firstrun/d" /etc/profile
sed -i "/return/d" ${HOME}/firstrun
if ! grep -q termux /etc/bash.bashrc; then
if [ -f /data/data/com.termux/files/usr/etc/motd.sh ]; then
cat /data/data/com.termux/files/usr/etc/motd.sh|sed '/com.termux/d;s/pkg/apt/' >>/etc/bash.bashrc
sed -i '/TERMUX_APP_PACKAGE_MANAGER/i clear\nTERMUX_VERSION=$(cat /etc/os-release|grep PRETTY | cut -d "=" -f 2)\nclear' /etc/bash.bashrc
echo 'if [ -d ${HOME}/.wine/drive_c/users/*/Temp/*490 ]; then echo -e "\e[31m注意，有不明文件夹！谨慎中电脑病毒。\e[0m"; fi' >>/etc/bash.bashrc
fi
fi
case $NOR_USER in
TRUE)
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo
chmod 4711 /usr/bin/su
echo -e "\e[33m请设置root用户密码(输入内容不会反显)\e[0m\n"
passwd
echo -e "\e[33m请设置普通用户密码(输入内容不会反显)，用户名为 $(grep 'Android user' /etc/passwd|cut -d ':' -f 1)\e[0m\n"
passwd $(grep 'Android user' /etc/passwd|cut -d ':' -f 1)
sed -i "/\%sudo/a $(grep 'Android user' /etc/passwd|cut -d ':' -f 1) ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers
cp /etc/skel/.profile /home/*/
cp /etc/skel/.bashrc /home/*/
esac

if [ ! $(command -v box64) ] || [ ! $(command -v box86) ]; then
rm box86.tar.gz box64.tar.gz 2>/dev/null
case $BOX_INSTALL in
XB6868)
echo -e "\e[33m下载box86与box64\e[0m"
sleep 2
wget https://shell.xb6868.com/wine/box86.tar.gz
tar zxvf box86.tar.gz -C /
rm box86.tar.gz

wget https://shell.xb6868.com/wine/box64.tar.gz
tar zxvf box64.tar.gz -C /
rm box64.tar.gz

;;
PACKAGE)
#deb包安装
rm box64* box86*
i=0
while [ ! $(command -v box86) ] || [ ! $(command -v box64) ] && [[ $i -ne 3 ]]
do
rm box64* box86*
i=$(( i+1 ))
date -d "$(LANG=C.UTF_8 box86 --version|awk -F ' on ' '{print $2}'|awk '{print $1,$2,$3}')" +%Y%m%d
curl https://kgithub.com/Itai-Nelken/weekly-box86-debs/tree/main/debian/pool|grep 'armhf.deb'|awk -F 'href="' '{print $2}'|tail -n 1|cut -d '+' -f2|cut -d '.' -f1
wget https://raw.githubusercontent.com$(curl https://kgithub.com/Itai-Nelken/weekly-box86-debs/tree/main/debian/pool|grep 'armhf.deb'|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1|sed 's@/blob@@') -O box86.deb

date -d "$(LANG=C.UTF_8 box64 --version|awk -F ' on ' '{print $2}'|awk '{print $1,$2,$3}')" +%Y%m%d
curl https://kgithub.com/ryanfortner/box64-debs/tree/master/debian|grep 'arm64.deb'|awk -F 'href="' '{print $2}'|tail -n 1|cut -d '+' -f2|cut -d '.' -f1
wget https://raw.githubusercontent.com$(curl https://kgithub.com/ryanfortner/box64-debs/tree/master/debian|grep 'arm64.deb'|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1|sed 's@/blob@@') -O box64.deb
dpkg -X box64.deb /
dpkg -X box86.deb /
done
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
#wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg 2>&1 >/dev/null
#
wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
#if [ ! -f /usr/share/keyrings/box64-debs-archive ]; then
if [ ! -f /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg ]; then
#wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/box64-debs-archive-keyring.gpg
wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
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
if [ ! $(command -v wine_original) ]; then
rm PlayOnLinux-wine-*-upstream-linux-amd64.tar.gz 2>/dev/null
case $WINE_INSTALL in
XB6868)
wget https://shell.xb6868.com/wine/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
echo -e "解压中"
tar zxvf PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz -C /usr >/usr/share/doc/wine/postrm 2>&1
mv /usr/bin/wineserver /usr/bin/wineserver_original
echo '#!/bin/sh
box64 /usr/bin/wineserver_original "$@"' >/usr/bin/wineserver
mv /usr/bin/wine /usr/bin/wine_original
echo '#!/bin/sh
box86 /usr/bin/wine_original "$@"' >/usr/bin/wine
mv /usr/bin/wine64 /usr/bin/wine64_original
echo '#!/bin/sh
box64 /usr/bin/wine64_original "$@"' >/usr/bin/wine64
chmod a+x /usr/bin/wine /usr/bin/wine64 /usr/bin/wineserver
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
axel -o wine-devel-i386.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-i386/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-i386/|grep wine-devel-i386_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
i=0
while [ ! $(command -v wine_original) ] && [[ $i -ne 3 ]]
do
i=$(( $i+1 ))
apt --fix-broken install -y && apt install ./wine-devel-i386.deb --no-install-recommends -y
done
axel -o wine-devel-amd64.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep wine-devel-amd64_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
i=0
while [ ! $(command -v wine64_original) ] && [[ $i -ne 3 ]]
do
i=$(( $i+1 ))
apt --fix-broken install -y && apt install ./wine-devel-amd64.deb --no-install-recommends -y
done
axel -o wine-devel.deb  ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep wine-devel_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
dpkg -i --force-overwrite wine-devel.deb 
axel -o winehq-devel.deb ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/$(curl ${WINE_URL}/wine-builds/${LXC}/dists/${ROOTFS}/main/binary-amd64/|grep winehq-devel_8|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
dpkg -i --force-overwrite winehq-devel.deb
cd && rm -rf wine_tmp
;;

PLAYONLINUX)
echo -e "\n\e[33m下载wine 3.9版本，如果下载速度慢，请ctrl+c中止下载，并输bash firstrun重新初始化安装\e[0m"
sleep 3

rm wine.tar.gz 2>/dev/null
i=0
while [ ! -f wine.tar.gz ] && [[ $i -ne 3 ]]
do
#axel -o wine.tar.gz https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
#https://twisteros.com/wine.tgz 5.3_x86
#https://kgithub.com/Kron4ek/Wine-Builds/releases
axel -o wine.tar.gz https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-$WINE_VERSION-upstream-linux-amd64.tar.gz
i=$(( i+1 ))
done

tar zxvf wine.tar.gz -C /usr >/usr/share/doc/wine/postrm 2>&1
mv /usr/bin/wineserver /usr/bin/wineserver_original
echo '#!/bin/sh
box64 /usr/bin/wineserver_original "$@"' >/usr/bin/wineserver
mv /usr/bin/wine /usr/bin/wine_original
echo '#!/bin/sh
box86 /usr/bin/wine_original "$@"' >/usr/bin/wine
mv /usr/bin/wine64 /usr/bin/wine64_original
echo '#!/bin/sh
box64 /usr/bin/wine64_original "$@"' >/usr/bin/wine64
chmod a+x /usr/bin/wine /usr/bin/wine64 /usr/bin/wineserver
;;

*)
echo ""
esac
fi

if [ $(command -v wine_original) ] && [ $(command -v box64) ] && [ $(command -v box86) ]; then
if [ ! -f /usr/local/bin/winetricks ]; then
echo -e "\n\e[33m下载 winetricks\e[0m\n"
sleep 1
curl https://ghproxy.com/https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -o /usr/local/bin/winetricks
if [ -f /usr/local/bin/winetricks ]; then
sed -i '2a export WINEARCH=win32 BOX64_NOBANNER=1 BOX86_NOBANNER=1 WINEDEBUG=fixme-all' /usr/local/bin/winetricks
sed -i 's/github/kgithub/g' /usr/local/bin/winetricks
sed -E -i "s/(latest_version=.*winetricks.*)/#\1\n latest_version=/" /usr/local/bin/winetricks
chmod a+x /usr/local/bin/winetricks
fi
fi
echo -e "\e[33m进行wine初始化配置\e[0m"
sleep 1
rm -rf .wine 2>/dev/null
sleep 5
if [[ $(echo "$(wine64 --version)"|tail -1|cut -b 6) == [4-7] ]]; then
export BOX86_DYNAREC=0
wine64 wineboot 2>/dev/null &
pkill services
sed -i "/boxwine/a sleep 5\npkill services" /usr/local/bin/start*
else
wine64 wineboot 2>/dev/null
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

sed -i '/\[Environment/i \[Software\\\\Wine\\\\Explorer\]\n"Desktop"="Default"\n\n\[Software\\\\Wine\\\\Explorer\\\\Desktops\]\n"Default"="800x600"\n\n\[Software\\\\Wine\\\\X11 Driver\]\n"Decorated"="N"\n"Managed"="Y"' .wine/user.reg
#"GrabFullscreen"="y"
done

#cp /usr/share/fonts/truetype/wqy/wqy-zenhei.ttc .wine/drive_c/windows/Fonts/
#cp /usr/share/fonts/truetype/wqy/wqy-microhei.ttc .wine/drive_c/windows/Fonts/
#Disable the GUI crash dialog
sed -i '/X11/i [Software\\Wine\\WineDbg]\n"ShowCrashDialog"=dword:00000000\n' ${HOME}/.wine/user.reg

sed -i '/FontMapper/i \[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontLink\\\\SystemLink\]\n"Arial"="wqy-microhei.ttc"\n"Arial Black"="wqy-microhei.ttc"\n"Lucida Sans Unicode"="wqy-microhei.ttc"\n"MS Sans Serif"="wqy-microhei.ttc"\n"SimSun"="wqy-microhei.ttc"\n"Tahoma"="wqy-microhei.ttc"\n"Tahoma Bold"="wqy-microhei.ttc"\n\n' .wine/system.reg
:<<\Temp
if [ -d /root/wine4/.wine/drive_c ]; then
mkdir -vp /root/wine4/.wine/drive_c/users/*/Temp
chmod 0000 -vR /root/wine4/.wine/drive_c/users/*/Temp
fi
Temp
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
#wget https://www.7-zip.org/$(curl https://www.7-zip.org/download.html|grep '7z.*-x64.exe'|head -n1|sed 's/-x64//'|awk -F 'href="' '{print $2}'|cut -d '"' -f1)
#wget https://www.7-zip.org/$(curl https://www.7-zip.org/download.html|grep '7z.*-x64.exe'|head -n1|awk -F 'href="' '{print $2}'|cut -d '"' -f1)
echo -e "\n\e[33m配置完毕\e[0m\n"
echo -e "\n如果上面的安装失败,请输\e[33mbash firstrun\e[0m重新安装"
case $NOR_USER in
TRUE)
echo -e "普通用户登录容器\e[33mstart-$(grep 'Android user' /etc/passwd|cut -d ':' -f 1)\e[0m"
esac
echo -e "root用户登录容器\e[33m${START}\e[0m\n退出容器,在termux输\e[33mexit\e[0m即可\e[0m\n安装仿windows界面，输\e[33mbash undercover\e[0m\n多功能菜单\e[33mwine_menu\e[0m"

if [ $(command -v wine_original) ] && [ $(command -v box64) ] && [ $(command -v box86) ]; then
echo -e "vnc打开wine请输\e[33mstartwine\e[0m，vnc viewer地址输127.0.0.1:0\nxsdl打开wine\e[33m请先打开xsdl\e[0m，再输\e[33mstartxsdl\e[0m\n修改分辨率适配游戏，请输\e[33mfbl\e[0m\n提高游戏优先级，游戏中在这界面回车出现光标输\e[33myy\e[0m\n使用图形winetricks(只支持32位exe)\e[33mstartricks\e[0m\n"
fi
read -p "确认请回车"
eof

#If no 'isolated_environment', the following host directories will be available:


cat >${CONTAINER}/root/undercover<<-'eof'
#!/usr/bin/env bash
cd
#精简安装
#:<<\eof
if [ ! $(command -v xfce4-session) ]; then
apt update && apt install xfce4 xfce4-terminal ristretto lxtask dbus-x11 tigervnc-standalone-server tigervnc-viewer pulseaudio xserver-xorg x11-utils python3 tumbler python-gi-dev --no-install-recommends -y
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
apt update
apt install ./undercover.deb xfce4-terminal -y
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
export RUNLEVEL=5
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 1024x768 -depth 24 -once -localhost -securitytypes None :0 &
export DISPLAY=:0
. /etc/X11/xinit/Xsession >/dev/null 2>&1 &
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
sleep 1
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity 2>/dev/null
eom

rm /usr/share/xfce4/panel/plugins/power-manager-plugin.desktop undercover.deb 2>/dev/null

if [ $(command -v wine_original) ]; then
sed -i 's/^Exec=wine/Exec=wine64/' /usr/share/applications/wine.desktop 2>/dev/null
sed -i 's/^Icon.*$/Icon=utilities-system-monitor/' /usr/share/applications/wine.desktop
#sed -i 's/^Name=Wine Windows Program Loader/Name=wine任务管理器/' /usr/share/applications/wine.desktop
sed -i '/^Name=Wine Windows Program Loader/a Name[zh_CN]=wine任务管理器' /usr/share/applications/wine.desktop
#sed -i 's/^MimeType.*$/Categories=GTK;System;Monitor;/' /usr/share/applications/wine.desktop
fi

chmod +x /usr/local/bin/startvnc

for i in 16x16 22x22 24x24 32x32 48x48 256x256; do cp -v /usr/share/icons/Windows-10-Icons/$i/apps/utilities-system-monitor.png /usr/share/icons/hicolor/$i/apps ; done
gtk-update-icon-cache /usr/share/icons/hicolor

sed -i '/exit/s/^/#/' $(command -v kali-undercover)
#sed -E -i 's/(\$USER_PROFILE \])/\1 || grep undercover ~\/.bashrc/' $(command -v kali-undercover)
cp $(command -v kali-undercover) /usr/bin/kali-undercover.bak
#sed -i 's/disable_undercover()/disable()/' $(command -v kali-undercover)
#sed -i 's/disable_undercover/enable_undercover/' $(command -v kali-undercover)
mkdir ${HOME}/Desktop 2>/dev/null
mkdir ${HOME}/桌面 2>/dev/null
sed -E -i '/root.*0:0/s/^.*$/root:x:0:0:Administrator:\/root:\/bin\/bash/' /etc/passwd
cp /usr/share/applications/kali-undercover.desktop /etc/xdg/autostart/
if ! grep -q autostart $(command -v kali-undercover) ; then
sed -i '2i if [ -f /etc/xdg/autostart/kali-undercover.desktop ]; then rm /etc/xdg/autostart/kali-undercover.desktop; fi' $(command -v kali-undercover) $(command -v kali-undercover.bak)
fi
bash -c "$(sed '/am start/d' /usr/local/bin/startvnc)" >/dev/null 2>&1 &
sleep 5
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
cp /usr/bin/kali-undercover.bak $(command -v kali-undercover) 

if [ $(command -v wine_original) ]; then
cp /usr/share/applications/xfce4-terminal.desktop ${HOME}/Desktop/rscreen.desktop
#sed -i 's/xfce4-terminal/xrandr \-s 0/;s/Xfce\ Terminal/恢复屏幕/;/\]=/d;/=T/d;/preferences\]/,$d' ${HOME}/Desktop/rscreen.desktop
sed -i 's/xfce4-terminal/xrandr \-s 0/;s/Xfce\ Terminal/rscreen/;/\]=/d;/=T/d;/preferences\]/,$d;/rscreen/a Name[zh_CN]=恢复屏幕' ${HOME}/Desktop/rscreen.desktop
cp /usr/share/applications/xfce4-file-manager.desktop Desktop/explorer.desktop
#sed -E -i 's/Name=File\ Manager/Name=wine资源管理器/;/\]=/d' ${HOME}/Desktop/explorer.desktop
sed -E -i 's/Name=File\ Manager/Name=wine explorer/;s/(^Exec=).*$/\1wine64 explorer %U/;/\]=/d;/wine explorer/a Name[zh_CN]=wine资源管理器' ${HOME}/Desktop/explorer.desktop
cp /usr/share/applications/wine.desktop ${HOME}/Desktop/
sed -i 's/^Exec.*$/Exec=wine64 taskmgr %f/' ${HOME}/Desktop/wine.desktop

if [[ $(echo "$(wine64 --version)"|tail -1|cut -b 6) == [4-7] ]]; then
cp /usr/local/bin/boxwine /usr/local/bin/boxwinede
sed -E -i '/trap/d;s/(^box.*$)/\1 \&\nsleep 5\npkill services/' /usr/local/bin/boxwinede
sed -i 's/^Exec.*$/Exec=boxwinede %f/' ${HOME}/Desktop/wine.desktop
rm ${HOME}/Desktop/explorer.desktop ${HOME}/桌面/explorer.desktop 2>/dev/null
fi
cp ${HOME}/Desktop/* ${HOME}/桌面/
chmod a+x ${HOME}/Desktop/ -R
chmod a+x ${HOME}/桌面/ -R
fi
echo -e "\n已安装，启动命令\e[33mstartvnc\e[0m\n\n如果kali-undercover安装崩溃，请重新执行本脚本\e[33mbash undercover\e[0m\n如果需要用回xfce4桌面，请点击：开始--其他--kali-undercover进行切换\e[0m\n"
read -r -p "确定请回车 " input
unset input
echo -e "\n\e[33m正在进行自动首次登录...\e[0m"
startvnc >/dev/null 2>&1
echo -e "\n\e[33m请打开vncviewer输127.0.0.1:0\e[0m\n"
eof
sed -i "2i WINE_VERSION=$WINE_VERSION" ${CONTAINER}/root/firstrun
sed -i "2i ROOTFS=$ROOTFS" ${CONTAINER}/root/firstrun
sed -i "2i BOX_INSTALL=$BOX_INSTALL" ${CONTAINER}/root/firstrun
sed -i "2i LXC=$LXC" ${CONTAINER}/root/firstrun
sed -i "2i WINE_INSTALL=$WINE_INSTALL" ${CONTAINER}/root/firstrun
sed -i "2i START=$START" ${CONTAINER}/root/firstrun
sed -i "2i NOR_USER=$NOR_USER" ${CONTAINER}/root/firstrun
echo "#!/usr/bin/env bash
cd
pkill -9 pulseaudio 2>/dev/null
rm -rf ${PREFIX}/tmp/.* ${PREFIX}/tmp/*
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1 
unset LD_PRELOAD
proot --kill-on-exit -b /sdcard:/root/sdcard -b /sdcard -b /dev/null:/proc/sys/kernel/cap_last_cap -b /data/data/com.termux/cache -b /proc/self/fd/2:/dev/stderr -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/0:/dev/stdin -b /proc/self/fd:/dev/fd -b ${CONTAINER}/tmp:/dev/shm -b /data/data/com.termux/files/usr/tmp:/tmp -b /dev/urandom:/dev/random --sysvipc --link2symlink -S ${CONTAINER} -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TZ='Asia/Shanghai' LANG=C.UTF-8 /bin/bash --login" >${PREFIX}/bin/start-wine64
for i in version misc buddyinfo kmsg consoles execdomains stat fb filesystems loadavg key-users uptime devices vmstat; do if [ ! -r /proc/"${i}" ]; then sed -E -i "s@(cap_last_cap)@\1 -b ${CONTAINER}/etc/proc/${i}:/proc/${i}@" ${PREFIX}/bin/start-wine64; fi done

#高级proot登录
case $PROOT in
PRO)
if [ -z $ANDROID_RUNTIME_ROOT ]; then
export ANDROID_RUNTIME_ROOT=/apex/com.android.runtime
fi

cat >>${HOME}/${CONTAINER}/etc/profile<<-EOF
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
sed -i '/=$/d' ${HOME}/${CONTAINER}/etc/profile
:<<\gcc
cd ${HOME}/${CONTAINER}
GCC=$(find -name libgcc_s.so.1 2>/dev/null | sed 's/.//')
if [ "$GCC" != "/" ]; then
echo $GCC >>${HOME}/${CONTAINER}/etc/ld.so.preload
chmod 644 "${HOME}/${CONTAINER}/etc/ld.so.preload"
fi
cd -
gcc
cat >${PREFIX}/bin/start-wine-arm64<<eof
#!/usr/bin/env bash
cd
pkill -9 pulseaudio 2>/dev/null
rm -rf ${PREFIX}/tmp/.* ${PREFIX}/tmp/*
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &
unset LD_PRELOAD
proot --kill-on-exit -b /vendor -b /system -b /sdcard -b /sdcard:/root/sdcard -b /data/data/com.termux/files -b /data/data/com.termux/cache -b /data/data/com.termux/files/usr/tmp:/tmp -b /dev/null:/proc/sys/kernel/cap_last_cap -b /data/dalvik-cache -b ${CONTAINER}/tmp:/dev/shm -b /proc/self/fd/2:/dev/stderr -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/0:/dev/stdin -b /proc/self/fd:/dev/fd -b /dev/urandom:/dev/random --sysvipc --link2symlink -S ${CONTAINER} -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=zh_CN.UTF-8 TZ=Asia/Shanghai TERM=xterm-256color USER=root /bin/bash --login
eof
for i in version misc buddyinfo kmsg consoles execdomains stat fb filesystems loadavg key-users uptime devices vmstat; do if [ ! -r /proc/"${i}" ]; then sed -E -i "s@(cap_last_cap)@\1 -b ${CONTAINER}/etc/proc/${i}:/proc/${i}@" ${PREFIX}/bin/start-wine-arm64; fi done
:<<\eof
if [ ! -r /proc/sys/vm/mmap_min_addr ]; then
mkdir -p .wine-arm64/etc/proc/sys/vm
echo 0 >${PREFIX}/${CONTAINER}/etc/proc/sys/vm/mmap_min_addr
sed -E -i "s@(cap_last_cap)@\1 -b ${CONTAINER}/etc/proc/sys/vm/mmap_min_addr:/proc/sys/vm/mmap_min_addr@" ${PREFIX}/bin/start-wine-arm64
fi
eof
for i in /system_ext /linkerconfig/ld.config.txt /plat_property_contexts /property_contexts /apex; do if [ -e $i ]; then sed -i "s@shm@shm \-b ${i}@" ${PREFIX}/bin/start-wine-arm64; fi done

#for i in /proc/$(ls ./etc/proc/|sed 's/ /\n/g'|grep -v bus); do i=$(echo $i|sed 's@/proc/@@'); if [ ! -r /proc/$i ]; then cp ./etc/proc/$i ${HOME}/${name}/etc/proc/ ;sed -i "s@shm@shm \-b ${HOME}/${name}/etc/proc/$i:/proc/$i@" ${PREFIX}/bin/start-${name}; fi done
#for i in ./etc/proc/* ; do if [ ! -r /proc/${i##*/} ]; then cp $i ${HOME}/${name}/etc/proc/ ;sed -i "s@shm@shm \-b ${HOME}/${name}/etc/proc/${i##*/}:/proc/${i##*/}@" ${PREFIX}/bin/start-${name}; fi done

#${HOME}/${CONTAINER}/usr/bin/ps

case $NOR_USER in
TRUE)
cp ${PREFIX}/bin/start-wine-arm64 ${PREFIX}/bin/start-$(whoami)
sed -i "s@/bin/bash --login@/bin/su -l $(whoami)@" ${PREFIX}/bin/start-$(whoami)
mkdir -p "${HOME}/${CONTAINER}/home/$(whoami)"
echo "$(id -un):x:$(id -u):$(id -g):Android user:/home/$(whoami):/bin/bash" >> "${HOME}/${CONTAINER}/etc/passwd"
echo "$(id -un):*:18446:0:99999:7:::" >> "${HOME}/${CONTAINER}/etc/shadow"

:<<\old
for g in $(id -G); do
echo "aid_$(id -gn "$g"):x:${g}:root,aid_$(id -un)" >> "${HOME}/${CONTAINER}/etc/group"
if [ -f "${CONTAINER}/etc/gshadow" ]; then
echo "aid_$(id -gn "$g"):*::root,aid_$(id -un)" >> "${HOME}/${CONTAINER}/etc/gshadow"
fi
done
old

#local group_name group_id
while read -r group_name group_id; do
echo "${group_name}:x:${group_id}:root,$(id -un)" >> ${HOME}/${CONTAINER}/etc/group
if [ -f "${CONTAINER}/etc/gshadow" ]; then
echo "${group_name}:*::root,$(id -un)" >> ${HOME}/${CONTAINER}/etc/gshadow
fi
done < <(paste <(id -Gn | tr ' ' '\n') <(id -G | tr ' ' '\n'))
esac

esac
echo "bash firstrun" >>${HOME}/${CONTAINER}/etc/profile
proot --help | grep -q sysvipc
if [ $? == 1 ]; then
sed -i 's/--sysvipc//' ${PREFIX}/bin/start-wine64 ${PREFIX}/bin/start-wine-arm64 ${PREFIX}/bin/start-$(whoami) 2>/dev/null
fi

chmod a+x ${PREFIX}/bin/start-wine64 ${PREFIX}/bin/start-wine-arm64 ${PREFIX}/bin/start-$(whoami) 2>/dev/null
case $PROOT in
PRO)
. ${PREFIX}/bin/start-wine-arm64
;;
*)
. ${PREFIX}/bin/start-wine64
esac
