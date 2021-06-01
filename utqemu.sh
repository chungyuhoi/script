#!/data/data/com.termux/files/usr/bin/bash
cd $(dirname $0)
####################
INFO() {
#clear
echo -e "\n\e[33m更新日期2021.5.31 更新内容\e[0m
	为简化操作，增加快速启动选项体验，使用常用配置参数，声卡winxp为ac97，win7为hda，网卡e1000，显卡winxp为cirrus，win7为VGA，vnc输出
	应用维护项加入最新aspice安卓版下载地址
	简化参数内容
	取消tcg缓存设置与usb-audio选项(相关参数在qemu6.0被取消)	
	qemu5.0版本的声卡选项增加ac97与hda修改参数项，该选项参数做了调整，如果声音不流畅可尝试该选项
	将qxl显卡选项下的spice传输协议移到spice视频输出选项下(该选项参数需模拟系统安装virtio驱动，能解决win7声音卡顿问题)
	增加qemu5.0以下版本与5.0相同的一些选项
	增加qemu5.0以下旧版容器下载，winxp推荐此版本
	取消默认加载共享文件夹，可在进阶选项中选择加载
	增加独立系统(容器)支持多架构下载，由原来的arm64,aarch64增加amd64,i386,armhf,armel等架构，新增架构目前只测试过i386，其他架构有待验证
	简化磁盘接口virtio驱动安装模式，无需创建加载分区，默认为共享文件夹
	增加了一些未经完全测试通过的参数配置
	修改了一些细节\n"
}
###################
NOTE() {
#clear
echo -e "\n\e[33m注意事项\e[0m
	本脚本是方便大家简易配置，所有参数都是经多次测试通过，可运行大部分系统，由于兼容问题，性能不作保证，专业玩家请自行操作。
	qemu5.0前后版本选项参数区别不大，主要在于新版本比旧版多了些旧版本没有的参数。
	如果模拟效率不佳，请尝试大退到termux主界面，并清设备后台，然后重新启动模拟。
	xp玩经典游戏(如星际争霸，帝国时代)需使用cirrus显卡才能运行
	模拟效率，因手机而异，我用的是华为手机，termux(utermux)在后台容易被停或降低效率。通过分屏模拟的效果是aspice>vnc>xsdl，win8听歌流畅。
	q35主板与sata，virtio硬盘接口由于系统原因，可能导致启动不成功。
	声音输出（不支持termux与utermux环境，pc建议ac97，q35建议hda）。
	sdl输出显示，源地址并未编译qemu的sdl，这里只是通过信号输出，需先开启xsdl(不支持termux与utermux环境）。
	qemu5.0以下模拟xp较好，qemu5.0以上对win7以上模拟较好。\n"
	if [ $(command -v qemu-system-x86_64) ]; then
		echo -e "\e[33m检测到你已安装qemu-system-x86，版本是\e[0m"
echo -e "\e[32m$(qemu-system-x86_64 --version | head -n 1)\e[0m"
else
	echo -e "\e[1;31m检测到你未安装qemu-system-x86，请先选择安装\e[0m"
	fi
}
###################
ABOUT_UTQEMU(){
	clear
printf "%s
${YELLOW}关于utqemu脚本${RES}
	最初是为utermux写下的qemu-system-x86脚本，目的是增加utermux可选功能，给使用者提供简易快捷的启动，我是业余爱好者，给使用者提供简易快捷的启动。非专业人士，所以内容比较乱，请勿吐槽。为适配常用镜像格式，脚本的参数选用是比较常用。业余的我，专业的参数配置并不懂，脚本参数都是来自官方网站、百度与群友。qemu5.0以上的版本较旧版本变化比较大，所以5.0后的参数选项比较丰富，欢迎群友体验使用。\n"
CONFIRM
QEMU_SYSTEM	
}
ABOUT_VIRTIO(){
clear
printf "%s
${YELLOW}关于virtio驱动${RES}
	引用官方说法：QEMU为用户提供并行虚拟化块设备和网络设备的能力，其是借助virtio驱动实现的，拥有更好的性能表现以及更低的开销。

${YELLOW}virtio驱动的安装${RES}
	需下载好virtio驱动光盘，virtio磁盘接口安装程序比较多，其他驱动与普通的硬件驱动一样安装，本脚本已加入qxl显卡，virtio显卡，virtio网卡，virtio磁盘选项。

${YELLOW}关于virtio显卡3D加速${RES}
	virtio显卡因参数问题，未发挥其特性功能。3D模式需在gtk或sdl下才能开启，sdl模块在系统源默认是未编译。gtk则可在图形界面中启动。经过多次测试，作出的参数配置如下。当你选择virtio显卡中的3D模式时，vnc，sdl，spice输出端口不再有效，但仍会按你的上述选择作出以下配置。sdl将以-display sdl,gl=on输出（因系统的qemu源默认未编译sdl内容，所以选项未得到测试验证）。而spice则以wiki上的标准参数-display gtk,gl=on输出，但virtio显卡并不被识别。vnc除了spice上的参数外，我还加入了-vga qxl来兼容virtio显卡输出（我成功在图形界面中开启gl，但存在bug）。这个3D模式应该是在linux系统下加载，而非windows系统。

${YELLOW}系统镜像的磁盘驱动安装介绍：${RES}
	1)先创建一个新的磁盘镜像，用于搜索virtio驱动，参数如下
qemu-img create -f qcow2 fake.qcow2 1G
	2)挂载fake磁盘（处于virtio模式下），带有驱动的CD-ROM，运行原本的Windows客户机（boot磁盘依旧是处于IDE模式中），参数如下
qemu-system-x86_64 -m 4G -drive file=系统镜像,if=ide -drive file=fake.qcow2,if=virtio -cdrom virtio驱动.iso
	3)开机Windows会自动检测fake磁盘，并搜索适配的驱动。如果失败了，前往Device Manager，找到SCSI驱动器（带有感叹号图标，应处于打开状态），点击Update driver并选择虚拟的CD-ROM。不要定位到CD-ROM内的文件夹了，只选择CD-ROM设备就行，Windows会自动找到合适的驱动的。
	4)关机并重新启动它，现在可以以virtio模式挂载boot磁盘
qemu-system-x86_64 -m 4G -drive file=系统镜像,if=virtio

"
CONFIRM
VIRTIO
}
####################

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
PINK="\e[35m"
WHITE="\e[37m"
RES="\e[0m"
####################
`ip a | grep 192 | cut -d " " -f 6 | cut -d "/" -f 1` 2>/dev/null
if [ $? != 0 ]; then
	IP=$(ip a | grep 192 | cut -d " " -f 6 | cut -d "/" -f 1)
else
	`ip a | grep inet | grep rmnet | cut -d "/" -f 1 | cut -d " " -f 6` 2>/dev/null
	if [ $? -ne 0 ]; then
		IP=$(ip a | grep inet | grep rmnet | cut -d "/" -f 1 | cut -d " " -f 6)
	else
		IP=$(ip a | grep inet | grep wlan | cut -d "/" -f 1 | cut -d " " -f 6)
	fi
fi
####################
if [ `whoami` != "root" ];then
	sudo="sudo"
else
	sudo=""
fi
####################
INVALID_INPUT() {
	echo -e "\n${RED}重入无效，请重新输入${RES}" \\n
	sleep 1
}
#####################
CONFIRM() {
	read -r -p "按回车键继续" input
	case $input in
		*) ;; esac
		}
####################
ARCH_CHECK() {
	case $(dpkg --print-architecture) in
		arm*|aarch64) DIRECT="/sdcard"
			ARCH=tablet ;;
		i*86|x86*|amd64)
		       if grep -E -q 'tablet|computer' ${HOME}/.utqemu_ 2>/dev/null; then	
	case $(cat ${HOME}/.utqemu_) in
		tablet) DIRECT="/sdcard"
			ARCH=tablet ;;
		computer) DIRECT="${HOME}"
			ARCH=computer ;;
	esac
elif
	grep -E -q 'Z3560|Z5800|Z2580' "/proc/cpuinfo" 2>/dev/null; then
	read -r -p "请确认你使用的是否手机平板 1)是 2)否 " input
	case $input in
		1) echo "tablet" >${HOME}/.utqemu_
			DIRECT="/sdcard"
			ARCH=tablet
			echo -e "${GREEN}已配置设备识别参数，请重新打开脚本，如发现选错，请在相关应用维护选项中修改${RES}"
        CONFIRM ;;
		2) echo "computer" >${HOME}/.utqemu_
			DIRECT="${HOME}"
			ARCH=computer
			echo -e "${GREEN}已配置设备识别参数，请重新打开脚本，如发现选错，请在相关应用维护选项中修改${RES}"
        CONFIRM ;;
		*) INVALID_INPUT
			ARCH_CHECK ;;
	esac
else
			DIRECT="${HOME}"
			ARCH=computer
			fi ;;
		*) echo -e "${RED}不支持你设备的架构${RES}" ;;
esac
}
####################
####################
QEMU_VERSION(){
uname -a | grep 'Android' -q
        if [ $? == 0 ]; then
                SYS=ANDROID
	elif [ ! $(command -v qemu-system-x86_64) ]; then
		echo ""
        elif [[ $(qemu-system-x86_64 --version) =~ :[5-9] ]] ; then
                        SYS=QEMU_ADV
                else
                        SYS=QEMU_PRE
        fi
}
#################
LOGIN() {
	if [ -n $DEBIAN ]; then
		echo ""
	else
	echo -e "\n${YELLOW}请选择拟登录的系统${RES}
	1) 5.0以下版本
	2）5.0以上版本"
	read -r -p "请选择: " input
	case $input in
		1) DEBIAN=buster ;;
		2) DEBIAN=bullseye ;;
	esac
	fi
pulseaudio --start & 2>/dev/null
echo "" &
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
command+=" --link2symlink"
command+=" -S $DEBIAN-qemu"
command+=" -b /sdcard"
command+=" -b $DEBIAN-qemu/root:/dev/shm"
command+=" -b /sdcard:/root/sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" USER=root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=xterm-256color"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="$@"
if [ -z "$1" ];then
    exec $command
else
    $command -c "$com"
fi
}
##################
SYS_DOWN() {
	echo -e "${YELLOW}即将下载系统(约占500m空间)${RES}"
	sleep 2
case $(dpkg --print-architecture) in
	arm64|aarch*)
                DEF_CUR="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/$DEBIAN/arm64/default/" ;;
	x86_64|amd64)
		DEF_CUR="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/$DEBIAN/amd64/default/" ;;
	i*86|x86)
		DEF_CUR="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/$DEBIAN/i386/default/" ;;
	armv7*|armv8l)
		DEF_CUR="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/$DEBIAN/armhf/default/" ;;
	armv6*|armv5*)
		DEF_CUR="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/$DEBIAN/armel/default/" ;;
		esac
		BAGNAME="rootfs.tar.xz"
        if [ -e ${BAGNAME} ]; then
                rm -rf ${BAGNAME}
        fi
        curl -o ${BAGNAME} ${DEF_CUR}
                VERSION=`cat ${BAGNAME} | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1`
                curl -o ${BAGNAME} ${DEF_CUR}${VERSION}${BAGNAME}
                if [ $? -ne 0 ]; then
                        echo -e "${RED}下载失败，请重输${RES}\n" && MAIN
                fi
                if [ -e $sys_name ]; then
                        rm -rf $sys_name
                fi
                mkdir $sys_name
