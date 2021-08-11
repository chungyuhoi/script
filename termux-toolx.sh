#!/usr/bin/env bash
#####################
cd $(dirname $0)
date_t=`date +"%D"`
if ! grep -q $date_t ".date_tmp.log" 2>/dev/null; then
	echo -e "\n\e[33m为保证环境系统源正常使用，每日首次运行本脚本会先自检更新一遍哦(≧∇≦)/\e[0m"
	sleep 3
	apt update
	if [ ! $(command -v curl) ]; then
		apt install curl -y
	fi
	if [ ! $(command -v tar) ]; then
		apt install tar -y
	fi
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
TERMUX_CHECK() {
	uname -a | grep 'Android' -q
	if [ $? == 0 ]; then
	if [ ! -e ${HOME}/storage ]; then
	termux-setup-storage
	fi
	if grep '^[^#]' ${PREFIX}/etc/apt/sources.list | grep termux.org; then
	echo -e "${YELLOW}检测到你使用的可能为非国内源，为保证正常使用，建议切换为国内源(0.73版termux勿更换)${RES}\n
	1) 换国内源
	2) 不换"
	read -r -p "是否换国内源: " input
	case $input in
	1|"") echo "换国内源"
	sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
	sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
	sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list && pkg update ;;
	*) echo "#utqemucheck" >>${PREFIX}/etc/apt/sources.list ;;
	esac
        fi
        if [ ! $(command -v curl) ]; then
        pkg update && pkg install curl -y
        fi
        dpkg -l | grep pulseaudio -q 2>/dev/null
        if [ $? != 0 ]; then
        echo -e "${YELLOW}检测到你未安装pulseaudio，为保证声音正常输出，将自动安装${RES}"
        sleep 2
        pkg update && pkg install pulseaudio -y
        fi
        if grep -q "anonymous" ${PREFIX}/etc/pulse/default.pa; then
        echo ""
        else
        echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
	fi
	if grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf ; then
	sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
	echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf
	fi
	if [ ! $(command -v proot) ]; then
	pkg update && pkg install proot -y
	fi
        fi
}
#######################
TERMUX_CHECK
echo -e "${BLUE}welcome to use termux-toolx!\n
${YELLOW}更新日期20210726${RES}\n"
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
	echo -e "
1)  遇到关于Sub-process /usr/bin/dpkg returned an error code (1)错误提示
2)  安装个小火车(命令sl)
3)  增加普通用户并赋予sudo功能
4)  处理Ubuntu出现的groups: cannot find name for group *提示
5)  设置时区
6)  安装进程树(可查看进程,命令pstree)
7)  安装网络信息查询(命令ifconfig)
8)  修改国内源地址sources.list(only for debian and ubuntu)
9)  修改dns
10) GitHub资源库(仅支持debian-bullseye)
11) python3和pip应用
12) 中文汉化
13) 安装系统信息显示(neofetch,screenfetch)
14) 用不了pkill，下载pkill恢复包\n"
read -r -p "E(exit) M(main)请选择: " input

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
		SETTLE
;;
4) echo -e "请选择哪种方式处理
	1) 忽略信息
	2) 编辑gid信息\n"
	read -r -p "E(exit) M(main)请选择: " input
	case $input in
		1) echo "fix…"
			sleep 1
			touch ${HOME}/.hushlogin
			echo "done"
			sleep 1 ;;
		2) echo -n "如有多个gid，需重复多次，添加完请输'0'退出，请输gid数字(例如 3003)，GID: "
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
6) read -r -p "1)命令安装 2)恢复包安装 " input
	case $input in
		2) curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/PSTREE.tar.gz
		tar zxvf PSTREE.tar.gz && bash bash_me
		rm -rf PSTREE.tar.gz bash_me ;;
		*) 
	echo "安装进程树"
	$sudo_t apt install psmisc
	echo -e "${BLUE}done${RES}"
	;;
	esac
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
		read -r -p "E(exit) M(main)请选择: " input
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
	14) curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/PKILL.tar.gz
	tar zxvf PKILL.tar.gz && bash PKILL/bash_me
	rm -rf PKILL*
	echo -e "${BLUE}done${RES}"
	SETTLE
