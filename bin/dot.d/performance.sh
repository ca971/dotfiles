#!/usr/bin/env bash
cmd_benchmark() {
    local n="${1:-10}"
    _banner
    _section "${I_LIGHTNING}  Benchmark (${n}x)"
    for sh in zsh bash fish; do
        case "$sh" in zsh) ic="" ;; bash) ic="" ;; fish) ic="󰈺" ;; esac
        _has "$sh" || continue
        printf '  %b%s %-8s%b ' "$C_TEXT" "$ic" "$sh" "$S_RESET"
        local total=0 i s e
        for i in $(seq 1 "$n"); do
            s=$(date +%s%N 2> /dev/null || python3 -c 'import time;print(int(time.time()*1e9))')
            ZSH_NO_FASTFETCH=1 BASH_NO_FASTFETCH=1 "$sh" -ic exit 2> /dev/null
            e=$(date +%s%N 2> /dev/null || python3 -c 'import time;print(int(time.time()*1e9))')
            total=$((total + (e - s) / 1000000))
        done
        local avg=$((total / n))
        [ "$avg" -lt 150 ] && printf '%b%dms%b %b(%b)%b\n' "$C_SUCCESS" "$avg" "$S_RESET" "$C_OVERLAY" "$I_LIGHTNING" "$S_RESET" \
            || [ "$avg" -lt 500 ] && printf '%b%dms%b %b(%b)%b\n' "$C_YELLOW" "$avg" "$S_RESET" "$C_OVERLAY" "$I_WARNING" "$S_RESET" \
            || printf '%b%dms%b %b(%b)%b\n' "$C_RED" "$avg" "$S_RESET" "$C_OVERLAY" "$I_ERROR" "$S_RESET"
    done
    printf '\n'
}
cmd_profile() {
    _banner
    _section "${I_LIGHTNING}  Profile"
    ZSH_PROFILE=1 ZSH_NO_FASTFETCH=1 zsh -ic exit 2>&1 | head -25
    printf '\n'
}
