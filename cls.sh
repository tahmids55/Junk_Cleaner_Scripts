#!/bin/bash

# ------------------ ROOT CHECK ------------------
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# ------------------ UTILS ------------------
get_size() {
    du -sb "$@" 2>/dev/null | awk '{s+=$1} END {print s+0}'
}

format_size() {
    local b=$1
    if (( b < 1024 )); then
        echo "${b}B"
    elif (( b < 1048576 )); then
        echo "$(bc <<< "scale=2; $b/1024") KB"
    elif (( b < 1073741824 )); then
        echo "$(bc <<< "scale=2; $b/1048576") MB"
    else
        echo "$(bc <<< "scale=2; $b/1073741824") GB"
    fi
}

declare -A results

clean_task() {
    local label="$1"
    shift
    local paths=("$@")

    local before after saved

    before=$(get_size "${paths[@]}")

    "${CLEAN_CMD[@]}" >/dev/null 2>&1

    after=$(get_size "${paths[@]}")

    saved=$(( before - after ))
    (( saved < 0 )) && saved=0
    results["$label"]=$saved
}

echo "----- System Cleanup Started -----"

# ------------------ 1. APT ------------------
CLEAN_CMD=(apt-get autoremove -y && apt-get autoclean -y && apt-get clean)
clean_task "APT Cache" /var/cache/apt/archives

# ------------------ 2. JOURNAL LOGS ------------------
CLEAN_CMD=(journalctl --vacuum-time=2d)
clean_task "System Logs" /var/log/journal

# ------------------ 3. THUMBNAILS ------------------
CLEAN_CMD=(bash -c 'rm -rf /home/*/.cache/thumbnails/*')
clean_task "Thumbnail Cache" /home/*/.cache/thumbnails

# ------------------ 4. TRASH ------------------
CLEAN_CMD=(bash -c 'rm -rf /home/*/.local/share/Trash/* /root/.local/share/Trash/*')
clean_task "Trash Bins" /home/*/.local/share/Trash /root/.local/share/Trash

# ------------------ 5. TEMP FILES ------------------
CLEAN_CMD=(find /tmp -type f -atime +1 -delete)
clean_task "Temporary Files" /tmp

# ------------------ 6. BROWSER CACHE (INCLUDES BRAVE) ------------------
CLEAN_CMD=(bash -c '
for d in /home/*/.cache/{google-chrome,chromium,mozilla,firefox,microsoft-edge,brave-browser}; do
    [ -d "$d" ] && rm -rf "$d"/*
done
')
clean_task "Browser Cache" \
    /home/*/.cache/google-chrome \
    /home/*/.cache/chromium \
    /home/*/.cache/mozilla \
    /home/*/.cache/firefox \
    /home/*/.cache/microsoft-edge \
    /home/*/.cache/brave-browser

# ------------------ 7. VS CODE CACHE & LOGS ------------------
CLEAN_CMD=(bash -c '
for d in /home/*/.config/Code/logs \
         /home/*/.config/Code/Crashpad \
         /home/*/.config/Code/GPUCache \
         /home/*/.config/Code/User/workspaceStorage \
         /home/*/.cache/Code; do
    [ -d "$d" ] && rm -rf "$d"/*
done
')
clean_task "VS Code Cache & Logs" \
    /home/*/.config/Code/logs \
    /home/*/.config/Code/Crashpad \
    /home/*/.config/Code/GPUCache \
    /home/*/.config/Code/User/workspaceStorage \
    /home/*/.cache/Code

# ------------------ SUMMARY ------------------
echo
echo "----------- Cleanup Summary -----------"
printf "%-25s %15s\n" "Category" "Recovered"
echo "---------------------------------------"

total=0
for k in "${!results[@]}"; do
    printf "%-25s %15s\n" "$k" "$(format_size "${results[$k]}")"
    total=$(( total + results[$k] ))
done

echo "---------------------------------------"
printf "%-25s %15s\n" "TOTAL" "$(format_size "$total")"
echo "---------------------------------------"