;;
	*) INVALID_INPUT
		SETTLE ;;
esac
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
deb-src http://mirrors.ustc.edu.cn/kali kali-rolling ${DEB_DEBIAN}" >/etc/apt/sources.list ;;
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
echo -e "仅支持debian和ubuntu
1) 修改debian或ubuntu国内源
2) 更新源列表
3) 为http修改为https(使用 HTTPS 可以有效避免国内运营商的缓存劫持)${RES}"
read -r -p "E(exit) M(main)请选择: " input

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
read -r -p "1)是 2)否 E(exit) M(main) " input

case $input in
	1|"")
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

	2)
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
	echo -e "\n${YELLOW}注意，目前仅支持debian(bullseye),建议先安装常用应用\n请在root用户下操作${RES}"
	CONFIRM
	CHECK
	echo -e "${YELLOW}是否添加Github仓库${RES}"
	read -r -p "1)是 2)否 E(exit) M(main) " input

case $input in
	1|"")
		echo "Yes"
#		curl -1sLf "https://dl.cloudsmith.io/public/debianopt/debianopt/gpg.D215CE5D26AF10D5.key" | apt-key add -
	$sudo_t apt install gnupg2 -y
	URL=`curl https://dl.cloudsmith.io/public/debianopt/debianopt/setup.deb.sh | grep \.key | grep \.gpg | sed -n 2p | cut -d '"' -f 2 | cut -d '"' -f 1`
	curl -1sLf $URL | apt-key add -
	mkdir /etc/apt/sources.list.d
	echo "deb https://dl.cloudsmith.io/public/debianopt/debianopt/deb/debian bullseye main
deb-src https://dl.cloudsmith.io/public/debianopt/debianopt/deb/debian bullseye main" >/etc/apt/sources.list.d/debianopt-debianopt.list
: <<\eof
ID=`grep -w ID=* /etc/os-release | cut -d "=" -f 2`
CODENAME=`grep -w VERSION_CODENAME=* /etc/os-release | cut -d "=" -f 2`
echo "deb https://dl.cloudsmith.io/public/debianopt/debianopt/deb/${ID} ${CODENAME} main
deb-src https://dl.cloudsmith.io/public/debianopt/debianopt/deb/${ID} ${CODENAME} main" >/etc/apt/sources.list.d/debianopt-debianopt.list
eof
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
	2)
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
read -r -p "1)xfce4 2)lxde 3)mate " input
case $input in
        1) echo -e "done" && sleep 2 ;;
        2) sed -i "s/startxfce4/startlxde/g" ${HOME}/.vnc/xstartup 
		$sudo_t apt purge --allow-change-held-packages gvfs udisk2 -y 2>/dev/null
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
                $sudo_t apt purge --allow-change-held-packages gvfs udisk2 -y 2>/dev/null
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
read -r -p "E(exit) M(main)请选择: " input
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
5) echo -n "输入你手机分辨率,例如 2340x1080  resolution: "
	read resolution
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
	echo -n "输入你手机分辨率,例如 2340x1080  resolution: "
        read resolution
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
$sudo_t apt purge --allow-change-held-packages gvfs udisk2 -y 2>/dev/null
U_ID=`id | cut -d '(' -f 2 | cut -d ')' -f 1`
GROUP_ID=`id | cut -d '(' -f 4 | cut -d ')' -f 1`
touch .ICEauthority .Xauthority 2>/dev/null
sudo -E chown -Rv $U_ID:$GROUP_ID ".ICEauthority" ".Xauthority"
echo -e "${GREEN}请选择你已安装的图形界面${RES}"
read -r -p "1)xfce4 2)lxde 3)mate " input
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
read -r -p "按回车继续 " input
case $input in
        *) echo "" ;;
