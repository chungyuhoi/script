#!/usr/bin/env bash
#####################
cd $(dirname $0)
date_t=`date +"%D"`
if ! grep -q $date_t ".date_tmp.log" 2>/dev/null; then
	echo -e "\n\e[33m为保证环境系统源正常使用，每日首次运行本脚本会先自检更新一遍哦(≧∇≦)/\e[0m"
	sleep 3
	$sudo apt update
	echo $date_t >>.date_tmp.log 2>&1
fi

clear
#######################
#COLOR
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
RED="\e[1;31m"
BLUE="\e[1;34m"
PINK="\e[0;35m"
WHITE="\e[0;37m"
RES="\e[0m"

#SOURCE
SOURCES_USTC="deb http://mirrors.ustc.edu.cn/"
SOURCES_ADD="deb http://mirrors.bfsu.edu.cn/"
DEB_DEBIAN="main contrib non-free"
DEB_UBUNTU="main restricted universe multiverse"
#######################
echo -e "${BLUE}welcome to use termux-toolx!\n
${YELLOW}更新日期20210616${RES}\n"
echo -e "这个脚本是方便使用者自定义安装设置\n包括系统包也是很干净的"
uname -a | grep Android -q
if [ $? != 0 ]; then
	if [ `whoami` == "root" ];then
	echo -e "${BLUE}当前用户为root${RES}"
else
	echo -e "${RED}当前用户为$(whoami)，建议切换root用户${RES}\n"
	sleep 1
	fi
fi
if [ ! -e "/etc/os-release" ]; then
uname -a | grep 'Android' -q
if [ $? -eq 0 ]; then
	echo "你的系统是Android"
fi
	echo -e "${GREEN}"
cat <<'EOF'

          +hydNNNNdyh+
        +mMMMMMMMMMMMMm+
      `dMMm:NMMMMMMN:mMMd`
      hMMMMMMMMMMMMMMMMMMh
  ..  yyyyyyyyyyyyyyyyyyyy  ..
.mMMm`MMMMMMMMMMMMMMMMMMMM`mMMm.
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
:MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM:
-MMMM-MMMMMMMMMMMMMMMMMMMM-MMMM-
 +yy+ MMMMMMMMMMMMMMMMMMMM +yy+
      mMMMMMMMMMMMMMMMMMMm
      `/++MMMMh++hMMMM++/`
          MMMMo  oMMMM
          MMMMo  oMMMM
          oNMm-  -mMNs
EOF
echo -e "${RES}"
SYS=android
elif grep -q 'ID=debian' "/etc/os-release"; then
	printf '你的系统是'
cat /etc/os-release | grep PRETTY | cut -d '"' -f 2
echo -e "\e[0;31m"
cat <<'EOF'

       _,met$$$$$$gg.         
    ,g$$$$$$$$$$$$$$$P.       
  ,g$$P"        """Y$$.".        
 ,$$P'               `$$$.     