#tar xvf rootfs.tar.xz -C ${BAGNAME}
echo -e "${BLUE}正在解压系统包${RES}"
                tar xf ${BAGNAME} --checkpoint=100 --checkpoint-action=dot --totals -C $sys_name 2>/dev/null
                rm ${BAGNAME}
                echo -e "${BLUE}$sys_name系统已下载，文件夹名为$sys_name${RES}"
        echo "127.0.0.1 localhost" > $sys_name/etc/hosts
        rm -rf $sys_name/etc/resolv.conf &&
        echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >$sys_name/etc/resolv.conf
        echo "export  TZ='Asia/Shanghai'" >> $sys_name/root/.bashrc
	case $DEBIAN in
		bullseye) echo "deb http://mirrors.ustc.edu.cn/debian sid main contrib non-free" >$sys_name/etc/apt/sources.list ;;
		buster) echo "deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free
deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free" >$sys_name/etc/apt/sources.list ;;
esac
	cat >/dev/null <<EOF
echo 'deb http://mirrors.bfsu.edu.cn/debian/ bullseye main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian/ bullseye-updates main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian/ bullseye-backports main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian-security bullseye-security main contrib non-free' >$sys_name/etc/apt/sources.list
EOF
if [ ! -e ./utqemu.sh ]; then
curl -O http://shell.eacgh.cn/utqemu.sh 2>/dev/null
fi
cp utqemu.sh $sys_name/root/utqemu.sh
sed -i "s/qemu-system-x86-64-headless/qemu-system-x86 xserver-xorg x11-utils/" $sys_name/root/utqemu.sh
sed -i 's/qemu-system-i386-headless/-y \&\& apt --reinstall install pulseaudio/' $sys_name/root/utqemu.sh
#echo "bash utqemu.sh" >>$sys_name/etc/profile
echo "bash utqemu.sh" >>$sys_name/root/.bashrc
echo -e "${YELLOW}系统已下载，请登录系统继续完成qemu的安装${RES}"
sleep 2
}
##################

#####################
#####################
SYSTEM_CHECK() {
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
		if [ ! -e ${HOME}/storage ]; then
			termux-setup-storage
		fi
		grep -E -q 'bfsu|tsinghua|ustc|tencent|utqemucheck' ${PREFIX}/etc/apt/sources.list              
		if [ $? != 0 ]; then  
			echo -e "${YELLOW}检测到你使用的可能为非国内源，为保证正常使用，建议切换为国内源(0.73版termux勿更换)${RES}\n  
			1) 换国内源    
			2) 不换"   
			read -r -p "是否换国内源: " input   
			case $input in    
				1|"") echo "换国内源" 
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list 
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list 
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list && pkg update -n ;;  
*) echo "#utqemucheck" >>${PREFIX}/etc/apt/sources.list
	MAIN ;;  
esac                                                    
		fi
	dpkg -l | grep pulseaudio -q 2>/dev/null
if [ $? != 0 ]; then
	echo -e "${YELLOW}检测到你未安装pulseaudio，为保证声音正常输出，将自动安装${RES}"
	sleep 2
	apt update && apt install pulseaudio -y
fi
if grep -q "anonymous" ${PREFIX}/etc/pulse/default.pa ;
then
        echo ""
else
        echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
                                fi
if grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf ; then
sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf
fi
if [ ! $(command -v proot) ]; then
	apt update && apt install proot -y
fi
	fi
}
##################
WEB_SERVER() {
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
		if [ ! $(command -v python) ]; then
			echo -e "\n检测到你未安装所需要的包python,将先为你安装上"
			apt update && apt install python -y
		fi
		else
if [ ! $(command -v python3) ]; then
                echo -e "\n检测到你未安装所需要的包python,将先为你安装上"
                sleep 2
                apt update && $sudo apt install python3 python3-pip -y && mkdir -p /root/.config/pip && echo "[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >/root/.config/pip/pip.conf
        fi
		fi
        echo -e "已完成配置，请尝试用浏览器打开并输入地址\n
        ${YELLOW}http://$IP:8080${RES}\n
        如需关闭，请按ctrl+c，然后输pkill python3或直接exit退出shell\n"
        python3 -m http.server 8080 &
        sleep 2
}

##################
QEMU_ETC() {

	echo -e "\n1) 创建空磁盘(目前支持qcow2,vmdk)
2) 转换镜像磁盘格式(仅支持qcow2,vmdk,其他格式未验证)
3) 修改设备标识(手机、平板、电脑)
4) 修改源(只适用本脚本下载的系统)
5) 安装aqemu(适用于图形界面中操作的qemu皮肤)
6) 获取aspice安卓版下载地址(非永久有效)
7) 模拟系统的时间不准
9) 返回
0) 退出\n"
	read -r -p "请选择: " input
	case $input in
		1) if [ ! $(command -v qemu-img) ]; then
			apt update && apt install qemu-img
		fi
			echo -e "\n对于普通玩家这两个格式没什么区别，不用纠结"
			read -r -p "请选择格式 1)qcow2 2)vmdk : " input
			case $input in
				1|"") echo -e "${YELLOW}qcow2${RES}"
					FORMAT=qcow2	;;
				2) echo -e "${YELLOW}vmdk${RES}"
					FORMAT=vmdk ;;
				*) INVALID_INPUT
					QEMU_ETC ;;
			esac
			sleep 1
			while [ ! -n "$disk_name" ]
			do
				echo -e -n "\n请为磁盘起个名字(不能为空): "
	read disk_name
done
echo -n "请输入你拟创建的磁盘容量，以G为单位(例如4g则输4): "
	read capacity
	qemu-img create -f $FORMAT ${DIRECT}/xinhao/windows/${disk_name}.$FORMAT ${capacity}G
	if [ -f ${DIRECT}/xinhao/windows/${disk_name}.$FORMAT ]; then
	echo -e "${GREEN}已为你创建$FORMAT格式磁盘${disk_name}.$FORMAT 容量${capacity}G，仍需你登录系统，在控制面板通过磁盘管理进行格式化并分区方可正常使用${RES}"
else
	echo -e "${RED}创建失败，请重试${RES}"
	fi
	CONFIRM ;;
2) if [ ! $(command -v qemu-img) ]; then
	apt update && apt install qemu-img
fi
	echo ""
	read -r -p "请选择转换后格式 1)qcow2 2)vmdk : " input
	case $input in
	1) echo -e "转换为${YELLOW}qcow2${RES}格式"
		FORMAT=qcow2 ;;
	2) echo -e "转换为${YELLOW}vmdk${RES}格式"
		FORMAT=vmdk ;;
	*) INVALID_INPUT
		QEMU_ETC ;;
esac
echo -e "\n已为你列出镜像文件夹中的文件（仅供参考）\n"
ls ${DIRECT}/xinhao/windows
sleep 1
	while ( [ "$FORMAT_" != '0' ] && [ ! -f "${DIRECT}/xinhao/windows/$FORMAT_" ] ) 
do
	if [ -n "$FORMAT_" ]; then
		echo -e "\n${RED}未匹配到镜像，请重试${RES}"
		sleep 1
		fi
		echo -en "\n请输入原镜像格式全名(例如andows.img) ,退出请输${YELLOW}0${RES} "
		read  FORMAT_
	done
	if [ $FORMAT_ == '0' ]; then
		exit 0
	fi
	if [ -f ${DIRECT}/xinhao/windows/${FORMAT_%%.*}.$FORMAT ]; then
		echo -e "\n${RED}检测到目录下已有转换后同名文件名，请确认，以免造成误操作${RES}"
		read -r -p "1)继续 9)返回 0)退出 " input
		case $input in
			1) ;;
			0) exit 0 ;;
			*) unset FORMAT_
				unset FORMAT
				QEMU_ETC ;;
		esac
		fi
	echo -e "\e[33m转换过程需要点时间，请耐心等待...${RES}"
	case "${FORMAT_##*.}" in
		img) qemu-img convert -f raw -O $FORMAT ${DIRECT}/xinhao/windows/$FORMAT_ ${DIRECT}/xinhao/windows/${FORMAT_%%.*}.$FORMAT ;;
		*) qemu-img convert -f "${FORMAT_##*.}" ${DIRECT}/xinhao/windows/$FORMAT_ -O $FORMAT ${DIRECT}/xinhao/windows/${FORMAT_%%.*}.$FORMAT ;;
	esac
	if [ -f ${DIRECT}/xinhao/windows/${FORMAT_%%.*}.$FORMAT ]; then
		echo -e "\n${GREEN}已转换，${FORMAT_%%.*}.$FORMAT${RES}\n"
	else
		echo -e "\n${RED}转换失败${RES}\n"
	fi
		sleep 1 ;;
3) read -r -p "1)手机平板 2)电脑 " input
	case $input in
		1) echo "tablet" >${HOME}/.utqemu_
		       echo -e "${GREEN}已修改，请重新登录脚本${RES}"
	       sleep 1 ;;
		2) echo "computer" >${HOME}/.utqemu_
		       echo -e "${GREEN}已修改，请重新登录脚本${RES}"
	       sleep 1 ;;
		*) INVALID_INPUT
			sleep 2
			QEMU_ETC ;;
	esac ;;
4) if ! grep -E -q 'buster|bullseye/sid' "/etc/os-release"; then
	echo -e "\n${RED}只支持bullseye与buster${RES}\n"
sleep 2
QEMU_ETC
else
	read -r -p "1)中科源 2)北外源 9)返回主目录 0)退出 " input
	case $input in
		1) if grep -q 'bullseye' /etc/os-release ;then
			echo "deb http://mirrors.ustc.edu.cn/debian sid main contrib non-free" >/etc/apt/sources.list
		elif grep -q 'buster' /etc/os-release ;then
			echo "deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free
deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free" >/etc/apt/sources.list
		fi
		apt update ;;
		2) if grep -q 'bullseye/sid' /etc/os-release ;then
			echo 'deb http://mirrors.bfsu.edu.cn/debian/ bullseye main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian/ bullseye-updates main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian/ bullseye-backports main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian-security bullseye-security main contrib non-free' >/etc/apt/sources.list
elif grep -q 'buster' /etc/os-release ;then
	echo "deb http://mirrors.bfsu.edu.cn/debian buster main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian buster-updates main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian buster-backports main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian-security buster/updates main contrib non-free" >/etc/apt/sources.list
fi
	apt update ;;
		9) QEMU_SYSTEM ;;
		0) exit 1 ;;
		*) INVALID_INPUT && QEMU_ETC ;;