esac
$sudo_t apt install xserver-xorg x11-utils
echo -e "${YELLOW}请选择你的桌面
1) startxfce4
2) startlxde
3) mate${RES}"
read -r -p "请选择: " input
case $input in
1) XWIN="x-window-manager & dbus-launch startxfce4" ;;
2) XWIN="x-window-manager & dbus-launch startlxde" ;;
3) XWIN="x-window-manager & dbus-launch mate-session" ;;
*) echo -e "\e[1;31m输入无效，已退出\e[0m" ;;
esac
# ip -4 -br -c a | awk '{print $NF}' | cut -d '/' -f 1 | grep -v '127\.0\.0\.1' | sed "s@\$@:5901@"
echo '#!/usr/bin/env bash
killall -9 Xtightvnc 2>/dev/null
killall -9 Xtigertvnc 2>/dev/null
killall -9 Xvnc 2>/dev/null
killall -9 vncsession 2>/dev/null
export DISPLAY=127.0.0.1:0
export PULSE_SERVER=tcp:127.0.0.1:4713' >/usr/local/bin/easyxsdl
echo "$XWIN" >>/usr/local/bin/easyxsdl && chmod +x /usr/local/bin/easyxsdl
echo -e "${YELLOW}已创建，命令easyxsdl${RES}"
sleep 2
VNCSERVER
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
VNCSERVER
;;
9) $sudo_t apt install xvfb x11vnc -y
	echo -n "输入你手机分辨率(例如:2340x1080) : "
	read resolution
cat >/usr/local/bin/easyx11vnc<<-'eof'
#!/usr/bin/env bash
killall -9 Xtightvnc 2>/dev/null
killall -9 Xtigertvnc 2>/dev/null
killall -9 Xvnc 2>/dev/null
killall -9 vncsession 2>/dev/null
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
set -- "${@}" "-wm"
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
sed -i "s/1080x2340/${resolution}/" /usr/local/bin/easyx11vnc
chmod +x /usr/local/bin/easyx11vnc
echo -e "\n已配置，启动命令${YELLOW}easyx11vnc${RES}\n"
sleep 1
INSTALL_SOFTWARE
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
	echo -e "1) 安装谷歌浏览器chromium
2) 安装火狐浏览器firefox
3) 安装epiphany-browser浏览器
4) 安装360浏览器(有一个月使用限制，需向360获取授权码)\n${RES}"
read -r -p "E(exit) M(main)请选择: " input
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
			echo -e "${YELLOW}你所使用的ubuntu源装chromium目前有bug${RES}
1) 临时切换有效的bionic(不建议)
2) 通过ppa源安装(未完全测试)
0) 返回"
read -r -p "请选择: " input
case $input in
	1) cp /etc/apt/sources.list /etc/apt/sources.list.tmp
		echo "${SOURCES_ADD}ubuntu-ports/ bionic ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-security ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-updates ${DEB_UBUNTU}
${SOURCES_ADD}ubuntu-ports/ bionic-backports ${DEB_UBUNTU}" >/etc/apt/sources.list
apt update && $sudo_t apt install chromium-browser chromium-codecs-ffmpeg-extra -y
PROCESS_CHECK
sudo echo "chromium-browser hold" | sudo dpkg --set-selections
sudo echo "chromium-browser-l10n hold" | sudo dpkg --set-selections
sudo echo "chromium-codecs-ffmpeg-extra hold" | sudo dpkg --set-selections
mv /etc/apt/sources.list.tmp /etc/apt/sources.list
apt update ;;
2) echo "检测到你用的ubuntu系统,将切换ppa源下载,下载过程会比较慢,请留意进度"
			sleep 2
CURL="http://ppa.launchpad.net/xalt7x/chromium-deb-vaapi/ubuntu/pool/main/c/chromium-browser/"
BRO="$(curl $CURL | grep arm64 | head -n 2 | tail -n 1 | cut -d '"' -f 8)"
curl -o chromium.deb ${CURL}${BRO}
BRO_FF="$(curl $CURL | grep arm64.deb | grep ffmpeg | tail -n 3 | head -n 1 | cut -d '"' -f 8)"
curl -o chromium_ffmpeg.deb ${CURL}${BRO_FF}
curl -o chromium-browser-l10n.deb http://ppa.launchpad.net/xalt7x/chromium-deb-vaapi/ubuntu/pool/main/c/chromium-browser/$(curl http://ppa.launchpad.net/xalt7x/chromium-deb-vaapi/ubuntu/pool/main/c/chromium-browser/ | grep chromium-browser-l10n | awk -F 'href="' '{print $2}' | cut -d '"' -f 1 | tail -n 1)
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
	read -r -p "E(exit) M(main)请选择: " input
	case $input in
		1) $sudo_t apt install xfce4 xfce4-terminal ristretto dbus-x11 lxtask -y ;;
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
	echo -e "\n1) 安装桌面图形界面
