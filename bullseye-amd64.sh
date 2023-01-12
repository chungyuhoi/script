#!/usr/bin/env bash
#apt-get install debian-archive-keyring
cd
#am start -a android.intent.action.VIEW -d https://www.baidu.com
#am start -n com.android.browser/com.android.browser.BrowserActivity
#am start -a android.intent.action.VIEW -d "content://com.android.externalstorage.documents/root/primary"

#容器安装方式 可选 lxc debootstrap(不可用)
ROOTFS=lxc

#容器架构 可选 amd64 i386
ARCH=amd64

#浏览器 可选 chromium firefox
BROWSER=none

#播放器 可选 vlc mpv
PLAYER=mpv

#图形界面 可选 xfce4 lxde mate
WM=xfce4
#sed -i 's/quick_exec=0/quick_exec=1/' /root/.config/libfm/libfm.conf

URL="https://mirrors.bfsu.edu.cn"
#URL="https://mirrors.tuna.tsinghua.edu.cn"
#URL="https://mirrors.ustc.edu.cn"
#URL="http://ftp.cn.debian.org/debian/"
DEB="main contrib non-free"
echo -e "\e[33m欢迎使用本脚本安装debian-bullseye\n\e[0m"
sleep 1
if [ $(uname -o) != Android ]; then echo -e "\e[33m仅适用于termux环境\e[0m";sleep 1; exit 0; fi

echo -e "\e[33m环境检测\e[0m"
sleep 2
pkg i -y $(for i in curl tar proot debootstrap pulseaudio; do if [ ! $(command -v $i) ]; then echo $i; fi done | sed 's/\n/ /g')
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

echo -e "\n\e[33m>>请选择拟模拟架构<<\e[0m\n\n1) amd64\n2) i386\n0) 退出"
read -r -p "请选择: " input
case $input in
2) ARCH=i386 ;;
0) exit 0 ;;
*) echo ""
esac

CONTAINER=".t_bullseye-${ARCH}"
ETC_DIR="${CONTAINER}/etc"
if [ -d ${HOME}/${CONTAINER} ]; then echo -e "\n检测已有相关文件夹，是否删除？\n\e[33m1)删除重装\n2)删除\n0)退出\e[0m\n"
read -r -p "请选择: " input
case $input in
	1) rm -rf ${HOME}/${CONTAINER} ;;
	2) rm -rvf ${HOME}/${CONTAINER} ${PREFIX}/bin/start-bullseye-${ARCH} /data/data/com.termux/files0 ${PREFIX}/bin/start-androiduser-${ARCH} && exit 0 ;;
	*) exit 0
esac
fi
:<<\eof
echo -e "\n\e[33m>>请选择拟安装的容器方式<<\e[0m\n\n1) 清华或北外镜像站LXC-Images\n2) debootstrap构建\n0) 退出"
read -r -p "请选择: " input
case $input in
2) ROOTFS=debootstrap ;;
0) exit 0 ;;
*) echo ""
esac
eof
:<<\eof
echo -e "\n\e[33m>>请选择浏览器<<\e[0m\n\n1) 谷歌浏览器\n2) 火狐浏览器\n9) 不安装\n0) 退出"
read -r -p "请选择: " input
case $input in
2) BROWSER=firefox ;;
9) BROWSER=none ;;
0) exit 0 ;;
*) echo ""
esac
eof
:<<\eof
echo -e "\n\e[33m>>请选择播放器<<\e[0m\n\n1) mpv\n2) vlc\n9) 不安装\n0) 退出"
read -r -p "请选择: " input
case $input in
2) PLAYER=vlc ;;
9) PLAYER=none ;;
0) exit 0 ;;
*) echo ""
esac
eof
:<<\eof
echo -e "\n\e[33m>>请选择桌面<<\e[0m\n\n1) xfce4\n2) lxde\n3) mate(建议用普通用户登录)\n0) 退出"
read -r -p "请选择: " input
case $input in
2) WM=lxde ;;
3) WM=mate ;;
0) exit 0 ;;
*) echo ""
esac
eof
echo -e "\n\e[33m即将下载系统,本脚本是进行全新安装,非恢复包\n即将检测最新容器版本\e[0m"
sleep 1

