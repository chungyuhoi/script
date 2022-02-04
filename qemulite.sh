#!/usr/bin/env bash
############
YELLOW="\e[33m"
RES="\e[0m"
STORAGE="/xinhao/windows/"
DIRECT="/sdcard"
URL="https://mirrors.tuna.tsinghua.edu.cn/"
############
#环境版本检测
	uname -a | grep 'Android' -q
	if [ $? == 1 ]; then
	if [ ! $(command -v qemu-system-x86_64) ]; then
	echo -e "${YELLOW}安装qemu${RES}"
	sleep 1
	apk update
	apk add bash qemu-system-x86_64 pulseaudio newt qemu-audio-pa --no-cache
	if grep -q '^sh qemulite.sh' /etc/profile; then
	sed -i '/qemulite.sh/s/^/ba/' /etc/profile
	fi
	whiptail --title "欢迎使用qemulite" --msgbox "你已安装 QEMU emulator version $(echo $(qemu-system-x86_64 --version) | awk '{print $4}')\n\n目录下的文件名切勿有空格，否则影响文件扫描\n\n手机目录下已创建/xinhao/windows文件夹，请把系统镜像放进这个目录里\n\n共享目录是/xinhao/share(目录内总文件大小不能超过500m)\n\n退出请输 exit" 0 0
	fi
	fi

############
############
#CPU检测
	if [ $(command -v bash) ]; then
	LO_CPU=$(cat  /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1)
	if [ $? = 0 ]; then
	if (( $LO_CPU <= 3000000 )) 2>/dev/null; then
		SMP=LOW_CPU
	else
		SMP=NORMAL_CPU
	fi
	fi
############
#内存检测
	mem=$(free -m | awk '{print $2/4}' | sed -n 2p | cut -d '.' -f 1)
	if (( $mem >= 2048 )) 2>/dev/null; then
		mem_=3072
	elif (( $mem >= 1536 )) 2>/dev/null; then
		mem_=2048
	elif (( $mem >= 1024 )) 2>/dev/null; then
		mem_=1536
	elif (( $mem >= 512 )) 2>/dev/null; then
		mem_=1024
	else
		mem_=512
	fi
	fi
############

#镜像目录文件检测
LIST() {
unset list
list=$(whiptail --title "选择镜像文件" --menu "请上下滑动选择\n\n*镜像名称不能有空格，否则启动失败" 0 0 0 \
$(ls "$DIRECT""$STORAGE" | sed 's/ //' | cat -n) \
3>&1 1>&2 2>&3)
if [ -n "$list" ]; then
	echo  -e ""
else
	echo  -e "${YELLOW}你已取消选择${RES}"
	sleep 1
	exit 1
fi
hda_name=`ls "$DIRECT""$STORAGE" | cat -n | grep -w "${list}" | awk '{print $2}' | sed -n 1p`
}
############
#配置选择
CHOICE() {
SELECT=$(whiptail  --title  "配置参数" --checklist "请滑动上下移动,空格键选择" 0 0 20 \
"max"           	"cpu" ON \
"core2duo"		"cpu" OFF \
"Cascadelake-Server"	"cpu" OFF \
"VGA"			"显卡" ON \
"vmware-svga"   	"显卡" OFF \
"AC97"			"声卡" ON \
"hda"			"声卡"  OFF \
"e1000"			"网卡" ON \
"virtio"		"网卡" OFF \
"ide"			"磁盘接口" ON \
"sata"			"磁盘接口" OFF \
3>&1  1>&2  2>&3)
if [ $? == 0 ]; then
        echo  -e ""
else
	echo  -e "${YELLOW}你已取消选择${RES}"
	sleep 1
	exit 0
fi
}
############
#自动配置
SET() {
	echo ""
}
############
#开始模拟
START() {
export PULSE_SERVER=tcp:127.0.0.1:4713
set -- "${@}" "qemu-system-x86_64"
set -- "${@}" "-machine" "pc,vmport=off,kernel-irqchip=off,dump-guest-core=off,mem-merge=off,usb=on"
if [ -n "${mem_}" ]; then
set -- "${@}" "-m" "${mem_}"
else
set -- "${@}" "-m" "1024"
fi
set -- "${@}" "--accel" "tcg,thread=multi"
#CPU
case $SELECT in
	*Cascadelake*) 
		set -- "${@}" "-cpu" "Cascadelake-Server"
		set -- "${@}" "-smp" "4,cores=2,threads=2,sockets=1" ;;
	*core2duo*) 
		set -- "${@}" "-cpu" "core2duo"
		set -- "${@}" "-smp" "2,cores=2,threads=1,sockets=1" ;;
	*)
		set -- "${@}" "-cpu" "max"
		case $SMP in
		LOW_CPU)
		set -- "${@}" "-smp" "2,cores=2" ;;
		*)
		set -- "${@}" "-smp" "4,cores=4" ;;
		esac
esac

#显卡
case $SELECT in
	*vmware-svga*)
		set -- "${@}" "-device" "vmware-svga,vgamem_mb=256,x-pcie-lnksta-dllla=off" ;;
	*) 
		set -- "${@}" "-device" "VGA,vgamem_mb=256,edid=off,x-pcie-lnksta-dllla=off" ;;