2) 安装VNCSERVER远程服务${RES}\n"
	read -r -p "E(exit) M(main)请选择: " input
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
read -r -p "E(exit) M(main)请选择: " input
case $input in
	1) echo -e "正在安装minetest"
	$sudo_t apt install minetest -y
	if echo $PATH | grep -vq games; then
	ln -s /usr/games/minetest /usr/local/bin
	fi
	if [ ! -f /usr/share/locale/zh_CN/LC_MESSAGES/minetest.mo ]; then
	curl -O https://cdn.jsdelivr.net/gh/chungyuhoi/script/MINETEST_MO.tar.gz
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
	[Ee]) exit 1 ;;
	[Mm]) MAIN ;;
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
5)  安装非官方版electron-netease-cloud-music(需先安装GitHub仓库与Electron)
6)  中文输入法
7)  mpv播放器
8)  办公office软件
9)  安装dosbox 并配置dosbox文件目录(运行文件目录需先运行一次dosbox以生成配置文件)
10) qemu-system-x86_64模拟器
11) 游戏相关
12) 让本终端成为局域网浏览器页面
13) 新立得(类软件商店)
14) linux版qq\n"
read -r -p "E(exit) M(main)请选择: " input

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
		$sudo_t apt update
		if grep -q bullseye /etc/os-release; then
		$sudo_t apt install electron -y
		else
		$sudo_t	apt install libnss3 unzip wget gnupg2 libxtst-dev -y
		mkdir /usr/share/electron
		cd /usr/share/electron
		wget https://npm.taobao.org/mirrors/electron/10.1.4/chromedriver-v10.1.4-linux-arm64.zip
		wget https://npm.taobao.org/mirrors/electron/10.1.4/ffmpeg-v10.1.4-linux-arm64.zip
		wget https://npm.taobao.org/mirrors/electron/10.1.4/electron-v10.1.4-linux-arm64.zip
        echo -e "\e[33m即将解压包，如遇到提示，请输y回车\e[0m"
        read -r -p "确认请回车" input
        case $input in
        *) ;;
        esac
        unzip chromedriver-v10.1.4-linux-arm64.zip
        unzip ffmpeg-v10.1.4-linux-arm64.zip
        unzip electron-v10.1.4-linux-arm64.zip
        ln -s /usr/share/electron/electron /usr/bin/
        if grep -q 'Package: electron' /var/lib/dpkg/status; then
        RAW=`cat -n /var/lib/dpkg/status | grep 'Package: electron' | awk '{print $1}'`
        let RAW_="$RAW+10"
        sed -i "${RAW},${RAW_}d" /var/lib/dpkg/status
        fi
cat >>/var/lib/dpkg/status<<-eof
Package: electron
Status: install ok installed
Priority: extra
Section: devel
Installed-Size: 185860
Maintainer: coslyk <cos.lyk@gmail.com>
Architecture: arm64
Version: 10.1.4-1
Depends: libasound2 (>= 1.0.16), libatk-bridge2.0-0 (>= 2.5.3), libatk1.0-0 (>= 2.2.0), libatspi2.0-0 (>= 2.9.90), libc6 (>= 2.17), libcairo2 (>= 1.6.0), libcups2 (>= 1.7.0), libdbus-1-3 (>= 1.9.14), libdrm2 (>= 2.4.38), libexpat1 (>= 2.0.1), libgbm1 (>= 17.1.0~rc2), libgcc1 (>= 1:4.2), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.39.4), libgtk-3-0 (>= 3.19.12), libnspr4 (>= 2:4.9-2~), libnss3 (>= 2:3.22), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libx11-6 (>= 2:1.4.99.1), libx11-xcb1, libxcb-dri3-0, libxcb1 (>= 1.6), libxcomposite1 (>= 1:0.3-1), libxcursor1 (>> 1.1.2), libxdamage1 (>= 1:1.1), libxext6, libxfixes3, libxi6 (>= 2:1.2.99.4), libxrandr2, libxrender1, libxtst6
Description: Build cross platform desktop apps with web technologies
Homepage: https://github.com/electron/electron
eof
		fi
        electron --version --no-sandbox
        if [ $? == 0 ]; then
        echo -e "\e[33m安装成功\e[0m"
	fi
		sleep 1
		INSTALL_SOFTWARE
		;;
	5)
		dpkg -l | grep electron -q
