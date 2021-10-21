if [ ! $(command -v qemu-system-i386) ]; then
echo -e "\e[33m请先安装qemu-system-i386\e[0m"
sleep 1
else
echo -e "\n\e[33m针对qemu模拟i386,x86_64的cpu特性支持测试\e[0m\n"
echo -e "\e[33m正在检测中...\e[0m\n"
sleep 1
case $(qemu-system-i386 --version | grep version | awk -F "." '{print $1}' | awk '{print $4}') in
	3)
qemu-system-i386 -cpu max,+3dnow,+3dnowext,+3dnowprefetch,+abm,+ace2,+ace2-en,+acpi,+adx,+aes,+amd-no-ssb,+amd-ssbd,+apic,+arat,+arch-capabilities,+avx,+avx2,+avx512-4fmaps,+avx512-4vnniw,+avx512-vpopcntdq,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512er,+avx512f,+avx512ifma,+avx512pf,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+bmi1,+bmi2,+cid,+cldemote,+clflush,+clflushopt,+clwb,+cmov,+cmp-legacy,+cr8legacy,+cx16,+cx8,+dca,+de,+decodeassists,+ds,+ds-cpl,+dtes64,+erms,+est,+extapic,+f16c,+flushbyasid,+fma,+fma4,+fpu,+fsgsbase,+fxsr,+fxsr-opt,+gfni,+hle,+ht,+hypervisor,+ia64,+ibpb,+ibrs-all,+ibs,+intel-pt,+invpcid,+invtsc,+kvm-asyncpf,+kvm-hint-dedicated,+kvm-mmu,+kvm-nopiodelay,+kvm-pv-eoi,+kvm-pv-ipi,+kvm-pv-tlb-flush,+kvm-pv-unhalt,+kvm-steal-time,+kvmclock,+kvmclock,+kvmclock-stable-bit,+la57,+lahf-lm,+lbrv,+lm,+lwp,+mca,+mce,+md-clear,+mds-no,+misalignsse,+mmx,+mmxext,+monitor,+movbe,+mpx,+msr,+mtrr,+nodeid-msr,+npt,+nrip-save,+nx,+osvw,+pae,+pat,+pause-filter,+pbe,+pcid,+pclmulqdq,+pcommit,+pconfig,+pdcm,+pdpe1gb,+perfctr-core,+perfctr-nb,+pfthreshold,+pge,+phe,+phe-en,+pku,+pmm,+pmm-en,+pn,+pni,+popcnt,+pschange-mc-no,+pse,+pse36,+rdctl-no,+rdpid,+rdrand,+rdseed,+rdtscp,+rsba,+rtm,+sep,+sha-ni,+skinit,+skip-l1dfl-vmentry,+smap,+smep,+smx,+spec-ctrl,+ss,+ssb-no,+ssbd,+sse,+sse2,+sse4.1,+sse4.2,+sse4a,+ssse3,+svm,+svm-lock,+syscall,+tbm,+tce,+tm,+tm2,+topoext,+tsc,+tsc-adjust,+tsc-deadline,+tsc-scale,+umip,+vaes,+virt-ssbd,+vmcb-clean,+vme,+vmx,+vpclmulqdq,+wbnoinvd,+wdt,+x2apic,+xcrypt,+xcrypt-en,+xgetbv1,+xop,+xsave,+xsavec,+xsaveopt,+xsaves,+xstore,+xstore-en,+xtpr -daemonize -display none >/dev/null 2>.utqemu_log ;;
*)
qemu-system-i386 -cpu max,+3dnow,+3dnowext,+3dnowprefetch,+abm,+ace2,+ace2-en,+acpi,+adx,+aes,+amd-no-ssb,+amd-ssbd,+amd-stibp,+apic,+arat,+arch-capabilities,+avx,+avx2,+avx512-4fmaps,+avx512-4vnniw,+avx512-bf16,+avx512-vp2intersect,+avx512-vpopcntdq,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512er,+avx512f,+avx512ifma,+avx512pf,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+bmi1,+bmi2,+cid,+cldemote,+clflush,+clflushopt,+clwb,+clzero,+cmov,+cmp-legacy,+core-capability,+cr8legacy,+cx16,+cx8,+dca,+de,+decodeassists,+ds,+ds-cpl,+dtes64,+erms,+est,+extapic,+f16c,+flushbyasid,+fma,+fma4,+fpu,+fsgsbase,+fsrm,+full-width-write,+fxsr,+fxsr-opt,+gfni,+hle,+ht,+hypervisor,+ia64,+ibpb,+ibrs-all,+ibs,+intel-pt,+invpcid,+invtsc,+kvm-asyncpf,+kvm-asyncpf-int,+kvm-hint-dedicated,+kvm-mmu,+kvm-nopiodelay,+kvm-poll-control,+kvm-pv-eoi,+kvm-pv-ipi,+kvm-pv-sched-yield,+kvm-pv-tlb-flush,+kvm-pv-unhalt,+kvm-steal-time,+kvmclock,+kvmclock,+kvmclock-stable-bit,+la57,+lahf-lm,+lbrv,+lm,+lwp,+mca,+mce,+md-clear,+mds-no,+misalignsse,+mmx,+mmxext,+monitor,+movbe,+movdir64b,+movdiri,+mpx,+msr,+mtrr,+nodeid-msr,+npt,+nrip-save,+nx,+osvw,+pae,+pat,+pause-filter,+pbe,+pcid,+pclmulqdq,+pcommit,+pdcm,+pdpe1gb,+perfctr-core,+perfctr-nb,+pfthreshold,+pge,+phe,+phe-en,+pku,+pmm,+pmm-en,+pn,+pni,+popcnt,+pschange-mc-no,+pse,+pse36,+rdctl-no,+rdpid,+rdrand,+rdseed,+rdtscp,+rsba,+rtm,+sep,+serialize,+sha-ni,+skinit,+skip-l1dfl-vmentry,+smap,+smep,+smx,+spec-ctrl,+split-lock-detect,+ss,+ssb-no,+ssbd,+sse,+sse2,+sse4.1,+sse4.2,+sse4a,+ssse3,+stibp,+svm,+svm-lock,+syscall,+taa-no,+tbm,+tce,+tm,+tm2,+topoext,+tsc,+tsc-adjust,+tsc-deadline,+tsc-scale,+tsx-ctrl,+tsx-ldtrk,+umip,+vaes,+virt-ssbd,+vmcb-clean,+vme,+vmx,+vmx-activity-hlt,+vmx-activity-shutdown,+vmx-activity-wait-sipi,+vmx-apicv-register,+vmx-apicv-vid,+vmx-apicv-x2apic,+vmx-apicv-xapic,+vmx-cr3-load-noexit,+vmx-cr3-store-noexit,+vmx-cr8-load-exit,+vmx-cr8-store-exit,+vmx-desc-exit,+vmx-encls-exit,+vmx-entry-ia32e-mode,+vmx-entry-load-bndcfgs,+vmx-entry-load-efer,+vmx-entry-load-pat,+vmx-entry-load-perf-global-ctrl,+vmx-entry-load-rtit-ctl,+vmx-entry-noload-debugctl,+vmx-ept,+vmx-ept-1gb,+vmx-ept-2mb,+vmx-ept-advanced-exitinfo,+vmx-ept-execonly,+vmx-eptad,+vmx-eptp-switching,+vmx-exit-ack-intr,+vmx-exit-clear-bndcfgs,+vmx-exit-clear-rtit-ctl,+vmx-exit-load-efer,+vmx-exit-load-pat,+vmx-exit-load-perf-global-ctrl,+vmx-exit-nosave-debugctl,+vmx-exit-save-efer,+vmx-exit-save-pat,+vmx-exit-save-preemption-timer,+vmx-flexpriority,+vmx-hlt-exit,+vmx-ins-outs,+vmx-intr-exit,+vmx-invept,+vmx-invept-all-context,+vmx-invept-single-context,+vmx-invept-single-context,+vmx-invept-single-context-noglobals,+vmx-invlpg-exit,+vmx-invpcid-exit,+vmx-invvpid,+vmx-invvpid-all-context,+vmx-invvpid-single-addr,+vmx-io-bitmap,+vmx-io-exit,+vmx-monitor-exit,+vmx-movdr-exit,+vmx-msr-bitmap,+vmx-mtf,+vmx-mwait-exit,+vmx-nmi-exit,+vmx-page-walk-4,+vmx-page-walk-5,+vmx-pause-exit,+vmx-ple,+vmx-pml,+vmx-posted-intr,+vmx-preemption-timer,+vmx-rdpmc-exit,+vmx-rdrand-exit,+vmx-rdseed-exit,+vmx-rdtsc-exit,+vmx-rdtscp-exit,+vmx-secondary-ctls,+vmx-shadow-vmcs,+vmx-store-lma,+vmx-true-ctls,+vmx-tsc-offset,+vmx-unrestricted-guest,+vmx-vintr-pending,+vmx-vmfunc,+vmx-vmwrite-vmexit-fields,+vmx-vnmi,+vmx-vnmi-pending,+vmx-vpid,+vmx-wbinvd-exit,+vmx-xsaves,+vmx-zero-len-inject,+vpclmulqdq,+waitpkg,+wbnoinvd,+wdt,+x2apic,+xcrypt,+xcrypt-en,+xgetbv1,+xop,+xsave,+xsavec,+xsaveerptr,+xsaveopt,+xsaves,+xstore,+xstore-en,+xtpr -daemonize -display none >/dev/null 2>.utqemu_log ;;
esac
case $(qemu-system-i386 --version | grep version | awk -F "." '{print $1}' | awk '{print $4}') in
	4|5|6)