esac

#声卡
case $SELECT in
	*AC97*)
		set -- "${@}" "-device" "AC97,audiodev=pa" ;;
	*)
		set -- "${@}" "-device" "intel-hda" "-device" "hda-duplex,audiodev=pa" ;;
esac
	set -- "${@}" "-audiodev" "pa,server=127.0.0.1:4713,id=pa,in.channels=2,in.frequency=44100,out.buffer-length=5124,in.format=s16"

#网卡
case $SELECT in
	*virtio-net-pci*)
		set -- "${@}" "-device" "virtio-net-pci,netdev=user" ;;
	*) 
		set -- "${@}" "-device" "e1000,netdev=user" ;;
esac
set -- "${@}" "-netdev" "user,ipv6=off,id=user"

#硬盘
case $SELECT in
	*sata*)
		set -- "${@}" "-drive" "file=${DIRECT}${STORAGE}${hda_name},if=none,id=disk"
		set -- "${@}" "-device" "ahci,id=ahci"
		set -- "${@}" "-device" "ide-hd,drive=disk,bus=ahci.0"
		set -- "${@}" "-global" "ide-hd.physical_block_size=1024"
		set -- "${@}" "-drive" "if=none,format=raw,id=disk1,file=fat:rw:${DIRECT}/xinhao/share/"
		set -- "${@}" "-device" "usb-storage,drive=disk1" ;;
	*)
		set -- "${@}" "-drive" "file=${DIRECT}${STORAGE}${hda_name},if=ide,index=0,media=disk"
		set -- "${@}" "-drive" "file=fat:rw:${DIRECT}/xinhao/share,if=ide,index=1,media=disk,format=raw" ;;
esac

set -- "${@}" "-boot" "menu=on,strict=off"
set -- "${@}" "-device" "usb-tablet"
set -- "${@}" "-nodefaults"
set -- "${@}" "-no-user-config"
set -- "${@}" "-msg" "timestamp=off"
set -- "${@}" "-rtc" "base=localtime"
set -- "${@}" "-display" "vnc=127.0.0.1:0,lossy=on,non-adaptive=on"
echo "${@}"
echo -e "${YELLOW}启动模拟器，请打开vncviewer输ip地址127.0.0.1:0${RES}"
"${@}" 2>${HOME}/.err_log
if [ $? == 1 ]; then
	echo -e "\n${YELLOW}启动失败( ﾟ∀ ﾟ)${RES}"
	cat ${HOME}/.err_log
	sleep 1
fi

}
#################
#下载容器
TERMUX(){
	case $(dpkg --print-architecture) in
		arm*|aarch64) echo "" ;;
		*) echo -e "${YELLOW}仅支持arm64架构${RES}"
			sleep 2
			exit
	esac
	if [ -d "${HOME}/qemu_alpine" ]; then
pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S ${HOME}/qemu_alpine --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b ${HOME}/qemu_alpine/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=xterm-256color USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 TZ=UTC-8 /bin/sh --login
	else
	echo -e "${YELLOW}将下载容器${RES}"
	sleep 1
	if [ ! -d "$DIRECT""$STORAGE" ]; then
	termux-setup-storage
	mkdir -p "$DIRECT""$STORAGE"
	mkdir -p "$DIRECT"/xinhao/share
	fi
VERSION=`curl -s ${URL}lxc-images/images/alpine/ | awk -F 'title="' '{print $2}' | cut -d '"' -f 1 | grep -v edge | sort -r | sed -n 4p`
curl -o rootfs.tar.xz ${URL}lxc-images/images/alpine/${VERSION}/arm64/default/$(curl ${URL}lxc-images/images/alpine/${VERSION}/arm64/default/ | grep link | awk -F 'href="' '{print $2}' | awk -F '" title' '{print $1}' | tail -1)rootfs.tar.xz
mkdir ${HOME}/qemu_alpine
tar Jxvf rootfs.tar.xz -C ${HOME}/qemu_alpine
echo "${URL}alpine/edge/main
${URL}alpine/edge/community
${URL}alpine/edge/testing" >${HOME}/qemu_alpine/etc/apk/repositories
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >${HOME}/qemu_alpine/etc/resolv.conf
curl https://cdn.jsdelivr.net/gh/chungyuhoi/script/qemulite.sh -o ${HOME}/qemu_alpine/root/
echo 'sh qemulite.sh' >>${HOME}/qemu_alpine/etc/profile
rm rootfs.tar.xz
	echo -e "${YELLOW}容器已下载，正在登录系统${RES}"
	sleep 2	
	TERMUX
	fi
}
##############
MAIN1() {
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
	TERMUX
else
list=$(whiptail --title "欢迎使用qemulite" --menu "请选择" 0 0 0 \
"1" "快速启动" \
"2" "自定义参数" \
3>&1 1>&2 2>&3) 
exitstatus=$?
[[ "$exitstatus" = 1 ]] && exit
case $list in
	1) 
		LIST
		SET
		START ;;
	2)
		LIST
		CHOICE
		START ;;
esac
	fi
}
###############
MAIN() {                                                             uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
		TERMUX
	else
		LIST
		CHOICE
		START
	fi
}
MAIN "$@"