case $ROOTFS in
debootstrap)
debootstrap --no-check-gpg --arch=${ARCH} --include=passwd,locales,openssl,ca-certificates,libterm-readkey-perl,dialog,dbus,apt-utils,libterm-readkey-perl,netbase,perl,policy-rcd-declarative,policy-rcd-declarative-allow-all bullseye ${HOME}/${CONTAINER} ${URL}/debian
#rm -v ${HOME}/${CONTAINER}/usr/lib/tmpfiles.d/systemd.conf
echo '_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
pulse:x:106:113:PulseAudio daemon,,,:/var/run/pulse:/usr/sbin/nologin
systemd-network:x:101:102:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:102:103:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:103:104::/nonexistent:/usr/sbin/nologin
systemd-timesync:x:104:105:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin' >>${HOME}/${ETC_DIR}/passwd
echo -e "systemd-journal:x:101:\nsystemd-network:x:102:\nsystemd-resolve:x:103:\nmessagebus:x:104:\nsystemd-timesync:x:105:\ninput:x:106:\nkvm:x:107:\nrender:x:108:\nssh:x:109:" >>${HOME}/${ETC_DIR}/group
echo -e "systemd-journal:!::\nsystemd-network:!::\nsystemd-resolve:!::\nmessagebus:!::\nsystemd-timesync:!::\ninput:!::\nkvm:!::\nrender:!::\nssh:!::" >>${HOME}/${ETC_DIR}/gshadow
for i in _apt systemd-network systemd-resolve messagebus systemd-timesync; do sed -E -n "s/^root(:.*$)/$i\1/"p ${HOME}/${ETC_DIR}/shadow >>${HOME}/${ETC_DIR}/shadow; done
;;
*)
curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/${ARCH}/default/$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/${ARCH}/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
	if [ ! -f rootfs.tar.xz ]; then echo -e "\e[31m下载错误，请检查网络\e[0m"; sleep 1; exit 0; fi
mkdir ${HOME}/${CONTAINER}
tar xvf rootfs.tar.xz -C ${HOME}/${CONTAINER}
rm rootfs.tar.xz
esac

#for i in boot dev etc mnt opt proc run sys usr var; do if [[ ! -d ${HOME}/${CONTAINER}/$i ]]; then echo -e "\e[31m下载错误，请检查网络\e[0m"; sleep 1; exit 0; fi done