',$$P       ,ggs.     `$$b:   
`d$$'     ,$P"'   .    $$$    
 $$P      d$'     ,    $$P    
 $$:      $$.   -    ,d$$'    
 $$;      Y$b._   _,d$P'      
 Y$$.    `.`"Y$$$$P"'         
 `$$b      "-.__
  `Y$$
   `Y$$.
     `$$b.
       `Y$$b.
          `"Y$b._
              `"""

EOF
echo -e "${RES}"
SYS=debian
elif grep -q 'ID=ubuntu' "/etc/os-release"; then
printf "你的系统是"
cat /etc/os-release | grep PRETTY | cut -d '"' -f 2
	echo -e "${RED}"
cat <<'EOF'

	    .-/+oossssoo+/-.
        `:+ssssssssssssssssss+:`
      -+ssssssssssssssssssyyssss+-
    .ossssssssssssssssssdMMMNysssso.
   /ssssssssssshdmmNNmmyNMMMMhssssss/
  +ssssssssshmydMMMMMMMNddddyssssssss+
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/
.ssssssssdMMMNhsssssssssshNMMMdssssssss.
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
ossyNMMMNyMMhsssssssssssssshmmmhssssssso
ossyNMMMNyMMhsssssssssssssshmmmhssssssso
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
.ssssssssdMMMNhsssssssssshNMMMdssssssss.
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/
  +sssssssssdmydMMMMMMMMddddyssssssss+
   /ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
EOF
echo -e "${RES}"
SYS=ubuntu
elif grep -q 'ID=kali' "/etc/os-release"; then
	printf "你的系统是"
cat /etc/os-release | grep PRETTY | cut -d '"' -f 2
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
SYS=kali
fi
echo -e "你的架构为" $(dpkg --print-architecture)
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
SUDO_CHECK() {
if [ `whoami` != "root" ];then
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
case $input in
*) ;; esac
}
#####################
PROCESS_CHECK() {
if [ $? != 0 ]; then
       echo -e "${RED}下载失败，请重试${RES}"
fi
}
#####################
SETTLE() {
	echo -e "\n1) 遇到关于Sub-process /usr/bin/dpkg returned an error code (1)错误提示
2) 安装个小火车(命令sl)
3) 增加普通用户并赋予sudo功能
4) 处理Ubuntu出现的groups: cannot find name for group *提示
5) 设置时区
6) 安装进程树(可查看进程,kali不可用,命令pstree)
7) 安装网络信息查询(命令ifconfig)
8) 修改国内源地址sources.list(only for debian and ubuntu)
9) 修改dns
10) GitHub资源库(只支持debian和ubuntu)
11) python3和pip应用
12) 中文汉化
13) 安装系统信息显示(neofetch,screenfetch)\n${RES}"
read -r -p "E(exit) M(main)请选择:" input

case $input in
	1)
		echo "修复中..."
		sleep 1
		mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
		apt install
		echo "done"
		SETTLE
		;;
	2)
		echo "安装个小火车，运行命令sl"
		$sudo_t apt install sl && cp /usr/games/sl /usr/local/bin && sl 
		SETTLE
		;;
	3)
		echo -n "请输入普通用户名name:"
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

1)重新安装 2)不需要重新安装" input
	case $input in
		1) apt --reinstall install sudo ;;
		2|"") echo "" ;;
	esac
#	chmod +4755 /usr/bin/sudo ; chown root:root /usr/bin/sudo ; chmod +w /etc/sudoers
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
read -r -p "1)自定义时间 2)免密 3)不修改" input
case $input in
	1) echo -n "请输入时间数字，以分钟为单位(例如20)sudo_time:"
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
		SETTLE
;;
4) echo -e "请选择哪种方式处理
	1) 忽略信息
	2) 编辑gid信息\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in
		1) echo "fix…"
			sleep 1
			touch ${HOME}/.hushlogin
			echo "done"
			sleep 1 ;;
		2) echo -n "如有多个gid，需重复多次，添加完请输'0'退出，请输gid数字(例如 3003)，GID:"
			while echo "请输入"
				read GID
				[ $GID != "0" ]
do
        echo "$GID:x:$GID:" >>/etc/group
	echo -e "${YELLOW}已添加，如还需添加处理，请继续，退出请输'0'${RES}"
done
			echo -e "${YELLOW}exit${RES}"
			sleep 1 ;;
		[eE]) echo "exit"
			exit 1 ;;
        [Mm]) echo -e "back to main\n\n"
		MAIN ;;
	*) INVALID_INPUT
		SETTLE ;;
	esac
	SETTLE
	;;
	[eE])
		echo "exit"
		exit 1
		;;
	[Mm])
                echo -e "back to main\n\n"
		MAIN
		;;
	5) echo "设置时区为上海"
		sed -i "/^export TZ=/d" /etc/profile
		sed -i "1i\export TZ='Asia/Shanghai'" /etc/profile
		echo "done"
		sleep 2
SETTLE ;;
6)
	echo "安装进程树"
	$sudo_t apt install psmisc
	echo -e "${BLUE}done${RES}"
	SETTLE
                ;;
	7)
		echo "安装ifconfig"
	$sudo_t apt install net-tools
		echo -e "${BLUE}done${RES}"
		SETTLE
		;;
	8) SOURCES_LIST ;;
	9) MODIFY_DNS ;;
	10) ADD_GITHUB ;;
	11) INSTALL_PYTHON3 ;;
	12) LANGUAGE_CHANGE ;;
	13) echo -e "\n1)neofetch
2)screenfetch\n"
		read -r -p "E(exit) M(main)请选择:" input
		case $input in
			1) echo "安装neofetch"
			$sudo_t	apt install neofetch
				echo -e "${BLUE}done${RES}"
				SETTLE ;;
			2) echo "安装screenfetch"
			$sudo_t	apt install screenfetch
				echo -e "${BLUE}done${RES}"
				SETTLE ;;
			[Ee]) echo "exit"
				exit 0 ;;
			[Mm]) echo "返回"
				MAIN
				;;
			*) INVALID_INPUT
				SETTLE ;;
		esac ;;
	*) INVALID_INPUT
		SETTLE ;;
esac
}
################
LANGUAGE_CHANGE(){
                        echo "1)修改为中文; 2)修改为英文"
			read -r -p "1) 2)" input
			case $input in
			1) export LANGUAGE=zh_CN.UTF-8 && sed -i '/^export LANGUAGE/d' /etc/profile && sed -i '1i\export LANGUAGE=zh_CN.UTF-8' /etc/profile && source /etc/profile && echo '修改完毕,请重新登录' && sleep 2 && SETTLE ;;
2) export LANGUAGE=C.UTF-8 && sed -i '/^export LANGUAGE/d' /etc/profile && echo '修改完毕，请重新登录' && sleep 2 && SETTLE ;;
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
echo "${SOURCES_ADD}ubuntu-ports/ bionic ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-backports ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-security ${DEB_UBUNTU}" >/etc/apt/sources.list ;;
		*focal*)
echo "${SOURCES_ADD}ubuntu-ports/ focal ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ focal-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ focal-backports ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ focal-security ${DEB_UBUNTU}" >/etc/apt/sources.list ;;
		*Groovy*)
echo "${SOURCES_ADD}ubuntu-ports/ groovy ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ groovy-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ groovy-backports ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ groovy-security ${DEB_UBUNTU}" >/etc/apt/sources.list ;;
		*kali*)
echo "${SOURCES_USTC}kali kali-rolling ${DEB_DEBIAN}
deb-src http://mirrors.ustc.edu.cn/kali kali-rolling ${DEB_DEBIAN}" >/etc/apt/sources.lis ;;
		*strentch*)
echo "${SOURCES_ADD}debian/ stretch ${DEB_DEBIAN}
${SOURCES_ADD}debian/ stretch-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian/ stretch-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security stretch/updates ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*jessie*)
echo "${SOURCES_ADD}debian/ jessie ${DEB_DEBIAN}
${SOURCES_ADD}debian/ jessie-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian/ jessie-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security jessie/updates ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*buster*)
echo "${SOURCES_ADD}debian/ buster ${DEB_DEBIAN}
${SOURCES_ADD}debian/ buster-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian/ buster-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security buster/updates ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*bullseye*|*sid*)
echo "${SOURCES_ADD}debian/ bullseye ${DEB_DEBIAN}
${SOURCES_ADD}debian/ bullseye-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian/ bullseye-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security bullseye-security ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
		*)
echo -e "${RED}未收录你的系统源${RES}"
sleep 2
	SOURCES_LIST ;;
esac
if grep -q 'ubuntu' "/etc/os-release" ; then
sed -i "s/http/https/g" /etc/apt/sources.list
else
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
echo -e "${YELLOW} 仅支持debian和ubuntu
1) 修改debian或ubuntu国内源
2) 更新源列表
3) 为http修改为https(使用 HTTPS 可以有效避免国内运营商的缓存劫持)${RES}"
read -r -p "E(exit) M(main)请选择:" input

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
	[eE])                    
		echo "exit"                       
		exit
		;;
	[Mm])
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
read -r -p "Y(yes) N(no) E(exit) M(main)" input

case $input in
	[yY]|"")
		echo "Yes"
if [ ! -L "/etc/resolv.conf" ]; then
	echo "nameserver 223.5.5.5
nameserver 223.6.6.6" > /etc/resolv.conf
echo -e "${GREEN}已修改为223.5.5.5;223.6.6.6${RES}"          
sleep 1
SETTLE
elif [ -L "/etc/resolv.conf" ]; then
	mkdir -p /run/systemd/resolve 2>/dev/null && echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >/run/systemd/resolve/stub-resolv.conf
echo -e "${GREEN}已修改为223.5.5.5;223.6.6.6${RES}"
sleep 1
SETTLE
else
	echo "你的系统不支持"
	sleep 2
	SETTLE
fi
	;;

	[nN])
		echo "No"
		SETTLE
		;;

	[eE]) 
		echo "exit"
		exit 1
		;;
	[Mm])
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
	echo -e "\n${YELLOW}注意，目前仅支持debian(buster)与ubuntu(bionic),建议先安装常用应用\n请在root用户下操作${RES}"
	CONFIRM
	CHECK
	echo -e "${YELLOW}是否添加Github仓库${RES}"
read -r -p "Y(yes) N(no) E(exit) M(main)" input

case $input in
	[yY]|"")
		echo "Yes"
		curl -1sLf "https://dl.cloudsmith.io/public/debianopt/debianopt/gpg.D215CE5D26AF10D5.key" | apt-key add -
cat >/dev/null<<-eof
		dpkg -l | grep gnupg -q
		if [ "$?" != "0" ]; then
		$sudo_t apt install gnupg2 -y
		fi
		echo "deb https://bintray.proxy.ustclug.org/debianopt/debianopt buster main" > /etc/apt/sources.list.d/debianopt.list && curl -L https://bintray.com/user/downloadSubjectPublicKey?username=bintray | apt-key add -
eof
		apt update && SETTLE
		sleep 1
		;;
	[nN])
		echo "No"
		SETTLE
		;;

	[eE])        
		echo "exit"
		exit 1
		;;
	[Mm])
		echo "back to main"
		MAIN
		;;
	*)
		INVALID_INPUT
		ADD_GITHUB
		
		;;
esac
}
###################
XSTARTUP(){
	sed -i '/rm -rf \/tmp\/.X*/d' /etc/profile
	sed -i "1i\rm -rf \/tmp\/.X\*" /etc/profile
if [ ! -e ${HOME}/.vnc ]; then
                mkdir ${HOME}/.vnc
        fi
        echo "#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
#xrdb ${HOME}/.Xresources
export PULSE_SERVER=127.0.0.1
export XKL_XMODMAP_DISABLE=1
#vncconfig -iconic &
startxfce4 &" >${HOME}/.vnc/xstartup && chmod +x ${HOME}/.vnc -R
echo -e "${GREEN}请选择使用哪个图形界面${RES}"
read -r -p "1)xfce4 2)lxde 3)mate" input
case $input in
        1) echo -e "done" && sleep 2 ;;
        2) sed -i "s/startxfce4/startlxde/g" ${HOME}/.vnc/xstartup 
		$sudo_t apt purge --allow-change-held-packages gvfs -y && $sudo_t apt purge --allow-change-held-packages udisk2 -y 
		echo -e "done" && sleep 2 ;;
		3)
echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export PULSE_SERVER=127.0.0.1
export XKL_XMODMAP_DISABLE=1
x-window-manager
mate-panel
mate-session
thunar' >${HOME}/.vnc/xstartup
                $sudo_t apt purge --allow-change-held-packages gvfs -y && $sudo_t apt purge --allow-change-held-packages udisk2 -y
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
	echo -e "\n1) 安装tightvncserver
2) 安装tigervncserver (推荐)
3) 安装vnc4server
4) 配置vnc的xstartup参数
5) 设置tigervnc分辨率
6) 创建另一个VNC启动脚本（推荐 命令easyvnc）
7) 创建xsdl启动脚本(命令easyxsdl)
8) 创建局域网vnc连接(命令easyvnc-wifi)\n${RES}"
read -r -p "E(exit) M(main)请选择:" input
case $input in
	1)
		echo -e "${YELLOW}安装tightvncserver"
	$sudo_t apt install tightvncserver -y
	if [ ! -e "${HOME}/.vnc/passwd" ]; then       
		echo "请设置vnc密码,6到8位"          
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
		echo "请设置vnc密码,6到8位"        
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
   		echo "请设置vnc密码,6到8位"      
	       	vncpasswd                         
	fi
	XSTARTUP
	echo -e "${BLUE}已安装，请输vncserver :0并打开vnc viewer地址输127.0.0.1:0${RES}"
	sleep 2
	INSTALL_SOFTWARE
	;;
4) XSTARTUP ;;
5) echo -n "输入你手机分辨率,例如 2340x1080  resolution:"
	read resolution
	#sed -i "/^alias/d" /etc/profile && echo "alias vncserver='vncserver -geometry $resolution'" >>/etc/profile
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
		echo "请设置vnc密码,6到8位"
		vncpasswd
	fi
	echo -n "输入你手机分辨率,例如 2340x1080  resolution:"
        read resolution
	echo '#!/usr/bin/env bash
vncserver -kill $DISPLAY 2>/dev/null
pkill -9 Xtightvnc 2>/dev/null
pkill -9 Xtigertvnc 2>/dev/null
pkill -9 Xvnc 2>/dev/null
pkill -9 vncsession 2>/dev/null
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
set -- "${@}" "-geometry" '$resolution'
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
if [ ! -e /etc/X11/xinit/Xsession ]; then
	mkdir -p /etc/X11/xinit 2>/dev/null
fi
echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
#if [ $(command -v x-terminal-emulator) ]; then
#x-terminal-emulator &
#fi
if [ $(command -v xfce4-session) ]; then
dbus-launch xfce4-session
else
dbus-launch startxfce4
fi' >/etc/X11/xinit/Xsession && chmod +x /etc/X11/xinit/Xsession
cat >/dev/null <<EOF
echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
if [ $(command -v x-terminal-emulator) ]; then
x-terminal-emulator &
fi
if [ $(command -v xfce4-session) ]; then
dbus-launch xfce4-session
else
dbus-launch startxfce4
fi' >${HOME}/.vnc/xstartup
EOF
$sudo_t apt purge --allow-change-held-packages gvfs -y && $sudo_t apt purge --allow-change-held-packages udisk2 -y
U_ID=`id | cut -d '(' -f 2 | cut -d ')' -f 1`
GROUP_ID=`id | cut -d '(' -f 4 | cut -d ')' -f 1`
touch .ICEauthority .Xauthority 2>/dev/null
sudo -E chown -Rv $U_ID:$GROUP_ID ".ICEauthority" ".Xauthority"
echo -e "${GREEN}请选择你已安装的图形界面${RES}"
read -r -p "1)xfce4 2)lxde 3)mate" input
	case $input in
	1) echo -e "done" && sleep 2 && VNCSERVER ;;
	2) sed -i "s/startxfce4/startlxde/g" /etc/X11/xinit/Xsession
		sed -i "s/xfce4-session/lxsession/g" /etc/X11/xinit/Xsession
echo -e "Done\n打开vnc viewer地址输127.0.0.1:0\nvnc的退出，在系统输exit即可"
sleep 2
VNCSERVER
;;
3) echo '#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
x-window-manager
mate-panel
mate-session
thunar' >/etc/X11/xinit/Xsession
		echo -e "Done\n打开vnc viewer地址输127.0.0.1:0\nvnc的退出，在系统输exit即可"
		sleep 2
		VNCSERVER
		;;
*) echo -e "${RED}输入无效，已中止${RES}"
	sleep 2
VNCSERVER
esac ;;
7)
echo -e "\n\e[33m使用的时候需先打开手机xsdl！\e[0m"
read -r -p "按回车继续" input
case $input in
        *) echo "" ;;
esac
$sudo_t apt install xserver-xorg x11-utils
echo -e "${YELLOW}请选择你的桌面
1) startxfce4
2) startlxde
3) mate${RES}"
read -r -p "请选择:" input
case $input in
1) XWIN="x-window-manager & dbus-launch startxfce4" ;;
2) XWIN="x-window-manager & dbus-launch startlxde" ;;
3) XWIN="x-window-manager & dbus-launch mate-session" ;;
*) echo -e "\e[1;31m输入无效，已退出\e[0m" ;;
esac
# ip -4 -br -c a | awk '{print $NF}' | cut -d '/' -f 1 | grep -v '127\.0\.0\.1' | sed "s@\$@:5901@"
cat >/dev/null<<EOF
echo '#!/usr/bin/env bash
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
export DISPLAY=$IP:0
export PULSE_SERVER=tcp:$IP:4713
' >/usr/local/bin/easyxsdl
EOF
echo '#!/usr/bin/env bash
pkill -9 Xtightvnc 2>/dev/null
pkill -9 Xtigertvnc 2>/dev/null
pkill -9 Xvnc 2>/dev/null
pkill -9 vncsession 2>/dev/null
export DISPLAY=127.0.0.1:0
export PULSE_SERVER=tcp:127.0.0.1:4713' >/usr/local/bin/easyxsdl
echo "$XWIN" >>/usr/local/bin/easyxsdl && chmod +x /usr/local/bin/easyxsdl
echo -e "${YELLOW}已创建，命令easyxsdl${RES}"
sleep 2
VNCSERVER
;;
8) echo -e "\n创建局域网vnc连接(命令easyvnc-wifi)"
	sleep 2
	if [ ! $(command -v tigervncserver) ]; then
		$sudo_t apt install tigervnc-standalone-server tigervnc-viewer -y
	fi
	if [ ! -e ${HOME}/.vnc/xstartup ]; then
		XSTARTUP
	fi
# ip -4 -br -c a | awk '{print $NF}' | cut -d '/' -f 1 | grep -v '127\.0\.0\.1'
	echo '#!/usr/bin/env bash
pkill -9 Xtightvnc 2>/dev/null
pkill -9 Xtigertvnc 2>/dev/null
pkill -9 Xvnc 2>/dev/null
pkill -9 vncsession 2>/dev/null
vncserver -kill $DISPLAY 2>/dev/null
tigervncserver :0 -localhost no
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
echo -e "\e[33mVNCVIEWER打开地址为$IP:0\e[0m\n"
sleep 2' >/usr/local/bin/easyvnc-wifi && chmod +x /usr/local/bin/easyvnc-wifi
VNCSERVER
;;
[Ee])
	echo "exit"
	exit 1
	;;
[Mm])
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
	echo -e "${YELLOW}1) 安装谷歌浏览器chromium
2) 安装火狐浏览器firefox
3) 安装epiphany-browser浏览器
4) 安装360浏览器(有一个月使用限制，需向360获取授权码)\n${RES}"
read -r -p "E(exit) M(main)请选择:" input
	case $input in
	1)
		echo -e "安装谷歌浏览器chromium"
		if grep -q 'ID=debian' "/etc/os-release"; then
			$sudo_t apt install chromium -y
		elif grep -q 'ID=kali' "/etc/os-release"; then
			$sudo_t apt install chromium -y
		elif grep -q 'bionic' "/etc/os-release"; then
			$sudo_t apt install chromium-browser chromium-codecs-ffmpeg-extra -y
		elif grep -q 'ID=ubuntu' "/etc/os-release"; then
			echo -e "${YELLOW}你所使用的ubuntu源装chromium目前有bug，正在临时切换有效的bionic源${RES}"
			CONFIRM
			cp /etc/apt/sources.list /etc/apt/sources.list.tmp
			echo "${SOURCES_ADD}ubuntu-ports/ bionic ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-security ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-backports ${DEB_UBUNTU}" >/etc/apt/sources.list
apt update && $sudo_t apt install chromium-browser chromium-codecs-ffmpeg-extra -y
PROCESS_CHECK
sudo echo "chromium-browser hold" | sudo dpkg --set-selections
sudo echo "chromium-browser-l10n hold" | sudo dpkg --set-selections
sudo echo "chromium-codecs-ffmpeg-extra hold" | sudo dpkg --set-selection
mv /etc/apt/sources.list.tmp /etc/apt/sources.list
apt update
cat >/dev/null<<-'EOF'
echo "检测到你用的ubuntu系统,将切换ppa源下载,下载过程会比较慢,请留意进度"
			sleep 2
CURL="http://ppa.launchpad.net/xalt7x/chromium-deb-vaapi/ubuntu/pool/main/c/chromium-browser/"
BRO="$(curl $CURL | grep arm64 | head -n 2 | tail -n 1 | cut -d '"' -f 8)"
curl -o chromium.deb ${CURL}${BRO}
BRO_FF="$(curl $CURL | grep arm64.deb | grep ffmpeg | tail -n 3 | head -n 1 | cut -d '"' -f 8)"
curl -o chromium_ffmpeg.deb ${CURL}${BRO_FF}
$sudo_t dpkg -i chromium.deb && rm chromium.deb
$sudo_t dpkg -i chromium_ffmpeg.deb && rm chromium_ffmpeg.deb
EOF
sleep 2
else
        echo -e "${RED}你用的不是Debian或Ubuntu系统，操作将中止...${RES}"
sleep 2
WEB_BROWSER
fi
	if [ -e /usr/share/applications/chromium.desktop ]; then
		sed -i "s/Exec=\/usr\/bin\/chromium %U/Exec=\/usr\/bin\/chromium --no-sandbox \%U/g" /usr/share/applications/chromium.desktop
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
		echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export MOZ_FAKE_NO_SANDBOX=1' >/etc/environment
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
	[Ee])
		echo "exit"
		exit 1
		;;
	[Mm])
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
	3) 安装mate(有bug，请勿选)\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in
		1) $sudo_t apt install xfce4 xfce4-terminal ristretto -y ;;
		2) $sudo_t apt install lxde-core lxterminal dbus-x11 -y ;;
		3) 
#			$sudo_t apt install mate-desktop-environment mate-terminal -y
			$sudo_t apt install --no-install-recommends mate-session-manager mate-settings-daemon marco mate-terminal mate-panel dbus-x11 thunar -y && apt purge ^libfprint -y
			;;
		[eE]) echo "exit"
			exit 1 ;;
		[Mm]) echo "back to main"
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
	echo -e "${YELLOW}
	1) 安装桌面图形界面
	2) 安装VNCSERVER远程服务${RES}\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in
		1) DM ;;
		2) VNCSERVER ;;
		[eE]) echo "exit"
			exit 1 ;;
		[Mm]) echo "back to main"
			MAIN ;;
		*) INVALID_INPUT
			DM_VNC ;;
	esac
}
#######################
ENTERTAINMENT() {
	echo -e "\n1) minetest(画面跟我的世界相似，方向是个问题，需键盘操作)
2) mame街机模拟器(需键盘操作)\n"
read -r -p "E(exit) M(main)请选择:" input
case $input in
	1) echo -e "正在安装minetest"
		$sudo_t apt install minetest -y
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
	[Ee]) exit 1 ;;
	[Mm]) MAIN ;;
	*) INVALID_INPUT
		ENTERTAINMENT ;;
esac
}
#######################
INSTALL_SOFTWARE() {
	echo -e "\n\n${RED}注意，建议先安装常用应用\n${RES}"
	echo -e "1) ${GREEN}*安装常用应用(目前包括curl,wget,vim,fonts-wqy-zenhei,tar)${RES}
2) 安装Electron(将先安装GitHub仓库)
3) ${YELLOW}*安装桌面图形界面及VNCSERVER远程服务${RES}
4) 浏览器
5) 安装非官方版electron-netease-cloud-music(需先安装GitHub仓库与Electron)
6) 中文输入法
7) mpv播放器
8) 办公office软件
9) 安装dosbox 并配置dosbox文件目录(运行文件目录需先运行一次dosbox以生成配置文件)
10) qemu-system-x86_64模拟器
11) 游戏相关
12) 让本终端成为局域网浏览器页面
13) 安装新立得(类软件商店)
14) linux版qq\n"
read -r -p "E(exit) M(main)请选择:" input

case $input in
	1)
		echo "安装常用应用..."
		$sudo_t apt install curl wget vim fonts-wqy-zenhei tar -y
		echo -e "${YELLOW}done${RES}"
		sleep 1
		INSTALL_SOFTWARE
		
		;;

	2)
		echo -e "安装Electron\n如果安装不成功，请先安装Githut库"
		CONFIRM
		$sudo_t apt install electron -y
		echo -e "${YELLOW}done${RES}"
		sleep 1
		INSTALL_SOFTWARE
		;;
	3)	DM_VNC ;;
	4)	WEB_BROWSER ;;
	5)
		dpkg -l | grep electron -q
if [ "$?" == '0' ]; then
echo -e "${BLUE}检测到已安装Electron${RES}"
sleep 1
else
echo -e "${BLUE}检测到你未安装Electron，需先安装GitHub仓库与Electron${RES}"
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
2) ibus输入法\n"
read -r -p "E(exit) M(main)请选择:" input
case $input in
	1) echo -e "${YELLOW}安装fcitx输入法${RES}"
	$sudo_t apt install fcitx*googlepinyin* fcitx-table-wubi
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
[Ee]) exit 2 ;;
[Mm]) MAIN ;;
*) INVALID_INPUT
	INSTALL_SOFTWARE ;;
esac
;;
7)
	echo "安装mpv播放器"
	$sudo_t apt install mpv
	echo -e "${BLUE}done${RES}"
		sleep 1
		INSTALL_SOFTWARE
		;;
	8)
		echo -e "\n1) 安装libreoffice
2) 安装wps(注意，目前wps在vnc比较多的bug,建议用xsdl来传输)\n"
		read -r -p "E(exit) M(main)请选择:" input
		case $input in
			1|"") echo "安装libreoffice"
		$sudo_t apt install libreoffice 
		echo -e "${BLUE}done${RES}"
		sleep 1 ;;
	2) 
		ls /usr/share/applications/ | grep wps -q 2>/dev/null
		if [ $? != 0 ]; then
			echo -e "\n正在下载wps"
		CURL="$(curl -L https://www.wps.cn/product/wpslinux\# | grep .deb | grep arm | cut -d '"' -f 2)"
		curl -o wps.deb $CURL && $sudo_t dpkg -i wps.deb && rm wps.deb
		PROCESS_CHECK
		sed -i '2i\export XMODIFIERS="@im=fcitx"' /usr/bin/wps /usr/bin/et /usr/bin/wpp 2>/dev/null
		sed -i '2i\export QT_IM_MODULE="fcitx"' /usr/bin/wps /usr/bin/et /usr/bin/wpp 2>/dev/null
	else echo "已安装wps"
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
INSTALL_SOFTWARE
		;;
	[Ee]) exit 2 ;;
	[Mm]) MAIN ;;
	*) INVALID_INPUT ;;
esac
		INSTALL_SOFTWARE
		;;
	[eE])
		echo "exit"
		exit 1
		;;
	[Mm])
		echo -e "back to main\n\n"
		MAIN
		;;
	9) DOSBOX ;;
	10) QEMU_SYSTEM ;;
	11) ENTERTAINMENT ;;
	12) if [ ! $(command -v python3) ]; then
		echo -e "\n检测到你未安装python,将先为你安装上"
		sleep 2
		$sudo_t apt install python3 python3-pip -y && mkdir -p /root/.config/pip && echo "[global] 
index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >/root/.config/pip/pip.conf
	fi
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
	echo -e "已完成配置，请尝试用浏览器打开并输入地址\n
	${YELLOW}本机	http://127.0.0.1:8080
	局域网	http://$IP:8080${RES}\n
	如需关闭，请按ctrl+c，然后输pkill python3或直接exit退出shell\n"
	python3 -m http.server 8080 &
	sleep 2
	;;
13) echo -e "正在安装新立得"
	sleep 2
	apt install synaptic -y
	echo -e "done"
	sleep 1
	INSTALL_SOFTWARE ;;
14) VERSION=`curl -L https://aur.tuna.tsinghua.edu.cn/packages/linuxqq | grep x86 | cut -d "_" -f 2 | cut -d "_" -f 1`
	echo -e "${YELLOW}检测到新版本为${VERSION}${RES}"
	sleep 2
	wget  https://down.qq.com/qqweb/LinuxQQ/linuxqq_${VERSION}_arm64.deb
	dpkg -i linuxqq_${VERSION}_arm64.deb
	dpkg -l | grep linuxqq -q 2>/dev/null
	if [ $? == 0 ]; then
		echo -e "已安装"
	else
		echo -e "安装失败"
	fi
	sleep 2
	INSTALL_SOFTWARE
	;;
*) INVALID_INPUT
		INSTALL_SOFTWARE ;;
esac
}
##################
DOSBOX() {
	echo -e "\n1）安装dosbox
2）创建dos运行文件目录\n"
		read -r -p "E(exit) M(main)请选择:" input
		case $input in
			1) echo "安装dosbox"
				$sudo_t apt install dosbox -y
				echo -e "done\n如需创建dos运行文件目录，需先运行一次dosbox以生成配置文件"
				CONFIRM
				INSTALL_SOFTWARE ;;
			2) rm -rf $DIRECT/DOS && mkdir $DIRECT/DOS
		if [ ! -e ${HOME}/.dosbox ]; then
			echo -e "\n${RED}未检测到dosbox配置文件，请先运行一遍dosbox，再做此步操作${RES}"
			sleep 2
		else
		dosbox=`ls ${HOME}/.dosbox`
                sed -i "/^\[autoexec/a\mount c $DIRECT/DOS" ${HOME}/.dosbox/$dosbox
#		echo 'mount d $DIRECT/DOS/hospital -t cdrom' ${HOME}/.dosbox/$dosbox
#		echo 'mount d $DIRECT/DOS/CDROM -t cdrom -label mdk' ${HOME}/.dosbox/$dosbox
		echo -e "${GREEN}配置完成，请把运行文件夹放在手机主目录DOS文件夹里，打开dosbox输入c:即可看到运行文件夹${RES}"
		sleep 2
	fi
		INSTALL_SOFTWARE ;;
	[Ee]) 
		exit 0 ;;
	[Mm]) MAIN ;;
	*) INVALID_INPUT
		INSTALL_SOFTWARE ;;
esac
}
#####################
INSTALL_PYTHON3() {
echo -e "${YELLOW}安装python3和pip并配置国内源${RES}"
read -r -p "Y(yes) N(no) E(exit) M(main)" input
case $input in
	[Yy]|"")
		echo "yes"
		$sudo_t apt install python3 python3-pip && mkdir -p /root/.config/pip && echo "[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple" > /root/.config/pip/pip.conf
echo -e "${BLUE}done${RES}"
sleep 1
SETTLE
		;;
	[Nn])
		echo "no"
		SETTLE
		;;
	[Ee])
		echo "exit"
		exit 1
		;;
	[Mm])
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
1) 安装qemu-system-x86_64，并联动更新模拟器所需应用
2) 创建windows镜像目录
3) 启动qemu-system-x86_64模拟器
4) 安装5.0版本(注意!该操作需临时换源,仅适用debian与ubuntu)
5) 退出\n"
read -r -p "请选择:" input
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
# 	sed -i "1i\export PULSE_SERVER=tcp:127.0.0.1:4713" /etc/profile 2>/dev/null
#	sed -i "1i\export QEMU_AUDIO_DRV=alsa" /etc/profile 2>/dev/null	
        if [ ! -e "$DIRECT/windows" ]; then
                mkdir $DIRECT/windows
        fi
	if [ ! -e "$DIRECT/share/" ]; then
		mkdir $DIRECT/share
	fi
	if [ ! -e "$DIRECT/windows" ]; then
		echo -e "${RED}创建目录失败${RES}"
	else
		echo -e "${GREEN}手机主目录下已创建windows文件夹，请把'系统镜像，分区镜像，光盘镜像'放进这个目录里\n共享目录是share(目录内总文件大小不能超过500m)${RES}"
	fi
        CONFIRM
	QEMU_SYSTEM
        ;;
3) export PULSE_SERVER=tcp:127.0.0.1:4713
	read -r -p "请选择显示输出方式 1)vnc 2)xsdl(不推荐)" input
	case $input in
		1|"") echo "vncviewer地址为127.0.0.1:0"
			sleep 1
			set -- "${@}" "-vnc" ":0" ;;
		2) echo "需先打开xsdl再继续此操作"
			sleep 1
			export DISPLAY=127.0.0.1:0 ;;
	esac
	echo -e "\n请选择启动哪个模拟器\n
	1) qemu-system-x86_64
	2) qemu-system-i386\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in
		1) QEMU_SYS=qemu-system-x86_64 ;;
		2) QEMU_SYS=qemu-system-i386 ;;
		[Ee]) exit 1 ;;
		[Mm]) MAIN ;;
		*) INVALID_INPUT 
			QEMU_SYSTEM ;;
	esac

	qemu-system-x86_64 --version | grep ':5' -q || uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
		echo -e "${RED}5.0以上版本未经过完全测试，如运行不成功，请自行配置${RES}"
		sleep 2
	fi
	echo -e "${GREEN}请确认系统镜像已放入手机目录windows里${RES}"
	CONFIRM
	pkill -9 qemu-system-x86
	pkill -9 qemu-system-i38
	
	qemu-system-x86_64 --version | grep ':5' -q || uname -a | grep 'Android' -q
                                if [ $? != 0 ]; then
                set -- "${@}" "--accel" "tcg,thread=multi"
        else
                echo -e "请选择计算机类型"
                read -r -p "1)pc默认 2)q35" input
                case $input in
                        1|"") case $(dpkg --print-architecture) in
                        arm*|aarch64) set -- "${@}" "--accel" "tcg" ;;
                *) set -- "${@}" "-machine" "pc,accel=kvm:xen:hax:tcg" ;;
        esac ;;
                        2) echo -e ${RED}"如果无法进入系统，请选择pc${RES}"
                                set -- "${@}" "-machine" "q35,accel=kvm:xen:hax:tcg" ;;
                esac
#               set -- "${@}" "-machine" "q35"
                fi

        echo -n -e "请输入${YELLOW}系统镜像${RES}全名（例如andows.img）hda_name:"
	read hda_name
#	qemu-system-x86_64 --version | grep ':5' -q || uname -a | grep 'Android' -q
#	if [ $? != 0 ]; then
	echo -n -e "请输入${YELLOW}分区镜像${RES}全名,不加载请直接回车（例如hdb.img）hdb_name:"
	read hdb_name
#	fi
	echo -n -e "请输入${YELLOW}光盘${RES}全名,不加载请直接回车（例如DVD.iso）iso_name:"
	read iso_name
	echo -n "请输入模拟的内存大小,以m为单位（1g=1024m，例如512）mem:"
	read mem
	set -- "${@}" "-m" "$mem"
       	set -- "${@}" "-rtc" "base=localtime"
	set -- "${@}" "-no-user-config"
	set -- "${@}" "-nodefaults"
	read -r -p "请选择cpu 1)core2duo 2)athlon 3)pentium2 4)n270 5)Skylake-Server-IBRS" input
	case $input in
	1) set -- "${@}" "-cpu" "core2duo"
		set -- "${@}" "-smp" "2,cores=2,threads=1,sockets=1" ;;	
	2) set -- "${@}" "-cpu" "athlon"
		set -- "${@}" "-smp" "2,cores=2,threads=1,sockets=1" ;;
	3) set -- "${@}" "-cpu" "pentium2"
		set -- "${@}" "-smp" "1,cores=1,threads=1,sockets=1" ;;
	4) set -- "${@}" "-cpu" "n270"
		set -- "${@}" "-smp" "2,cores=1,threads=2,sockets=1" ;;
#	*) set -- "${@}" "-cpu" "Nehalem"
#		set -- "${@}" "-smp" "4,cores=2,threads=2,sockets=1" ;;
	5) set -- "${@}" "-cpu" "Skylake-Server-IBRS"
		set -- "${@}" "-smp" "4,cores=2,threads=1,sockets=2" ;;
	*) set -- "${@}" "-cpu" "max"
		set -- "${@}" "-smp" "4" ;;
esac
read -r -p "请选择显卡 1)cirrus 2)std 3)vmware" input
	case $input in
		1|"") set -- "${@}" "-vga" "cirrus" ;;
		2) set -- "${@}" "-vga" "std" ;;
		3) set -- "${@}" "-vga" "vmware" ;;
	esac
	read -r -p "请选择网卡 1)e1000 2)rtl8139 0)不加载" input
	case $input in
                        1) set -- "${@}" "-net" "user"
                                set -- "${@}" "-net" "nic,model=e1000" ;;
                        0) ;;
                        *) set -- "${@}" "-net" "user"
                                set -- "${@}" "-net" "nic,model=rtl8139" ;;
                esac
		read -r -p "是否加载usb鼠标 1)加载 0)不加载" input
		case $input in
			1|"") set -- "${@}" "-usb" "-device" "usb-tablet" ;;
			2) ;;
		esac
	qemu-system-x86_64 --version | grep ':5' -q || uname -a | grep 'Android' -q
		if [ $? != 0 ]; then
			read -r -p "请选择声卡 1)ac97 2)sb16 3)es1370 4)hda 0)不加载" input
                        case $input in
                1|"") set -- "${@}" "-soundhw" "ac97" ;;
                2) set -- "${@}" "-soundhw" "sb16" ;;
                0) ;;
                3) set -- "${@}" "-soundhw" "es1370" ;;
		4) set -- "${@}" "-soundhw" "hda" ;;
esac
                set -- "${@}" "-hda" "$DIRECT/windows/$hda_name"
		if [ -n "$hdb_name" ]; then
			set -- "${@}" "-hdb" "$DIRECT/windows/$hdb_name"
		fi
		if [ -n "$iso_name" ]; then
			set -- "${@}" "-cdrom" "$DIRECT/windows/$iso_name"
		fi
                set -- "${@}" "-hdd" "fat:rw:$DIRECT/share/"
		set -- "${@}" "-boot" "order=dc"

	else
		read -r -p "请选择声卡 1)es1370 2)sb16 3)hda 4)ac97(推荐) 0)不加载" input
                        case $input in
                        1) set -- "${@}" "-device" "ES1370" ;;
                        2) set -- "${@}" "-device" "sb16" ;;
			3) set -- "${@}" "-device" "intel-hda" "-device" "hda-duplex" ;;
                        0) ;;
                        4|"") set -- "${@}" "-device" "AC97" ;;
                esac
		set -- "${@}" "-boot" "order=dc,menu=on,strict=off"
		set -- "${@}" "-hda" "$DIRECT/windows/$hda_name"
		if [ -n "$hdb_name" ] ; then
			set -- "${@}" "-hdb" "$DIRECT/windows/$hdb_name"
		fi   
			if [ -n "$iso_name" ] ; then
				set -- "${@}" "-cdrom" "$DIRECT/windows/$iso_name"
			fi
		set -- "${@}" "-hdd" "fat:rw:$DIRECT/share/"
		fi
	set -- "$QEMU_SYS" "${@}"
	"${@}" &

	;;
4) echo -e "\n${YELLOW}安装5.0版本(不建议!注意!该操作需临时换源,仅适用debian与ubuntu)${RES}"
	sleep 1
	CHECK
	echo -e "${GREEN}请再次确认，不一定能成功安装，且可能改变你的系统版本${RES}
	Y(yes) 继续
	任意键 退出\n"
	read -r -p "请选择:" input
	case $input in
		[Yy]) echo "Yes" ;;
		"") QEMU_SYSTEM ;;
	esac
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	if grep -q 'ID=debian' "/etc/os-release" 2>/dev/null; then
echo "${SOURCES_ADD}debian/ bullseye ${DEB_DEBIAN}
${SOURCES_ADD}debian/ bullseye-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian/ bullseye-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security bullseye-security ${DEB_DEBIAN} " >/etc/apt/sources.list
	elif grep -q 'ID=ubuntu' "/etc/os-release" 2>/dev/null; then
		echo "${SOURCES_ADD}ubuntu-ports/ groovy ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ groovy-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ groovy-backports ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ groovy-security ${DEB_UBUNTU}" >/etc/apt/sources.list
		else
		echo -e "${RED}暂不支持你的系统${RES}"
		sleep 2
		QEMU_SYSTEM
	fi
	apt update
	$sudo_t apt install qemu-system-x86* -y
	cp /etc/apt/sources.list.bak /etc/apt/sources.list && apt update
	echo "done..."
	sleep 1
        QEMU_SYSTEM ;;
5) MAIN ;;
*) INVALID_INPUT && QEMU_SYSTEM ;;
esac
}
#################
#################
TERMUX() {
	echo -e "\n${PINK}注意！以下均在termux环境中操作\n${RES}"
	echo -e "1) ${YELLOW}* 一键配置好termux环境 (*^ω^*)${RES}
2) termux换国内源
3) 安装常用应用(包括curl tar wget vim proot)
4) 安装pulseaudio并配置(让termux支持声音输出)
5) 创建用户系统登录脚本
6) 下载Debian(buster)系统
7) 下载Ubuntu(bionic)系统
8) qemu-system-x86_64模拟器
9) 下载x86架构的Debian(buster)系统(qemu模拟)
10) 备份恢复系统
11) 修改termux键盘
12) 设置打开termux等待七秒(别问为什么)
13) 下载最新版本termux与xsdl\n"
read -r -p "E(exit) M(main)请选择:" input
case $input in
	1) echo -e "\n是否一键配置termux
               1) Yes
               2) No"
               read -r -p "请选择:" input
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
                               sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list && pkg update
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
3) 中科源
4) 腾讯源"
		read -r -p "请选择:" input
		case $input in
			1) echo -e "正在更换清华源"
		sleep 1
		sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
;;
2|"") echo -e "正在更换北外源" 
	sleep 1
	sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
;;
3) echo -e "正在更换中科源"
	sleep 1
	sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.ustc.edu.cn/termux stable main@' $PREFIX/etc/apt/sources.list
	;;
4) echo -e "正在更换腾讯源"
	sleep 1
	sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.cloud.tencent.com/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
	sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.cloud.tencent.com/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
	sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.cloud.tencent.com/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list ;;
esac
apt update && apt upgrade
echo -e  "已换源"
sleep 1
TERMUX
	;;
3)
	echo "安装常用应用(curl tar vim wget proot)"
	pkg install curl tar wget vim proot
	echo "已安装"
	TERMUX
	;;
4)
	echo -e "安装并配置pulseaudio\n如果安装失效，请选择另一种安装方式\n1)直接安装\n2)通过setup-audio脚本安装\n3)修复出现([pulseaudio] main.c: ${RED}Daemon startup failed.${RES})提示"
	read -r -p ":" input
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
		2) wget https://andronixos.sfo2.cdn.digitaloceanspaces.com/OS-Files/setup-audio.sh
			if [ $? -ne 0 ]; then
				echo -e "${RED}下载失败，请重试${RES}"
				sleep 2
				TERMUX
				fi
				chmod +x setup-audio.sh && ./setup-audio.sh
		echo -e "${GREEN}重新配置待机时长...${RES}"
        sed -i "s/180/-1/g" ${PREFIX}/etc/pulse/daemon.conf
	sleep 2 ;;
		3) unset LD_LIBRARY_PATH
			echo -e "已处理"
			sleep 1 ;;
		*) INVALID_INPUT
			TERMUX ;;
esac
		echo -e "\n已安装并配置pulseaudio"
	sleep 1
	TERMUX
	;;
5) echo -e "\n${GREEN}如需加挂外部sdcard，请先ls /mnt确认外部sdcard名字${RES}\n\n1)创建root用户 2)普通用户 9)返回 0)退出"
	read -r -p ":" input
	case $input in
		2) echo -e "\n${GREEN}请确认已安装sudo，否则无法系统内进行安装维护，切换root用户命令sudo su${RES}"
			echo -n "请把系统文件夹放根目录并输入系统文件夹名字rootfs: "
			read rootfs
			while [ ! -d $rootfs ]
			do
				echo -e "${RED}无此文件夹\n${RES}请重输: ${RES}"
			read rootfs
		done
		echo -n "请输入普通用户名name:"
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
echo -e "\n是否加载外部sdcard\n1)是\n2)跳过"
read -r -p ":" input
case $input in
	1) echo -n "请输入外部sdcard名字ext_sdcard:"
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
	echo -n "请把系统文件夹放根目录并输入系统文件夹名字rootfs:"
	read rootfs
	while [ ! -d $rootfs ]
                        do
				echo -e "${RED}无此文件夹\n${RES}请重输: ${RES}"
				read rootfs
		done
	if [ -e start-$rootfs.sh ]; then
		rm -rf start-$rootfs.sh
	fi
	echo "" >$rootfs/proc/version
		echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S $rootfs --link2symlink -b $DIRECT:/root$DIRECT -b $DIRECT -b $rootfs/proc/version:/proc/version -b $rootfs/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" > start-$rootfs.sh && chmod +x start-$rootfs.sh
echo -e "\n是否加载外部sdcard\n1)是\n2)跳过"
read -r -p ":" input
case $input in
	1) echo -n "请输入外部sdcard名字ext_sdcard:"
		read ext_sdcard
		sed -i "s/shm/shm -b \/mnt\/$ext_sdcard:\/root\/ext_sdcard/g" start-$rootfs.sh ;;
		*) echo "" ;;
	esac
echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW}./start-$rootfs.sh${RES}"
if [ -e ${PREFIX}/etc/bash.bashrc ]; then
	if ! grep -q 'pulseaudio' ${PREFIX}/etc/bash.bashrc; then
		sed -i "1i\pkill -9 pulseaudio" ${PREFIX}/etc/bash.bashrc
	fi
fi
sleep 2 ;;
esac
TERMUX
;;
6) echo -e "由于系统包很干净，所以进入系统后，建议再用本脚本安装常用应用"
	CONFIRM
	echo "检查下载安装所需应用..."
	sleep 2
	if [ ! $(command -v curl) ]; then
		apt install curl
	fi
	if [ ! $(command -v tar) ]; then
		apt install tar
	fi
	if [ -e rootfs.tar.xz ]; then
		rm -rf rootfs.tar.xz
	fi
	case $(dpkg --print-architecture) in
		aarch64|arm64) ;;
		*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
		sleep 2  ;;
	esac
	echo -e "请选择下载地址
	1) 清华大学
	2) 北外大学(推荐)\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in                                 
		1) CURL_T="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/debian/buster/arm64/default/" ;;
		2) CURL_T="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/buster/arm64/default/" ;;
		[Ee]) exit 0 ;;
		[Mm]) MAIN ;;
	esac
	echo "下载Debian(buster)系统..."                    
	sleep 1
	curl -o rootfs.tar.xz ${CURL_T}
		SYSTEM_DOWN
echo "修改为北外源"
echo "${SOURCES_ADD}debian buster ${DEB_DEBIAN}
${SOURCES_ADD}debian buster-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian buster-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security buster/updates ${DEB_DEBIAN}" >$bagname/etc/apt/sources.list
sleep 2
		TERMUX
		;;

	7) echo -e "由于系统包很干净，所以建议进入系统后，再用本脚本安装常用应用"
		CONFIRM
		echo "检查下载安装所需应用..."    
		sleep 2
		if [ ! $(command -v curl) ]; then
			apt install curl -y
		fi
		if [ ! $(command -v tar) ]; then
			apt install tar -y
		fi
		if [ -e rootfs.tar.xz ]; then
			rm -rf rootfs.tar.xz
		fi
		case $(dpkg --print-architecture) in
			aarch64|arm64) ;;
			*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
			sleep 2  ;;
		esac
	echo -e "请选择下载地址
	1) 清华大学
	2) 北外大学(推荐)\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in
		1) CURL_T="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/ubuntu/bionic/arm64/default/" ;;
		2) CURL_T="https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/bionic/arm64/default/" ;;
		[Ee]) exit 0 ;;
		[Mm]) MAIN ;;
	esac
	echo "下载Ubuntu(bionic)系统..."                     
	sleep 1
	curl -o rootfs.tar.xz ${CURL_T}
SYSTEM_DOWN
echo "修改为北外源"
echo "${SOURCES_ADD}ubuntu-ports/ bionic ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-security ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-backports ${DEB_UBUNTU}" >$bagname/etc/apt/sources.list
sleep 2
TERMUX ;;

	8) QEMU_SYSTEM ;;
	9) echo -e "\n你正在下载的是x86架构的debian(buster),将会通过qemu的模拟方式运行;
由于系统包很干净，所以建议进入系统后，再用本脚本安装常用应用"
                CONFIRM
                echo "检查下载安装所需应用..."
                sleep 2
		if [ ! $(command -v curl) ]; then
			apt install curl -y
		fi
		if [ ! $(command -v tar) ]; then
			apt install tar -y
		fi
		if [ -e rootfs.tar.xz ]; then
			rm -rf rootfs.tar.xz
		fi
		case $(dpkg --print-architecture) in
			aarch64|arm64) ;;
			*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
			sleep 2  ;;
		esac
        echo -e "请选择下载地址
        1) 清华大学
        2) 北外大学(推荐)\n"
        read -r -p "E(exit) M(main)请选择:" input
        case $input in
                1) CURL_T="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/debian/buster/amd64/default/" ;;
                2) CURL_T="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/buster/amd64/default/" ;;
                [Ee]) exit 0 ;;
                [Mm]) MAIN ;;
        esac
        echo "下载x86的Debian(buster)系统..."
        sleep 1
        curl -o rootfs.tar.xz ${CURL_T}
SYSTEM_DOWN
echo "修改为北外源"
echo "${SOURCES_ADD}debian buster ${DEB_DEBIAN}
${SOURCES_ADD}debian buster-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian buster-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security buster/updates ${DEB_DEBIAN}" >$bagname/etc/apt/sources.list
sleep 2
echo "配置qemu"
sleep 2
rm -rf termux_tmp && mkdir termux_tmp && cd termux_tmp
CURL_T=`curl https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/ | grep '\.deb' | grep 'qemu-user-static' | grep arm64 | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2`
curl -o qemu.deb https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/$CURL_T
apt install binutils -y
ar -vx qemu.deb
tar xvf data.tar.xz
cd && cp termux_tmp/usr/bin/qemu-x86_64-static $bagname/
echo "删除临时文件"
sleep 1
rm -rf termux_tmp
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S $bagname --link2symlink -b $bagname/root:/dev/shm -b $DIRECT -q $bagname/qemu-x86_64-static -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TERM=xterm-256color LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 /bin/bash" >$bagname.sh
echo -e "现在可以用${YELLOW}./$bagname.sh${RES}登录系统"
sleep 2
TERMUX ;;

	[Kk][Aa][Ll][Ii]) echo -e "\n${YELLOW}欢迎进入隐藏选项，kali系统的下载安装!(≧∇≦)/\n${RES}"
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
echo "检查下载安装所需应用..."                          
sleep 2
if [ ! $(command -v curl) ]; then
	apt install curl -y
	fi
	if [ ! $(command -v tar) ]; then
	apt install tar -y
fi
if [ -e rootfs.tar.xz ]; then
	rm -rf rootfs.tar.xz
fi
case $(dpkg --print-architecture) in
	aarch64|arm64) ;;
	*) echo -e "${RED}你用的架构不支持，下载中止${RES}"
	sleep 2  ;;
esac
echo -e "请选择下载地址
1) 清华大学
2) 北外大学(推荐)\n"
read -r -p "E(exit) M(main)请选择:" input
case $input in
	1) CURL_T="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/kali/current/arm64/default/" ;;
	2) CURL_T="https://mirrors.bfsu.edu.cn/lxc-images/images/kali/current/arm64/default/" ;;
	[Ee]) exit 0 ;;
	[Mm]) MAIN ;;
esac
echo "下载kali系统..."                                      
sleep 1
curl -o rootfs.tar.xz ${CURL_T}
SYSTEM_DOWN
echo "修改为中科源"
echo "${SOURCES_USTC}kali kali-rolling ${DEB_DEBIAN}
deb-src http://mirrors.ustc.edu.cn/kali kali-rolling ${DEB_DEBIAN}" >$bagname/etc/apt/sources.list
sleep 2
                TERMUX
		;;
	10) if [ ! $(command -v tar) ]; then
		echo -e "检测到你未安装tar,将先安装tar"
		sleep 2
		pkg install tar -y
	fi
		echo -e "\n请选择备份或恢复
		1) 备份
		2) 恢复\n"
	read -r -p "E(exit) M(main)请选择:" input
	case $input in
		1) echo -n "请输入拟备份的系统文件夹名(可含路径)backup:"
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
			     2) echo -n "请把恢复包放到本脚本目录，并输入拟恢复包的完整名字(可含路径，支持*.tar.gz或*.tar.xz后缀名) backup:"
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
				     [Ee]) echo "exit"
					     exit 1 ;;
				     [Mm]) echo "back to Main"
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
	12) echo -e "
		1) 增加等待7秒\n
		任意键) 取消等待"
		read -r -p "请选择:" input
		case $input in
			1) echo -e "\nwait for 7 seconds"
cat >>${PREFIX}/etc/bash.bashrc<<-'EOF'
echo -e "wait for 7 seconds"
i=0
while [ $i -le 70 ]
do
printf "$ %-7s\r" "$i"
sleep 0.1
let i++
done
printf "\n"
EOF
;;
			*) echo "取消"
sed -i '/seconds/,+8d' ${PREFIX}/etc/bash.bashrc ;;
esac
TERMUX ;;
	13) 
	read -r -p "1)termux 2)xsdl " input
	case $input in
		1) echo -e "\n${YELLOW}检测最新版本${RES}"
		VERSION=`curl https://f-droid.org/packages/com.termux/ | grep apk | sed -n 2p | cut -d '_' -f 2 | cut -d '"' -f 1`
		echo -e "\n下载地址\n${GREEN}https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/com.termux_$VERSION${RES}\n"
		read -r -p "1)下载 9)返回 " input
		case $input in
			1) rm termux.apk 2>/dev/null
		curl https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/com.termux_$VERSION -o termux.apk
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
		echo -e "移到${DIRECT}${STORAGE}目录中..."
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
	*) INVALID_INPUT ;;
	esac
        TERMUX ;;
	[nN])
		echo "no"
		MAIN
		;;

	[Ee])
		echo "exit"
		exit 1
		;;
	[Mm])
		echo "back to Main"
		MAIN
		;;
	*)
		INVALID_INPUT
		TERMUX
		;;
esac
}
#######################
SYSTEM_DOWN() {
        VERSION=`cat rootfs.tar.xz | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1`
                curl -o rootfs.tar.xz ${CURL_T}${VERSION}rootfs.tar.xz
                if [ $? -ne 0 ]; then
                        echo -e "${RED}下载失败，请重输${RES}\n"
                        TERMUX
                        sleep 2
                fi
                echo -n "请给系统文件夹起个名bagname:"
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
                echo "配置dns"
		rm $bagname/etc/resolv.conf 2>/dev/null
		echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >$bagname/etc/resolv.conf
echo -e "${GREEN}已修改为223.5.5.5
223.6.6.6${RES}"
sleep 1
if grep -q 'ubuntu' "$bagname/etc/os-release" ; then
        touch "$bagname/root/.hushlogin"
fi
echo "" >$bagname/proc/version
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S $bagname --link2symlink -b $DIRECT:/root$DIRECT -b $DIRECT -b $bagname/proc/version:/proc/version -b $bagname/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >$bagname.sh && chmod +x $bagname.sh
echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW}./$bagname.sh${RES}"
if [ -e ${PREFIX}/etc/bash.bashrc ]; then
if ! grep -q 'pulseaudio' ${PREFIX}/etc/bash.bashrc; then
sed -i "1i\pkill -9 pulseaudio" ${PREFIX}/etc/bash.bashrc
fi
fi
ln -s ${HOME}/termux-toolx.sh $bagname/root/
sleep 2
}
#########################
#################
MAIN() {
	ARCH_CHECK
	uname -a | grep 'Android' -q
	if [ $? -ne 0 ]; then
	echo "当前环境为rootfs系统,已自动屏蔽termux相关选项"
	SUDO_CHECK
	echo -e "${YELLOW}1) 软件安装
2) 系统相关
E) exit\n${RES}"
read -r -p "CHOOSE: 1) 2) E(exit)" input
case $input in
        1) clear 
		INSTALL_SOFTWARE ;;
	2) clear
		SETTLE ;;
	[Ee]) exit 1 ;;
	*) INVALID_INPUT
		MAIN ;;
esac
else
	echo "当前环境为termux,已自动屏蔽rootfs系统相关选项"
	echo -e "${YELLOW}3) termux相关(包括系统包下载)
E) exit\n${RES}"
read -r -p "CHOOSE: 3) E(exit)" input
	case $input in
		3) TERMUX ;;
		[Ee]) exit 1 ;;
		*) INVALID_INPUT
			MAIN ;;    
	esac
	fi
}
###############
MAIN "$@"
