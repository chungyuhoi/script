#!/usr/bin/env bash
#####################
#cd $(dirname $0)
cd ${HOME}
date_t=`date +"%D"`
if ! grep -q $date_t ".date_tmp.log" 2>/dev/null; then
	echo -e "\n\e[33m为保证环境系统源正常使用，每日首次运行本脚本会先自检更新一遍哦(≧∇≦)/\e[0m"
	sleep 3
	apt update
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
		apt install $(for i in curl tar proot pulseaudio; do if [ $(command -v $i) ]; then echo $i; fi done | sed 's/\n/ /g') -y
	else
		apt install $(for i in curl tar pulseaudio; do if [ $(command -v $i) ]; then echo $i; fi done | sed 's/\n/ /g') -y
	fi
	unset i
	echo $date_t >>.date_tmp.log 2>&1
fi

clear
#######################
#COLOR
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
PINK="\e[35m"
WHITE="\e[37m"
RES="\e[0m"

#SOURCE
SOURCES_USTC="https://mirrors.ustc.edu.cn/"
SOURCES_BF="https://mirrors.bfsu.edu.cn/"
SOURCES_TUNA="https://mirrors.tuna.tsinghua.edu.cn/"
DEB_DEBIAN="main contrib non-free"
DEB_UBUNTU="main restricted universe multiverse"
#######################
TERMUX_CHECK() {
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
	if [ ! -e ${HOME}/storage ]; then
	termux-setup-storage
	fi
	if grep '^[^#]' ${PREFIX}/etc/apt/sources.list | egrep "mirror.iscas.ac.cn|mirror.nyist|aliyun.com|bfsu|cqupt|dgut|hit|nju|njupt|pku|sau|scau|sdu|sustech|tuna.tsinghua|ustc" >/dev/null 2>&1; then
		echo ""
	else
		echo -e "${YELLOW}检测到你使用的可能为非国内源，为保证正常使用，建议切换为国内源(0.73版termux勿更换)${RES}\n
		1) 换国内源
		2) 不换"
read -r -p "是否换国内源: " input
case $input in
1|"") echo "换国内源"
if [ -d /data/data/com.termux/files/usr/etc/termux/mirrors/china ]; then
ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/china /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
fi
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list && yes | pkg update
ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/china /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list && yes | pkg update
;;

	*) echo "#utqemucheck" >>${PREFIX}/etc/apt/sources.list ;;
	esac
        fi
        fi
}
#######################
TERMUX_CHECK
echo -e "${BLUE}welcome to use termux-toolx!\n
${YELLOW}更新日期20221231${RES}\n"
echo -e "这个脚本是方便使用者自定义安装设置\n包括系统包也是很干净的"
#echo -e "\n今天的天气\n$(curl -s wttr.in/shenzhen | sed '8,$d')\n"
uname -a | grep Android -q
if [ $? != 0 ]; then
	if [ `id -u` == "0" ];then
	echo -e "${BLUE}当前用户为root${RES}"
else
	echo -e "${RED}当前用户为$(whoami)${RES}\n"
	sleep 1
	fi
fi
if [ ! -e "/etc/os-release" ]; then
uname -a | grep 'Android' -q
if [ $? -eq 0 ]; then
echo "你的系统是Android"
SYS=android
fi
elif grep -q 'ID=debian' "/etc/os-release"; then
printf '你的系统是'
cat /etc/os-release | grep PRETTY | cut -d '"' -f 2
SYS=debian
elif grep -q 'ID=ubuntu' "/etc/os-release"; then
printf "你的系统是"
cat /etc/os-release | grep PRETTY | cut -d '"' -f 2
SYS=ubuntu
elif grep -q 'ID=kali' "/etc/os-release"; then
printf "你的系统是"
cat /etc/os-release | grep PRETTY | cut -d '"' -f 2
SYS=kali
fi
echo -e "你的架构为" $(dpkg --print-architecture)
echo ""
#####################
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
        read -r -p "请确认你使用的是否手机平板 1) 是 2)否 " input
        case $input in
                1) echo "tablet" >${HOME}/.utqemu_
                        DIRECT="/sdcard"
                        ARCH=tablet ;;
                2) echo "computer" >${HOME}/.utqemu_
                        DIRECT="${HOME}"
                        ARCH=computer ;;
                *) INVALID_INPUT
                        ARCH_CHECK ;;
        esac
        echo -e "${GREEN}已配置设备识别参数，如发现选错，请执行 rm ${HOME}/.utqemu_ 并新打开本脚本${RES}"
        CONFIRM
else
                        DIRECT="${HOME}"
                        ARCH=computer
                        fi ;;
                *) echo -e "${RED}不支持你设备的架构${RES}" ;;
esac
}
#####################
CHECK (){
	if [ -e /etc/os-release ]; then
        printf '你的系统是'
        cat /etc/os-release | head -n 1 | cut -d '"' -f 2
else
		echo -e "${RED}你用的不是Debian或Ubuntu系统，操作将中止...${RES}"
	sleep 2
        MAIN
	fi
if ! grep -E -q 'ID=debian|ID=ubuntu|ID=kali' "/etc/os-release"; then
	echo -e "${RED}你用的不是Debian或Ubuntu系统，操作将中止...${RES}"
	sleep 2
	MAIN
fi
}
#####################
#####################
SUDO_CHECK() {
if [ `id -u` != "0" ];then
	sudo_t="sudo"
else
	sudo_t=""
fi
}
#####################
INVALID_INPUT() {
echo -e "${RED}输入无效，请重输...${RES}" \\n
sleep 1
}
#####################
CONFIRM() {
read -r -p "按回车键继续" input
unset input
}
#####################
PROCESS_CHECK() {
if [ $? != 0 ]; then
       echo -e "${RED}下载失败，请重试${RES}"
fi
}
#####################
#echo 'deb [by-hash=force] https://d.store.deepinos.org.cn /' >/etc/apt/sources.list.d/sparkstore.list
#curl -1sLf https://d.store.deepinos.org.cn//dcs-repo.gpg-key.asc | apt-key add -
#####################
SETTLE() {
	echo -e "
1)  遇到关于Sub-process /usr/bin/dpkg returned an error code (1)错误提示
2)  安装个小火车(命令sl)
3)  增加普通用户并赋予sudo功能
4)  处理Ubuntu出现的groups: cannot find name for group *提示
5)  设置时区
6)  修改国内源地址sources.list(only for debian and ubuntu)
7)  修改dns
8)  electron资源库(仅支持debian-bullseye)
9)  python3和pip应用
10) 中文汉化
11) 安装系统信息显示(neofetch,screenfetch,conky)
12) 安装busybox(解决部分命令不可用)
13) 返回
0)  退出\n"
read -r -p "请选择: " input

case $input in
	1)
		echo "修复中..."
		sleep 1
		mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
		apt install
		echo "done"
		;;
	2)
		echo "安装个小火车，运行命令sl"
		$sudo_t apt install sl && cp /usr/games/sl /usr/local/bin && sl 
		;;
	3)
		echo -n "请输入普通用户名name: "
		read name
		if grep -qw "$name" "/etc/passwd"; then
			echo -e "${RED}你的普通用户名貌似已经有了，起个其他名字吧${RES}"
			sleep 2
			if [ ! $(command -v sudo) ]; then
echo -e "${BLUE}先帮你把这个用户的sudo功能装上。${RES}"
sleep 2
       	apt --reinstall install sudo -y
else
	read -r -p "sudo是否能用，如不能用请选择重新安装

1)重新安装 2)不需要重新安装 " input
	case $input in
		1) apt --reinstall install sudo ;;
		2|"") echo "" ;;
	esac
#	chmod +4755 /usr/bin/sudo ; chown root:root /usr/bin/sudo ; chmod +w /etc/sudoers
#	chmod -v 4755 /usr/bin/sudo
#	chmod -v 0440 /etc/sudoers
			fi
	if grep -q "$name" "/etc/sudoers"; then
		echo ""
	else
	sed -i "/^root/a\\$name ALL=(ALL:ALL) ALL" /etc/sudoers
	fi
	echo "done"
else
		adduser $name
		if [ ! -e /usr/bin/sudo ]; then
			echo -e "${BLUE}安装sudo${RES}"
			apt --reinstall install sudo
		fi
#		chmod +4755 /usr/bin/sudo && chown root:root /usr/bin/sudo && chmod +w /etc/sudoers
		sed -i "/^root/a\\$name ALL=(ALL:ALL) ALL" /etc/sudoers
		echo "done"
fi
echo "是否修改sudo临时生效时间，默认5分钟"
read -r -p "1)自定义时间 2)免密 3)不修改 " input
case $input in
	1) echo -n "请输入时间数字，以分钟为单位(例如20)sudo_time: "
		read sudo_time
		if grep -q 'timestamp' "/etc/sudoers"; then
			timestamp=`cat /etc/sudoers | grep timestamp | cut -d "=" -f 2`
			sed -i "s/env_reset,timestamp_timeout=$timestamp/env_reset,timestamp_timeout=$sudo_time/g" /etc/sudoers
		else
		sed -i "s/env_reset/env_reset,timestamp_timeout=$sudo_time/g" /etc/sudoers
	fi
	;;
	2) sed -i "/execute/a\\$name ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers ;;
*)
	echo ""
	;;
esac
;;
4) echo -e "即将编辑gid信息\n"
	sleep 3
for i in $(groups 2>/dev/null|sed "s/$(whoami)//"); do if ! grep -q "$i" /etc/group; then echo "$i:x:$i:" >>/etc/group; fi done
#for i in $(groups 2>/dev/null|sed "s/$(whoami)//"); do echo "$i:x:$i:" >>/etc/group; done; source /etc/profile
echo -e "已处理\n" ;;
5) echo "设置时区为上海"
		sed -i "/^export TZ=/d" /etc/profile
		sed -i "1i\export TZ='Asia/Shanghai'" /etc/profile
		echo "done"
		sleep 2
SETTLE ;;
	6) SOURCES_LIST ;;
	7) MODIFY_DNS ;;
	8) ADD_GITHUB ;;
	9) INSTALL_PYTHON3 ;;
	10) LANGUAGE_CHANGE ;;
	11) echo -e "\n1) neofetch
2) screenfetch
3) conky(在图形界面下使用)
9) 返回
0) 退出\n"
		read -r -p "请选择: " input
		case $input in
			1) echo "安装neofetch"
			$sudo_t	apt install neofetch -y
				echo -e "${BLUE}done${RES}"
				SETTLE ;;
			2) echo "安装screenfetch"
			$sudo_t	apt install screenfetch -y
				echo -e "${BLUE}done${RES}"
				SETTLE ;;
			3) echo "安装conky"
				$sudo_t apt install conky -y
#${execi 60 echo "Battery: $(termux-battery-status | grep percentage | awk '{print $2}' | sed 's/,//')%"}
cat >${HOME}/.conkyrc<<-'eof'
conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = true,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans Mono:size=12',
    gap_x = 10,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 5,
    maximum_width = 300,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_argb_visual = true,
    own_window_class = 'Conky',
    own_window_transparent = true,
    own_window_type = 'desktop',
    own_window_hints = 'undecorated,sticky,skip_taskbar,skip_pager,below',
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 8.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
}

