#!/usr/bin/env bash

# Try common AC adapter names (AC, ACAD, AC0)
for path_ac in /sys/class/power_supply/AC /sys/class/power_supply/ACAD /sys/class/power_supply/AC0; do
    if [ -f "$path_ac/online" ]; then
        ac=$(cat "$path_ac/online")
        break
    fi
done

ac=${ac:-0}
battery_level_1=0
battery_max_1=0

# Try charge_now/charge_full first (mAh), then energy_now/energy_full (mWh)
if [ -f "/sys/class/power_supply/BAT1/charge_now" ]; then
    battery_level_1=$(cat "/sys/class/power_supply/BAT1/charge_now")
    battery_max_1=$(cat "/sys/class/power_supply/BAT1/charge_full")
elif [ -f "/sys/class/power_supply/BAT1/energy_now" ]; then
    battery_level_1=$(cat "/sys/class/power_supply/BAT1/energy_now")
    battery_max_1=$(cat "/sys/class/power_supply/BAT1/energy_full")
fi

# Fallback: try BAT0 if BAT1 not found
if [ "$battery_max_1" -eq 0 ] && [ -f "/sys/class/power_supply/BAT0/charge_now" ]; then
    battery_level_1=$(cat "/sys/class/power_supply/BAT0/charge_now")
    battery_max_1=$(cat "/sys/class/power_supply/BAT0/charge_full")
elif [ "$battery_max_1" -eq 0 ] && [ -f "/sys/class/power_supply/BAT0/energy_now" ]; then
    battery_level_1=$(cat "/sys/class/power_supply/BAT0/energy_now")
    battery_max_1=$(cat "/sys/class/power_supply/BAT0/energy_full")
fi

if [ "$battery_max_1" -eq 0 ]; then
    battery_percent=0
else
    battery_percent=$(("$battery_level_1 * 100"))
    battery_percent=$(("$battery_percent / $battery_max_1"))
fi

# Font Awesome battery icons (use font-1)
if [ "$ac" -eq 1 ]; then
    icon=$(printf '\uf0e7')  # bolt (charging)

    if [ "$battery_percent" -gt 97 ]; then
        echo "%{T1}$icon%{T-}"
    else
        printf "%%{T1}%s%%{T-} %02d%%\n" "$icon" "$battery_percent"
    fi
else
    if [ "$battery_percent" -gt 85 ]; then
        icon=$(printf '\uf240')
    elif [ "$battery_percent" -gt 60 ]; then
        icon=$(printf '\uf241')
    elif [ "$battery_percent" -gt 35 ]; then
        icon=$(printf '\uf242')
    elif [ "$battery_percent" -gt 10 ]; then
        icon=$(printf '\uf243')
    else
        icon=$(printf '\uf244')
    fi

    printf "%%{T1}%s%%{T-} %02d%%\n" "$icon" "$battery_percent"
fi