curl -o ${HOME}/${CONTAINER}/root/openssl.deb ${URL}/debian/pool/main/o/openssl/$(curl ${URL}/debian/pool/main/o/openssl/|grep openssl_1.*${ARCH}.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
curl -o ${HOME}/${CONTAINER}/root/ca-certificates.deb ${URL}/debian/pool/main/c/ca-certificates/$(curl ${URL}/debian/pool/main/c/ca-certificates/|grep all.deb|awk -F 'href="' '{print $2}'|cut -d '"' -f 1|tail -n 1)
mkdir -p /data/data/com.termux/files0/home
echo -e "\e[33m系统已下载,文件夹名为${CONTAINER}\e[0m"
sleep 2

#伪proc文件
PROC_DIR="${CONTAINER}/etc/proc"
mkdir ${HOME}/${PROC_DIR} -p
printf ' 52 memory_bandwidth! 53 network_throughput! 54 network_latency! 55 cpu_dma_latency! 56 xt_qtaguid! 57 vndbinder! 58 hwbinder! 59 binder! 60 ashmem!239 uhid!236 device-mapper!223 uinput!  1 psaux!200 tun!237 loop-control! 61 lightnvm!228 hpet!229 fuse!242 rfkill! 62 ion! 63 vga_arbiter\n' | sed 's/!/\n/g' >${HOME}/${PROC_DIR}/misc
printf "%-1s %-1s %-1s %8s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s\n" Node 0, zone DMA 3 2 2 4 3 3 2 1 2 2 0 Node 0, zone DMA32 1774 851 511 220 67 3 2 0 0 1 0 >${HOME}/${PROC_DIR}/buddyinfo
echo "0.03 0.03 0.00 1/116 17521" >${HOME}/${PROC_DIR}/loadavg
touch ${HOME}/${PROC_DIR}/kmsg
echo 'tty0                 -WU (EC p  )    4:7' >${HOME}/${PROC_DIR}/consoles
echo '0-0     Linux                   [kernel]' >${HOME}/${PROC_DIR}/execdomains
echo '0 EFI VGA' >${HOME}/${PROC_DIR}/fb
echo '    0:     9 8/8 3/1000000 27/25000000' >${HOME}/${PROC_DIR}/key-users
echo '285490.46 1021963.95' >${HOME}/${PROC_DIR}/uptime
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >${HOME}/${PROC_DIR}/version
touch ${HOME}/${PROC_DIR}/vmstat
echo 'Character devices:!  1 mem!  4 /dev/vc/0!  4 tty!  4 ttyS!  5 /dev/tty!  5 /dev/console!  5 /dev/ptmx!  7 vcs! 10 misc! 13 input! 21 sg! 29 fb! 81 video4linux!128 ptm!136 pts!180 usb!189 usb_device!202 cpu/msr!203 cpu/cpuid!212 DVB!244 hidraw!245 rpmb!246 usbmon!247 nvme!248 watchdog!249 ptp!250 pps!251 media!252 rtc!253 dax!254 gpiochip!!Block devices:!  1 ramdisk!  7 loop!  8 sd! 11 sr! 65 sd! 66 sd! 67 sd! 68 sd! 69 sd! 70 sd! 71 sd!128 sd!129 sd!130 sd!131 sd!132 sd!133 sd!134 sd!135 sd!179 mmc!253 device-mapper!254 virtblk!259 blkext' | sed 's/!/\n/g' >${HOME}/${PROC_DIR}/devices
echo "cpu  0 0 0 0 0 0 0 0 0 0
intr 1
ctxt 0
btime 0
processes 0
procs_running 1
procs_blocked 0
softirq 0 0 0 0 0 0 0 0 0 0 0" >${HOME}/${PROC_DIR}/stat
cpus=`cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1 | awk '{print $1}'`
if [ -n $cpus ]; then
while [[ $cpus -ne 1 ]]
do
cpus=$(( $cpus-1 ))
sed -i "1a cpu${cpus} 0 0 0 0 0 0 0 0 0 0" ${HOME}/${PROC_DIR}/stat
done
fi

rm ${HOME}/${ETC_DIR}/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >${HOME}/${ETC_DIR}/resolv.conf
echo "deb ${URL}/debian/ bullseye ${DEB}
deb ${URL}/debian/ bullseye-updates ${DEB}
deb ${URL}/debian/ bullseye-backports ${DEB}
deb ${URL}/debian-security bullseye-security ${DEB}" >${HOME}/${ETC_DIR}/apt/sources.list

cat >${HOME}/${PROC_DIR}/termux-change-repo<<-'EOF'
#!/usr/bin/env bash
echo -e "请选择镜像源
1) 清华大学
2) 北京外国语大学
3) 中国科学技术大学"
read -r -p "请选择: " input
case $input in
1)
URL="https://mirrors.tuna.tsinghua.edu.cn" ;;
2)
URL="https://mirrors.bfsu.edu.cn" ;;
3)
URL="https://mirrors.ustc.edu.cn" ;;
*)
exit 0
esac
DEB="main contrib non-free"
cat >/etc/apt/sources.list<<-eof
deb ${URL}/debian/ bullseye ${DEB}
deb ${URL}/debian/ bullseye-updates ${DEB}
deb ${URL}/debian/ bullseye-backports ${DEB}
deb ${URL}/debian-security bullseye-security ${DEB}
eof
apt update
EOF
chmod a+x ${HOME}/${PROC_DIR}/termux-change-repo
echo 'for i in /var/run/dbus/pid /tmp/.X*-lock /tmp/.X11-unix/X*; do if [[ -e "${i}" ]]; then rm -vf "${i}"; fi done' >>${HOME}/${ETC_DIR}/profile
sed -i '3i export MOZ_FAKE_NO_SANDBOX=1' ${HOME}/${ETC_DIR}/profile
#echo "service dbus start" >>${HOME}/${CONTAINER}/root/.bashrc