conky.text = [[
#${color white}Note:$color ${scroll 32 Goodday $conky_version}
${texeci 1800 curl wttr.in/shenzhen_0pq.png -so /etc/conky/shenzhen.png}
${image /etc/conky/shenzhen.png -p 0,0}
${color white}
${color white}
${color white}
${color white}
$hr
#${exec cat /etc/conky/moo}
${color white}Uptime:$color ${execi 8 uptime|cut -d ',' -f1}
${execi 300 echo "WlanIP:" $(ip -br -4 a | grep -q wlan && ip -br -4 a | grep wlan|awk '{print $3}'||echo none)}
#${execi 300 echo "WlanIP: $(ip -br -4 a|grep wlan|awk '{print $3}'||echo None)"}
#${execi 300 echo "Battery: $(termux-battery-status | grep percentage | awk '{print $2}' | sed 's/,//')%"}
#CpuTemp: ${acpitemp}°C
#$hr
#${color white}Frequency (in GHz):$color $freq_g
${color white}CPU ${hr 1}
Frequency: ${alignr}${freq dyn} MHz
#${color0}${cpugraph cpu0 2 32,0 104E8B ff0000}
#${color0}Cpu Usage:${color #BBFFFF} ${freq dyn} MHz
#${alignc}${color0}${cpugraph cpu0 32,280}
Processes: ${alignr}$processes ($running_processes running)
${top name 1}$alignr${top cpu 1}
${top name 2}$alignr${top cpu 2}
${top name 3}$alignr${top cpu 3}
#${color white}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
#${color white}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
${color white}PROCESS $hr
${color white}Name              PID     CPU%   MEM%
${color white} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
${color white} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
${color white} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
${color white} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
${color white}SYSTEM ${hr 1}
Logname: $alignr$LOGNAME
Hostname: $alignr$nodename
Kernel: $alignr$kernel
Machine:$alignr$machine
${color white}MEMORY ${hr 1}
Ram ${alignr}$mem / $memmax ($memperc%)
${membar 4}
swap ${alignr}$swap / $swapmax ($swapperc%)
${swapbar 4}
${color white}File systems:
$color${fs_used /}/${fs_size /} ${fs_bar 6 /}
#$hr
#Highest MEM $alignr MEM%
#${top_mem name 1}$alignr ${top_mem mem 1}
#${top_mem name 2}$alignr ${top_mem mem 2}
#${top_mem name 3}$alignr ${top_mem mem 3}
#${downspeedgraph eth0 25,107} ${alignr}${upspeedgraph eth0 25,107}
]]
eof
sed -i "/Goodday/a$(sed -n 1p /etc/os-release|awk -F '"' '{print $2}')" ${HOME}/.conkyrc
if [ ! -r /sys/class/thermal/thermal_zone0/temp ]; then sed -i '/^Temp/d' ${HOME}/.conkyrc; fi
			echo -e "${BLUE}done${RES}"
			SETTLE ;;
			0) echo "exit"
				exit 0 ;;
			9) echo "返回"
				MAIN
				;;
			*) INVALID_INPUT
				SETTLE ;;
		esac ;;
	12) $sudo_t apt install busybox -y
		echo -e 'busybox用法：
例如 ps 不可用，请使用命令
ln -sf $(command -v busybox) $(command -v ps)'
		;;
	0) echo "exit"
		exit 0 ;;
	13) echo "返回"
		MAIN
		;;
	*) INVALID_INPUT
		 ;;
esac
	SETTLE
}
################
LANGUAGE_CHANGE(){
                        echo "1)修改为中文; 2)修改为英文"
			read -r -p "1) 2) " input
			case $input in
			1) $sudo apt install fonts-wqy-zenhei locales -y
			sed -i '/zh_CN.UTF/s/#//' /etc/locale.gen
			locale-gen || /usr/sbin/locale-gen
			sed -i '/^export LANG/d' /etc/profile && sed -i '1i\export LANG=zh_CN.UTF-8' /etc/profile && source /etc/profile && export LANG=zh_CN.UTF-8 && echo '修改完毕,请重新登录' && sleep 2 && SETTLE ;;
2) export LANG=C.UTF-8 && sed -i '/^export LANG/d' /etc/profile && echo '修改完毕，请重新登录' && sleep 2 && SETTLE ;;
*) INVALID_INPUT
LANGUAGE_CHANGE ;;
esac
}
#################
SOURCES() {
if [ -e /etc/os-release ]; then
	echo ""
else
	echo -e "${RED}你用的不是Debian或Ubuntu系统，操作将中止...${RES}"
	sleep 2
	MAIN
fi
CHECK
	case $(cat /etc/os-release) in
		*bionic*)
echo "deb ${SOURCES_BF}ubuntu-ports/ bionic ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ bionic-updates ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ bionic-backports ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ bionic-security ${DEB_UBUNTU}" >/etc/apt/sources.list ;;
		*focal*)
echo "deb ${SOURCES_BF}ubuntu-ports/ focal ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ focal-updates ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ focal-backports ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ focal-security ${DEB_UBUNTU}" >/etc/apt/sources.list ;;
		*Groovy*)
echo "deb ${SOURCES_BF}ubuntu-ports/ groovy ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ groovy-updates ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ groovy-backports ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ groovy-security ${DEB_UBUNTU}" >/etc/apt/sources.list ;;
		*kali*)
echo "deb ${SOURCES_USTC}kali kali-rolling ${DEB_DEBIAN}
deb-src http://mirrors.ustc.edu.cn/kali kali-rolling ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*strentch*)
echo "deb ${SOURCES_BF}debian/ stretch ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ stretch-updates ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ stretch-backports ${DEB_DEBIAN}
deb ${SOURCES_BF}debian-security stretch/updates ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*jessie*)
echo "deb ${SOURCES_BF}debian/ jessie ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ jessie-updates ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ jessie-backports ${DEB_DEBIAN}
deb ${SOURCES_BF}debian-security jessie/updates ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*buster*)
echo "deb ${SOURCES_BF}debian/ buster ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ buster-updates ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ buster-backports ${DEB_DEBIAN}
deb ${SOURCES_BF}debian-security buster/updates ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*bullseye*|*sid*)
echo "deb ${SOURCES_BF}debian/ bullseye ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ bullseye-updates ${DEB_DEBIAN}
deb ${SOURCES_BF}debian/ bullseye-backports ${DEB_DEBIAN}
deb ${SOURCES_BF}debian-security bullseye-security ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*)
echo -e "${RED}未收录你的系统源${RES}"
sleep 2
	SOURCES_LIST ;;
esac
dpkg -l ca-certificates | grep ii
if [ $? == 1 ]; then
sed -i "s/https/http/g" /etc/apt/sources.list
apt update && $sudo_t apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list
fi
apt update
echo "done"
sleep 2
SOURCES_LIST
}
#####################
SOURCES_LIST() {
echo -e \\n
if [ -e /etc/os-release ]; then
	printf "你的系统是"
	cat /etc/os-release | head -n 1 | cut -d '"' -f 2
fi
echo -e "仅支持debian和ubuntu
1) 修改debian或ubuntu国内源
2) 更新源列表
3) 为http修改为https(使用 HTTPS 可以有效避免国内运营商的缓存劫持)
9) 返回
0) 退出${RES}"
read -r -p "请选择: " input

case $input in
       	1)
		echo "修改debian或ubuntu国内源"
		SOURCES
		;;
	
	2)
		echo "更新源列表"
		apt update && SOURCES_LIST
		;;

        3)
                echo "fixing..."
		sleep 1
		sed -i "s/https/http/g" /etc/apt/sources.list 2>/dev/null
		apt update && $sudo_t apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update && SOURCES_LIST
                ;;
	0)                    
		echo "exit"                       
		exit 0
		;;
	9)
		echo "back to main"
		MAIN
		;;
        *)
		INVALID_INPUT
		SOURCES_LIST
                ;;
esac
}
#######################
MODIFY_DNS() {
echo -e "${YELLOW}是否修改DNS${RES}"
read -r -p "1)是 2)否 9)返回 0)退出 " input

case $input in
	1|"")
		echo "Yes"
if [ ! -L "/etc/resolv.conf" ]; then
	echo "nameserver 223.5.5.5
nameserver 223.6.6.6" > /etc/resolv.conf
echo -e "${GREEN}已修改为${RES}\n223.5.5.5;223.6.6.6"
sleep 1
SETTLE
elif [ -L "/etc/resolv.conf" ]; then
	mkdir -p /run/systemd/resolve 2>/dev/null && echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >/run/systemd/resolve/stub-resolv.conf
echo -e "${GREEN}已修改为\n223.5.5.5;223.6.6.6${RES}"
sleep 1
SETTLE
else
	echo "你的系统不支持"
	sleep 2
	SETTLE
fi
	;;

	2)
		echo "No"
		SETTLE
		;;

	0) 
		echo "exit"
		exit 1
		;;
	9)
		echo "back to main"
		MAIN
			;;
	*)
		INVALID_INPUT
		MODIFY_DNS
		;;
esac
}
########################
ADD_GITHUB() {
	echo -e "\n${YELLOW}注意，目前仅支持debian(bullseye),建议先安装常用应用\n请在root用户下操作${RES}"
	CONFIRM
	CHECK

$sudo_t apt install libnss3 unzip wget gnupg2 libxtst-dev apt-transport-https -y
if [ ! $(command -v electron) ]; then
mkdir /usr/share/electron
cd /usr/share/electron
#最新版本
#VERSION=`curl https://registry.npmmirror.com/-/binary/electron/|sed 's/name/\n/g'|cut -d '"' -f 3|sed 's/\n//g;s/\///'|grep '^v2'|tail -n 1`; wget https://registry.npmmirror.com/-/binary/electron/${VERSION}/electron-${VERSION}-linux-arm64.zip
wget https://registry.npmmirror.com/-/binary/electron/v8.5.5/chromedriver-v8.5.5-linux-arm64.zip
wget https://registry.npmmirror.com/-/binary/electron/v8.5.5/ffmpeg-v8.5.5-linux-arm64.zip
wget https://registry.npmmirror.com/-/binary/electron/v8.5.5/electron-v8.5.5-linux-arm64.zip
echo -e "\e[33m即将解压包，如遇到提示，请输y回车\e[0m"
read -r -p "确认请回车" input
unset input
unzip -n chromedriver-v8.5.5-linux-arm64.zip
unzip -n ffmpeg-v8.5.5-linux-arm64.zip
unzip -n electron-v8.5.5-linux-arm64.zip
ln -s /usr/share/electron/electron /usr/bin/
curl -1sLf 'https://dl.cloudsmith.io/public/debianopt/debianopt/setup.deb.sh' | sudo -E bash
if ! grep -q 'Package: electron' /var/lib/dpkg/status; then
cat >>/var/lib/dpkg/status<<-EOF
Package: electron
Version: 8.5.5
Architecture: arm64
Status: install ok installed
Priority: extra
Section: devel
Maintainer: coslyk <cos.lyk@gmail.com>
Installed-Size: 200 MB
Homepage: https://github.com/electron/electron
Download-Size: 56.7 MB
APT-Sources: https://dl.cloudsmith.io/public/debianopt/debianopt/deb/debian bullseye/main arm64 Packages
Description: Build cross platform desktop apps with web technologies
EOF
touch /var/lib/dpkg/info/electron.list
fi
fi
electron --version --no-sandbox
apt show electron-netease-cloud-music >/dev/null 2>&1
if [ $? != 0 ]; then
	if [ ! -d /etc/apt/sources.list.d ]; then
	mkdir /etc/apt/sources.list.d
	fi
	cat >/etc/apt/sources.list.d/debianopt-debianopt.list<<-eof
deb [signed-by=/usr/share/keyrings/debianopt-debianopt-archive-keyring.gpg] https://dl.cloudsmith.io/public/debianopt/debianopt/deb/debian bullseye main
deb-src [signed-by=/usr/share/keyrings/debianopt-debianopt-archive-keyring.gpg] https://dl.cloudsmith.io/public/debianopt/debianopt/deb/debian bullseye main
eof
#apt show electron|sed -E 's/(^Version: ).*$/\18.5.5/;/Depends/d;/Version/aArchitecture: arm64\nStatus: install ok installed' >>/var/lib/dpkg/status
fi
apt update && SETTLE
sleep 1
}
###################
XSESSION(){
	mkdir -p /etc/X11/xinit/
echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
if [[ $(id -u) = 0 ]];then
	if [ ! -d /tmp/runtime-$(id -u) ]; then
		#mkdir -pv "/var/run/user/$(id -u)"
		mkdir -pv /tmp/runtime-$(id -u)
	fi
	chmod -R 1777 "/tmp/runtime-$(id -u)"
#	service dbus start
else
	if [ ! -d /tmp/runtime-$(id -u) ]; then
		sudo mkdir -pv "/tmp/runtime-$(id -u)"
	fi
	sudo chmod -R 1777 "/tmp/runtime-$(id -u)"
#	sudo service dbus start
fi
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
if [ $(command -v xfce4-session) ]; then
	dbus-launch xfce4-session
else
	dbus-launch startxfce4
fi' >/etc/X11/xinit/Xsession.bak && chmod +x /etc/X11/xinit/Xsession.bak
}
XSTARTUP(){
if [ ! -e ${HOME}/.vnc ]; then
	mkdir ${HOME}/.vnc
fi
cp /etc/X11/xinit/Xsession.bak ${HOME}/.vnc/xstartup && chmod +x ${HOME}/.vnc -R
echo -e "${GREEN}请选择使用哪个图形界面${RES}"
read -r -p "1)xfce4 2)lxde " input
case $input in
        1) echo -e "done" && sleep 2 ;;
        2) sed -i "s/startxfce4/startlxde/g" ${HOME}/.vnc/xstartup
		sed -i "s/xfce4-session/lxsession/g" ${HOME}/.vnc/xstartup
