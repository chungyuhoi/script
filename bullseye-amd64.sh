#!/usr/bin/env bash
echo -e "\e[33m即将下载系统,本系统将通过模拟x86_64架构运行\n本脚本是进行全新安装,非恢复包\e[0m"
sleep 2
rm rootfs.tar.xz 2>/dev/null
curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/amd64/default/$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/amd64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1)rootfs.tar.xz
mkdir bullseye-amd64
tar xvf rootfs.tar.xz -C bullseye-amd64
rm rootfs.tar.xz
echo -e "\e[33m系统已下载,文件夹名为bullseye-amd64\e[0m"
sleep 2
echo $(uname -a) | sed 's/Android/GNU\/Linux/' >bullseye-amd64/proc/version
if [ ! -f "bullseye-amd64/usr/bin/perl" ]; then
        cp bullseye-amd64/usr/bin/perl* bullseye-amd64/usr/bin/perl
fi
echo ". firstrun" >>bullseye-amd64/root/.bashrc
sed -i "1i\dpkg --print-architecture" bullseye-amd64/root/.bashrc
sed -i "1i\rm -rf \/tmp\/.X\*" bullseye-amd64/root/.bashrc
rm bullseye-amd64/etc/resolv.conf 2>/dev/null
echo "nameserver 223.5.5.5
nameserver 223.6.6.6" >bullseye-amd64/etc/resolv.conf
echo 'deb http://mirrors.bfsu.edu.cn/debian/ bullseye main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian/ bullseye-updates main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian/ bullseye-backports main contrib non-free
deb http://mirrors.bfsu.edu.cn/debian-security bullseye-security main contrib non-free' >bullseye-amd64/etc/apt/sources.list

echo "配置qemu"
sleep 2
curl -o qemu.deb https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/$(curl https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/ | grep '\.deb' | grep 'qemu-user-static' | grep arm64 | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)
mkdir qemu_temp
dpkg -X qemu.deb ./qemu_temp
cp qemu_temp/usr/bin/qemu-x86_64-static bullseye-amd64/
echo "删除临时文件"
sleep 1
rm -rf qemu_temp qemu.deb
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start &
unset LD_PRELOAD
proot --kill-on-exit -S bullseye-amd64 --link2symlink -b bullseye-amd64/root:/dev/shm -b /sdcard -q bullseye-amd64/qemu-x86_64-static -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TERM=xterm-256color LANG=C.UTF-8 TZ=Asia/Shanghai /bin/bash" >start-bullseye-amd64.sh && chmod +x start-bullseye-amd64.sh
echo -e "现在可以用\e[33m./start-bullseye-amd64.sh\e[0m登录系统"

cat >bullseye-amd64/root/firstrun<<-'eof'
echo -e "正在配置首次运行\n由于跨架构，速度会比较慢"
sleep 2
apt update
if ! grep -q https /etc/apt/sources.list; then
apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update
fi
sed -i "/firstrun/d" .bashrc
echo "如果想运行桌面，测试xfce4与tigervnc可正常安装"
read -r -p "安装完成，按回车键确认" input
case $input in
*) ;; esac
eof
