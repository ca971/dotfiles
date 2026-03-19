#!/usr/bin/env zsh
# ============================================================================
# @file        .zlogin
# @description Post-login hook. Sourced at the END of login shell
#              initialization (after .zshrc). Used for commands that should
#              run after the entire shell setup is complete.
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @note        This file runs AFTER .zshrc for login shells only.
#              Ideal for: background compilation, update checks, motd.
# ============================================================================

# ============================================================================
# Compile ZSH files in background — Speed up subsequent startups
# ============================================================================

# @description Asynchronously compile (zcompile) ZSH configuration files
#              to improve startup time for future shell sessions.
{
  # -- Compile ZDOTDIR files
  local file
  for file in "${ZDOTDIR}"/**/*.zsh(N) "${ZDOTDIR}"/.z*(N); do
    if [[ -f "$file" ]] && [[ ! -f "${file}.zwc" ]] || \
       [[ "$file" -nt "${file}.zwc" ]]; then
      zcompile "$file" 2>/dev/null
    fi
  done

  # -- Compile completion dump
  local zcompdump="${ZDOTDIR}/cache/zcompdump-${ZSH_VERSION}"
  if [[ -f "$zcompdump" ]] && [[ ! -f "${zcompdump}.zwc" ]] || \
     [[ "$zcompdump" -nt "${zcompdump}.zwc" ]]; then
    zcompile "$zcompdump" 2>/dev/null
  fi
} &!  # Run in background, disown