esac
fi ;;
5) echo -e "${GREEN}aqemu是qemu的前端，适用于图形界面下简易配置操作qemu，安装完aqemu，首次启动时请搜索并绑定qemu-system-x86_64${RES}"
	CONFIRM
	apt update && $sudo apt install aqemu -y
	if [ ! $(command -v aqemu ) ]; then
		echo -e "${RED}安装失败，请重试${RES}"
		sleep 1
		fi
		;;
		9) unset FORMAT_
			unset FORMAT
			QEMU_SYSTEM ;;
		0) exit 1 ;;
6) if [ ! $(command -v curl) ]; then
	echo -e "${YELLOW}检测到你未安装需要的应用curl，将为你先安装curl${RES}"
	sleep 2
	apt update && apt install curl -y
fi
	echo -e "\n${YELLOW}下载的地址来自spice的作者最新版，由于Github速度非常有限，所以这边只提供下载地址，请复制到其他方式下载，如获取失败，请重试${RES}\n"
	CONFIRM
	unset CURL
	unset CURL_
	while ( [ "$CURL" != '0' ] && [[ ! $CURL_ =~ apk ]] )
do
	CURL=`curl --connect-timeout 5 -m 8 -s https://github.com/iiordanov/remote-desktop-clients | grep tag\/ | cut -d '"' -f 4 | cut -d '"' -f 2 `
CURL_=`curl --connect-timeout 5 -m 8 https://github.com$CURL | grep SPICE | grep apk | tail -n 1 | cut -d '>' -f 2 | cut -d '<' -f 1`
if [[ ! $CURL_ =~ apk ]]; then
read -r -p "获取失败，重试请回车，退出请输0 " input
case $input in
	0) QEMU_ETC ;;
	*) ;;
esac
fi
done
echo -e "\n下载地址\n${GREEN}https://github.com/iiordanov/remote-desktop-clients/releases/download/v5.0.4/$CURL_${RES}\n"
CONFIRM
QEMU_ETC ;;
7) echo -e "\n通常情况下，参数rtc可以解决，但可能由于容器时区问题导致，可通过修改时区来解决\n"
	read -r -p "1)修改时区 0)返回 " input
	case $input in
		1)
sed -i "/^export TZ=/d" /etc/profile
sed -i "1i\export TZ='Asia/Shanghai'" /etc/profile
	echo -e "\n${GREEN}请退出容器返回termux主界面，再重新进入${RES}\n"
	sleep 2 ;;
*) ;;
esac
QEMU_ETC ;;
	*) INVALID_INPUT && QEMU_ETC ;;
esac
	unset FORMAT_
	unset FORMAT
	QEMU_ETC
}
##################
QEMU_SYSTEM() {
	unset hda_name display hdb_name iso_name iso1_name
	QEMU_VERSION
	NOTE
echo -e "
1) 安装qemu-system-x86_64，并联动更新模拟器所需应用\n\e[33m(由于qemu的依赖问题，安装过程可能会失败，请尝试重新安装)${RES}
2) 创建windows镜像目录
3) 启动qemu-system-x86_64模拟器
4) 让termux成为网页服务器\n(使模拟系统可以通过浏览器访问本机内容)
5) virtio驱动相关"
case $SYS in
	ANDROID) ;;
	*) echo -e "6) 应用维护" ;;
esac
echo -e "7) 查看日志
8) 更新内容
9) 关于utqemu
0) 退出\n"
read -r -p "请选择: " input
case $input in
	1)  echo -e "${YELLOW}安装过程中，如遇到询问选择，请输(y)，安装过程容易出错，请重试安装${RES}"
	sleep 2
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
	apt update && apt --fix-broken install -y && apt install qemu-system-x86-64-headless qemu-system-i386-headless -y
else
	apt update && $sudo apt install qemu-system-x86 xserver-xorg x11-utils pulseaudio -y
#apt install samba
	fi
        QEMU_SYSTEM
        ;;
2) if [ -e "/root/sd" ]; then
	ln  -s /root/sd /sdcard
fi
	echo -e "创建windows镜像目录及共享目录\n"
        if [ ! -e "${DIRECT}/xinhao/windows" ]; then
                mkdir -p ${DIRECT}/xinhao/windows
        fi
        if [ ! -e "${DIRECT}/xinhao/share/" ]; then
                mkdir -p ${DIRECT}/xinhao/share
        fi
        if [ ! -e "${DIRECT}/xinhao/windows" ]; then        
	echo -e "${RED}创建目录失败${RES}"
        else
                echo -e "${GREEN}手机根目录下已创建/xinhao/windows文件夹，请把系统镜像，分驱镜像，光盘放进这个目录里\n\n共享目录是/xinhao/share(目录内总文件大小不能超过500m)\n${RES}"
        fi
        CONFIRM
        QEMU_SYSTEM
        ;;
3) if [ ! $(command -v qemu-system-x86_64) ]; then
	echo -e "\n${RED}检测到你未安装qemu，请先执行安装选项${RES}"
	sleep 2
	QEMU_SYSTEM
fi
	if [ ! -d /sdcard/xinhao ]; then
		echo -e "\n${RED}未检测到你的镜像目录，请确认已赋予手机存储权限并创建镜像目录${RES}"
		CONFIRM
fi
	uname -a | grep 'Android' -q 
	if [ $? == 0 ]; then
		echo -e "\n${YELLOW}vncviewer地址为127.0.0.1:0${RES}"     
		sleep 1
		display=vnc
	else
		echo -n -e "\n${GREEN}是否已有快捷脚本，如有请输快捷脚本名字，如无请回车:${RES} "
		read script_name
		if [ -n "$script_name" ]; then
			if [ $(command -v $script_name) ]; then
				printf "%s\n"
#cat $(which $script_name)

if grep 'vnc' $(which $script_name); then
	printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开vncviewer 127.0.0.1:0"
	elif grep -q 'DISPLAY' $(which $script_name); then
		grep '\-cpu' $(which $script_name)
		printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开xsdl"
		elif grep '\-spice' $(which $script_name); then
			printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开aspice 127.0.0.1 端口 5900"
		else
			grep '\-cpu' $(which $script_name)
			printf "%s\n${GREEN}模拟器已启动"
fi
printf "%s\n${YELLOW}如启动失败请ctrl+c退回shell，并查阅日志${RES}"
sleep 1
$script_name >/dev/null 2>>${HOME}/.utqemu_log
				exit 1
			else
				echo -e "\n${RED}未获取到你的快捷脚本${RES}\n"
				sleep 1
				fi
		fi
case $ARCH in
	tablet) echo -e "\n请选择${YELLOW}显示输出方式${RES}"
		case $SYS in
			QEMU_PRE) read -r -p "1)vnc 2)sdl 3)spice 4)图形界面下 5)局域网vnc 9)返回 0)退出 " input ;;
			*) read -r -p "1)vnc 2)sdl 3)spice 4)图形界面下 5)局域网vnc 6)快速启动(测试阶段) 9)返回 0)退出 " input
		esac
	case $input in
		1|"") echo -e "\n${BLUE}vnc输出${RES}"
			display=vnc
			;;
		2) echo -e "${BLUE}sdl信号输出，需先打开xsdl再继续此操作${RES}"
			display=xsdl
			;;
		3) echo -e "${BLUE}spice输出${RES}"
read -r -p "1)常规使用 2)spice传输协议使用(需virtio驱动) " input
case $input in
	2) display=spice_ ;;
		*) display=spice ;;
	esac
	;;
		4) echo -e "\n${BLUE}窗口输出${RES}"
			display=gtk_ ;;
		5) display=wlan_vnc
			echo -e "\n${GREEN}为减少效率的影响，暂不支持声音输出${RES}\n因部分机型支持双wifi或wifi热点同开，导致出现两段ip，请确保使用的${RED}ip唯一${RES}\n输出显示的设备vnc地址为$IP:0${RES}"
			sleep 1 ;;
		6) case $SYS in
			QEMU_PRE) INVALID_INPUT
			QEMU_SYSTEM ;; 
		*) echo -e "\n${GREEN}本选项使用常用配置参数${RES}\n声卡 winxp为ac97 win7为hda\n网卡 e1000\n显卡 winxp为cirrus win7为VGA\n视频输出 vnc${RES}\n"
			mem=$(free -m | awk '{print $2/4}' | sed -n 2p | cut -d '.' -f 1)
echo -e "请选择拟模拟的系统"
read -r -p "1)winxp 2)win7 9)返回 " input
case $input in
1) echo -e "\nqemu5.0以上版本模拟winxp开机比较慢\n"
	echo -e -n "请输镜像全名: "
	read hda
	if (( $mem >= 512 )); then
	mem_=1024
else
	mem_=512
fi
	MA=pc-i440fx-3.1 VIDEO="-device cirrus-vga" DRIVE="-drive file=${DIRECT}/xinhao/windows/$hda,if=ide,index=0,media=disk,aio=threads,cache=writeback" AUDIO="-device AC97" SHARE="-drive file=fat:rw:${DIRECT}/xinhao/share,if=ide,index=3,media=disk,aio=threads,cache=writeback";;
2) echo -e -n "请输镜像全名: "
	read hda
	if (( $mem >= 2048 )); then
	mem_=3072
elif (( $mem >= 1536 )); then
	mem_=2048
elif (( $mem >= 1024 )); then
	mem_=1536
elif (( $mem >= 512 )); then
	mem_=1024
else
	mem_=512
fi
	MA=pc VIDEO="-device VGA" DRIVE="-drive id=disk,file=${DIRECT}/xinhao/windows/$hda,if=none -device ahci,id=ahci -device ide-hd,drive=disk,bus=ahci.0" AUDIO="-device intel-hda -device hda-duplex" SHARE="-usb -drive if=none,format=raw,id=disk1,file=fat:rw:${DIRECT}/xinhao/share/ -device usb-storage,drive=disk1"
;;
9) QEMU_SYSTEM ;;
*) INVALID_INPUT
	QEMU_SYSTEM ;;
esac
printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开vncviewer 127.0.0.1:0"
printf "%s\n${YELLOW}如启动失败请ctrl+c退回shell，并查阅日志${RES}\n"
killall -9 qemu-system-x86 2>/dev/null
killall -9 qemu-system-i38 2>/dev/null
export PULSE_SERVER=tcp:127.0.0.1:4713
START="qemu-system-x86_64 -machine $MA,hmat=off,usb=off,vmport=off,dump-guest-core=off,kernel-irqchip=off --accel tcg,thread=multi -m $mem_ -nodefaults -no-user-config -msg timestamp=off -cpu max,-hle,-rtm -smp 2 $VIDEO -device e1000,netdev=user0 -netdev user,id=user0 -audiodev alsa,id=alsa1,in.format=s16,in.channels=2,in.frequency=44100,out.buffer-length=5124,out.period-length=1024 $AUDIO,audiodev=alsa1 -rtc base=localtime -boot order=cd,menu=on,strict=off -usb -device usb-tablet $DRIVE $SHARE -vnc :0,lossy=on"
#-display vnc=127.0.0.1:0,key-delay-ms=0,connections=15000"