if [ "$?" == '0' ]; then
echo -e "${BLUE}检测到已安装Electron${RES}"
sleep 1
else
	echo -e "${BLUE}检测到你未安装Electron，需先添加GitHub仓库与安装electron(目前仅支持bullseye)${RES}"
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
read -r -p "E(exit) M(main)请选择: " input
case $input in
	1) echo -e "${YELLOW}安装fcitx输入法${RES}"
	$sudo_t apt install fcitx*googlepinyin* fcitx-table-wubi
#fcitx fcitx-tools fcitx-config-gtk fcitx-googlepinyin
if ! grep -q 'fcitx' /etc/environment; then
echo 'export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export SDL_IM_MODULE=fcitx' >>/etc/environment
fi
if ! grep -q 'PATH' /etc/environment; then
	sed -i '1i\PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' /etc/environment
fi
if ! grep -q 'environment' /etc/profile; then
	echo 'source /etc/environment' >>/etc/profile
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
		read -r -p "E(exit) M(main)请选择: " input
		case $input in
			1|"") echo "安装libreoffice"
		$sudo_t apt install --no-install-recommends libreoffice libreoffice-l10n-zh-cn libreoffice-gtk3 -y 
		echo -e "${GREEN}中文界面，请打开LibreOffice，左上角Tools-Options-Language settings-languages，User interface选择Chinese${RES}"
		CONFIRM ;;
	2) 
		ls /usr/share/applications/ | grep wps -q 2>/dev/null
		if [ $? != 0 ]; then
			echo -e "\n正在下载wps"
		CURL="$(curl -L https://www.wps.cn/product/wpslinux\# | grep .deb | grep arm | cut -d '"' -f 2)"
		curl -o wps.deb $CURL && $sudo_t dpkg -i wps.deb && rm wps.deb
		PROCESS_CHECK
#		sed -i '2i\export XMODIFIERS="@im=fcitx"' /usr/bin/wps /usr/bin/et /usr/bin/wpp 2>/dev/null
#		sed -i '2i\export QT_IM_MODULE="fcitx"' /usr/bin/wps /usr/bin/et /usr/bin/wpp 2>/dev/null
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
mkdir -p ${HOME}/.config/Kingsoft/
echo '[General]
languages=zh_CN' >${HOME}/.config/Kingsoft/Office.conf
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
IP=`ip -4 -br a | awk '{print $3}' | cut -d '/' -f 1 | sed -n 2p`
	echo -e "已完成配置，请尝试用浏览器打开并输入地址\n
	${YELLOW}本机	http://127.0.0.1:8080
	局域网	http://$IP:8080${RES}\n
	如需关闭，请按ctrl+c，然后输killall python3或直接exit退出shell\n"
	python3 -m http.server 8080 &
	sleep 2
	;;
13) echo -e "正在安装新立得"
	sleep 2
	$sudo_t apt install synaptic -y
	echo -e "done"
	sleep 1
	INSTALL_SOFTWARE ;;
