#!/usr/bin/env bash
# @file bin/dot.d/help.sh — Help page

cmd_help() {
    _banner
    printf '\n'

    printf '  %b%bUSAGE%b\n' "$S_BOLD" "$C_TEXT" "$S_RESET"
    printf '    %bdot%b %b<command>%b %b[options]%b\n\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET" "$C_OVERLAY" "$S_RESET"

    printf '  %b%b%b  INFORMATION%b\n' "$S_BOLD" "$C_TEXT" "$I_INFO" "$S_RESET"
    printf '    %binfo%b              %bSystem overview%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bstatus%b            %bQuick dashboard%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bdoctor%b            %bHealth check%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bshells%b            %bShell status%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %btools%b             %bTool report%b\n\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b%s THEMES%b\n' "$S_BOLD" "$C_TEXT" "$I_PALETTE" "$S_RESET"
    printf '    %btheme%b             %bInteractive switcher%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %btheme%b %b<name>%b      %bpowerline | minimal | nerd%b\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %btheme list%b        %bList themes%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %btheme preview%b     %bPreview all%b\n\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b%b  CONFIGURATION%b\n' "$S_BOLD" "$C_TEXT" "$I_SETTINGS" "$S_RESET"
    printf '    %bgenerate%b %b[t]%b      %ball|aliases|colors|icons|highlights%b\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %blink%b / %bunlink%b     %bManage symlinks%b\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bedit%b %b[file]%b       %bOpen in editor%b\n\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b%b  SECURITY%b\n' "$S_BOLD" "$C_TEXT" "$I_SHIELD" "$S_RESET"
    printf '    %bssh%b %b<cmd>%b         %binfo|keys|edit|add|test|generate|copy|fix%b\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bsecret%b %b<cmd>%b      %blist|add|edit|fix%b\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bgit-sign%b %b<cmd>%b    %binfo|ssh|off|verify|trust%b\n\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b  ❄️  NIX%b\n' "$S_BOLD" "$C_TEXT" "$S_RESET"
    printf '    %bnix%b %b<cmd>%b         Nix management (info|dev|install|update|search|clean)\n\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET"

    printf '  %b%b%b  MAINTENANCE%b\n' "$S_BOLD" "$C_TEXT" "$I_ROCKET" "$S_RESET"
    printf '    %bupdate%b / %bupgrade%b  %bPull + regen / full upgrade%b\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bclean%b             %bRemove cache & compiled%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bbackup%b / %brestore%b  %bSnapshot management%b\n\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b%b  PERFORMANCE%b\n' "$S_BOLD" "$C_TEXT" "$I_LIGHTNING" "$S_RESET"
    printf '    %bbenchmark%b %b[n]%b     %bStartup timing%b\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bprofile%b           %bZSH zprof%b\n\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b%b  EXPLORATION%b\n' "$S_BOLD" "$C_TEXT" "$I_SEARCH" "$S_RESET"
    printf '    %balias%b %b[q]%b         %bBrowse aliases%b\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bpath%b              %bPATH audit%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bcolor%b             %bPalette test%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %bdiff%b              %bUncommitted changes%b\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"
    printf '    %blog%b               %bStartup logs%b\n\n' "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$S_RESET"

    printf '  %b%b%b  SHORTCUTS%b\n' "$S_BOLD" "$C_TEXT" "$I_ARROW" "$S_RESET"
    printf '    %bcd%b / %bversion%b / %bhelp%b\n\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
    printf '  %b%b%b  TERMINAL & EDITOR%b\n' "$S_BOLD" "$C_TEXT" "$I_TERMINAL" "$S_RESET"
    printf '    %bterminal%b %b[cmd]%b     Terminal management (info|update|edit|reinstall|list)\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET"
    printf '    %beditor%b %b[cmd]%b       Editor management (info|update|edit|health|reinstall|list)\n\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET"
}