cat <<-EOF
$START
EOF
printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开vncviewer 127.0.0.1:0"
printf "%s\n${YELLOW}如启动失败请ctrl+c退回shell，并查阅日志${RES}\n"
$START >/dev/null 2>>${HOME}/.utqemu_log
#-drive file=fat:rw:/sdcard/xinhao/share,if=ide,media=disk,aio=threads,cache=writeback
	exit 1 ;;
esac
			;;
		9) QEMU_SYSTEM ;;
		0) exit 1 ;;
		*) INVALID_INPUT
			QEMU_SYSTEM ;;
	esac
	sleep 1 ;;
	computer)
		echo -e "\n请选择${YELLOW}显示输出方式${RES}"
		read -r -p "1)本地 2)局域网vnc 9)返回 0)退出 " input
		case $input in
			1|"")
				display=amd ;;
			2)
				display=wlan_vnc
				echo -e "\n${BLUE}vnc不支持声音输出，输出显示的设备vnc地址为$IP:0${RES}"
				sleep 1 ;;
			9) QEMU_SYSTEM ;;
			0) exit 1 ;;
			*) INVALID_INPUT
				QEMU_SYSTEM ;;
		esac
		sleep 1 ;;
esac
	fi

##################
SELECT_EMU_MODE() {

	echo -e "\n请选择启动哪个${YELLOW}模拟器架构${RES}\n
	1) qemu-system-x86_64 (64位操作系统)
	2) qemu-system-i386   (32位操作系统)\n"
	read -r -p "请选择: " input
	case $input in
	1) QEMU_SYS=qemu-system-x86_64 ;;
	2) QEMU_SYS=qemu-system-i386 ;;

	*) INVALID_INPUT
	SELECT_EMU_MODE ;;
esac
}
##################
##################
SELECT_EMU() {
        echo -e "\n请选择启动哪个${YELLOW}模拟器架构${RES}\n
	1) qemu-system-x86_64 (64位操作系统)
	2) qemu-system-i386   (32位操作系统)
	3) 磁盘接口virtio驱动安装模式(测试阶段)	\n"
	read -r -p "请选择: " input
        case $input in
                1) QEMU_SYS=qemu-system-x86_64 ;;
                2) QEMU_SYS=qemu-system-i386 ;;
		3) echo -e "\n${GREEN}你选择了磁盘接口virtio驱动安装模式，此模式下的系统磁盘接口为ide，共享文件接口为virtio，请务必准备好virtio驱动光盘\n如启动安装失败，也请在(VIRTIO驱动相关)选项中进行兼容启动安装${RES}"
#echo -e "${GREEN}你选择了磁盘接口virtio驱动安装模式，此模式下的系统磁盘接口为ide，分区接口为virtio，请务必准备好分区镜像(可为空盘)及virtio驱动光盘\n空盘可在(VIRTIO驱动相关)选项中创建，如启动安装失败，也请在(VIRTIO驱动相关)选项中进行兼容启动安装${RES}"
			read -r -p "1)继续 9)返回 0)退出 " input
			case $input in
				1) QEMU_MODE=VIRTIO_MODE
				       	SELECT_EMU_MODE ;;
				0) exit 1 ;;
				*) echo "返回"
					sleep 1
					QEMU_SYSTEM ;;
			esac ;;
                *) INVALID_INPUT
			SELECT_EMU ;;
        esac
}
###################
	case $QEMU_MODE in
		VIRTIO_MODE) SELECT_EMU_MODE ;;
		*) case $SYS in
			QEMU_PRE) SELECT_EMU_MODE ;;
			*) SELECT_EMU ;;
		esac ;;

	esac
	case $ARCH in
		tablet)
	echo -e "\n${GREEN}请确认系统镜像已放入手机目录/xinhao/windows里${RES}\n" ;;
*) echo -e "\n${GREEN}请确认系统镜像已放入目录/xinhao/windows里${RES}\n" ;;
esac
	sleep 1
#       pkill -9 qemu-system-x86
#	pkill -9 qemu-system-i38
	killall -9 qemu-system-x86 2>/dev/null
	killall -9 qemu-system-i38 2>/dev/null
		echo -e "请选择${YELLOW}计算机类型${RES}，默认pc，因系统原因，q35可能导致启动不成功"
#cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
#kernel-irqchip=on|off|split中断控制器，如果可用，控制内核对irqchip的支持。
#vmport=on|off|auto为vmmouse等 启用VMWare IO端口的仿真，默认开
#dump-guest-core=on|off将客户机内存包括在核心转储中，类似于dump日志。默认为开。
#tb-size=n (TCG translation block cache size)，Controls the size (in MiB) of the TCG translation block cache.Host instruction codes are stored in code_gen_buffer[]. The default buffer size is 32MB.(Ram_size/4, while ram_size default value is 128MB).
#mem-merge=on|off启用或禁用内存合并支持。主机支持时，此功能可在VM实例之间重复删除相同的内存页面（默认情况下启用）。
#aes-key-wrap=on|off在s390-ccw主机上 启用或禁用AES密钥包装支持。此功能控制是否将创建AES包装密钥以允许执行AES加密功能。默认为开。
#dea-key-wrap=on|off在s390-ccw主机上 启用或禁用DEA密钥包装支持。此功能是否DEA控制，默认开
MA="usb=off,vmport=off,dump-guest-core=off,kernel-irqchip=off"
TCG="tcg,thread=multi"
read -r -p "1)pc 2)q35 " input
		case $input in
			1|"")
			case $(dpkg --print-architecture) in
					arm*|aarch64) 
case $SYS in
	QEMU_PRE) set -- "${@}" "-machine" "pc" "--accel" "$TCG" ;;
	*)
echo -e "\n请选择${YELLOW}加速${RES}方式(理论上差不多，但貌似指定tcg更流畅点，请自行体验)"
read -r -p "1)tcg 2)自动检测 " input
	case $input in
		1)
	set -- "${@}" "-machine" "pc,$MA" "--accel" "$TCG" ;;
	3) if [[ $(qemu-system-x86_64 --version) =~ :[4-5] ]] ; then
		echo -e "${RED}你选了隐藏选项，注意！设置tcg的缓存可以提高模拟效率，以m为单位，跟手机闪存ram也有关系(调高了会出现后台杀)，请谨慎设置${RES}"
		echo -n -e "请输入拟缓存的数值(以m为单位，例如1800)，回车为默认值，请输入: "
		read TB
		if [ -n "$TB" ]; then
		set -- "${@}" "-machine" "pc,usb=off,vmport=off,dump-guest-core=off,kernel-irqchip=off" "--accel" "$TCG,tb-size=$TB"
	else
		set -- "${@}" "-machine" "pc,$MA" "--accel" "$TCG"
		fi
		else
			set -- "${@}" "-machine" "pc,$MA" "--accel" "$TCG"
			fi ;;
		*) set -- "${@}" "-machine" "pc,accel=kvm:xen:hax:tcg,$MA" ;;
	esac ;;
esac ;;
					*)
	set -- "${@}" "-machine" "pc,accel=kvm:xen:hax:tcg,usb=off,dump-guest-core=on" ;;
esac ;;
			2) echo -e ${BLUE}"如果无法进入系统，请选择pc${RES}"
				case $(dpkg --print-architecture) in
					arm*|aarch64) 
						case $SYS in
							QEMU_PRE) set -- "${@}" "-machine" "q35" "--accel" "$TCG" ;;
							*)
						echo -e "\n请选择${YELLOW}加速${RES}方式(理论上差不多，但貌似指定tcg更流畅点，请自行体验)"
read -r -p "1)tcg 2)自动检测 " input
case $input in
	1) set -- "${@}" "-machine" "q35,$MA" "--accel" "$TCG" ;;
	3) if [[ $(qemu-system-x86_64 --version) =~ :[4-5] ]] ; then
		echo -e "${RED}你选了隐藏选项，注意！设置tcg的缓存可以提高模拟效率，以m为单位，跟手机闪存ram也有关系(调高了会出现后台杀)，请谨慎设置${RES}"
		echo -n -e "请输入拟缓存的数值(以m为单位，例如1800)，回车为默认值，请输入: "
		read TB
		if [ -n "$TB" ]; then
			set -- "${@}" "-machine" "q35,usb=off,vmport=off,dump-guest-core=off,kernel-irqchip=off" "--accel" "$TCG,tb-size=$TB"
		else
			set -- "${@}" "-machine" "q35,$MA" "--accel" "$TCG"
			fi
			else                                                            set -- "${@}" "-machine" "pc,$MA" "--accel" "$TCG"
				fi ;;

	*) set -- "${@}" "-machine" "q35,accel=kvm:xen:hax:tcg,$MA" ;;
esac ;;
esac ;;
					*)
				set -- "${@}" "-machine" "q35,accel=kvm:xen:hax:tcg,usb=off,dump-guest-core=on" 
;;
		esac ;;
esac
	if [ ! -d "${DIRECT}/xinhao/windows/" ];then
		echo -e "${RED}未获取到镜像目录，请确认已创建镜像目录${RES}\n"
		CONFIRM
		QEMU_SYSTEM
	fi
		echo -e "已为你列出镜像文件夹中的常用镜像格式文件（仅供参考）\e[33m"
		ls ${DIRECT}/xinhao/windows | egrep "\.blkdebug|\.blkverify|\.bochs|\.cloop|\.cow|\.tftp|\.ftps|\.ftp|\.https|\.http|\.dmg|\.nbd|\.parallels|\.qcow|\.qcow2|\.qed|\.host_cdrom|\.host_floppy|\.host_device|\.file|\.raw|\.sheepdog|\.vdi|\.vmdk|\.vpc|\.vvfat|\.img|\.XBZJ|\.vhd|\.iso|\.fd"
		sleep 1
while ( [ "$hda_name" != '0' ] && [ ! -f "${DIRECT}/xinhao/windows/$hda_name" ] )
do
	if [ -n "$hda_name" ]; then
		echo -e "\n${RED}未匹配到镜像，请重试${RES}"
		sleep 1
	fi
	echo -n -e "${RES}\n请输入${YELLOW}系统镜像${RES}全名（例如andows.img），退出请输${YELLOW}0${RES}，请输入: "
	read  hda_name
done
	if [ $hda_name == '0' ]; then
		QEMU_SYSTEM
	fi
	case $SYS in
		QEMU_ADV) 
			case $QEMU_MODE in
				"")
					echo -e "请选择${YELLOW}分区磁盘${RES}加载模式"
				read -r -p "1)加载分区镜像 2)加载双光盘 不加载请直接回车 " input
			case $input in
				1) echo -n -e "请输入${YELLOW}分区镜像${RES}全名,不加载请直接回车（例如hdb.img）: "
					read hdb_name ;;
				2) echo -n -e "请输入${YELLOW}第一个光盘${RES}全名,不加载请直接回车（例如DVD.iso）: "
					read iso1_name ;;
				*) ;;
			esac ;;
			VIRTIO_MODE) ;;
	esac ;;