14) VERSION=`curl -L https://aur.tuna.tsinghua.edu.cn/packages/linuxqq | grep x86 | cut -d "_" -f 2 | cut -d "_" -f 1`
	echo -e "${YELLOW}检测到新版本为${VERSION}${RES}"
	sleep 2
	rm linuxqq_${VERSION}_arm64.deb 2>/dev/null
	wget  https://down.qq.com/qqweb/LinuxQQ/linuxqq_${VERSION}_arm64.deb
	$sudo_t dpkg -i linuxqq_${VERSION}_arm64.deb
	dpkg -l | grep linuxqq -q 2>/dev/null
	if [ $? == 0 ]; then
		echo -e "\n${YELLOW}已安装${RES}"
	else
		echo -e "\n${RED}安装失败${RES}"
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
		read -r -p "E(exit) M(main)请选择: " input
		case $input in
			1) echo "安装dosbox"
				$sudo_t apt install dosbox -y
				echo -e "done\n如需创建dos运行文件目录，需先运行一次dosbox以生成配置文件"
				CONFIRM
				INSTALL_SOFTWARE ;;
			2) mkdir -p $DIRECT/xinhao/DOS
		if [ ! -e ${HOME}/.dosbox ]; then
			echo -e "\n${RED}未检测到dosbox配置文件，请先运行一遍dosbox，再做此步操作${RES}"
			sleep 2
		else
		dosbox=`ls ${HOME}/.dosbox`
                sed -i "/^\[autoexec/a\mount c $DIRECT/xinhao/DOS" ${HOME}/.dosbox/$dosbox
#		echo 'mount d $DIRECT/DOS/hospital -t cdrom' ${HOME}/.dosbox/$dosbox
#		echo 'mount d $DIRECT/DOS/CDROM -t cdrom -label mdk' ${HOME}/.dosbox/$dosbox
		echo -e "${GREEN}配置完成，请把运行文件夹放在手机主目录xinhao/DOS文件夹里，打开dosbox输入c:即可看到运行文件夹${RES}"
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
read -r -p "1)是 2)否 E(exit) M(main) " input
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
1) 使用在线utqemu脚本(功能完善)
2) 本脚本安装(仅提供安装与目录创建)"
read -r -p "E(exit) M(main) 请选择: " input
case $input in
	1)
	bash -c "$(curl https://cdn.jsdelivr.net/gh/chungyuhoi/script/utqemu.sh)" ;;
2) echo -e "
1) 安装qemu-system-x86_64，并联动更新模拟器所需应用
2) 创建windows镜像目录\n"
read -r -p "E(exit) M(main)请选择: " input
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
	[Ee])
	echo "exit"
	exit 1 ;;
	[Mm])
	echo "back to Main"
	MAIN ;;
	*) INVALID_INPUT && QEMU_SYSTEM ;;
	esac ;;                                              [Ee]) echo "exit"
	exit 1 ;;
	[Mm])
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
6)  下载Debian(buster)系统
7)  下载Ubuntu(bionic)系统
8)  下载Debian(bullseye)系统
9)  qemu-system-x86_64模拟器
10) 下载x86架构的Debian(buster)系统(qemu模拟)
11) 备份恢复系统
12) 修改termux键盘
13) 设置打开termux等待七秒(别问为什么)
14) 下载最新版本termux与xsdl\n"
read -r -p "E(exit) M(main)请选择: " input
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
		read -r -p "请选择: " input
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
echo "killall -9 pulseaudio 2>/dev/null
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
echo "killall -9 pulseaudio 2>/dev/null
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
	echo "" >$rootfs/proc/version
		echo "killall -9 pulseaudio 2>/dev/null
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
		sed -i "1i\killall -9 pulseaudio" ${PREFIX}/etc/bash.bashrc
	fi
fi
sleep 2 ;;
esac
TERMUX
;;
6) echo -e "由于系统包很干净，所以进入系统后，建议再用本脚本安装常用应用"
	CONFIRM
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
	read -r -p "E(exit) M(main) 请选择: " input
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
	read -r -p "E(exit) M(main) 请选择: " input
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

	8) echo -e "由于系统包很干净，所以进入系统后，建议再用本脚本安装常用应用"
	CONFIRM
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
	read -r -p "E(exit) M(main)请选择: " input
	case $input in
		1) CURL_T="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/debian/bullseye/arm64/default/" ;;
		2) CURL_T="https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/arm64/default/" ;;
        [Ee]) exit 0 ;;
        [Mm]) MAIN ;;
        esac
        echo "下载Debian(bullseye)系统..."
        sleep 1
        curl -o rootfs.tar.xz ${CURL_T}
        SYSTEM_DOWN
