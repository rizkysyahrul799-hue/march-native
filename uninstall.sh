MODDIR="/data/adb/modules/march"
CONF_DIR="$MODDIR/config"

for group in /dev/cpuctl/*; do
    [ -d "$group" ] || continue
    [ -f "$group/cpu.uclamp.min" ] && echo 0.00 > "$group/cpu.uclamp.min" 2>/dev/null
done

setprop sys.perf.profile 0 2>/dev/null
setprop persist.sys.thermal.config "normal" 2>/dev/null
setprop sys.thermal.mode 0 2>/dev/null

for CPU_DIR in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
    if [ -f "$CPU_DIR/cpuinfo_max_freq" ]; then
        MAX=$(cat "$CPU_DIR/cpuinfo_max_freq")
        chmod 664 "$CPU_DIR/scaling_max_freq" 2>/dev/null
        echo "$MAX" > "$CPU_DIR/scaling_max_freq" 2>/dev/null
    fi
done

rm -rf "$CONF_DIR"
rm -rf "/data/adb/modules/march"