*) echo -n -e "请输入${YELLOW}分区镜像${RES}全名,不加载请直接回车（例如hdb.img）: "
	read hdb_name ;;
esac
	echo -n -e "请输入${YELLOW}光盘${RES}全名,不加载请直接回车（例如DVD.iso）: "
	read iso_name
#		set -- "${@}" "-net" "nic" "-net" "user,smb=${DIRECT}/xinhao/"
#内存
	echo -e -n "请输入模拟的${YELLOW}内存${RES}大小(建议本机的1/4)，以m为单位（1g=1024m，例如输512），自动分配请回车: "
        read mem
	mem=`echo $mem | tr -cd [0-9]`
	if [ -n "$mem" ]; then
		set -- "${@}" "-m" "$mem"
	else
		case $ARCH in
			tablet) 
#				set -- "${@}" "-m" "$(free -m | awk '{print $2/4}' | sed -n 2p | cut -d '.' -f 1)"
mem=$(free -m | awk '{print $2/4}' | sed -n 2p | cut -d '.' -f 1)
if (( $mem >= 2048 )); then
	set -- "${@}" "-m" "3072"
elif (( $mem >= 1536 )); then
	set -- "${@}" "-m" "2048"
elif (( $mem >= 1024 )); then
	set -- "${@}" "-m" "1536"
	elif (( $mem >= 512 )); then
		set -- "${@}" "-m" "1024"
	else set -- "${@}" "-m" "512"
fi
	;;
			*) 
#				set -- "${@}" "-m" "$(free -m | awk '{print $2/2}' | sed -n 2p | cut -d '.' -f 1)"
mem=$(free -m | awk '{print $2/2}' | sed -n 2p | cut -d '.' -f 1)
if (( $mem >= 2048 )); then
	set -- "${@}" "-m" "3072"
elif (( $mem >= 1536 )); then
	set -- "${@}" "-m" "2048"
elif (( $mem >= 1024 )); then
	set -- "${@}" "-m" "1536"
elif (( $mem >= 512 )); then
	set -- "${@}" "-m" "1024"
else set -- "${@}" "-m" "512"
fi
;;
		esac
	fi


#	set -- "${@}" "-full-screen"
#不加载默认的配置文件。默认会加载/use/local/share/qemu下的文件，通常模拟器默认加载串口，并口，软盘，光驱等。
	set -- "${@}" "-nodefaults"
#不加载用户自定义的配置文件。
	set -- "${@}" "-no-user-config"
	case $ARCH in
		tablet)
#重定向虚拟串口到主机设备
#	set -- "${@}" "-serial" "none"
#重定向虚拟并口到主机设备
#	set -- "${@}" "-parallel" "none"
#控制台，一种类似于shell的交互方式
#	set -- "${@}" "-monitor" "none"
;;
		*) ;;
	esac
#更改消息的格式，时间戳
	set -- "${@}" "-msg" "timestamp=off"
#qemu monitor protocol协议，对qemu虚拟机进行交互
#	set -- "${@}" "-qmp" "tcp:127.0.0.1:4444,server,nowait" "-monitor" "none"
#使用bios配置
#	set -- "${@}" "-L" "${DIRECT}/xinhao/windows/"
#使用bzImage内核镜像
#	set -- "${@}" "-kernel" "bzImage"
#使用cmdline作为内核命令行
#	set -- "${@}" "-append" "cmdline"
	case $QEMU_SYS in
		qemu-system-i386)
#取消高精度定时器
	set -- "${@}" "-no-hpet"
#取消软盘启动检测
	set -- "${@}" "-no-fd-bootchk"
#取消高级配置与电源管理
#        set -- "${@}" "-no-acpi"
;;
		*) ;;
esac
	echo -e "是否自定义${YELLOW}逻辑cpu${RES}数量"
	read -r -p "1)默认配置 2)自定义 " input
	case $input in
		1|"") _SMP="" ;;
		*) CPU=0
			while [ $CPU -eq 0 ]
do
	echo -n -e "请输入逻辑cpu参数，分别为核心、线程、插槽个数，输入三位数字(例如2核1线2插槽,不能有0 则输212) "
	read SMP     
	CORES=`echo $SMP | cut -b 1`   
	THREADS=`echo $SMP | cut -b 2`    
	SOCKETS=`echo $SMP | cut -b 3`    
	let CPU=$CORES*$THREADS*$SOCKETS 2>/dev/null
done
echo -e "${YELLOW}$CORES核心$THREADS线程$SOCKETS插槽${RES}"
_SMP="$CPU,cores=$CORES,threads=$THREADS,sockets=$SOCKETS" ;;
esac
echo -e "请选择${YELLOW}cpu${RES}"
case $SYS in
	QEMU_ADV|ANDROID)
		read -r -p "1)n270 2)athlon 3)pentium2 4)core2duo 5)Skylake-Server-IBRS 6)Nehalem-IBRS 7)Opteron_G5 8)Dhyana 9)测试用(勿选) 0)max(推荐) " input ;;
QEMU_PRE) read -r -p "1)n270 2)athlon 3)pentium2 4)core2duo 5)Skylake-Server-IBRS 6)Nehalem-IBRS 7)Opteron_G5 " input ;;
esac
#max 对本机cpu的特性加载到虚拟机 host 直接迁移本机cpu到虚拟机(适用于kvm)
#部分cpu id flags：fpu –板载FPU，vme –虚拟模式扩展，de –调试扩展，pse –页面大小扩展，tsc –时间戳计数器，操作系统通常可以得到更为精准的时间度量，msr –特定于模型的寄存器，pae –物理地址扩展，cx8 – CMPXCHG8指令，apic–板载APIC，sep– SYSENTER/SYSEXIT，mtrr –存储器类型范围寄存器，pge – Page Global Enable，mca –Machine Check Architecture，cmov – CMOV instructions（附加FCMOVcc，带有FPU的FCOMI），pat –页面属性表，pse36 – 36位PSE，clflush – CLFLUSH指令，dts –调试存储，acpi –ACPI via MSR，mmx –多媒体扩展，fxsr – FXSAVE/FXRSTOR, CR4.OSFXSR，sse – SSE，sse2 – SSE2，ss – CPU自侦听，ht –超线程，tm –自动时钟控制，ia64 – IA-64处理器，pbe –等待中断启用，mmxext – AMD MMX扩展，fxsr_opt – FXSAVE / FXRSTOR优化，rdtscp – RDTSCP，lm –长模式（x86-64），3dnowext – AMD 3DNow扩展，k8 –皓龙，速龙64，k7 –速龙，pebs –基于精确事件的采样，bts –分支跟踪存储，nonstop_tsc – TSC不会在C状态下停止，PNI – SSE-3，pclmulqdq – PCLMULQDQ指令，dtes64 – 64位调试存储，监控器–监控/等待支持，ds_cpl – CPL Qual.调试存储，vmx –英特尔虚拟化技术(VT技术)，smx –更安全的模式，est –增强的SpeedStep，tm2 –温度监控器2，ssse3 –补充SSE-3，cid –上下文ID，cx16 – CMPXCHG16B，xptr –发送任务优先级消息，dca –直接缓存访问，sse4_1 – SSE-4.1，sse4_2 – SSE-4.2，x2apic – x2APIC，aes – AES指令集，xsave – XSAVE / XRSTOR / XSETBV / XGETBV，avx –高级矢量扩展，hypervisor–在hypervisor上运行，svm –AMD的虚拟化技术(AMD-V)，extapic –扩展的APIC空间，cr8legacy – 32位模式下的CR8，abm –高级bit操作，ibs –基于Sampling的采样，sse5 – SSE-5，wdt –看门狗定时器，硬件锁定清除功能（HLE），受限事务存储（RTM）功能，HLE与RTM为TSX指令集，决定服务器cpu多线程或单线程处理数据。
        case $input in
        1) set -- "${@}" "-cpu" "n270"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
                set -- "${@}" "-smp" "2,cores=1,threads=2,sockets=1"
		fi ;;
        2) set -- "${@}" "-cpu" "athlon"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
                set -- "${@}" "-smp" "2,cores=2,threads=1,sockets=1"
			fi ;;
        3) set -- "${@}" "-cpu" "pentium2"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
                set -- "${@}" "-smp" "1,cores=1,threads=1,sockets=1"
			fi ;;
        4) set -- "${@}" "-cpu" "core2duo"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
                set -- "${@}" "-smp" "2,cores=2,threads=1,sockets=1"
		fi ;;
	5) set -- "${@}" "-cpu" "Skylake-Server-IBRS"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
		set -- "${@}" "-smp" "4,cores=2,threads=1,sockets=2"
			fi ;;
	6) set -- "${@}" "-cpu" "Nehalem-IBRS"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
			set -- "${@}" "-smp" "8,cores=8,threads=1,sockets=1"
			fi ;;
	7) set -- "${@}" "-cpu" "Opteron_G5"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
			set -- "${@}" "-smp" "8,cores=8,threads=1,sockets=1"
			fi ;;
	8) case $SYS in
		QEMU_ADV|ANDROID) set -- "${@}" "-cpu" "Dhyana"
		if [ -n "$_SMP" ]; then
			set -- "${@}" "-smp" "$_SMP"
		else
			set -- "${@}" "-smp" "8,cores=8,threads=1,sockets=1"
			fi ;;
		*) set -- "${@}" "-cpu" "max"
			if [ -n "$CPU" ]; then
				set -- "${@}" "-smp" "$CPU"
			else
				set -- "${@}" "-smp" "4"
				fi ;;
	esac
	;;
	0) set -- "${@}" "-cpu" "max,-hle,-rtm"
		if [ -n "$CPU" ]; then
			set -- "${@}" "-smp" "$CPU"
		else
			set -- "${@}" "-smp" "4"
		fi ;;
	9) set -- "${@}" "-cpu" "max,level=0xd,vendor=GenuineIntel"
		if [ -n "$CPU" ]; then
			set -- "${@}" "-smp" "$CPU"
		else
		set -- "${@}" "-smp" "4"
		fi ;;
        *)      set -- "${@}" "-cpu" "max"
		if [ -n "$CPU" ]; then
                set -- "${@}" "-smp" "$CPU"
	else
		set -- "${@}" "-smp" "4"
		fi ;;
esac
#####################
#TERMUX
	uname -a | grep 'Android' -q 
	if [ $? == 0 ]; then