if [ -z $ANDROID_RUNTIME_ROOT ]; then
export ANDROID_RUNTIME_ROOT=/apex/com.android.runtime
fi

cat >>${HOME}/${ETC_DIR}/profile<<-EOF
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
sed -i '/=$/d' ${HOME}/${ETC_DIR}/profile
#添加termux用户
echo "$(id -un):x:$(id -u):$(id -g):Android user:/data/data/com.termux/files0/home:/bin/bash" >> "${HOME}/${CONTAINER}/etc/passwd"
echo "$(id -un):*:18446:0:99999:7:::" >> "${HOME}/${CONTAINER}/etc/shadow"
while read -r group_name group_id; do
echo "${group_name}:x:${group_id}:root,$(id -un)" >> ${HOME}/${ETC_DIR}/group
if [ -f "${CONTAINER}/etc/gshadow" ]; then
echo "${group_name}:*::root,$(id -un)" >> ${HOME}/${ETC_DIR}/gshadow
fi
done < <(paste <(id -Gn | tr ' ' '\n') <(id -G | tr ' ' '\n'))
:<<gcc
cd ${HOME}/${CONTAINER}
GCC=$(find -name libgcc_s.so.1 2>/dev/null | sed 's/^.//')
if [ -n $GCC ]; then
echo $GCC >>etc/ld.so.preload
chmod 644 etc/ld.so.preload
fi
cd -
gcc
cat >${HOME}/${CONTAINER}/root/firstrun<<-'eof'
#!/usr/bin/env bash
export LANG=C.UTF-8
cd
echo -e "\e[33m正在配置首次运行\n安装常用应用\e[0m"
sleep 1
#echo -e '#!/usr/bin/sh\nexit 0' >/usr/sbin/policy-rc.d
dpkg -i /var/cache/apt/archives/pass*.deb 2>/dev/null
if [ ! -f "/usr/bin/perl" ]; then
ln -sv /usr/bin/perl* /usr/bin/perl
fi
dpkg -l ca-certificates | grep ii
if [ $? == 1 ]; then
if [ -f ca-certificates.deb ] && [ -f openssl.deb ]; then
dpkg -i openssl.deb && dpkg -i ca-certificates.deb
else
sed -i "s/https/http/g" /etc/apt/sources.list
apt update
apt install ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list
fi
apt update
fi
case $ROOTFS in
debootstrap)
apt update && apt install libterm-readkey-perl dbus apt-utils dialog -y
#policy-rcd-declarative*
while [ ! $(command -v dbus-uuidgen) ]
do
apt --fix-broken install && apt install libterm-readkey-perl policy-rcd-declarative* dbus apt-utils dialog passwd -y
if [[ $i -eq 3 ]]; then
break
fi
i=$(( $i+1 ))
sleep 2
done
unset i
esac

if [ ! -f /var/lib/dbus/machine-id ]; then
dbus-uuidgen > /var/lib/dbus/machine-id
fi


DEPENDS="apt-utils sudo busybox locales curl elementary-icon-theme wget vim fonts-wqy-microhei tar lxtask dbus-x11 tigervnc-standalone-server tigervnc-viewer libtinfo5 ristretto python3 pulseaudio xserver-xorg x11-utils psmisc procps"