echo "修改为北外源"
echo "${SOURCES_ADD}debian bullseye ${DEB_DEBIAN}
${SOURCES_ADD}debian bullseye-updates ${DEB_DEBIAN}
${SOURCES_ADD}debian bullseye-backports ${DEB_DEBIAN}
${SOURCES_ADD}debian-security bullseye-security ${DEB_DEBIAN}" >$bagname/etc/apt/sources.list
        sleep 2
        TERMUX ;;
	9) QEMU_SYSTEM ;;
	10) echo -e "\n你正在下载的是x86架构的debian(buster),将会通过qemu的模拟方式运行;
由于系统包很干净，所以建议进入系统后，再用本脚本安装常用应用"
                CONFIRM
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
        read -r -p "E(exit) M(main) 请选择: " input
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
echo "killall -9 pulseaudio 2>/dev/null
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
read -r -p "E(exit) M(main) 请选择: " input
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
	11)
		echo -e "\n请选择备份或恢复
		1) 备份
		2) 恢复\n"
	read -r -p "E(exit) M(main) 请选择: " input
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
	[Ee]) echo "exit"
		exit 1 ;;
	[Mm]) echo "back to Main"
		unset backup
		MAIN ;;
	*) INVALID_INPUT
		unset backup
		TERMUX
	esac ;;
	12)  echo "修改键盘"
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
	13) echo -e "
		1) 增加等待7秒\n
		任意键) 取消等待"
		read -r -p "请选择: " input
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
	14) 
		echo -e "\n1)termux 2)xsdl 3)termux-api"
		read -r -p "E(exit) M(main)请选择: " input
	case $input in
		1) echo -e "\n${YELLOW}检测最新版本${RES}"
		VERSION=`curl https://f-droid.org/packages/com.termux/ | grep apk | sed -n 2p | cut -d '_' -f 2 | cut -d '"' -f 1`
		if [ ! -z "$VERSION" ]; then
		echo -e "\n下载地址\n${GREEN}https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/com.termux_$VERSION${RES}\n"
	else
		echo -e "${RED}获取失败，请重试${RES}"
		sleep 2
		unset VERSION
		TERMUX
		fi
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
	[Ee]) echo "exit"
                exit 1 ;;
        [Mm]) echo -e "back to Main\n"
                TERMUX ;;
	*) INVALID_INPUT ;;
	esac
        TERMUX ;;


	[Ee]) echo "exit"
	exit 1 ;;
	[Mm]) echo "back to Main"
	MAIN ;;
	*) INVALID_INPUT
	TERMUX ;;
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
		cat >$bagname/root/firstrun<<-'eof'
		printf "%b" "\e[33m正常进行首次运行配置\e[0m" && sleep 1 &&apt update
		if ! grep -q https /etc/apt/sources.list ]; then
		apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update
		fi
		apt install curl -y && sed -i "/firstrun/d" /etc/profile
		eof
		echo 'bash firstrun' >>$bagname/etc/profile
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
echo "killall -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S $bagname --link2symlink -b $DIRECT:/root$DIRECT -b $DIRECT -b $bagname/proc/version:/proc/version -b $bagname/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >$bagname.sh && chmod +x $bagname.sh
echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW}./$bagname.sh${RES}"
if [ -e ${PREFIX}/etc/bash.bashrc ]; then
if ! grep -q 'pulseaudio' ${PREFIX}/etc/bash.bashrc; then
sed -i "1i\killall -9 pulseaudio" ${PREFIX}/etc/bash.bashrc
fi
fi
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
	echo -e "1) 软件安装
2) 系统相关
E) exit\n"
read -r -p "CHOOSE: 1) 2) E(exit) " input
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
	echo -e "3) termux相关(包括系统包下载)
E) exit\n"
read -r -p "CHOOSE: 3) E(exit) " input
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