#		$sudo_t apt purge --allow-change-held-packages gvfs udisks2 -y 2>/dev/null
echo -e "done" && sleep 2 ;;
	3) sed -i "s/xfce4-session/mate-session/g" ${HOME}/.vnc/xstartup
		sed -i "s/startxfce4/mate-panel/g" ${HOME}/.vnc/xstartup


#                $sudo_t apt purge --allow-change-held-packages gvfs udisks2 -y 2>/dev/null
                echo -e "done" && sleep 2
                ;;
        *)
                INVALID_INPUT
                ;;
esac
VNCSERVER
}
###################
VNCSERVER(){
if [ ! -f /etc/X11/xinit/Xsession.bak ]; then
	XSESSION
fi
	echo -e "\n1)  安装tightvncserver
2)  安装tigervncserver (推荐)
3)  安装vnc4server
4)  配置vnc的xstartup参数
5)  设置tigervnc分辨率
6)  创建另一个VNC启动脚本（推荐 命令easyvnc）
7)  创建xsdl启动脚本(命令easyxsdl)
8)  创建局域网vnc连接(命令easyvnc-wifi)
11) 返回
0)  退出\n${RES}"
read -r -p "请选择: " input
case $input in
	1)
		echo -e "${YELLOW}安装tightvncserver"
	$sudo_t apt install tightvncserver -y
	if [ ! -e "${HOME}/.vnc/passwd" ]; then       
		echo -e "请设置vnc密码,6到8位(输入内容不反显)\n\e[32m输完请按提示输y再设置一遍\e[0m" 
	       	vncpasswd                           
fi
XSTARTUP
	echo -e "${BLUE}已安装，请输vncserver :0并打开vnc viewer地址输127.0.0.1:0${RES}"
	sleep 2
	INSTALL_SOFTWARE
	;;
2)
	echo "安装tigervncserver"
	$sudo_t apt install tigervnc-standalone-server tigervnc-viewer -y
	if [ ! -e "${HOME}/.vnc/passwd" ]; then     
		echo -e "请设置vnc密码,6到8位(输入内容不反显)\n\e[32m输完请按提示输y再设置一遍\e[0m" 
	       	vncpasswd                                
fi
XSTARTUP
	echo -e "${BLUE}已安装，请输vncserver :0并打开vnc viewer地址输127.0.0.1:0${RES}"
	sleep 2
	INSTALL_SOFTWARE
	;;
3)
	echo "安装vnc4server"
	$sudo_t apt install vnc4server -y
	if [ ! -e "${HOME}/.vnc/passwd" ]; then    
		echo -e "请设置vnc密码,6到8位(输入内容不反显)\n\e[32m输完请按提示输y再设置一遍\e[0m" 
	       	vncpasswd                         
	fi
	XSTARTUP
	echo -e "${BLUE}已安装，请输vncserver :0并打开vnc viewer地址输127.0.0.1:0${RES}"
	sleep 2
	INSTALL_SOFTWARE
	;;
4) XSTARTUP ;;
5) echo -n "输入你手机分辨率,例如 2340x1080 (默认请回车) resolution: "
	read resolution
	if [ -z $resolution ]; then
		resolution=1024x768
	fi
	ex_resolution=`cat /etc/vnc.conf | grep '^$geometry' | cut -d '=' -f 2`
	sed -i "s/$ex_resolution/\"${resolution}\"\;/g" /etc/vnc.conf
	echo "已修改，请重新打开vnc"
	sleep 1
	INSTALL_SOFTWARE
	;;
6)
	echo "创建另一个VNC启动脚本（命令easyvnc）"
	if [ ! -e /usr/bin/tigervncserver ]; then
		echo "检测到你没安装tigervnc，将先安装tigervnc"
		CONFIRM
	$sudo_t	apt install tigervnc-standalone-server tigervnc-viewer -y
	fi
	if [ ! -e "${HOME}/.vnc/passwd" ]; then
		echo -e "请设置vnc密码,6到8位(输入内容不反显)\n\e[32m输完请按提示输y再设置一遍\e[0m"
		vncpasswd
	fi
	echo -n "输入你手机分辨率,例如 2340x1080 (默认请回车) resolution: "
        read resolution
	if [ -z $resolution ]; then
		resolution=1024x768
	fi
echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
export USER="$(whoami)"
export PULSE_SERVER=127.0.0.1
Xvnc -ZlibLevel=1 -quiet -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 1024x768 -once -depth 24 -localhost -securitytypes None :0 &
export DISPLAY=:0
. /etc/X11/xinit/Xsession 2>/dev/null &
am start -n com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity
exit 0' >/usr/local/bin/easyvnc && chmod +x /usr/local/bin/easyvnc
sed -i "s/1024x768/$resolution/" /usr/local/bin/easyvnc
cp /etc/X11/xinit/Xsession.bak /etc/X11/xinit/Xsession
#$sudo_t apt purge --allow-change-held-packages gvfs udisks2 -y 2>/dev/null
U_ID=`id | cut -d '(' -f 2 | cut -d ')' -f 1`
GROUP_ID=`id | cut -d '(' -f 4 | cut -d ')' -f 1`
touch .ICEauthority .Xauthority 2>/dev/null
sudo -E chown -Rv $U_ID:$GROUP_ID ".ICEauthority" ".Xauthority"
echo -e "${GREEN}请选择你已安装的图形界面${RES}"
read -r -p "1)xfce4 2)lxde 3)mate " input
	case $input in
	1) echo -e "done" && sleep 2 && INSTALL_SOFTWARE ;;
	2)
sed -i "s/startxfce4/startlxde/g" /etc/X11/xinit/Xsession
sed -i "s/xfce4-session/lxsession/g" /etc/X11/xinit/Xsession
echo -e "Done\n打开vnc viewer地址输127.0.0.1:0\nvnc的退出，在系统输exit即可"
sleep 2
INSTALL_SOFTWARE
;;
3) 
sed -i "s/startxfce4/mate-panel/g" /etc/X11/xinit/Xsession
sed -i "s/xfce4-session/mate-session/g" /etc/X11/xinit/Xsession
		echo -e "Done\n打开vnc viewer地址输127.0.0.1:0\nvnc的退出，在系统输exit即可"
		sleep 2
		INSTALL_SOFTWARE
		;;
*) echo -e "${RED}输入无效，已中止${RES}"
	sleep 2
VNCSERVER
esac ;;
7)
echo -e "\n\e[33m使用的时候需先打开手机xsdl！\e[0m"
read -r -p "按回车继续 " input
case $input in
        *) echo "" ;;
esac
$sudo_t apt install xserver-xorg x11-utils
echo -e "${YELLOW}请选择你的桌面
1) startxfce4
2) startlxde${RES}"
read -r -p "请选择: " input
case $input in
1) XWIN="x-window-manager & dbus-launch startxfce4" ;;
2) XWIN="x-window-manager & dbus-launch startlxde" ;;
3) XWIN="x-window-manager & dbus-launch mate-session" ;;
*) echo -e "\e[1;31m输入无效，已退出\e[0m"
	sleep 2
	VNCSERVER ;;
esac
# ip -4 -br -c a | awk '{print $NF}' | cut -d '/' -f 1 | grep -v '127\.0\.0\.1' | sed "s@\$@:5901@"
echo '#!/usr/bin/env bash
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
export DISPLAY=127.0.0.1:0
export PULSE_SERVER=tcp:127.0.0.1:4713' >/usr/local/bin/easyxsdl
echo "$XWIN" >>/usr/local/bin/easyxsdl && chmod +x /usr/local/bin/easyxsdl
echo -e "${YELLOW}已创建，命令easyxsdl${RES}"
sleep 2
INSTALL_SOFTWARE
;;
8) echo -e "\n创建局域网vnc连接(命令easyvnc-wifi)"
	if [ ! -f /usr/local/bin/easyvnc ]; then
		echo -e "请先安装easyvnc"
		CONFIRM
		VNCSERVER
	fi
cp /usr/local/bin/easyvnc /usr/local/bin/easyvnc-wifi
sed -i '/exit/d' /usr/local/bin/easyvnc-wifi
cat >>/usr/local/bin/easyvnc-wifi<<-'eof'
IP=`ip -4 -br a | awk '{print $3}' | cut -d '/' -f 1 | sed -n 2p`
echo -e "\e[33mVNCVIEWER打开地址为$IP:0\e[0m\n"
sleep 2
exit 0
eof
chmod +x /usr/local/bin/easyvnc-wifi
echo -e "\n${YELLOW}已配置${RES}"
sleep 2
INSTALL_SOFTWARE
;;
9) $sudo_t apt install xvfb x11vnc -y
	echo -n "输入你手机分辨率(例如:2340x1080) : "
	read resolution
	if [ -z $resolution ]; then
		resolution=1024x768
	fi
cat >/usr/local/bin/easyx11vnc<<-'eof'
#!/usr/bin/env bash
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
vncserver -kill $DISPLAY 2>/dev/null
export PULSE_SERVER=127.0.0.1
export DISPLAY=:233
#####################
start_xvfb() {
set -- "${@}" "${DISPLAY}"
set -- "${@}" "-screen" "0" "1080x2320x24"
set -- "${@}" "-ac"
set -- "${@}" "+extension" "GLX"
set -- "${@}" "+render"
set -- "${@}" "-deferglyphs" "16"
set -- "${@}" "-br"
set -- "${@}" "-retro"
set -- "${@}" "-noreset"
set -- "Xvfb" "${@}"
"${@}" & >/dev/null 2>&1
}
start_x11vnc() {
set -- "${@}" "-localhost"
set -- "${@}" "-ncache_cr"
set -- "${@}" "-xkb"
set -- "${@}" "-noxrecord"
#set -- "${@}" "-noxfixes"
set -- "${@}" "-noxdamage"
set -- "${@}" "-display" "${DISPLAY}"
set -- "${@}" "-forever"
set -- "${@}" "-bg"
set -- "${@}" "-rfbauth" "${HOME}/.vnc/passwd"
set -- "${@}" "-users" "$(whoami)"
set -- "${@}" "-rfbport" "5900"
set -- "${@}" "-noshm"
set -- "${@}" "-desktop" "${desktop}"
set -- "${@}" "-shared"
set -- "${@}" "-verbose"
set -- "${@}" "-cursor" "arrow"
set -- "${@}" "-arrow" "2"
set -- "${@}" "-nothreads"
set -- "x11vnc" "${@}"
"${@}" & >/dev/null 2>&1
}
echo -e "如无法启动，请ctrl+c退出"
start_xvfb
. /etc/X11/xinit/Xsession &
start_x11vnc
###########
eof
sed -i "s/1080x2320/${resolution}/" /usr/local/bin/easyx11vnc
chmod +x /usr/local/bin/easyx11vnc
echo -e "\n已配置，启动命令${YELLOW}easyx11vnc${RES}\n"
sleep 1
INSTALL_SOFTWARE
	;;