apt install -y && apt install $DEPENDS $WM $BROWSER $PLAYER --no-install-recommends -y
while [ ! $(command -v dbus-launch) ] || [ ! $(command -v tigervncserver) ] || [ ! $(command -v xfce4-session) ]
do
echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
apt --fix-broken install && apt install $DEPENDS $WM $BROWSER $PLAYER --no-install-recommends -y
if [[ $i -eq 3 ]]; then
break
fi
i=$(( $i+1 ))
sleep 2
done
unset i
echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
export USER="$(whoami)"
export PULSE_SERVER=127.0.0.1
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 1024x768 -once -depth 16 -localhost -securitytypes None :0 &
export DISPLAY=:0
. /etc/X11/xinit/Xsession 2>/dev/null &
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity
exit 0' >/usr/local/bin/easyvnc && chmod +x /usr/local/bin/easyvnc
mkdir -p /etc/X11/xinit 2>/dev/null
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
xfce4-session
else
startxfce4
fi' >/etc/X11/xinit/Xsession && chmod +x /etc/X11/xinit/Xsession

for i in /etc/xdg/autostart/lxpolkit.desktop /usr/bin/lxpolkit; do
if [ -f "${i}" ]; then
mv -f ${i} ${i}.bak 2>/dev/null
fi
done
mkdir -p /root/.config/libfm
mkdir -p /data/data/com.termux/files0/home/.config/libfm
echo -e '[config]\nquick_exec=1' >/root/.config/libfm/libfm.conf
echo -e '[config]\nquick_exec=1' >/data/data/com.termux/files0/home/.config/libfm/libfm.conf
ln -sf /usr/share/zoneinfo/Etc/GMT-8 /etc/localtime
sed -i "/zh_CN.UTF/s/#//" /etc/locale.gen
locale-gen
sed -i "/firstrun/d" /etc/profile
#处理部分不可用命令
echo -e "\e[33m优化部分命令\e[0m\n"
sleep 1
#mv lib/ld-musl-aarch64.so.1 /usr/lib
if [ $(command -v busybox) ]; then
for i in ps uptime killall egrep top ifconfig; do if [ $(command -v $i) ]; then ln -svf $(command -v busybox) $(command -v $i); else ln -svf $(command -v busybox) /usr/bin/$i; fi done
fi
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo
chmod 4711 /usr/bin/su
echo -e "\e[33m请设置root用户密码(输入内容不会反显)\e[0m\n"
passwd
echo -e "\e[33m请设置普通用户密码(输入内容不会反显)，用户名为$(grep 'Android user' /etc/passwd|cut -d ':' -f 1)\e[0m\n"
passwd $(grep 'Android user' /etc/passwd|cut -d ':' -f 1)
sed -i "/\%sudo/a $(grep 'Android user' /etc/passwd|cut -d ':' -f 1) ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers
cp /etc/skel/.profile /data/data/com.termux/files0/home
cp /etc/skel/.bashrc /data/data/com.termux/files0/home
echo -e "export LANG=zh_CN.UTF-8\nexport TZ=Asia/Shanghai" >>/data/data/com.termux/files0/home/.bashrc
#echo "sudo service dbus start" >>/data/data/com.termux/files0/home/.bashrc
echo 'chmod -R 1777 "/tmp/runtime-$(id -u)" 2>/dev/null' >>/data/data/com.termux/files0/home/.bashrc
echo 'printf "\n你当前的系统是 $(cat /etc/os-release | sed -n 1p | cut -d "=" -f 2)\ncpu架构 $(uname -m)\n"' >>/data/data/com.termux/files0/home/.bashrc
mkdir ${HOME}/Desktop ${HOME}/桌面 2>/dev/null
if [ $(command -v firefox-esr) ]; then
cp /usr/share/applications/firefox-esr.desktop ${HOME}/Desktop
fi
if [ $(command -v chromium) ]; then
if [ ! -d /run/shm ]; then
mkdir /run/shm
fi
sed -E -i 's/(^Exec=.* )/\1--no-sandbox /' /usr/share/applications/chromium.desktop
cp /usr/share/applications/chromium.desktop ${HOME}/Desktop
fi
if [ $(command -v vlc) ]; then
sed -i 's/geteuid/getppid/' /usr/bin/vlc
cp /usr/share/applications/vlc.desktop ${HOME}/Desktop
fi
if [ $(command -v mpv) ]; then
cp /usr/share/applications/mpv.desktop ${HOME}/Desktop
fi
cp ${HOME}/Desktop ${HOME}/桌面 -r
cp ${HOME}/Desktop /data/data/com.termux/files0/home -r
cp ${HOME}/桌面 /data/data/com.termux/files0/home -r
chmod a+x ${HOME}/Desktop ${HOME}/桌面 /data/data/com.termux/files0/home/Desktop /data/data/com.termux/files0/home/桌面 -R