cat >all_flags<<-eof
3dnow
3dnowext
3dnowprefetch
abm
ace2
ace2-en
acpi
adx
aes
amd-no-ssb
amd-ssbd
amd-stibp
apic
arat
arch-capabilities
avx
avx2
avx512-4fmaps
avx512-4vnniw
avx512-bf16
avx512-vp2intersect
avx512-vpopcntdq
avx512bitalg
avx512bw
avx512cd
avx512dq
avx512er
avx512f
avx512ifma
avx512pf
avx512vbmi
avx512vbmi2
avx512vl
avx512vnni
bmi1
bmi2
cid
cldemote
clflush
clflushopt
clwb
clzero
cmov
cmp-legacy
core-capability
cr8legacy
cx16
cx8
dca
de
decodeassists
ds
ds-cpl
dtes64
erms
est
extapic
f16c
flushbyasid
fma
fma4
fpu
fsgsbase
fsrm
full-width-write
fxsr
fxsr-opt
gfni
hle
ht
hypervisor
ia64
ibpb
ibrs-all
ibs
intel-pt
invpcid
invtsc
kvm-asyncpf
kvm-asyncpf-int
kvm-hint-dedicated
kvm-mmu
kvm-nopiodelay
kvm-poll-control
kvm-pv-eoi
kvm-pv-ipi
kvm-pv-sched-yield
kvm-pv-tlb-flush
kvm-pv-unhalt
kvm-steal-time
kvmclock
kvmclock
kvmclock-stable-bit
la57
lahf-lm
lbrv
lm
lwp
mca
mce
md-clear
mds-no
misalignsse
mmx
mmxext
monitor
movbe
movdir64b
movdiri
mpx
msr
mtrr
nodeid-msr
npt
nrip-save
nx
osvw
pae
pat
pause-filter
pbe
pcid
pclmulqdq
pcommit
pdcm
pdpe1gb
perfctr-core
perfctr-nb
pfthreshold
pge
phe
phe-en
pku
pmm
pmm-en
pn
pni
popcnt
pschange-mc-no
pse
pse36
rdctl-no
rdpid
rdrand
rdseed
rdtscp
rsba
rtm
sep
serialize
sha-ni
skinit
skip-l1dfl-vmentry
smap
smep
smx
spec-ctrl
split-lock-detect
ss
ssb-no
ssbd
sse
sse2
sse4.1
sse4.2
sse4a
ssse3
stibp
svm
svm-lock
syscall
taa-no
tbm
tce
tm
tm2
topoext
tsc
tsc-adjust
tsc-deadline
tsc-scale
tsx-ctrl
tsx-ldtrk
umip
vaes
virt-ssbd
vmcb-clean
vme
vmx
vmx-activity-hlt
vmx-activity-shutdown
vmx-activity-wait-sipi
vmx-apicv-register
vmx-apicv-vid
vmx-apicv-x2apic
vmx-apicv-xapic
vmx-cr3-load-noexit
vmx-cr3-store-noexit
vmx-cr8-load-exit
vmx-cr8-store-exit
vmx-desc-exit
vmx-encls-exit
vmx-entry-ia32e-mode
vmx-entry-load-bndcfgs
vmx-entry-load-efer
vmx-entry-load-pat
vmx-entry-load-perf-global-ctrl
vmx-entry-load-rtit-ctl
vmx-entry-noload-debugctl
vmx-ept
vmx-ept-1gb
vmx-ept-2mb
vmx-ept-advanced-exitinfo
vmx-ept-execonly
vmx-eptad
vmx-eptp-switching
vmx-exit-ack-intr
vmx-exit-clear-bndcfgs
vmx-exit-clear-rtit-ctl
vmx-exit-load-efer
vmx-exit-load-pat
vmx-exit-load-perf-global-ctrl
vmx-exit-nosave-debugctl
vmx-exit-save-efer
vmx-exit-save-pat
vmx-exit-save-preemption-timer
vmx-flexpriority
vmx-hlt-exit
vmx-ins-outs
vmx-intr-exit
vmx-invept
vmx-invept-all-context
vmx-invept-single-context
vmx-invept-single-context
vmx-invept-single-context-noglobals
vmx-invlpg-exit
vmx-invpcid-exit
vmx-invvpid
vmx-invvpid-all-context
vmx-invvpid-single-addr
vmx-io-bitmap
vmx-io-exit
vmx-monitor-exit
vmx-movdr-exit
vmx-msr-bitmap
vmx-mtf
vmx-mwait-exit
vmx-nmi-exit
vmx-page-walk-4
vmx-page-walk-5
vmx-pause-exit
vmx-ple
vmx-pml
vmx-posted-intr
vmx-preemption-timer
vmx-rdpmc-exit
vmx-rdrand-exit
vmx-rdseed-exit
vmx-rdtsc-exit
vmx-rdtscp-exit
vmx-secondary-ctls
vmx-shadow-vmcs
vmx-store-lma
vmx-true-ctls
vmx-tsc-offset
vmx-unrestricted-guest
vmx-vintr-pending
vmx-vmfunc
vmx-vmwrite-vmexit-fields
vmx-vnmi
vmx-vnmi-pending
vmx-vpid
vmx-wbinvd-exit
vmx-xsaves
vmx-zero-len-inject
vpclmulqdq
waitpkg
wbnoinvd
wdt
x2apic
xcrypt
xcrypt-en
xgetbv1
xop
xsave
xsavec
xsaveerptr
xsaveopt
xsaves
xstore
xstore-en
xtpr
eof
;;
2|3)
cat >all_flags<<-eof
3dnow
3dnowext
3dnowprefetch
abm
ace2
ace2-en
acpi
adx
aes
amd-no-ssb
amd-ssbd
apic
arat
arch-capabilities
avx
avx2
avx512-4fmaps
avx512-4vnniw
avx512-vpopcntdq
avx512bitalg
avx512bw
avx512cd
avx512dq
avx512er
avx512f
avx512ifma
avx512pf
avx512vbmi
avx512vbmi2
avx512vl
avx512vnni
bmi1
bmi2
cid
cldemote
clflush
clflushopt
clwb
cmov
cmp-legacy
cr8legacy
cx16
cx8
dca
de
decodeassists
ds
ds-cpl
dtes64
erms
est
extapic
f16c
flushbyasid
fma
fma4
fpu
fsgsbase
fxsr
fxsr-opt
gfni
hle
ht
hypervisor
ia64
ibpb
ibrs-all
ibs
intel-pt
invpcid
invtsc
kvm-asyncpf
kvm-hint-dedicated
kvm-mmu
kvm-nopiodelay
kvm-pv-eoi
kvm-pv-ipi
kvm-pv-tlb-flush
kvm-pv-unhalt
kvm-steal-time
kvmclock
kvmclock
kvmclock-stable-bit
la57
lahf-lm
lbrv
lm
lwp
mca
mce
md-clear
mds-no
misalignsse
mmx
mmxext
monitor
movbe
mpx
msr
mtrr
nodeid-msr
npt
nrip-save
nx
osvw
pae
pat
pause-filter
pbe
pcid
pclmulqdq
pcommit
pconfig
pdcm
pdpe1gb
perfctr-core
perfctr-nb
pfthreshold
pge
phe
phe-en
pku
pmm
pmm-en
pn
pni
popcnt
pschange-mc-no
pse
pse36
rdctl-no
rdpid
rdrand
rdseed
rdtscp
rsba
rtm
sep
sha-ni
skinit
skip-l1dfl-vmentry
smap
smep
smx
spec-ctrl
ss
ssb-no
ssbd
sse
sse2
sse4.1
sse4.2
sse4a
ssse3
svm
svm-lock
syscall
tbm
tce
tm
tm2
topoext
tsc
tsc-adjust
tsc-deadline
tsc-scale
umip
vaes
virt-ssbd
vmcb-clean
vme
vmx
vpclmulqdq
wbnoinvd
wdt
x2apic
xcrypt
xcrypt-en
xgetbv1
xop
xsave
xsavec
xsaveopt
xsaves
xstore
xstore-en
xtpr
eof
;;
esac
cat .utqemu_log | grep does | awk -F '.' '{print $NF}' | awk '{print $1}' >> all_flags
echo -e "\e[33m你的设备参数\e[0m"
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null
if [ $? == 0 ]; then
printf "%-15s %s %s\n" cpu核数: $(cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1 | awk '{print $1}') 核
printf "%-15s %s %s\n" cpu低频: $(cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | head -n 1 | awk '{printf ("%.2f", $2 / 1048576"G")}') G
printf "%-15s %s %s\n" cpu高频: $(cat -n /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | tail -n 1 | awk '{printf "%.2f", $2 / 1048576}') G
printf "%-17s %s %s\n" 运行内存: $(free -m | awk '{print $2}' | sed -n 2p | cut -d '.' -f 1) M
fi
echo -e "\e[33mcpu支持以下特性\e[0m"
echo $(sort all_flags | uniq -u) | sed 'N;s/\n/ /g'
echo -e "\e[33m由于qemu每个版本支持的特性不同，qemu1-3用的是版本3的特性参数，qemu4-6用的是版本5的特性参数\n本测试仅供参考\e[0m\n"
fi
pkill qemu-system-i38 2>/dev/null
killall qemu-system-i38 2>/dev/null