10) $sudo_t apt install novnc xvfb x11vnc tigervnc-standalone-server tigervnc-viewer net-tools -y
cat >/usr/local/bin/easynovnc<<-'eof'
read -r -p "是否使用vncviewer密码 1)密码(建议) 2)免密 3)修改密码 :" input
case $input in
1) if [ ! -f ${HOME}/.vnc/passwd ]; then
mkdir -p ${HOME}/.vnc
vncpasswd
fi
PASS="-rfbauth ${HOME}/.vnc/passwd" ;;
3) if [ ! -f ${HOME}/.vnc/passwd ]; then
mkdir -p ${HOME}/.vnc
fi
vncpasswd
PASS="-rfbauth ${HOME}/.vnc/passwd" ;;
*)
PASS="-SecurityTypes None" ;;
esac
vncserver -kill $DISPLAY 2>/dev/null
for i in Xtightvnc Xtigertvnc Xvnc vncsession; do pkill -9 $i 2>/dev/null; done
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=:0
Xvnc -ZlibLevel=1 -securitytypes vncauth,tlsvnc -verbose -ImprovedHextile -CompareFB 1 -br -retro -a 5 -alwaysshared -geometry 2320x1080 -once -depth 24 -deferglyphs 16 $PASS &
. /etc/X11/xinit/Xsession 2>/dev/null &
bash /usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 6080 2>/dev/null
echo -e "请打开浏览器输\e[33mhttp://localhost:6080/vnc.html\e[0m"
eof
chmod 756 /usr/local/bin/easynovnc
INSTALL_SOFTWARE
;;
0)
	echo "exit"
	exit 1
	;;
11)
	MAIN
	;;
*)
		INVALID_INPUT
		INSTALL_SOFTWARE
		;;
esac
}

##########################
WEB_BROWSER() {
	echo -e "1) 安装谷歌浏览器chromium
2) 安装火狐浏览器firefox
3) 安装epiphany-browser浏览器
4) 安装360浏览器(有一个月使用限制，需向360获取授权码)
9) 返回
0) 退出\n${RES}"
read -r -p "请选择: " input
	case $input in
	1)
		if [ ! -d /run/shm ]; then
			mkdir /run/shm
		fi
		echo -e "安装谷歌浏览器chromium"
		if grep -q 'ID=debian' "/etc/os-release"; then
			$sudo_t apt install chromium -y
		elif grep -q 'ID=kali' "/etc/os-release"; then
			$sudo_t apt install chromium -y
		elif grep -q 'bionic' "/etc/os-release"; then
			$sudo_t apt install chromium-browser chromium-codecs-ffmpeg-extra -y
		elif grep -q 'ID=ubuntu' "/etc/os-release"; then
			echo -e "${YELLOW}你所使用的ubuntu源装chromium目前有bug${RES}
1) 尝试通过ppa源安装(未完全测试)
0) 返回"
read -r -p "请选择: " input
case $input in
	1) echo "检测到你用的ubuntu系统,将切换ppa源下载,下载过程会比较慢,请留意进度"
			sleep 2
			$sudo_t apt install axel -y
CURL="http://ppa.launchpad.net/xalt7x/chromium-deb-vaapi/ubuntu/pool/main/c/chromium-browser/"
BRO="$(curl $CURL | grep arm64 | head -n 2 | tail -n 1 | cut -d '"' -f 8)"
axel -o chromium.deb ${CURL}${BRO}
BRO_FF="$(curl $CURL | grep arm64.deb | grep ffmpeg | tail -n 3 | head -n 1 | cut -d '"' -f 8)"
axel -o chromium_ffmpeg.deb ${CURL}${BRO_FF}
axel -o chromium-browser-l10n.deb ${CURL}$(curl ${CURL} | grep chromium-browser-l10n | awk -F 'href="' '{print $2}' | cut -d '"' -f 1 | tail -n 1)
$sudo_t dpkg -i chromium.deb
$sudo_t dpkg -i chromium_ffmpeg.deb
$sudo_t dpkg -i chromium-browser-l10n.deb
rm chromium*
sudo echo "chromium-browser hold" | sudo dpkg --set-selections
sudo echo "chromium-browser-l10n hold" | sudo dpkg --set-selections
sudo echo "chromium-codecs-ffmpeg-extra hold" | sudo dpkg --set-selections
$sudo_t apt --fix-broken install -y
echo -e "\n${YELLOW}如安装失败，请重试${RES}"
CONFIRM ;;
*) WEB_BROWSER ;;
esac
sleep 2
else
        echo -e "${RED}你用的不是Debian或Ubuntu系统，操作将中止...${RES}"
sleep 2
WEB_BROWSER
fi
	if [ -e /usr/share/applications/chromium.desktop ]; then
		sed -E -i "s/(^Exec=.* )/\1--no-sandbox /g" /usr/share/applications/chromium.desktop
	elif [ -e /usr/share/applications/chromium-browser.desktop ]; then
		sed -i "s/Exec=chromium-browser %U/Exec=chromium-browser --no-sandbox \%U/g" /usr/share/applications/chromium-browser.desktop
		fi
		echo -e "${YELLOW}done..${RES}"
	sleep 1
	WEB_BROWSER
	;;
2)
	echo -e "${YELLOW}安装火狐浏览器firefox${RES}"
	if grep -q 'ID=debian' "/etc/os-release"; then                 $sudo_t apt install firefox-esr -y && sed -i "s/firefox-esr %u/firefox-esr --no-sandbox \%u/g" /usr/share/applications/firefox-esr.desktop 2>/dev/null
		elif grep -q 'ID=kali' "/etc/os-release"; then
			$sudo_t apt install firefox-esr -y && sed -i "s/firefox-esr %u/firefox-esr --no-sandbox \%u/g" /usr/share/applications/firefox-esr.desktop 2>/dev/null
	elif grep -q 'ID=ubuntu' "/etc/os-release"; then
		$sudo_t apt install firefox firefox-locale-zh-hans ffmpeg
	else
		echo -e "${RED}你用的不是Debian或Ubuntu系统，操作将中止...${RES}"
		sleep 2
		WEB_BROWSER
	fi
	if grep -q '^ex.*MOZ_FAKE_NO_SANDBOX=1' /etc/environment; then
		printf "%s\n" "MOZ_FAKE_NO_SANDBOX=1" /etc/environment
	else
		echo 'export MOZ_FAKE_NO_SANDBOX=1' >>/etc/environment
	fi
	if ! grep -q 'PATH' /etc/environment; then
		sed -i '1i\PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' /etc/environment
	fi
	if ! grep -q 'environment' /etc/profile; then
		echo 'source /etc/environment' >>/etc/profile
	fi
	echo -e "\n\e[0;32m因firefox限制，已帮你修正设置。如仍然无法上网，请打开firefox，在地址栏输about:config，搜索并修改如下信息:
	media.cubeb.sandbox的值改成false
	security.sandbox.content.level的值改成0
	修改完成后重新打开vnc才能正常使用${RES}"
	CONFIRM
	WEB_BROWSER
	;;
3)
	echo -e "${YELLOW}安装浏览器epiphany-browser${RES}"
	$sudo_t apt install epiphany-browser
	echo -e "${YELLOW}done${RES}"
	sleep 1
	WEB_BROWSER
	;;
4) echo -e "${YELLOW}安装360浏览器${RES}"
	curl https://browser.360.cn/se/linux/ -o 360
	cur=`cat 360 | grep "arm" | head -n 1 | cut -d "'" -f 2`
	curl http://$cur -o 360.deb
	if [ $? = 0 ]; then
		$sudo_t dpkg -i 360.deb
		rm 360.deb 360
		echo "安装完成"
		sleep 2
		WEB_BROWSER
	else -e "${RED}下载失败，请重试${RES}"
		sleep 2
		WEB_BROWSER
	fi
	;;
	0)
		echo "exit"
		exit 1
		;;
	9)
		MAIN
		;;
	*)
		INVALID_INPUT
		WEB_BROWSER
		;;
esac
}
#######################
DM() {
	echo -e "安装桌面图形界面
	1) 安装xfce4
	2) 安装lxde
	9) 返回
	0) 退出\n"
	read -r -p "请选择: " input
	case $input in
		1) $sudo_t apt install xfce4 xfce4-terminal ristretto dbus-x11 lxtask --no-install-recommends -y
			VNCSERVER
			;;
		2) $sudo_t apt install lxde-core lxterminal dbus-x11 lxdm --no-install-recommends -y
#			apt purge lxpolkit -y
	for i in /etc/xdg/autostart/lxpolkit.desktop /usr/bin/lxpolkit; do
		if [ -f "${i}" ]; then
			mv -f ${i} ${i}.bak 2>/dev/null
		fi
	done
#	sed -i 's/quick_exec=0/quick_exec=1/' /root/.config/libfm/libfm.conf
mkdir -p /root/.config/libfm
echo -e '[config]\nquick_exec=1' >/root/.config/libfm/libfm.conf
			VNCSERVER
			;;
		3) 
#			$sudo_t apt install mate-desktop-environment mate-terminal -y
#mate-desktop-environment-core
		$sudo_t apt install --no-install-recommends mate-desktop-environment mate-session-manager mate-settings-daemon marco mate-terminal mate-panel dbus-x11 -y && apt purge ^libfprint -y
			VNCSERVER
			;;
		0) echo "exit"
			exit 1 ;;
		9) echo "back to main"
			MAIN ;;
		*) INVALID_INPUT
			DM ;;
	esac
	echo -e "${YELLOW}done${RES}"
                        sleep 1
                        INSTALL_SOFTWARE
}
#######################
DM_VNC() {
	echo -e "\n1) 安装桌面图形界面
2) 安装VNCSERVER远程服务
9) 返回
0) 退出${RES}\n"
	read -r -p "请选择: " input
	case $input in
		1) DM ;;
		2) VNCSERVER ;;
		0) echo "exit"
			exit 1 ;;
		9) echo "back to main"
			MAIN ;;
		*) INVALID_INPUT
			DM_VNC ;;
	esac
}
#######################
ENTERTAINMENT() {
	echo -e "\n1) minetest(画面跟我的世界相似，方向是个问题，需键盘操作)
2) mame街机模拟器(需键盘操作)
3) fc模拟器(需键盘操作)
9) 返回
0) 退出\n"
read -r -p "请选择: " input
case $input in
	1) echo -e "正在安装minetest"
	$sudo_t apt install minetest -y
	if echo $PATH | grep -vq games; then
	ln -s /usr/games/minetest /usr/local/bin
	fi
	if [ ! -f /usr/share/locale/zh_CN/LC_MESSAGES/minetest.mo ]; then
	curl -O https://shell.xb6868.com/ut/files/MINETEST_MO.tar.gz
	tar zxvf MINETEST_MO.tar.gz && $sudo_t mv minetest.mo /usr/share/locale/zh_CN/LC_MESSAGES/ && rm MINETEST_MO.tar.gz
	fi
	echo -e "\n是否中文界面(不建议，默认随系统语言)"
		read -r -p "1)是 2)否 " input
		case $input in
		1) mkdir -p ${HOME}/.minetest/
			echo 'language = zh_CN' >${HOME}/.minetest/minetest.conf ;;
		*) ;;
		esac
		ENTERTAINMENT ;;
	2) echo -e "正在安装mame,游戏rom请放/usr/share/games/mame/rom"
		sleep 2
		$sudo_t apt install mame mame-doc mame-extra mame-tools -y
		cat >/usr/local/bin/m_mame<<'EOF'
#!/usr/bin/env bash
echo -e "\e[33m
关于mame\n
支持的游戏并不多，自己多尝试一下\n
游戏rom存放路径为/usr/share/games/mame/roms\n
一些功能菜单键，是需要组合键ctrl使用，例如菜单项切换ctrl+tab，投币ctrl+5，开启游戏ctrl+1\n
游戏的配置可在游戏界面修改，也可以在主目录下.mame/mame.ini修改\e[0m\n"
EOF
chmod +x /usr/local/bin/m_mame
		echo -e "${YELLOW}已为你写了使用手册，请直接输指令 m_mame${RES}"
		sleep 2
		ENTERTAINMENT ;;
	3) $sudo_t apt install fceux -y