if grep 'LANG=zh_CN' /root/.bashrc; then
echo "export LANG=zh_CN.UTF-8" >>/root/.bashrc
fi
echo -e "\e[33m清理缓存包\e[0m\n"
sleep 1
rm -rf openssl* ca-certificates* /var/cache/apt/archives/*.deb
echo -e "如果启动失败,请输\e[33mbash firstrun\e[0m重新初始化安装配置
登录容器请输\e[33mstart-bullseye-${ARCH}\e[0m
登录容器普通用户请输\e[33mstart-androiduser-${ARCH}\e[0m
打开vnc请输\e[33measyvnc\e[0m\nvnc viewer地址输127.0.0.1:0，免密登录。
容器的退出,在系统输exit即可
删除容器请输\e[33mstart-bullseye-${ARCH} --purge\e[0m"
read -r -p "按回车键继续" input
unset input
export MOZ_FAKE_NO_SANDBOX=1
export LANG=zh_CN.UTF-8
eof

echo 'printf "\n你当前使用的系统是 $(cat /etc/os-release | sed -n 1p | cut -d "=" -f 2)\ncpu架构 $(uname -m)\n"' >>${HOME}/${CONTAINER}/root/.bashrc


echo "配置qemu"
sleep 2
curl -o qemu.deb https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/$(curl https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/ | grep '\.deb' | grep 'qemu-user-static' | grep arm64 | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
mkdir qemu_temp
dpkg -X qemu.deb ./qemu_temp
case $ARCH in
	amd64)
		STATIC=qemu-x86_64-static ;;
	i386)
		STATIC=qemu-i386-static
esac
cp qemu_temp/usr/bin/${STATIC} ${CONTAINER}
echo "删除临时文件"
sleep 1
rm -rf qemu_temp qemu.deb

cat >${PREFIX}/bin/start-bullseye-${ARCH}<<eof
#!/usr/bin/env bash
cd
case \$1 in
	--purge) echo -e "是否删除容器？确认请输\e[33m y \e[0m回车，任意键退出"
	read -r -p "" input
	case \$input in
		Y|y) rm -rfv ${PREFIX}/bin/start-bullseye-${ARCH} /data/data/com.termux/files0 ${PREFIX}/bin/start-androiduser-${ARCH}
		rm -rf ${CONTAINER}
			if [ -d ${CONTAINER} ]; then
			echo -e "删除失败"
		else
		echo -e "已删除"
			fi
			sleep 1
				;;
		*) echo -e "操作取消"
	esac
	exit 0
esac
pkill -9 pulseaudio 2>/dev/null
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &
unset LD_PRELOAD
proot --kill-on-exit -b /vendor -b /system -b /sdcard -b /sdcard:/root/sdcard -b /data/data/com.termux/files -b /data/data/com.termux/files0/home -b /sdcard:/data/data/com.termux/files0/home/sdcard -b /data/data/com.termux/cache -b /data/data/com.termux/files/usr/tmp:/tmp -b /dev/null:/proc/sys/kernel/cap_last_cap -b ${HOME}/${CONTAINER}/etc/proc/termux-change-repo:/data/data/com.termux/files/usr/bin/termux-change-repo -b /data/dalvik-cache -b ${HOME}/${CONTAINER}/tmp:/dev/shm -b /proc/self/fd/2:/dev/stderr -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/0:/dev/stdin -b /proc/self/fd:/dev/fd -b /dev/urandom:/dev/random --link2symlink -S ${HOME}/${CONTAINER} -q ${CONTAINER}/${STATIC} -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=zh_CN.UTF-8 TZ=Asia/Shanghai TERM=xterm-256color USER=root /bin/bash --login
eof
for i in version misc buddyinfo kmsg consoles execdomains stat fb loadavg key-users uptime devices vmstat; do if [ ! -r /proc/"${i}" ]; then sed -E -i "s@(cap_last_cap)@\1 -b ${HOME}/${CONTAINER}/etc/proc/${i}:/proc/${i}@" ${PREFIX}/bin/start-bullseye-${ARCH}; fi done

if [ ! -r /etc/proc/bus/pci/devices ]; then
mkdir -p ${HOME}/${CONTAINER}/etc/proc/bus/pci
touch ${HOME}/${CONTAINER}/etc/proc/bus/pci/devices
sed -E -i "s@(cap_last_cap)@\1 -b ${HOME}/${CONTAINER}/etc/proc/bus/pci/devices:/proc/bus/pci/devices@" ${PREFIX}/bin/start-bullseye-${ARCH}
fi

#/system 存放的是rom的信息
#/system/app 存放rom本身附带的软件即系统软件
#/system/data 存放/system/app 中核心系统软件的数据文件信息。
#/data 存放的是用户的软件信息（非自带rom安装的软件）
#/data/app 存放用户安装的软件
#/data/data 存放所有软件（包括/system/app 和 /data/app 和 /mnt/asec中装的软件）的一些lib和xml文件等数据信息
#/data/dalvik-cache 存放程序的缓存文件，这里的文件都是可以删除的。

for i in /system_ext /linkerconfig/ld.config.txt /plat_property_contexts /property_contexts /apex; do if [ -e $i ]; then sed -i "s@shm@shm \-b ${i}@" ${PREFIX}/bin/start-bullseye-${ARCH}; fi done
cp ${PREFIX}/bin/start-bullseye-${ARCH} ${PREFIX}/bin/start-androiduser-${ARCH}
sed -i "s@/bin/bash --login@/bin/su -l $(whoami)@" ${PREFIX}/bin/start-androiduser-${ARCH}
chmod a+x ${PREFIX}/bin/start-bullseye-${ARCH} ${PREFIX}/bin/start-androiduser-${ARCH}
FIRSTRUN="${CONTAINER}/root/firstrun"
sed -i "2i CONTAINER=$CONTAINER" ${HOME}/$FIRSTRUN
case $BROWSER in
	firefox)
sed -i '2i BROWSER="firefox-esr firefox-esr-l10n-zh-cn"' ${HOME}/$FIRSTRUN
		;;
	none) unset BROWSER 
		;;
	*)
sed -i '2i BROWSER="chromium chromium-l10n"' ${HOME}/$FIRSTRUN
esac
case $PLAYER in
	vlc)
sed -i '2i PLAYER="vlc"' ${HOME}/$FIRSTRUN
		;;
	none) unset PLAYER
		;;
	*)
sed -i '2i PLAYER="mpv"' ${HOME}/$FIRSTRUN
esac
case $WM in
	lxde)
sed -i '2i WM="lxde-core lxterminal lxdm"' ${HOME}/$FIRSTRUN
sed -i "s/startxfce4/startlxde/g" ${HOME}/$FIRSTRUN
sed -i "s/xfce4-session/lxsession/g" ${HOME}/$FIRSTRUN
;;
	mate)
sed -i '2i WM="mate-desktop-environment mate-session-manager mate-settings-daemon marco mate-terminal mate-panel"' ${HOME}/$FIRSTRUN
sed -i "s/startxfce4/mate-panel/g" ${HOME}/$FIRSTRUN
sed -i "s/xfce4-session/mate-session/g" ${HOME}/$FIRSTRUN
;;
	*)
sed -i '2i WM="xfce4 xfce4-terminal xfce4-weather-plugin"' ${HOME}/${CONTAINER}/root/firstrun
esac
sed -i "2i ARCH=$ARCH" ${HOME}/${CONTAINER}/root/firstrun
echo -e "已创建root用户系统登录脚本,登录方式为\e[33mstart-bullseye-${ARCH}\e[0m\n"
sleep 2
echo "bash firstrun" >>${HOME}/${ETC_DIR}/profile
start-bullseye-${ARCH}
