if [ -z "$MODPATH" ]; then
    ui_print "! Modul harus di-flash lewat Manager (KernelSU/APatch/Magisk)!"
    exit 1
fi


ui_print "**************************************"
ui_print "*        MARCH - NATIVE EDITION      *"
ui_print "*        Optimized for Dimensity     *"
ui_print "**************************************"
ui_print "- Android Version : $(getprop ro.build.version.release)"
ui_print "- Device Model    : $(getprop ro.product.model)"


ui_print "- Mengekstrak file modul ke sistem..."

mkdir -p "$MODPATH/config"


ui_print "- Menyunting hak akses backend..."


if [ -f "$MODPATH/action.sh" ]; then
    chmod 755 "$MODPATH/action.sh"
    ui_print "  • action.sh -> Chmod 755 OK"
else
    ui_print "  ! Kritis: action.sh tidak ditemukan!"
    exit 1
fi

if [ -f "$MODPATH/service.sh" ]; then
    chmod 755 "$MODPATH/service.sh"
    ui_print "  • service.sh -> Chmod 755 OK"
else
    ui_print "  ! Kritis: service.sh tidak ditemukan!"
    exit 1
fi


ui_print "- Menyelesaikan instalasi..."

echo "100" > "$MODPATH/config/cpu_limit.conf"
echo "off" > "$MODPATH/config/flow_state.conf"
echo "off" > "$MODPATH/config/smart_sleep.conf"
echo "off" > "$MODPATH/config/thermal_sync.conf"
echo "off" > "$MODPATH/config/apply_on_boot.conf"

ui_print "**************************************"
ui_print "*   Instalasi Selesai! Sukses Gaes   *"
ui_print "*   Silakan Reboot Perangkat Anda!   *"
ui_print "**************************************"
