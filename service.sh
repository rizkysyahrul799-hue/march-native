#!/system/bin/sh

MODDIR="/data/adb/modules/march"
CONF_DIR="$MODDIR/config"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 3
done

sleep 5

if [ -f "$CONF_DIR/apply_on_boot.conf" ] && [ "$(cat "$CONF_DIR/apply_on_boot.conf")" = "on" ]; then

    if [ -f "$CONF_DIR/flow_state.conf" ] && [ "$(cat "$CONF_DIR/flow_state.conf")" = "on" ]; then
        for group in /dev/cpuctl/*; do
            [ -d "$group" ] || continue
            [ -f "$group/cpu.uclamp.min" ] && echo 20.00 > "$group/cpu.uclamp.min" 2>/dev/null
        done
        setprop sys.perf.profile 1 2>/dev/null
    fi

    if [ -f "$CONF_DIR/smart_sleep.conf" ] && [ "$(cat "$CONF_DIR/smart_sleep.conf")" = "on" ]; then
        if [ -x /system/bin/sh ]; then /system/bin/sh -c "dumpsys deviceidle force-idle"; else dumpsys deviceidle force-idle; fi
    fi

    if [ -f "$CONF_DIR/thermal_sync.conf" ] && [ "$(cat "$CONF_DIR/thermal_sync.conf")" = "on" ]; then
        if [ -x /system/bin/sh ]; then
            /system/bin/sh -c "setprop persist.sys.thermal.config cool"
            /system/bin/sh -c "setprop sys.thermal.mode 1"
        else
            setprop persist.sys.thermal.config "cool"
            setprop sys.thermal.mode 1
        fi
    fi

    if [ -f "$CONF_DIR/cpu_limit.conf" ]; then
        VALUE=$(cat "$CONF_DIR/cpu_limit.conf")
        
        if [ -n "$VALUE" ] && [ "$VALUE" -ge 40 ] && [ "$VALUE" -le 100 ]; then
            for CPU_DIR in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
                [ -f "$CPU_DIR/cpuinfo_max_freq" ] || continue
                
                MAX_FREQ=$(cat "$CPU_DIR/cpuinfo_max_freq")
                TARGET=$(( (MAX_FREQ * VALUE) / 100 ))
                
                if [ -f "$CONF_DIR/boot_boost.conf" ] && [ "$(cat "$CONF_DIR/boot_boost.conf")" = "on" ]; then
                    for CPU_DIR in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
                        if [ -f "$CPU_DIR/cpuinfo_max_freq" ]; then
                            MAX=$(cat "$CPU_DIR/cpuinfo_max_freq")
                            chmod 664 "$CPU_DIR/scaling_max_freq" 2>/dev/null
                            echo "$MAX" > "$CPU_DIR/scaling_max_freq" 2>/dev/null
                        fi
                    done
                    sleep 60
                fi
                
                if [ -f "$CPU_DIR/scaling_available_frequencies" ]; then
                    CLOSEST=""
                    CLOSEST_DIFF=999999999
                    for F in $(cat "$CPU_DIR/scaling_available_frequencies"); do
                        DIFF=$(( TARGET - F ))
                        [ $DIFF -lt 0 ] && DIFF=$(( -DIFF ))
                        if [ $DIFF -lt $CLOSEST_DIFF ]; then
                            CLOSEST_DIFF=$DIFF
                            CLOSEST=$F
                        fi
                    done
                    [ -n "$CLOSEST" ] && TARGET=$CLOSEST
                fi
                
                if [ -f "$CPU_DIR/scaling_max_freq" ]; then
                    chmod 664 "$CPU_DIR/scaling_max_freq"
                    echo "$TARGET" > "$CPU_DIR/scaling_max_freq"
                    chmod 444 "$CPU_DIR/scaling_max_freq"
                fi
            done
        fi
    fi

fi
