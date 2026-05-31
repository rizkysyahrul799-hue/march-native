MODDIR="/data/adb/modules/march"
CONF_DIR="$MODDIR/config"
mkdir -p "$CONF_DIR"

ACTION="$1"
VALUE="$2"


run_cmd() {
    if [ -x /system/bin/sh ]; then
        /system/bin/sh -c "$1" 2>/dev/null
    else
        $1 2>/dev/null
    fi
}

case "$ACTION" in

  
  get_name)
    NAME=$(getprop ro.product.marketname 2>/dev/null | tr -d '\r' | xargs)
    [ -z "$NAME" ] && NAME=$(getprop ro.product.model 2>/dev/null | tr -d '\r' | xargs)
    [ -z "$NAME" ] && echo "Android Device" || echo "$NAME"
    exit 0
    ;;

  get_model)
    MODEL=$(getprop ro.product.model 2>/dev/null | tr -d '\r' | xargs)
    [ -z "$MODEL" ] && echo "Unknown Model" || echo "$MODEL"
    exit 0
    ;;

  get_android)
    ANDROID=$(getprop ro.build.version.release 2>/dev/null | tr -d '\r' | xargs)
    [ -z "$ANDROID" ] && echo "Unknown" || echo "$ANDROID"
    exit 0
    ;;

  get_kernel)
    KERNEL=$(uname -r 2>/dev/null | tr -d '\r' | xargs)
    [ -z "$KERNEL" ] && echo "Unknown Kernel" || echo "$KERNEL"
    exit 0
    ;;
  

   flow_state)
    echo "$VALUE" > "$CONF_DIR/flow_state.conf"
    if [ "$VALUE" = "on" ]; then
        
        for group in /dev/cpuctl/*; do
            [ -d "$group" ] || continue
            [ -f "$group/cpu.uclamp.min" ] && echo 20.00 > "$group/cpu.uclamp.min" 2>/dev/null
        done
        
        setprop sys.perf.profile 1 2>/dev/null
    else
        
        for group in /dev/cpuctl/*; do
            [ -d "$group" ] || continue
            [ -f "$group/cpu.uclamp.min" ] && echo 0.00 > "$group/cpu.uclamp.min" 2>/dev/null
        done
        setprop sys.perf.profile 0 2>/dev/null
    fi
    echo "ok"
    ;;


  smart_sleep)
    echo "$VALUE" > "$CONF_DIR/smart_sleep.conf"
    if [ "$VALUE" = "on" ]; then
        run_cmd "dumpsys deviceidle force-idle"
    else
        run_cmd "dumpsys deviceidle unforce"
    fi
    echo "ok"
    ;;

  thermal_sync)
    echo "$VALUE" > "$CONF_DIR/thermal_sync.conf"
    if [ "$VALUE" = "on" ]; then
        run_cmd "setprop persist.sys.thermal.config cool"
        run_cmd "setprop sys.thermal.mode 1"
    else
        run_cmd "setprop persist.sys.thermal.config normal"
        run_cmd "setprop sys.thermal.mode 0"
    fi
    echo "ok"
    ;;


  limit_cpu)
    echo "$VALUE" > "$CONF_DIR/cpu_limit.conf"
    

    if [ -z "$VALUE" ] || [ "$VALUE" -lt 40 ] || [ "$VALUE" -gt 100 ]; then
        VALUE=100
    fi

    for CPU_DIR in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
        [ -f "$CPU_DIR/cpuinfo_max_freq" ] || continue
        
        MAX_FREQ=$(cat "$CPU_DIR/cpuinfo_max_freq")
        
        
        TARGET=$(( (MAX_FREQ * VALUE) / 100 ))
        
        
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
    echo "ok"
    ;;


  check_state)
    if [ -f "$CONF_DIR/$VALUE.conf" ]; then
        cat "$CONF_DIR/$VALUE.conf"
    else
        
        [ "$VALUE" = "cpu_limit" ] && echo "100" || echo "off"
    fi
    ;;

  apply_on_boot)
    echo "$VALUE" > "$CONF_DIR/apply_on_boot.conf"
    echo "ok"
    ;;

  
  reset)
    rm -f "$CONF_DIR"/*.conf
    run_cmd "setprop persist.sys.thermal.config normal"
    run_cmd "dumpsys deviceidle unforce"
    
  
    for CPU_DIR in /sys/devices/system/cpu/cpu[0-9]*/cpufreq; do
        [ -f "$CPU_DIR/cpuinfo_max_freq" ] || continue
        MAX=$(cat "$CPU_DIR/cpuinfo_max_freq")
        chmod 664 "$CPU_DIR/scaling_max_freq"
        echo "$MAX" > "$CPU_DIR/scaling_max_freq"
    done
    echo "ok"
    ;;

  *) echo "unknown_action" ;;
esac
