#!/usr/bin/env bash
DIRECT="/sdcard/xinhao/DOS"
YELLOW="\e[33m"
RES="\e[0m"
if [ $(id -u) != 0 ]; then sudo=sudo; fi
uname -a | grep 'Android' -q
if [ $? == 0 ]; then
	echo -e "不支持termux环境"
	sleep 1
	exit 0
fi

start_dos() {
clear
#trap "pkill Xvnc 2>/dev/null;exit" SIGINT EXIT
echo -e "\n本脚本仅适合字符界面使用，图形界面请点dosbox图标\n${YELLOW}请确认系统镜像已放入目录${DIRECT}里${RES}\n"
echo -e "模拟器启动后，请打开vncviewer输地址 ${YELLOW}127.0.0.1:0${RES}\n\ndos操作\n${YELLOW}查看文件夹内容 dir\n进入目录 cd 目录名\n鼠标解锁 ctrl+f10\n退出 exit\n偶尔花屏/强制关闭，在termux输 ctrl+c${RES}"
echo ""
LIST=`ls ${DIRECT} | awk '{printf("%d) %s\n" ,NR,$0)}'`
echo -e "已为你列出目录文件\n$LIST"
echo ""
read -r -p "请输序号选择，其他键退出: " input
doc_name=`echo "$LIST" | grep -w "${input})" | awk '{print $2}'`
if [ -z "${doc_name}" ]; then
	echo -e "输出无效，退出"
sleep 1
exit 0
fi
sed -i "/mount c/s/\(DOS\/\).*$/\1${doc_name}/" ${HOME}/.dosbox/*.conf
sed -i "/mount d/s/#//;/mount d/s/\(DOS\/\).*/\1${doc_name} -t cdrom -label ${doc_name}/" ${HOME}/.dosbox/*.conf
export PULSE_SERVER=127.0.0.1:4713
export DISPLAY=:0
Xvnc -ZlibLevel=1 -securitytypes vncauth,tlsvnc -verbose -ImprovedHextile -CompareFB 1 -br -retro -a 5 -wm -alwaysshared -geometry 640x480 -once -depth 16 -localhost -SecurityTypes None &
sleep 1
trap "pkill Xvnc 2>/dev/null; cp ${HOME}/.dosbox/*.conf.bak ${HOME}/.dosbox/*.conf; exit" SIGINT EXIT
dosbox

}
install_dos() {
clear
if [ ! $(command -v dosbox) ]; then
$sudo 	apt install tigervnc-standalone-server pulseaudio dosbox --no-install-recommends -y
mkdir -p $DIRECT
echo -e "${YELLOW}请把运行文件夹放在手机主目录xinhao/DOS文件夹里。\n脚本只是给玩友体验linux中运行dos，想提高运行效率请自行去网上搜索dosbox并安装设备版本的app${RES}"
read -r -p "按回车继续" input
case $input in
	*) ;;
esac
fi
if [ ! -f ${HOME}/.dosbox/*.conf ]; then
	dosbox -printconf >/dev/null 2>&1
elif ! grep -q utdos ${HOME}/.dosbox/*.conf; then
	dosbox -printconf >/dev/null 2>&1
	echo "#utdos" >>${HOME}/.dosbox/*conf
fi
dos_conf=`ls ${HOME}/.dosbox/*conf` >/dev/null 2>&1
if ! grep "^mount c" $dos_conf; then
sed -i "/^\[autoexec/a\mount c $DIRECT\/" $dos_conf
fi
if ! grep "mount d" $dos_conf; then
sed -i "/xinhao/a #挂载光盘\n#mount d $DIRECT/光盘目录 -t cdrom" $dos_conf
fi
if ! grep ^c: $dos_conf; then
echo "c:" >>$dos_conf
fi
if ! grep cls $dos_conf; then
echo "cls" >>$dos_conf
fi
sed -i 's/\(fullscreen=\)false/\1true/' $dos_conf
cp $dos_conf $dos_conf.bak
}
main() {
install_dos
start_dos
}
main "$@"