echo -e "请选择${YELLOW}显卡${RES}"
read -r -p "1)cirrus 2)vmware 3)vga 4)virtio " input
	case $input in 
		1) set -- "${@}" "-device" "cirrus-vga" ;;
		2) read -r -p "1)不设置3D参数 2)设置3D参数 " input
			case $input in
				1|"") set -- "${@}" "-device" "vmware-svga" ;;
				*) set -- "${@}" "-device" "vmware-svga,vgamem_mb=512" ;;
			esac ;;
		4) set -- "${@}" "-device" "virtio-vga" ;;
		*) set -- "${@}" "-device" "VGA" ;;
        esac


	echo -e "请选择${YELLOW}网卡${RES}"
	read -r -p "1)e1000 2)rtl8139 3)virtio 0)不加载 " input
	case $input in
		2) set -- "${@}" "-device" "rtl8139,netdev=user0"
			set -- "${@}" "-netdev" "user,id=user0" ;;
		3) set -- "${@}" "-device" "virtio-net-pci,netdev=user0"
			set -- "${@}" "-netdev" "user,id=user0" ;;
		0) set -- "${@}" "-net" "none" ;;
		*)   set -- "${@}" "-device" "e1000,netdev=user0"
			set -- "${@}" "-netdev" "user,id=user0" ;;
esac
else
##################
#PROOT
#####################
#<5.0
	qemu-system-x86_64 --version | grep ':[5-9]' -q || uname -a | grep 'Android' -q
	if [ $? != 0 ]; then
echo -e "请选择${YELLOW}显卡${RES}"
	read -r -p "1)cirrus 2)vmware 3)std 4)virtio 5)qxl " input
        case $input in
                1) set -- "${@}" "-vga" "cirrus" ;;
                2) set -- "${@}" "-vga" "vmware" ;;
		4) set -- "${@}" "-vga" "virtio" ;;
		5) set -- "${@}" "-vga" "qxl" ;;
		*) set -- "${@}" "-vga" "std" ;;
esac
#内存锁，默认打开
		set -- "${@}" "-realtime" "mlock=off"

echo -e "请选择${YELLOW}网卡${RES}"
read -r -p "1)e1000 2)rtl8139 3)virtio 0)不加载 " input
case $input in
	2) set -- "${@}" "-net" "user"
		set -- "${@}" "-net" "nic,model=rtl8139" ;;
	3) set -- "${@}" "-net" "user"
		set -- "${@}" "-net" "nic,model=virtio" ;;
	0) set -- "${@}" "-net" "none" ;;
	*)
#set -- "${@}" "-net" "nic"
#set -- "${@}" "-net" "user,smb=${DIRECT}/xinhao"
set -- "${@}" "-net" "user"
set -- "${@}" "-net" "nic,model=e1000" ;;
esac
case $display in
	wlan_vnc) ;;
	*)
			echo -e "请选择${YELLOW}声卡${RES}(不加载可提升模拟效率)"
			read -r -p "1)ac97 2)sb16 3)es1370 4)hda 0)不加载 " input
                        case $input in
                1|"") set -- "${@}" "-soundhw" "ac97" ;;
                2) set -- "${@}" "-soundhw" "sb16" ;;
                0) ;;
                3) set -- "${@}" "-soundhw" "es1370" ;;
		4) set -- "${@}" "-soundhw" "hda" ;;
		*) set -- "${@}" "-soundhw" "all" ;;
esac
;;
esac
        else
####################
#5.0
####################
echo -e "请选择${YELLOW}显卡${RES}"
read -r -p "1)cirrus 2)vmware 3)vga 4)virtio 5)qxl " input
	case $input in
		1) set -- "${@}" "-device" "cirrus-vga" ;;
		2) read -r -p "1)不设置3D参数 2)设置3D参数 " input
			case $input in
				1|"") set -- "${@}" "-device" "vmware-svga" ;;
				*) set -- "${@}" "-device" "vmware-svga,vgamem_mb=512" ;;
			esac ;;
				4) echo -e "${YELLOW}virtio显卡带3D功能，但因使用的系统环境原因，目前只能通过电脑启用，如果真想尝试，可在图形界面打开(需32位色彩，否则出现花屏)。${RES}"
		read -r -p "1)不设置3D参数 2)设置3D参数 " input
		case $input in
			1|"")
#				set -- "${@}" "-vga" "virtio"
				set -- "${@}" "-device" "virtio-vga"
#                       set -- "${@}" "-device" "virtio-vga,virgl=on"
;;
			2) echo -e "\n${YELLOW}你选择virtio显卡3D参数，该模式只能在图形界面(桌面)显示${RES}"
				CONFIRM
				case $display in
					xsdl) set -- "${@}" "-device" "virtio-vga" "-display" "sdl,gl=on" ;;
					vnc|wlan_vnc)
						set -- "${@}" "-vga" "qxl" "-display" "gtk,gl=on" "-device" "virtio-gpu-pci,virgl=on"
#                               set -- "${@}" "-device" "qxl" "-vga" "virtio" "-display" "gtk,gl=on"
;;
					spice_|spice|amd|gtk_) set -- "${@}" "-device" "virtio-vga" "-display" "gtk,gl=on" ;;
				esac
				unset display
				case $ARCH in
					computer) ;;
					*) env | grep 'PULSE_SERVER' -q
						if [ $? != 0 ]; then
							export PULSE_SERVER=tcp:127.0.0.1:4713
							fi ;;
					esac ;;
			esac ;;
		5) set -- "${@}" "-device" "qxl-vga"
cat >/dev/null <<EOF
set -- "${@}" "-device" "ich9-usb-ehci1,id=usb"
#set -- "${@}" "-device" "ich9-usb-ehci1,id=usb"
set -- "${@}" "-device" "ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on"
#set -- "${@}" "-device" "ich9-usb-uhci2,masterbus=usb.0,firstport=2"
#set -- "${@}" "-device" "ich9-usb-uhci3,masterbus=usb.0,firstport=4"
set -- "${@}" "-chardev" "spicevmc,name=usbredir,id=usbredirchardev1" "-device" "usb-redir,chardev=usbredirchardev1,id=usbredirdev1"
#set -- "${@}" "-chardev" "spicevmc,name=usbredir,id=usbredirchardev2" "-device" "usb-redir,chardev=usbredirchardev2,id=usbredirdev2"
#set -- "${@}" "-chardev" "spicevmc,name=usbredir,id=usbredirchardev3" "-device" "usb-redir,chardev=usbredirchardev3,id=usbredirdev3"
EOF
;;
*) set -- "${@}" "-device" "VGA" ;;
esac

echo -e "请选择${YELLOW}网卡${RES}"
read -r -p "1)e1000 2)rtl8139 3)virtio 0)不加载 " input
case $input in
	2) set -- "${@}" "-device" "rtl8139,netdev=user0"
		set -- "${@}" "-netdev" "user,id=user0" ;;
	3) set -- "${@}" "-device" "virtio-net-pci,netdev=user0"
		set -- "${@}" "-netdev" "user,id=user0" ;;
	0) set -- "${@}" "-net" "none" ;;
	*)   set -- "${@}" "-device" "e1000,netdev=user0"
		set -- "${@}" "-netdev" "user,id=user0" ;;
esac
case $display in
	wlan_vnc) ;;
	*)
echo -e "请选择${YELLOW}声卡${RES}(不加载可提升模拟效率)"
read -r -p "1)es1370 2)sb16 3)hda 4)ac97(推荐) 5)ac97(修改参数) 6)hda(修改参数) 0)不加载 " input
                        case $input in
                        1) set -- "${@}" "-device" "ES1370" ;;
                        2) set -- "${@}" "-device" "sb16" ;;
			3) set -- "${@}" "-device" "intel-hda" "-device" "hda-duplex" ;;
                        0) ;;
			5)
#adc in dac out				
#alsa参数			       	
#延迟timer-period=10000
#采样率out.frequency=8000
#缓冲长度(理论上应为周期长度的倍数)out.buffer-length=10000
#周期长度out.period-length=2500
#pa参数
#采样率out.frequency=8000
			set -- "${@}" "-audiodev" "alsa,id=alsa1,in.format=s16,in.channels=2,in.frequency=44100,out.buffer-length=5124,out.period-length=1024"
				set -- "${@}" "-device" "AC97,audiodev=alsa1" ;;
			6) set -- "${@}" "-audiodev" "alsa,id=alsa1,in.format=s16,in.channels=2,in.frequency=44100,out.buffer-length=5124,out.period-length=1024"
				set -- "${@}" "-device" "intel-hda" "-device" "hda-duplex,audiodev=alsa1" ;;
			*) set -- "${@}" "-device" "AC97" ;;
                esac
		;;
esac
	fi
	fi
####################
#进阶选项

echo -e "\n是否进阶选项，包括${YELLOW}共享文件夹、鼠标、启动顺序、时间${RES}等"
read -r -p "1)是 2)否 " input
case $input in
        1)
echo -e "是否加载${YELLOW}共享文件夹${RES}"
read -r -p "1)加载 2)不加载 " input
case $input in
	1|"") SHARE=true ;;
	*) ;;
esac
#开全内存balloon功能，俗称内存气球
echo -e "是否开${YELLOW}全内存balloon${RES}功能(需安装virtio驱动)"
read -r -p "1)开启 2)不开启 " input
case $input in
	1) set -- "${@}" "-device" "virtio-balloon-pci" ;;
	*) ;;
esac
#-L是DOS
#-bios，启动现系统
#-plash，启动UEFI 的BIOS
echo -e "是否加载${YELLOW}UEFI${RES}"
read -r -p "1)加载 2)不加载 " input
case $input in
	1) echo -n -e "请确认UEFI已放进xinhao/windows文件夹内，输入UEFI全名(例如OVMF_CODE.fd)，使用qemu的默认UEFI请直接回车 "
	read UEFI
	if [ -n "$UEFI" ]; then
		set -- "${@}" "-pflash" "${DIRECT}/xinhao/windows/$UEFI"
	else
		set -- "${@}" "-pflash" "/usr/share/OVMF/OVMF_CODE.fd"
		set -- "${@}" "-pflash" "/usr/share/OVMF/OVMF_VARS.fd"
	fi ;;
*) ;;
esac
#amd
####################
case $(dpkg --print-architecture) in
	i*86|x86*|amd64)
#在KVM中内存允许过载使用，分配给客户机的内存总数可以大于实际可用的物理内存总数。客户机过载使用内存的上限是：宿主机可用物理内存空间和交换空间的大小之和。超过这个上限会使客户机因内存不足被强制关闭。		
		echo -e "${YELLOW}过量内存使用${RES}(默认关闭)"
		read -r -p "1)开启 2)关闭 " input
		case $input in
			1) set -- "${@}" "-overcommit" "mem-lock=on" ;;
			*) set -- "${@}" "-overcommit" "mem-lock=off" ;;
		esac
#KVM允许客户机过载使用（over-commit）CPU资源，即让一个或多个客户机使用vCPU的总数量超过宿主机实际拥有的物理CPU数量。但不建议单个客户机的CPU数量多于物理宿主机的CPU数量。
		echo -e "${YELLOW}过量cpu控制${RES}(默认关闭)"
		read -r -p "1) 开启 2)关闭 " input
		case $input in
			1) set -- "${@}" "-overcommit" "cpu-pm=on" ;;
			*) set -- "${@}" "-overcommit" "cpu-pm=off" ;;
		esac ;;
	*) 