mkdir -p ${HOME}/.fceux/input/keyboard
echo 'keyboard,default,a:kK,b:kJ,back:kSpace,start:kReturn,dpup:kW,dpdown:kS,dpleft:kA,dpright:kD,turboA:kI,turboB:kU,' >${HOME}/.fceux/input/keyboard/default.txt
exho 'SDL.VideoDriver = 1' >${HOME}/.fceux/fceux.cfg
#sed -i '/SDL.VideoDriver/s/0/1/' >${HOME}/.fceux/fceux.cfg
		;;
	0) exit 0 ;;
	9) MAIN ;;
	*) INVALID_INPUT
		ENTERTAINMENT ;;
esac
}
#######################
INSTALL_SOFTWARE() {
echo -e "\n\n${RED}建议先安装常用应用\n${RES}"
echo -e "1)  *安装常用应用(目前包括curl,wget,vim,fonts-wqy-zenhei,tar)${RES}
2)  *桌面图形界面及VNCSERVER远程服务${RES}
3)  浏览器
4)  安装Electron(需先安装GitHub仓库)
5)  安装非官方版electron-netease-cloud-music(需先安装electron)
6)  中文输入法
7)  多媒体播放器
8)  办公office软件
9)  安装dosbox并配置dosbox文件目录
10) qemu-system-x86_64模拟器
11) 游戏相关
12) 让本终端成为局域网服务器
13) 新立得(类软件商店)
14) linux版qq
15) 安装默认版本java
16) 返回
0)  退出\n"
read -r -p "请选择: " input

case $input in
	1)
		echo "安装常用应用..."
		$sudo_t apt install curl wget vim fonts-wqy-zenhei tar wget -y
		echo -e "${YELLOW}done${RES}"
		sleep 1
		INSTALL_SOFTWARE
		
		;;
	2)	DM_VNC ;;
	3)	WEB_BROWSER ;;
	4)	echo -e "安装Electron\n如果安装不成功，需先添加Githut库"
		CONFIRM
		ADD_GITHUB
		INSTALL_SOFTWARE
		;;
	5)
		dpkg -l | grep electron -q
if [ "$?" == '0' ]; then
echo -e "${BLUE}检测到已安装Electron${RES}"
sleep 1
else
	echo -e "${BLUE}检测到你未安装electron，需先安装electron(目前仅支持bullseye)${RES}"
CONFIRM
SETTLE
fi
echo "正在安装非官方版electron-netease-cloud-music"
$sudo_t apt install electron-netease-cloud-music
if [ -e /usr/bin/electron-netease-cloud-music ]; then
	echo "#!/bin/bash
exec electron /opt/electron-netease-cloud-music/app.asar --no-sandbox" > /usr/bin/electron-netease-cloud-music
echo -e "${BLUE}请在图形界面查看是否安装成功${RES}"
else
	echo -e "${RED}安装失败${RES}"
fi
sleep 1
INSTALL_SOFTWARE
;;
6) echo -e "\n1) fcitx输入法
2) ibus输入法
9) 返回
0) 退出\n"
read -r -p "请选择: " input
case $input in
	1) echo -e "${YELLOW}安装fcitx输入法${RES}"
	$sudo_t apt install fcitx*googlepinyin* fcitx-table-wubi fcitx-tools fcitx-config-gtk
#apt install fcitx fcitx-module-dbus fcitx-module-kimpanel fcitx-module-lua fcitx-module-x11 fcitx5-module-quickphrase-editor aspell-en enchant-2 presage fcitx-googlepinyin fcitx-config-gtk fcitx-frontend-all fcitx-ui-classic im-config fcitx-frontend-qt5 hunspell-en-us qttranslations5-l10n libqt5svg5 qt5-gtk-platformtheme fcitx-frontend-gtk2 fcitx-frontend-gtk3 zenity --no-install-recommends
#fcitx fcitx-tools fcitx-config-gtk fcitx-googlepinyin
if ! grep -q 'fcitx' /etc/profile; then
echo 'export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export SDL_IM_MODULE=fcitx' >>/etc/profile
fi
	echo -e "${YELLOW}done${RES}"
	sleep 1
	INSTALL_SOFTWARE
	;;
2) echo -e "${YELLOW}安装ibus输入法${RES}"
	$sudo_t apt install ibus-libpinyin ibus-table-wubi
	echo -e "${YELLOW}done${RES}"                       
	sleep 1                                             
	INSTALL_SOFTWARE
        ;;
0) exit 2 ;;
9) MAIN ;;
*) INVALID_INPUT
	INSTALL_SOFTWARE ;;
esac
;;
7) read -r -p "1)mpv播放器 2)vlc播放器 9) 返回 0)退出 : " input
	case $input in
		1)
	echo "安装mpv播放器"
	$sudo_t apt install mpv --no-install-recommends -y
	echo -e "${BLUE}done${RES}"
		sleep 1 ;;
		2)
	echo "安装vlc播放器，播放器"
	$sudo_t apt install vlc --no-install-recommends -y
	sed -i 's/geteuid/getppid/' /usr/bin/vlc
	echo -e "${BLUE}done${RES}"
		sleep 1 ;;
		0) exit 2 ;;
		9) MAIN ;;
		*) INVALID_INPUT
			;;
	esac
		INSTALL_SOFTWARE
		;;
	8)
		echo -e "\n1) 安装libreoffice
2) 安装wps(注意，可能存在未知bug)
9) 返回
0) 退出\n"
		read -r -p "请选择: " input
		case $input in
			1|"") echo "安装libreoffice"
		$sudo_t apt install --no-install-recommends libreoffice libreoffice-l10n-zh-cn libreoffice-gtk3 -y 
		echo -e "${GREEN}中文界面，请打开LibreOffice，左上角Tools-Options-Language settings-languages，User interface选择Chinese${RES}"
		CONFIRM ;;
	2)
#如果出现 Could not load the Qt platform plugin xcb
#export QT_DEBUG_PLUGINS=1
		ls /usr/share/applications/ | grep wps -q 2>/dev/null
		if [ $? != 0 ]; then
			echo -e "\n正在下载wps"
		CURL="$(curl -L https://www.wps.cn/product/wpslinux\# | grep .deb | grep arm | cut -d '"' -f 2)"
		curl -o wps.deb $CURL && $sudo_t dpkg -i wps.deb && rm wps.deb
		PROCESS_CHECK
#		sed -i '2i\export XMODIFIERS="@im=fcitx"' /usr/bin/wps /usr/bin/et /usr/bin/wpp 2>/dev/null
#		sed -i '2i\export QT_IM_MODULE="fcitx"' /usr/bin/wps /usr/bin/et /usr/bin/wpp 2>/dev/null
	else 
		if [ $(command -v wps) ]; then
			echo "已安装wps"
		else
			echo "安装失败"
		fi
		sleep 2
		fi
		ls /usr/share/fonts/ | grep wps-fonts -q 2>/dev/null
		if [ $? != 0 ]; then
		echo -e "\n正在下载中文包"
		$sudo_t apt install unzip
		rm -rf wps_tmp && cd && mkdir wps_tmp && cd wps_tmp
FONT="$(curl -L https://aur.archlinux.org/packages/ttf-wps-fonts/ | grep zip | cut -d '"' -f 2)"
wget -c $FONT -O font.zip
PROCESS_CHECK
unzip font.zip && sed -i '$d' ttf-wps-fonts-master/install.sh && . ttf-wps-fonts-master/install.sh && cd && rm -rf wps_tmp
else echo "已安装中文包" 
	sleep 2
fi
mkdir -p ${HOME}/.config/Kingsoft/
echo '[General]
languages=zh_CN' >${HOME}/.config/Kingsoft/Office.conf
echo -e "如果点击没反应，请在终端输/opt/kingsoft/wps-office/office6/wps看是否缺少依赖包"
CONFIRM
INSTALL_SOFTWARE
		;;
	0) exit 0 ;;
	9) MAIN ;;
	*) INVALID_INPUT ;;
esac
		INSTALL_SOFTWARE
		;;
	9) DOSBOX ;;
	10) QEMU_SYSTEM ;;
	11) ENTERTAINMENT ;;
	12) if [ ! $(command -v python3) ]; then
		echo -e "\n检测到你未安装python,将先为你安装上"
		sleep 2
		$sudo_t apt install python3 python3-pip -y && mkdir -p ${HOME}/.config/pip && echo "[global] 
index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >${HOME}/.config/pip/pip.conf
	fi
	echo ""
	read -r -p "请选择 1)局域网http网页服务 2)ftp服务 9)返回 " input
	echo ""
	case $input in
		1)
IP=`ip -4 -br a | awk '{print $3}' | cut -d '/' -f 1 | sed -n 2p`
	echo -e "已完成配置，请尝试用浏览器打开并输入地址\n
	${YELLOW}本机	http://127.0.0.1:8080
	局域网	http://$IP:8080${RES}\n
	如需关闭，请按ctrl+c，然后输pkill python3或直接exit退出shell\n"
	python3 -m http.server 8080 &
	sleep 2 ;;
	2)
		echo -e "检测应用模块\n"
		pip3 list | grep -q pyftpdlib
		if [ $? != 0 ]; then
		pip3 install pyftpdlib
		fi
		echo -e "已完成配置，请尝试用浏览器打开并输入地址\n
		本机	${YELLOW}ftp://127.0.0.1:2121${RES}
		用户名	${YELLOW}guest${RES}
		密码	${YELLOW}123456${RES}"
		python3 -m pyftpdlib -u guest -P 123456
		;;
	*) echo ""
	esac
	INSTALL_SOFTWARE
	;;
13) echo -e "正在安装新立得"
	sleep 2
	$sudo_t apt install synaptic -y
	echo -e "done"
	sleep 1
	INSTALL_SOFTWARE ;;
14) 
#VERSION=`curl -L https://aur.tuna.tsinghua.edu.cn/packages/linuxqq | grep x86 | cut -d "_" -f 2 | cut -d "_" -f 1`
#	echo -e "${YELLOW}检测到新版本为${VERSION}${RES}"
#	sleep 2
	rm linuxqq_*_arm64.deb* 2>/dev/null
#	wget $(curl https://aur.archlinux.org/packages/linuxqq|grep qqweb|awk -F 'href="' '{print $2}'|awk -F '"' '{print $1}'|sed 's/x86.*$/arm64.deb/')
	wget $(curl https://aur.archlinux.org/packages/linuxqq|grep arm64|awk -F 'href="' '{print $2}'|cut -d '"' -f 1)
#	wget  https://down.qq.com/qqweb/LinuxQQ/linuxqq_${VERSION}_arm64.deb
#	$sudo_t dpkg -i linuxqq_${VERSION}_arm64.deb
	$sudo_t dpkg -i linuxqq_*_arm64.deb
	dpkg -l | grep linuxqq -q 2>/dev/null
	if [ $? == 0 ]; then
		echo -e "\n${YELLOW}已安装${RES}"
	else
		echo -e "\n${RED}安装失败${RES}"
	fi
	sleep 2
	INSTALL_SOFTWARE
	;;
15) echo -e "${YELLOW}包括两个不同的Java软件包：Java Runtime Environment（JRE）和Java Development Kit（JDK）。 JRE包括Java虚拟机（JVM），允许您运行Java程序的类和二进制文件。 Java开发人员应安装JDK，其中包括JRE以及构建Java应用程序所需的开发/调试工具和库，本次安装为JDK。${RES}"
	CONFIRM
	apt install default-jdk
: <<\eof
	包括两个不同的Java软件包：Java Runtime Environment（JRE）和Java Development Kit（JDK）。 JRE包括Java虚拟机（JVM），允许您运行Java程序的类和二进制文件。 Java开发人员应安装JDK，其中包括JRE以及构建Java应用程序所需的开发/调试工具和库。
apt install openjdk- -jdk中间空的选择你要装的版本。
apt install openjdk-7-jdk
eof
;;
0)
	echo "exit"
	exit 0
	;;
16)
	echo -e "back to main\n\n"
	MAIN
	;;
*) INVALID_INPUT
		INSTALL_SOFTWARE ;;
esac
}
##################
DOSBOX() {
	echo -e "\n1）安装dosbox
2）创建dos运行文件目录
9) 返回
0) 退出\n"
		read -r -p "请选择: " input
		case $input in
			1) echo "安装dosbox"
				$sudo_t apt install dosbox -y
				INSTALL_SOFTWARE ;;
			2) mkdir -p $DIRECT/xinhao/DOS
		if [ ! -f ${HOME}/.dosbox/*.conf ]; then
			dosbox -printconf >/dev/null 2>&1
		dosbox=`ls ${HOME}/.dosbox`
                sed -i "/^\[autoexec/a\mount c $DIRECT/xinhao/DOS" ${HOME}/.dosbox/$dosbox
		sed -i "/xinhao/a #挂载光盘\n#mount d $DIRECT/xinhao/DOS/光盘目录 -t cdrom" ${HOME}/.dosbox/$dosbox
#		echo 'mount d $DIRECT/DOS/hospital -t cdrom' ${HOME}/.dosbox/$dosbox
#		echo 'mount d $DIRECT/DOS/CDROM -t cdrom -label mdk' ${HOME}/.dosbox/$dosbox
		echo -e "${GREEN}配置完成，请把运行文件夹放在手机主目录xinhao/DOS文件夹里，打开dosbox输入c:即可看到运行文件夹，鼠标解锁ctrl+f10${RES}"
		sleep 2
	fi
		INSTALL_SOFTWARE ;;
	0) 
		exit 0 ;;
	9) MAIN ;;
	*) INVALID_INPUT
		INSTALL_SOFTWARE ;;
esac
}
#####################
INSTALL_PYTHON3() {
echo -e "${YELLOW}安装python3和pip并配置国内源${RES}"
read -r -p "1)是 2)否 9)返回 0)退出 " input
case $input in
	1|"")
		echo "yes"
		$sudo_t apt install python3 python3-pip && mkdir -p /root/.config/pip && echo "[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple" > /root/.config/pip/pip.conf
echo -e "${BLUE}done${RES}"
sleep 1
SETTLE
		;;
	2)
		echo "no"
		SETTLE
		;;
	0)
		echo "exit"
		exit 0
		;;
	9)
		echo "back to Main"
		MAIN
		;;
	*)
		INVALID_INPUT
		INSTALL_PYTHON3
		;;

esac



}
#################

#################
QEMU_SYSTEM() {
	echo -e "
1) 使用在线utqemu脚本(功能完善)
2) 本脚本安装(仅提供安装与目录创建)
9) 返回
0) 退出"
read -r -p "请选择: " input
case $input in
	1)
	bash -c "$(curl https://shell.xb6868.com/ut/utqemu.sh)" ;;
2) echo -e "
1) 安装qemu-system-x86_64，并联动更新模拟器所需应用
2) 创建windows镜像目录
9) 返回
0) 退出\n"
read -r -p "请选择: " input
case $input in
1) uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
	apt update -y && apt upgrade -y && apt --fix-broken install -y && apt install qemu-system-x86-64-headless x11-repo qemu-system-i386-headless -y
else
	apt --fix-broken install && $sudo_t apt install qemu-system-x86* xserver-xorg x11-utils -y && $sudo_t apt --reinstall install pulseaudio -y
	fi
        QEMU_SYSTEM
        ;;
2) echo -e "创建windows镜像目录及共享目录\n"
        if [ ! -e "$DIRECT/xinhao/windows" ]; then
                mkdir -p $DIRECT/xinhao/windows
        fi
	if [ ! -e "$DIRECT/xinhao/share/" ]; then
		mkdir -p $DIRECT/xinhao/share
	fi
	if [ ! -e "$DIRECT/xinhao/windows" ]; then
		echo -e "${RED}创建目录失败${RES}"
	else
		echo -e "${GREEN}手机主目录下已创建/xinhao/windows文件夹，请把'系统镜像，分区镜像，光盘镜像'放进这个目录里\n共享目录是share(目录内总文件大小不能超过500m)${RES}"
	fi
        CONFIRM
	QEMU_SYSTEM
        ;;
	0)
	echo "exit"
	exit 0 ;;
	9)
	echo "back to Main"
	MAIN ;;
	*) INVALID_INPUT && QEMU_SYSTEM ;;
	esac ;;
0) echo "exit"
	exit 1 ;;
9)
	echo "back to Main"
	MAIN ;;
	*) INVALID_INPUT && QEMU_SYSTEM ;;
	esac
}
#################
#################
TERMUX() {
	echo -e "\n${GREEN}注意！以下均在termux环境中操作\n${RES}"
	echo -e "1) ${YELLOW} * 一键配置好termux环境 (*^ω^*)${RES}
2)  termux换国内源
3)  安装常用应用(包括curl tar wget vim proot)
4)  安装pulseaudio并配置(让termux支持声音输出)
5)  创建用户系统登录脚本
6)  下载Debian(buster,bullseye)系统
7)  下载Ubuntu(focal,jammy)系统
8)  qemu-system-x86_64模拟器
9)  下载x86架构的Debian(buster)系统(qemu模拟)
10) 备份恢复系统
11) 修改termux键盘
12) 下载最新版本termux与xsdl
0)  退出\n"
read -r -p "请选择: " input
case $input in
	1) echo -e "\n是否一键配置termux
               1) Yes
               2) No"
               read -r -p "请选择: " input
               case $input in
                       1) echo -e "${GREEN}修改键盘${RES}"
                               sleep 1
                               if [ -d ${HOME}/.termux ]; then
                        rm -rf ${HOME}/.termux
                fi
                mkdir ${HOME}/.termux && echo "extra-keys = [ \
['ESC','|','/','HOME','UP','END','PGUP','-'], \
['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','~'] \
]" >${HOME}/.termux/termux.properties
                               echo -e "${GREEN}换北外源,过程中可能会有确认内容,请按回车${RES}"
                               sleep 2
                               sed -i "s@^\(deb.*stable main\)$@#\1\ndeb ${SOURCES_BF}termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb ${SOURCES_BF}termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb ${SOURCES_BF}termux/science-packages-24 science stable@" $PREFIX/etc/apt/sources.list.d/science.list && pkg update
                               echo -e "${GREEN}安装常用应用${RES}"
                               sleep 1
                               pkg install curl tar wget vim proot unstable-repo x11-repo -y
                               echo -e "${GREEN}安装配置声音pulseaudio${RES}"
			       sleep 1
                               pkg in pulseaudio -y
                               if grep -q "anonymous" ${PREFIX}/etc/pulse/default.pa ;
then
        echo "module already present"
else
        echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
                                fi
if grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf ; then
sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf
fi
echo -e "\n${YELLOW}已完成操作，请重启termux，如使用异常，请重新配置${RES}\n\n"
sleep 2
TERMUX ;;
*) TERMUX ;;
esac ;;

	2) echo -e "\n1) 清华源
2) 北外源 (推荐)
3) 中科源"
		read -r -p "请选择: " input
		case $input in
			1) echo -e "正在更换清华源"
		sleep 1
		sed -i "s@^\(deb.*stable main\)@#\1\ndeb ${SOURCES_TUNA}termux/termux-packages-24 stable main@" $PREFIX/etc/apt/sources.list
sed -i "s@^\(deb.*games stable\)@#\1\ndeb ${SOURCES_TUNA}termux/game-packages-24 games stable@" $PREFIX/etc/apt/sources.list.d/game.list
sed -i "s@^\(deb.*science stable\)@#\1\ndeb ${SOURCES_TUNA}termux/science-packages-24 science stable@" $PREFIX/etc/apt/sources.list.d/science.list
if [ -d /data/data/com.termux/files/usr/etc/termux/mirrors/china ]; then
	rm -rf /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
fi
mkdir /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
cp /data/data/com.termux/files/usr/etc/termux/mirrors/china/mirrors.tuna.tsinghua.edu.cn /data/data/com.termux/files//usr/etc/termux/chosen_mirrors/
;;
2|"") echo -e "正在更换北外源" 
	sleep 1
	sed -i "s@^\(deb.*stable main\)@#\1\ndeb ${SOURCES_BF}termux/termux-packages-24 stable main@" $PREFIX/etc/apt/sources.list
sed -i "s@^\(deb.*games stable\)@#\1\ndeb ${SOURCES_BF}termux/game-packages-24 games stable@" $PREFIX/etc/apt/sources.list.d/game.list
sed -i "s@^\(deb.*science stable\)@#\1\ndeb ${SOURCES_BF}termux/science-packages-24 science stable@" $PREFIX/etc/apt/sources.list.d/science.list
if [ -d /data/data/com.termux/files/usr/etc/termux/mirrors/china ]; then
	rm -rf /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
fi
mkdir /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
cp /data/data/com.termux/files/usr/etc/termux/mirrors/china/mirrors.bfsu.edu.cn /data/data/com.termux/files//usr/etc/termux/chosen_mirrors/
;;
*) echo -e "正在更换中科源"
	sleep 1
	sed -i "s@^\(deb.*stable main\)@#\1\ndeb ${SOURCES_USTC}termux stable main@" $PREFIX/etc/apt/sources.list
	if [ -d /data/data/com.termux/files/usr/etc/termux/mirrors/china ]; then
		rm -rf /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
	fi
	mkdir /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
	cp /data/data/com.termux/files/usr/etc/termux/mirrors/china/mirrors.ustc.edu.cn /data/data/com.termux/files//usr/etc/termux/chosen_mirrors/
esac
apt update && apt upgrade
echo -e  "已换源"
sleep 1
TERMUX
	;;
3)
	echo "安装常用应用(curl tar vim wget proot)"
	pkg install curl tar wget vim proot -y
	echo "已安装"
	TERMUX
	;;
4)
	echo -e "安装并配置pulseaudio\n1)直接安装\n2)修复出现([pulseaudio] main.c: ${RED}Daemon startup failed.${RES})提示"
	read -r -p "请选择: " input
	case $input in
		1|"") pkg in pulseaudio -y
			if [ $? -ne 0 ]; then
				echo -e "${RED}安装失败，请重试${RES}"
				sleep 2
				TERMUX
				fi
				if grep -q "anonymous" ${PREFIX}/etc/pulse/default.pa ;
then
	echo "module already present"
else
	echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
				fi
if grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf ; then
#sed -i 's/exit-idle-time = 20/exit-idle-time = -1/g' ${PREFIX}/etc/pulse/daemon.conf
sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf
fi			;;
		2) unset LD_LIBRARY_PATH
			echo -e "已处理"
			sleep 1 ;;
		*) INVALID_INPUT
			TERMUX ;;
esac
		echo -e "\n已安装并配置pulseaudio"
	sleep 1
	TERMUX
	;;
5) echo -e "\n${GREEN}如需加挂外部sdcard，请先ls /mnt确认外部sdcard名字${RES}\n"
	read -r -p "1)创建root用户 2)普通用户 9)返回 0)退出 请选择: " input
	case $input in
		2) echo -e "\n${GREEN}请确认已安装sudo，否则无法系统内进行安装维护，切换root用户命令sudo su${RES}"
			echo -n "请把系统文件夹放根目录并输入系统文件夹名字rootfs: "
			read rootfs
			while [ ! -d $rootfs ]
			do
				echo -e "${RED}无此文件夹\n${RES}请重输: ${RES}"
			read rootfs
		done
		echo -n "请输入普通用户名name: "
		read name
			if grep -wq "$name" "$rootfs/etc/passwd"; then
			echo -e "${GREEN}你的普通用户名貌似已经有了，将为此普通用户创建登录脚本${RES}"
			sleep 2
			Uid=`sed -n p $rootfs/etc/passwd | grep $name | cut -d ':' -f 3`
			Gid=`sed -n p $rootfs/etc/passwd | grep $name | cut -d ':' -f 4`
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -r $rootfs -i $Uid:$Gid --link2symlink -b $DIRECT:/root$DIRECT -b /dev -b /sys -b /proc -b /data/data/com.termux/files -b $DIRECT -b $rootfs/root:/dev/shm -w /home/$name /usr/bin/env USER=$name HOME=/home/$name TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >$name.sh && chmod +x $name.sh
echo -e "已创建用户系统登录脚本,登录方式为${YELLOW}./$name.sh${RES}"
sleep 2
		else
			mkdir -p $rootfs/home/$name
			i=1000
			while grep -q "$i" "$rootfs/etc/passwd"
			do
				let i++
			done
			if [ ! -e $rootfs/etc/sudoers ]; then
				echo -e "\n${GREEN}你这系统似乎没装sudo命令，故新创建的用户无法进行系统安装维护${RES}"
				sleep 2
			else
				sed -i "/execute/a\\$name ALL=(ALL:ALL) NOPASSWD:ALL" $rootfs/etc/sudoers
			fi
			echo "$name:x:$i:$i:,,,:/home/$name:/bin/bash" >>$rootfs/etc/passwd
			echo "$name:x:$i:" >>$rootfs/etc/group
			echo "$name:!:18682:0:99999:7:::" >>$rootfs/etc/shadow
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -r $rootfs -i $i:$i --link2symlink -b $DIRECT:/root$DIRECT -b /dev -b /sys -b /proc -b /data/data/com.termux/files -b $DIRECT -b $rootfs/root:/dev/shm -w /home/$name /usr/bin/env USER=$name HOME=/home/$name TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >$name.sh && chmod +x $name.sh
echo -e "\n是否加载外部sdcard"
read -r -p "1)是 2)跳过 请选择:" input
case $input in
	1) echo -n "请输入外部sdcard名字ext_sdcard: "
                read ext_sdcard
                sed -i "s/shm/shm -b \/mnt\/$ext_sdcard:\/home\/$name\/ext_sdcard/g" $name.sh ;;
	*) echo "" ;;
	esac
echo -e "已创建用户系统登录脚本,登录方式为${YELLOW}./$name.sh${RES}"
sleep 2
fi ;;
		9|"") TERMUX ;;
		0) exit 0 ;;
		1) 
	echo -n "请把系统文件夹放根目录并输入系统文件夹名字rootfs: "
	read rootfs
	while [ ! -d $rootfs ]
                        do
				echo -e "${RED}无此文件夹\n${RES}请重输: ${RES}"
				read rootfs
		done
	if [ -e start-$rootfs.sh ]; then
		rm -rf start-$rootfs.sh
	fi
	echo $(uname -a) | sed 's/Android/GNU\/Linux/' >$rootfs/proc/version
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S $rootfs --link2symlink -b $DIRECT:/root$DIRECT -b $DIRECT -b $rootfs/proc/version:/proc/version -b $rootfs/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" > start-$rootfs.sh && chmod +x start-$rootfs.sh
echo -e "\n是否加载外部sdcard"
read -r -p "1)是 2)跳过 请选择: " input
case $input in
	1) echo -n "请输入外部sdcard名字ext_sdcard: "
		read ext_sdcard
		sed -i "s/shm/shm -b \/mnt\/$ext_sdcard:\/root\/ext_sdcard/g" start-$rootfs.sh ;;
		*) echo "" ;;
	esac
echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW}./start-$rootfs.sh${RES}"
if [ -e ${PREFIX}/etc/bash.bashrc ]; then
	if ! grep -q 'pulseaudio' ${PREFIX}/etc/bash.bashrc; then
		sed -i "1i\pkill -9 pulseaudio 2>/dev/null" ${PREFIX}/etc/bash.bashrc
	fi
fi
sleep 2 ;;
esac
TERMUX
;;
6) 
	read -r -p "1) bullseye 2)buster 9) 返回 0) 退出 请选择: " input
	case $input in
		1) case $(dpkg --print-architecture) in
			aarch64|arm64) bash -c "$(curl https://shell.xb6868.com/ut/bullseye.sh)"
			exit 0 ;;
		*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
		esac
		TERMUX ;;
		2)
			CODENAME=buster
			LXC=debian
	echo -e "由于系统包很干净，所以进入系统后，建议再用本脚本安装常用应用"
	CONFIRM
		rm -rf rootfs.tar.xz 2>/dev/null
	case $(dpkg --print-architecture) in
		aarch64|arm64) ;;
		*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
		sleep 2  ;;
	esac
	echo "下载Debian(buster)系统..."
	sleep 1
		SYSTEM_DOWN
echo "修改为北外源"
echo "deb ${SOURCES_BF}debian buster ${DEB_DEBIAN}
deb ${SOURCES_BF}debian buster-updates ${DEB_DEBIAN}
deb ${SOURCES_BF}debian buster-backports ${DEB_DEBIAN}
deb ${SOURCES_BF}debian-security buster/updates ${DEB_DEBIAN}" >$bagname/etc/apt/sources.list
sleep 2
bash start-$bagname
exit 0
	;;
9) TERMUX ;;
0) exit 0
esac
		;;

	7) read -r -p "1) jammy 2) focal 9) 返回 0) 退出 请选择: " input
		case $input in
			1) CODENAME=jammy
				LXC=ubuntu ;;
			2) CODENAME=focal
				LXC=ubuntu ;;
			9) TERMUX ;;
			0) exit 0
		esac

		echo -e "由于系统包很干净，所以建议进入系统后，再用本脚本安装常用应用"
		CONFIRM
		if [ -e rootfs.tar.xz ]; then
			rm -rf rootfs.tar.xz
		fi
		case $(dpkg --print-architecture) in
			aarch64|arm64) ;;
			*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
			sleep 2  ;;
		esac
	echo -e "下载Ubuntu($CODENAME)系统..."
	sleep 1
#	curl -o rootfs.tar.xz ${CURL_T}
SYSTEM_DOWN
echo "修改为北外源"
echo "deb ${SOURCES_BF}ubuntu-ports/ $CODENAME ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ $CODENAME-security ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ $CODENAME-updates ${DEB_UBUNTU}
deb ${SOURCES_BF}ubuntu-ports/ $CODENAME-backports ${DEB_UBUNTU}" >$bagname/etc/apt/sources.list
bash start-$bagname
exit 0 ;;

	8) QEMU_SYSTEM ;;
	9) echo -e "\n你正在下载的是x86架构的debian(bullseye),将会通过qemu的模拟方式运行;
由于系统包很干净，所以建议进入系统后，再用本脚本安装常用应用"
                CONFIRM
		bash -c "$(curl https://shell.xb6868.com/ut/bullseye-amd64.sh)"
exit 1
TERMUX ;;

	[Kk][Aa][Ll][Ii]) echo -e "\n${YELLOW}欢迎进入kali系统的下载安装!(≧∇≦)/\n${RES}"
echo -e "${BLUE}"
cat <<'EOF'
..............                                     
            ..,;:ccc,.                            
          ......''';lxO.                          
.....''''..........,:ld;                           
           .';;;:::;,,.x,                         
      ..'''.            0Xxoc:,.  ...              
  ....                ,ONkc;,;cokOdc',.           
 .                   OMo           ':ddo.          
                    dMc               :OO;         
                    0M.                 .:o.     
                    ;Wd
                     ;XO,
                       ,d0Odlc;,..
                           ..',;:cdOOd::,.
                                    .:d;.':;.
                                       'd,  .'
                                         ;l   ..
                                          .o
                                            c
                                            .'
                                             .
EOF
echo -e "${RES}"
sleep 2
if [ -e rootfs.tar.xz ]; then
	rm -rf rootfs.tar.xz
fi
case $(dpkg --print-architecture) in
	aarch64|arm64) CODENAME=current
		LXC=kali ;;
	*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
	sleep 2  ;;
esac
SYSTEM_DOWN
echo "修改为中科源"
echo "deb ${SOURCES_USTC}kali kali-rolling ${DEB_DEBIAN}
deb-src ${SOURCES_USTC}kali kali-rolling ${DEB_DEBIAN}" >$bagname/etc/apt/sources.list
sleep 2
                bash start-$bagname
		;;
	10)
		echo -e "\n请选择备份或恢复
		1) 备份
		2) 恢复
		9) 返回
		0) 退出\n"
	read -r -p "请选择: " input
	case $input in
		1) echo -n "请输入拟备份的系统文件夹名(可含路径)backup: "
			read backup
			tar zcvf $backup.tar.gz $backup
			if [ $? -eq 0 ]; then
				echo -e "备份完成，文件名为$backup.tar.gz"
			else
				     echo -e "${RED}备份失败，请检查...${RES}"
				     rm $backup.tar.gz
			     fi
			     sleep 2
				     TERMUX ;;
			     2) echo -n "请把恢复包放到本脚本目录，并输入拟恢复包的完整名字(可含路径，支持*.tar.gz或*.tar.xz后缀名) backup: "
				     read backup
if [ "${backup##*.}" = "xz" ]; then                     
	tar -xvJf $backup                                     
elif [ "${backup##*.}" = "gz" ]; then                   
	tar -zxvf $backup                                  
			     else
	echo -e "${RED}不支持的格式${RES}"
	sleep 2
	unset backup
	TERMUX
	fi
	if [ $? -eq 0 ]; then
		echo -e "恢复完成"
	else
		echo -e "${RED}恢复失败，请检查...${RES}"
	fi
	sleep 2
	unset backup
	TERMUX ;;
	0) echo "exit"
		exit 0 ;;
	9) echo "back to Main"
		unset backup
		MAIN ;;
	*) INVALID_INPUT
		unset backup
		TERMUX
	esac ;;
	11)  echo "修改键盘"
                if [ -d ${HOME}/.termux ]; then
                        rm -rf ${HOME}/.termux
                fi
                mkdir ${HOME}/.termux
		read -r -p "1)常规触屏 2)m6键盘 " input
		case $input in
		2)
			echo "extra-keys = [ \
['ESC','HOME','END','PGUP','PGDN'] \
] \
]" >${HOME}/.termux/termux.properties ;;
		*) echo "extra-keys = [ \
['ESC','|','/','HOME','UP','END','PGUP','-'], \
['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','~'] \
]" >${HOME}/.termux/termux.properties ;;
esac
echo "已修改，请重启termux"
sleep 1
TERMUX
;;
	12) 
		echo -e "\n1)termux 2)xsdl 3)termux-api 4)avnc 9)返回 0)退出"
		read -r -p "请选择: " input
	case $input in
		1) echo -e "\n${YELLOW}检测最新版本${RES}"
		VERSION=`curl https://f-droid.org/packages/com.termux/ | grep apk | sed -n 2p | cut -d '_' -f 2 | cut -d '"' -f 1`
		if [ ! -z "$VERSION" ]; then
		echo -e "\n下载地址\n${GREEN}${SOURCES_TUNA}fdroid/repo/com.termux_$VERSION${RES}\n"
	else
		echo -e "${RED}获取失败，请重试${RES}"
		sleep 2
		unset VERSION
		TERMUX
		fi
		read -r -p "1)下载 9)返回 " input
		case $input in
			1) rm termux.apk 2>/dev/null
		curl ${SOURCES_TUNA}fdroid/repo/com.termux_$VERSION -o termux.apk
        mv -v termux.apk ${DIRECT}
	echo -e "\n已下载至${DIRECT}目录"
	sleep 2 ;;
	*) ;;
	esac
	unset VERSION
	TERMUX ;;
	2) VERSION=`curl https://sourceforge.net/projects/libsdl-android/files/apk/XServer-XSDL/ | grep android | grep 'XSDL/XServer' | grep '\.apk/download' | head -n 1 | cut -d '/' -f 9`
	echo -e "\n下载地址\n${GREEN}https://jaist.dl.sourceforge.net/project/libsdl-android/apk/XServer-XSDL/$VERSION${RES}\n"
	read -r -p "1)下载 9)返回 " input
	case $input in
	1) curl -O https://jaist.dl.sourceforge.net/project/libsdl-android/apk/XServer-XSDL/$VERSION
		if [ -f $VERSION ]; then
		echo -e "移到${DIRECT}目录中..."
		mv -v $VERSION ${DIRECT}
		if [ -f ${DIRECT}$VERSION ]; then
		echo -e "\n已下载至${DIRECT}目录"
		sleep 2
		fi
	else
		echo -e "\n${RED}错误，请重试${RES}"
		sleep 2
		fi ;;
	*) ;;
	esac
	unset VERSION ;;
	3) curl https://f-droid.org/packages/com.termux.api/ | grep apk | sed -n 2p | cut -d '"' -f 2 | cut -d '"' -f 1 | xargs curl -o ${DIRECT}/com.termux.api.apk
	if [ -f ${DIRECT}/com.termux.api.apk ]; then
	echo -e "\n已下载至${DIRECT}目录"
	else
	echo -e "\n${RED}错误，请重试${RES}"
	fi
	sleep 2 ;;

	4) 
	unset VERSION
	echo -e "\n${YELLOW}检测最新版本${RES}"
        VERSION=`curl https://f-droid.org/zh_Hant/packages/com.gaurav.avnc/ | awk -F 'repo/' '{print $2}' | grep apk | cut -d '"' -f 1 | sed -n 1p`
        if [ ! -z "$VERSION" ]; then
                echo -e "\n下载地址\n${GREEN}https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/$VERSION${RES}\n"
		rm avnc.apk 2>/dev/null
		curl https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/$VERSION -o avnc.apk
		mv -v avnc.apk ${DIRECT}
		if [ -f ${DIRECT}/avnc.apk ]; then
			echo -e "\n已下载至${YELLOW}${DIRECT}${RES}目录"
			sleep 1
		fi
        else
		echo -e "\n${YELLOW}获取失败${RES}"
		sleep 2
	fi
		;;
	0) echo "exit"
                exit 1 ;;
        9) echo -e "back to Main\n"
                TERMUX ;;
	*) INVALID_INPUT ;;
	esac
        TERMUX ;;
	0) echo "exit"
	exit 1 ;;
	*) INVALID_INPUT
	TERMUX ;;
esac
}
#######################
SYSTEM_DOWN() {
	case $ARCH_CHANGE in
		amd64) curl -O ${SOURCES_BF}lxc-images/images/${LXC}/${CODENAME}/amd64/default/$(curl ${SOURCES_BF}lxc-images/images/${LXC}/${CODENAME}/amd64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz ;;
		*) curl -O ${SOURCES_BF}lxc-images/images/${LXC}/${CODENAME}/arm64/default/$(curl ${SOURCES_BF}lxc-images/images/${LXC}/${CODENAME}/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
	esac
	if [ ! -f rootfs.tar.xz ]; then
		echo -e "\e[31m下载错误，请检查网络\e[0m"
		sleep 1
		exit 0
		TERMUX
	fi
                echo -n "请给系统文件夹起个名bagname: "
                read bagname
                if [ -e $bagname ]; then
                rm -rf $bagname
                fi
                mkdir $bagname && tar xvf rootfs.tar.xz -C $bagname
                rm rootfs.tar.xz
                echo -e "${BLUE}系统已下载，文件夹名为$bagname${RES}"
                sleep 2
                echo "修改时区"
                sed -i "1i\export TZ='Asia/Shanghai'" $bagname/etc/profile
	echo 'for i in /var/run/dbus/pid /tmp/.X*-lock /tmp/.X11-unix/X*; do if [ -e "${i}" ]; then rm -vf ${i}; fi; done' >>$bagname/etc/profile
		cat >$bagname/root/firstrun<<-'eof'
		printf "%b" "\e[33m正常进行首次运行配置\e[0m" && sleep 1
		if [ ! -f "/usr/bin/perl" ]; then
#			ln -sv /usr/bin/perl* /usr/bin/perl
			ln -sv /usr/bin/perl*aarch64* /usr/bin/perl
		fi
		dpkg -l ca-certificates | grep ii
		if [ $? == 1 ]; then
		sed -i "s/https/http/g" /etc/apt/sources.list
		apt update && $sudo_t apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list
		apt update

#		ln -svf /usr/bin/perl* /usr/bin/perl
		ln -svf /usr/bin/perl*aarch64* /usr/bin/perl
	else
	apt update
		fi
		for i in $(groups 2>/dev/null|sed "s/$(whoami)//"); do if ! grep -q "$i" /etc/group; then echo "$i:x:$i:" >>/etc/group; fi done
		apt install curl wget vim fonts-wqy-zenhei tar wget procps psmisc busybox pulseaudio -y && sed -i "/firstrun/d" .bashrc
		sed -i '/zh_CN.UTF/s/#//' /etc/locale.gen
		if grep -qi ubuntu /etc/os-release; then sed -i '/^SUPPORTED/s/^/#/;/^ALIASES/s/^/#/' /usr/sbin/locale-gen; fi
		locale-gen || /usr/sbin/locale-gen
		sed -i '/^export LANG/d' /etc/profile && sed -i '1i\export LANG=zh_CN.UTF-8' /etc/profile && source /etc/profile
		export LANG=zh_CN.UTF-8
		if [ ! $(command -v busybox) ]; then
		echo -e "\e[33m优化部分命令\e[0m"
		sleep 1
		mkdir temp
		cd temp
		wget -O busybox.apk https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main/aarch64/$(curl https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main/aarch64/ | grep busybox | sed -n 1p | awk -F 'href="' '{print $2}' | cut -d '"' -f 1)
	tar zxvf busybox.apk bin 2>/dev/null
	mv bin/busybox /usr/local/bin/busybox
	wget -O musl.apk ${URL}/alpine/latest-stable/main/aarch64/$(curl ${URL}/alpine/latest-stable/main/aarch64/ | grep musl | sed -n 1p | awk -F 'href="' '{print $2}' | cut -d '"' -f 1)
	tar zxvf musl.apk lib
	mv lib/* /usr/lib/
	cd && rm -rf temp
	fi
	mkdir -pv /tmp/runtime-$(id -u)
	chmod -Rv 1777 "/tmp/runtime-$(id -u)"
	if [ $(command -v busybox) ]; then
	for i in ps uptime killall egrep top; do if [ $(command -v $i) ]; then ln -svf $(command -v busybox) $(command -v $i); else ln -svf $(command -v busybox) /usr/bin/$i; fi done
	fi
	export LANG=zh_CN.UTF-8
		eof
		echo -e 'bash firstrun' >>$bagname/root/.bashrc
                echo "配置dns"
		rm $bagname/etc/resolv.conf 2>/dev/null
		echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >$bagname/etc/resolv.conf
echo -e "已修改为\n223.5.5.5
223.6.6.6"
sleep 1
mkdir $bagname/etc/proc/ -p
printf ' 52 memory_bandwidth! 53 network_throughput! 54 network_latency! 55 cpu_dma_latency! 56 xt_qtaguid! 57 vndbinder! 58 hwbinder! 59 binder! 60 ashmem!239 uhid!236 device-mapper!223 uinput!  1psaux!200 tun!237 loop-control! 61 lightnvm!228 hpet!229 fuse!242rfkill! 62 ion! 63 vga_arbiter\n' | sed 's/!/\n/g' >$bagname/etc/proc/misc
printf "%-1s %-1s %-1s %8s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s %6s\n" Node 0, zone DMA 3 2 2 4 3 3 2 1 2 2 0 Node 0, zone DMA321774 851 511 220 67 3 2 0 0 1 0 >$bagname/etc/proc/buddyinfo
echo "0.03 0.03 0.00 1/116 17521" >$bagname/etc/proc/loadavg
touch $bagname/etc/proc/kmsg
echo 'tty0                 -WU (EC p  )    4:7' >$bagname/etc/proc/consoles
echo '0-0     Linux                   [kernel]' >$bagname/etc/proc/execdomains
echo '0 EFI VGA' >$bagname/etc/proc/fb
echo '    0:     9 8/8 3/1000000 27/25000000' >$bagname/etc/proc/key-users
echo '285490.46 1021963.95' >$bagname/etc/proc/uptime
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >$bagname/etc/proc/version
touch $bagname/etc/proc/vmstat
echo 'Character devices:!  1 mem!  4 /dev/vc/0!  4 tty!  4 ttyS!5 /dev/tty!  5 /dev/console!  5 /dev/ptmx!  7 vcs! 10 misc! 13 input! 21 sg! 29 fb! 81 video4linux!128 ptm!136 pts!180 usb!189 usb_device!202 cpu/msr!203 cpu/cpuid!212 DVB!244 hidraw!245 rpmb!246 usbmon!247 nvme!248 watchdog!249 ptp!250 pps!251 media!252 rtc!253 dax!254 gpiochip!!Block devices:!  1 ramdisk!  7 loop!  8 sd! 11 sr! 65 sd! 66 sd! 67 sd! 68 sd! 69 sd! 70 sd! 71 sd!128 sd!129 sd!130 sd!131 sd!132 sd!133 sd!134 sd!135 sd!179 mmc!253 device-mapper!254 virtblk!259 blkext' | sed 's/!/\n/g' >$bagname/etc/proc/devices
echo "cpu  0 0 0 0 0 0 0 0 0 0
cpu0 0 0 0 0 0 0 0 0 0 0
intr 1
ctxt 0
btime 0
processes 0
procs_running 1
procs_blocked 0
softirq 0 0 0 0 0 0 0 0 0 0 0" >$bagname/etc/proc/stat
cpus=`cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1 | awk '{print $1}'`
if [ -n $cpus ]; then
	while [[ $cpus -ne 1 ]]
	do
		cpus=$(( $cpus-1 ))
		sed -i "2a cpu${cpus} 0 0 0 0 0 0 0 0 0 0" $bagname/etc/proc/stat
	done
	fi
	sed -i '3i export MOZ_FAKE_NO_SANDBOX=1' $bagname/etc/profile
echo "#!/usr/bin/env bash
cd

case \$1 in
        --purge) echo -e '是否删除容器？确认请输\e[33m y \e[0m回车，任意键退出'
        read -r -p '' input
	case \$input in
                Y|y) rm -rfv \${PREFIX}/bin/start-$bagname
                rm -rf $bagname
                        if [ -d $bagname ]; then
				echo -e '删除失败'
			else
				echo -e '已删除'
				fi
				sleep 1
				;;
			*) echo -e '操作取消'
		esac
		exit 0
esac

pkill -9 pulseaudio 2>/dev/null
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1
unset LD_PRELOAD
proot --kill-on-exit -b $DIRECT:/root$DIRECT -b $DIRECT -b /dev/null:/proc/sys/kernel/cap_last_cap -b /data/data/com.termux/cache -b /proc/self/fd/2:/dev/stderr -b /proc/self/fd/1:/dev/stdout -b /proc/self/fd/0:/dev/stdin -b /proc/self/fd:/dev/fd -b $bagname/tmp:/dev/shm -b /data/data/com.termux/files/usr/tmp:/tmp -b /dev/urandom:/dev/random --sysvipc --link2symlink -S $bagname -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TZ='Asia/Shanghai' LANG=C.UTF-8 /bin/bash --login" >${PREFIX}/bin/start-$bagname && chmod +x ${PREFIX}/bin/start-$bagname
for i in version misc buddyinfo kmsg consoles execdomains stat fb loadavg key-users uptime devices vmstat; do if [ ! -r /proc/"${i}" ]; then sed -E -i "s@(cap_last_cap)@\1 -b $bagname/etc/proc/${i}:/proc/${i}@" ${PREFIX}/bin/start-$bagname; fi done
echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW}start-$bagname${RES}\n删除容器${YELLOW}start-$bagname --purge${RES}"
:<<\eof
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S $bagname --link2symlink -b $DIRECT:/root$DIRECT -b $DIRECT -b $bagname/proc/version:/proc/version -b $bagname/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >$bagname.sh && chmod +x $bagname.sh
echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW}./$bagname.sh${RES}"
eof
sleep 2
}
#########################
#################
MAIN() {
	ARCH_CHECK
	uname -a | grep 'Android' -q
	if [ $? -ne 0 ]; then
	SUDO_CHECK
	echo -e "1) 软件安装
2) 系统相关
0) 退出\n"
read -r -p "请选择: " input
case $input in
        1) clear 
		INSTALL_SOFTWARE ;;
	2) clear
		SETTLE ;;
	0) exit 1 ;;
	*) INVALID_INPUT
		MAIN ;;
esac
else
	echo -e "1) termux相关(包括系统包下载)
0) 退出\n"
read -r -p "请选择: " input
	case $input in
		1) TERMUX ;;
		0) exit 0 ;;
		*) INVALID_INPUT
			MAIN ;;    
	esac
	fi
}
###############
MAIN "$@"