#让meminfo文件中HugePages_Free数量的减少和分配给客户机的内存保持一致。getconf  PAGESIZE
		echo -e "是否加载${YELLOW}mem-prealloc${RES}参数(测试失败，提高响应速度，如出现闪退请关闭)"
   	read -r -p "1)加载 2)不加载 " input
	case $input in
		1) ls /tmp/hugepages.* 2>/dev/null
			if [ $? != 0 ]; then
			mktemp -t hugepages.XXX
  			fi
			HUGEPAGES=`ls /tmp/hugepages.* | sed -n 1p`
			set -- "${@}" "-mem-path" "$HUGEPAGES"
			set -- "${@}" "-mem-prealloc" ;;
			*)	esac ;;
esac
echo -e "是否加载${YELLOW}usb鼠标${RES}(提高光标精准度),少部分系统可能不支持"
read -r -p "1)加载 2)不加载 " input
case $input in
	2) ;;
	*) set -- "${@}" "-usb" "-device" "usb-tablet" ;;
esac
#时间设置，RTC时钟，用于提供年、月、日、时、分、秒和星期等的实时时间信息，由后备电池供电，当你晚上关闭系统和早上开启系统时，RTC仍然会保持正确的时间和日期
echo -e "请选择${YELLOW}系统时间${RES}标准"
read -r -p "1)utc 2)localtime " input
case $input in
	1) set -- "${@}" "-rtc" "base=utc,clock=host,driftfix=slew" ;;
	*) set -- "${@}" "-rtc" "base=localtime" ;;
#       *) set -- "${@}" "-rtc" "base=`date +%Y-%m-%dT%T`" ;;
esac
echo -e "请选择${YELLOW}启动顺序${RES}"
read -r -p "1)优先硬盘启动 2)优先光盘启动 " input
case $input in
	1|"") set -- "${@}" "-boot" "order=cd,menu=on,strict=off" ;;
	*) set -- "${@}" "-boot" "order=dc,menu=on,strict=off" ;;
esac ;;
*)
        set -- "${@}" "-rtc" "base=localtime"
        set -- "${@}" "-boot" "order=cd,menu=on,strict=off"
        set -- "${@}" "-usb" "-device" "usb-tablet"
        ;;
esac


#################
cat >/dev/null<<EOF
if=INTERFACE：指定驱动器接口类型，可用的有：ide，scsi，sd，mtd，floopy，pflash，virtio等
bus=BUS NUM，unit=UNIT NUM：设置驱动器在客户机中的总线编号和单元编号
index=INDEX NUM：设置在同一种接口的驱动器中的索引编号
media=disk|cdrom：设置驱动器中媒介的类型，其值为“disk”或“cdrom”
snapshot=on|off：是否启用镜像功能，启用时，qemu不会将磁盘数据的更改写回镜像文件中，而是写到临时文件，也可以在qemu         monitor中使用commit命令强制将磁盘数据的更改保存回镜像文件中
cache=writethrough|writeback|（none|off）
writethrough：默认值，即直写模式，它是在调用write写入数据的同时将数据写入磁盘缓存和后端块设备中，优点：操作简单，缺点：写入数据速度较慢
writeback：回写模式，将数据写入到磁盘缓存中即返回，只有数据被换出缓存的时候才写入到后端块设备中，优点：写入速度快，缺点：可能造成数据丢失
（none|off）：设置none或者off表示不写入缓存，直接写入到块设备中，优点是数据安全，缺点:速度太慢
aio=threads|native：默认threads，即让一个线程池去处理异步io；而native只适用于cache=none的情况，就是使用linux原生的aio
format=FORMAT：使用的磁盘格式，默认qemu是自动检测磁盘格式的
serial=SERIAL NUM：分配给设备的序列号
add=ADDR:分配给驱动器控制器的pci地址，该选项只有在使用virtio接口才适用
id=NAME：设置该驱动器的id，这个id可以在qemu monitor中用info block命令查看
EOF
	case $QEMU_MODE in
		VIRTIO_MODE)
		set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hda_name,if=ide"
		set -- "${@}" "-drive" "file=fat:rw:${DIRECT}/xinhao/share,if=virtio"
		set -- "${@}" "-cdrom" "${DIRECT}/xinhao/windows/$iso_name" ;;
		*)
		echo -e "\n请选择${YELLOW}磁盘接口${RES},因系统原因,sata可能导致启动不成功,virtio需系统已装驱动,回车为兼容方式"
		read -r -p "1)ide 2)sata 3)virtio 4)测试用(勿选) " input
		case $input in
##################
#IDE			
			1)
		set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hda_name,if=ide,index=0,media=disk,aio=threads,cache=none"
		if [ -n "$hdb_name" ]; then
		set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hdb_name,if=ide,index=1,media=disk,aio=threads,cache=none"
		fi
		if [ -n "$iso1_name" ]; then
			set -- "${@}" "-cdrom" "${DIRECT}/xinhao/windows/$iso1_name"
		if [ -n "$iso_name" ]; then 
		       set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$iso_name,if=ide,media=cdrom"
		fi
	else
		if [ -n "$iso_name" ]; then
			set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$iso_name,if=ide,index=2,media=cdrom"
		fi
		fi
		case $SHARE in
			true) set -- "${@}" "-drive" "file=fat:rw:${DIRECT}/xinhao/share,if=ide,index=3,media=disk,aio=threads,cache=none" ;;
			*) ;;
		esac ;;


		2)

##################
#SATA        
		set -- "${@}" "-drive" "id=disk,file=${DIRECT}/xinhao/windows/$hda_name,if=none"
		set -- "${@}" "-device" "ahci,id=ahci"
		set -- "${@}" "-device" "ide-hd,drive=disk,bus=ahci.0"

		if [ -n "$hdb_name" ]; then
		set -- "${@}" "-drive" "id=installmedia,file=${DIRECT}/xinhao/windows/$hdb_name,if=none"
		set -- "${@}" "-device" "ide-hd,drive=installmedia,bus=ahci.1"
		fi
		if [ -n "$iso1_name" ]; then
			set -- "${@}" "-cdrom" "${DIRECT}/xinhao/windows/$iso1_name"
		fi
		if [ -n "$iso_name" ]; then
		set -- "${@}" "-drive" "id=cdrom,file=${DIRECT}/xinhao/windows/$iso_name,if=none"     
		set -- "${@}" "-device" "ide-cd,drive=cdrom,bus=ahci.2"
		fi
		case $SHARE in
			true)
		set -- "${@}" "-usb" "-drive" "if=none,format=raw,id=disk1,file=fat:rw:${DIRECT}/xinhao/share/"
		set -- "${@}" "-device" "usb-storage,drive=disk1"
		;;
	*) ;;
esac ;;
##################
#VIRTIO

	3) set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hda_name,index=0,media=disk,if=virtio"
if [ -n "$hdb_name" ]; then
			set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hdb_name,index=1,media=disk,if=virtio"
		fi
		if [ -n "$iso1_name" ]; then
			set -- "${@}" "-cdrom" "${DIRECT}/xinhao/windows/$iso1_name"
			if [ -n "$iso_name" ]; then
				set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$iso_name,media=cdrom"
			fi
		else
		if [ -n "$iso_name" ]; then
			set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$iso_name,index=2,media=cdrom"
		fi
		fi
		case $SHARE in
			true)
			set -- "${@}" "-drive" "file=fat:rw:${DIRECT}/xinhao/share,index=3,media=disk,if=virtio"
#			set -- "${@}" "-fsdev" "local,security_model=none,id=fsdev-fs0,path=/sdcard/xinhao/"
#			set -- "${@}" "-device" "virtio-9p-pci,fsdev=fsdev-fs0,mount_tag=virtio9p01"
#			set -- "${@}" "-fsdev" "local,security_model=none,id=fsdev-fs0,path=/sdcard/xinhao/"
#			set -- "${@}" "-device" "virtio-9p-pci,id=fs0,fsdev=fsdev-fs0,mount_tag=virtio9p01,bus=pci.0,addr=0x1d"
;;
			*) ;;
		esac ;;
##################
#test
	4) set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hda_name,index=0,media=disk"
if [ -n "$hdb_name" ]; then
	set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$hdb_name,index=1,media=disk"
	fi
	if [ -n "$iso_name" ]; then
		set -- "${@}" "-drive" "file=${DIRECT}/xinhao/windows/$iso_name,index=2,media=cdrom"
	fi
	case $SHARE in
		true)
	set -- "${@}" "-drive" "file=fat:rw:${DIRECT}/xinhao/share,index=3,media=disk,format=raw" ;;
*) ;;
esac
				;;
##################
#hda
		*) set -- "${@}" "-hda" "${DIRECT}/xinhao/windows/$hda_name" 
	if [ -n "$hdb_name" ]; then
		set -- "${@}" "-hdb" "${DIRECT}/xinhao/windows/$hdb_name"
		fi
		if [ -n "$iso_name" ]; then
			set -- "${@}" "-cdrom" "${DIRECT}/xinhao/windows/$iso_name"
			fi
			case $SHARE in
				true)
			set -- "${@}" "-hdd" "fat:rw:${DIRECT}/xinhao/share/" ;;
		*) ;;
	esac ;;
esac ;;
	esac


########################
		if [ -n "$display" ]; then
			case $display in
				wlan_vnc) set -- "${@}" "-vnc" "$IP:0,lossy=on" ;;
				vnc) 
					set -- "${@}" "-vnc" ":0,lossy=on"
					export PULSE_SERVER=tcp:127.0.0.1:4713 ;;
				xsdl) export DISPLAY=127.0.0.1:0
					export PULSE_SERVER=tcp:127.0.0.1:4713 ;;
				spice) set -- "${@}" "-spice" "port=5900,addr=127.0.0.1,disable-ticketing,seamless-migration=off"
					export PULSE_SERVER=tcp:127.0.0.1:4713 ;;
				spice_) set -- "${@}" "-spice" "port=5900,addr=127.0.0.1,disable-ticketing,seamless-migration=off"
					set -- "${@}" "-device" "virtio-serial-pci" "-device" "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0" "-chardev" "spicevmc,id=spicechannel0,name=vdagent"
					export PULSE_SERVER=tcp:127.0.0.1:4713 ;;
				amd) set -- "${@}" "-display" "gtk,gl=off" ;;
				gtk_) set -- "${@}" "-display" "gtk,gl=off"
					env | grep 'PULSE_SERVER' -q
					if [ $? != 0 ]; then
						export PULSE_SERVER=tcp:127.0.0.1:4713
						fi ;;
			esac
		fi

        set -- "$QEMU_SYS" "${@}"
	uname -a | grep 'Android' -q 
	if [ $? != 0 ]; then
		case $display in
		wlan_vnc) ;;
		*)
	echo -e "创建本次参数的${YELLOW}快捷脚本${RES}"
	read -r -p "1)是 2)否 " input
	case $input in
		1) echo -n "请给脚本起个名字: "
			read script_name
			case $display in
				xsdl)
cat >/usr/local/bin/$script_name <<-EOF
killall -9 qemu-system-x86 2>/dev/null
killall -9 qemu-system-i38 2>/dev/null
#pkill -9 qemu-system-x86
#pkill -9 qemu-system-i38
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=127.0.0.1:0
${@}
EOF
;;
				vnc|spice|spice_) 
cat >/usr/local/bin/$script_name <<-EOF
killall -9 qemu-system-x86 2>/dev/null
killall -9 qemu-system-i38 2>/dev/null
#pkill -9 qemu-system-x86
#pkill -9 qemu-system-i38
export PULSE_SERVER=tcp:127.0.0.1:4713
${@}
EOF
;;
				amd|gtk_|*)
cat >/usr/local/bin/$script_name <<-EOF
killall -9 qemu-system-x86 2>/dev/null
killall -9 qemu-system-i38 2>/dev/null
#pkill -9 qemu-system-x86
#pkill -9 qemu-system-i38
${@}
EOF
;;
esac
chmod +x /usr/local/bin/$script_name
echo -e "已保存本次参数的脚本，下次可直接输${GREEN}$script_name${RES}启动qemu"
sleep 2 ;;
		*) ;;
esac ;;
esac
	fi
	printf "%s\n"
	cat <<-EOF
	${@}
	EOF
	case $display in
		vnc) printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开vncviewer 127.0.0.1:0" ;;
		wlan_vnc) printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开vncviewer $IP:0" ;;
		xsdl) printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开xsdl" ;;
		spice|spice_) printf "%s\n${BLUE}模拟器已启动\n${GREEN}请打开aspice 127.0.0.1 端口 5900" ;;
		*) printf "%s\n${GREEN}模拟器已启动" ;;
	esac
	printf "%s\n${YELLOW}如启动失败请ctrl+c退回shell，并查阅日志${RES}"
	sleep 1
	"${@}" >/dev/null 2>>${HOME}/.utqemu_log
	exit 1
        ;;
4) WEB_SERVER ;;
5) VIRTIO ;;
6) case $SYS in
	ANDROID) INVALID_INPUT
	QEMU_SYSTEM ;;
*) QEMU_ETC ;;
esac ;;
7) if [ -e ${HOME}/.utqemu_log ]; then
	echo -e "\n${GREEN}日志已忽略不重要的信息${RES}\n按空格下一页，退出请按q\n"
	CONFIRM
	more ${HOME}/.utqemu_log | egrep "qemu-system-x86_64|qemu-system-i386" | egrep -v "stronger memory|Connection reset by peer|requested feature"
	echo -e "\n\e[33m到底了\e[0m"
	read -r -p "是否删除日志 1)是 0)否 " input
	case $input in
		1) rm ${HOME}/.utqemu_log 2>/dev/null ;;
		*) ;;
	esac
	else
		echo -e "${GREEN}无日志信息${RES}"
		sleep 1
fi
	QEMU_SYSTEM ;;
8) INFO
	CONFIRM
	QEMU_SYSTEM	;;
9) ABOUT_UTQEMU ;;
0) exit 1 ;;
*) INVALID_INPUT && QEMU_SYSTEM ;;
esac
}


#############################
VIRTIO() {

echo -e "
1) 下载virtio驱动光盘"
	case $SYS in
		QEMU_ADV)
echo -e "2) 为磁盘接口添加virtio驱动（需另外下载virtio驱动光盘）" ;;
*) ;;
esac
echo -e "8) 关于virtio
9) 返回主目录
0) 退出\n"

read -r -p "请选择: " input
case $input in
	1) if [ ! $(command -v curl) ]; then
		echo -e "${YELLOW}检测到你未安装需要的应用curl，将为你先安装curl${RES}"
		sleep 2
		apt update && apt install curl -y
	fi
		echo -e "${YELLOW}即将下载，下载速度可能比较慢，你也可以复制下载链接通过其他方式下载${RES}\n\n正在检测下载地址..."
		DATE=`date +"%Y"`
		VERSION=`curl -s https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/ | grep virtio-win | grep $DATE |tail -n 1 | cut -d ">" -f 3 | cut -d "<" -f 1`
	       	if [ ! -n "$VERSION" ]; then
			unset DATE
			DATE=`date -d "-1 year" +%Y`
			VERSION=`curl -s https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/ | grep virtio-win | grep $DATE |tail -n 1 | cut -d ">" -f 3 | cut -d "<" -f 1`
		fi
VERSION_=`curl https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/$VERSION | grep iso | cut -d ">" -f 3 | cut -d "<" -f 1 | head -n 1`
echo "$VERSION_" | grep iso -q
if [ $? -ne 0 ]; then
	echo -e "${RED}无法连接地址${RES}"
	sleep 2
                QEMU_SYSTEM
        else
        echo -e "${YELLOW}下载地址链接为\n\n${GREEN}https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/$VERSION$VERSION_${RES}\n"
	read -r -p "1)下载 0)返回 " input
	case $input in
		1)
curl -O https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/$VERSION$VERSION_
if [ -f $VERSION_ ]; then
	echo -e "移到/sdcard/xinhao/windows目录中..."
	mv -v $VERSION_ /sdcard/xinhao/windows
	if [ -f /sdcard/xinhao/windows/$VERSION_ ]; then
		echo -e "\n已下载至/sdcard/xinhao/windows/目录"
		sleep 2
	fi
else
	echo -e "\n${RED}错误，请重试${RES}"
	sleep 2
fi ;;
*) ;;
esac
QEMU_SYSTEM
fi
                ;;

	2) case $SYS in
		QEMU_ADV)
		echo -e "\n${GREEN}本次操作默认vnc输出，地址127.0.0.1:0\n请确认系统镜像与virtio驱动盘已放入手机目录/xinhao/windows里${RES}"
	CONFIRM
	if [ ! -e "${DIRECT}/xinhao/windows" ]; then
		echo -e "\n${RED}请选创建windows镜像目录及共享目录，并把系统镜像与驱动盘放入该目录${RES}\n"
		sleep 2
		QEMU_SYSTEM
	fi
killall -9 qemu-system-x86 2>/dev/null
killall -9 qemu-system-i38 2>/dev/null
#	pkill -9 qemu-system-x86
#	pkill -9 qemu-system-i38
	if [ ! -e "${DIRECT}/xinhao/windows/fake.qcow2" ]; then
	echo -e "\n将为你创建一个新的磁盘镜像，用于搜索virtio驱动\n"
	sleep 2
	qemu-img create -f qcow2 ${DIRECT}/xinhao/windows/fake.qcow2 1G 2>/dev/null
	if [ -e "${DIRECT}/xinhao/windows/fake.qcow2" ]; then
	echo -e "\n${GREEN}已创建fake.qcow2磁盘镜像${RES}"
else
	echo -e "创建失败，请重试"
	sleep 2
	QEMU_SYSTEM
	fi
	fi
	echo -e "已为你列出镜像文件夹中的常用镜像格式文件（仅供参考）\e[33m"
	ls ${DIRECT}/xinhao/windows | egrep "\.blkdebug|\.blkverify|\.bochs|\.cloop|\.cow|\.tftp|\.ftps|\.ftp|\.https|\.http|\.dmg|\.nbd|\.parallels|\.qcow|\.qcow2|\.qed|\.host_cdrom|\.host_floppy|\.host_device|\.file|\.raw|\.sheepdog|\.vdi|\.vmdk|\.vpc|\.vvfat|\.img|\.XBZJ|\.vhd|\.iso"
	sleep 1
	while [ ! -f "${DIRECT}/xinhao/windows/$hda_name" ]
	do
		if [ -n "$hda_name" ]; then
		echo -e "\n${RED}未匹配到镜像，请重试${RES}"
		sleep 1
	fi
	echo -n -e "${RES}\n请输入${YELLOW}系统镜像${RES}全名（例如andows.img）请输入: "
	read hda_name
done
	while [ ! -f "${DIRECT}/xinhao/windows/$iso_name" ]
	do
		if [ -n "$iso_name" ]; then
		echo -e "\n${RED}未匹配到镜像，请重试${RES}"
		sleep 1
	fi
	echo -n -e "请输入${YELLOW}virtio驱动盘${RES}全名,（例如virtio-win-0.1.185.iso）: "
        read iso_name
done
	echo -e "\e[33m即将开机，参数是默认的，开机过程会比较慢，Windows会自动检测fake磁盘，并搜索适配的驱动。如果失败了，前往Device Manager，找到SCSI驱动器（带有感叹号图标，应处于打开状态），点击Update driver并选择虚拟的CD-ROM。不要定位到CD-ROM内的文件夹了，只选择CD-ROM设备就行，Windows会自动找到合适的驱动的。完成后请关机，然后正常启动qemu-system-x86_64(qemu-system-i386)方式并选择磁盘接口virtio。${RES}"
	CONFIRM
qemu-system-x86_64 -m 1g -drive file=${DIRECT}/xinhao/windows/$hda_name,if=ide -drive file=${DIRECT}/xinhao/windows/fake.qcow2,if=virtio -cdrom ${DIRECT}/xinhao/windows/$iso_name -vnc :0 2>>${HOME}/.utqemu_log
exit 1 ;;
*)	INVALID_INPUT && VIRTIO
;;
esac ;;
8) ABOUT_VIRTIO ;;
9) QEMU_SYSTEM ;;
0) exit 1 ;;
*) INVALID_INPUT && VIRTIO ;;
esac
}
###################
MAIN() {
	ARCH_CHECK
	QEMU_VERSION
	SYSTEM_CHECK
	INFO
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
	echo -e "\n\e[33m请选择qemu-system-x86的运行环境\e[0m\n
	1) 直接运行，termux(utermux)目前版本为5.0以上，由于termux源的qemu编译的功能不全，强烈建议在容器上使用qemu，\e[33m其他系统的版本各不一样，一些功能参数可能没被编译进去${RES}
	2) 支持qemu5.0以下版本容器(选项内容比较简单，模拟xp建议此版本)
	3）支持qemu5.0以上版本容器(选项内容丰富)

	0) 退出\n"
	read -r -p "请选择: " input
	case $input in
	1) QEMU_SYSTEM ;;
	2) uname -a | grep 'Android' -q
if [ $? == 0 ]; then
	DEBIAN=buster
	sys_name=buster-qemu
	if [ -d $(pwd)/buster-qemu ]; then
		LOGIN
	else
		SYS_DOWN
		fi
		LOGIN
		fi ;;
	3) uname -a | grep 'Android' -q
if [ $? == 0 ]; then
	DEBIAN=bullseye
	sys_name=bullseye-qemu
	if [ -d $(pwd)/bullseye-qemu ]; then
		LOGIN
	else
		SYS_DOWN
		fi
		LOGIN
		fi ;;
	0) exit 1 ;;
	*) INVALID_INPUT
		MAIN ;;
esac
else
	QEMU_SYSTEM
	fi
}
####################
MAIN "$@"
