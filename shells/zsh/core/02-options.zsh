#!/usr/bin/env zsh
# ============================================================================
# @file        core/02-options.zsh
# @description ZSH shell options configuration. Defines the behavior of the
#              shell through setopt/unsetopt directives. Options are grouped
#              by category for maintainability and documented individually.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @see         https://zsh.sourceforge.io/Doc/Release/Options.html
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_OPTIONS_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_OPTIONS_LOADED=1

log_debug "Configuring ZSH options"

# ============================================================================
# Changing Directories
# ============================================================================

# @description Automatically cd into a directory by typing its name
setopt AUTO_CD

# @description Automatically push old directory onto the stack on cd
setopt AUTO_PUSHD

# @description Don't push duplicate directories onto the stack
setopt PUSHD_IGNORE_DUPS

# @description Make pushd silent (no directory listing after push)
setopt PUSHD_SILENT

# @description Allow pushd with no arguments to go to home
setopt PUSHD_TO_HOME

# @description Resolve symbolic links to their true path on cd
setopt CHASE_LINKS

# @description Maximum directory stack size
export DIRSTACKSIZE=20

# ============================================================================
# Completion
# ============================================================================

# @description Automatically list choices on ambiguous completion
setopt AUTO_LIST

# @description Automatically select the first completion match
setopt AUTO_MENU

# @description Move cursor to end of word on completion
setopt ALWAYS_TO_END

# @description Complete from both ends of a word
setopt COMPLETE_IN_WORD

# @description Do not beep on ambiguous completion
setopt NO_LIST_BEEP

# @description Show completion menu on successive tab presses
setopt AUTO_PARAM_SLASH

# @description If a parameter is completed with a trailing slash, remove it
#              if the next character typed is a word delimiter
setopt AUTO_REMOVE_SLASH

# @description When listing files that match a glob pattern, also show
#              the type of each file with a trailing mark
setopt LIST_TYPES

# @description Pack completion lists to use less screen space
setopt LIST_PACKED

# @description Don't show types in alternatives listing
unsetopt LIST_AMBIGUOUS

# ============================================================================
# Expansion and Globbing
# ============================================================================

# @description Treat '#', '~' and '^' as part of patterns for globbing
setopt EXTENDED_GLOB

# @description Allow glob patterns to match dotfiles without explicit dot
setopt GLOB_DOTS

# @description Enable brace expansion (e.g., {a,b,c})
setopt BRACE_CCL

# @description Sort numeric filenames numerically rather than lexicographically
setopt NUMERIC_GLOB_SORT

# @description Enable regex matching with =~ operator
setopt REMATCH_PCRE 2>/dev/null || true  # Requires PCRE support

# @description Allow unmatched glob patterns to pass through as literals
#              instead of causing an error — safer for scripts
setopt NO_NOMATCH

# @description Don't error on null glob results
setopt NULL_GLOB

# @description Case-insensitive globbing
setopt NO_CASE_GLOB

# ============================================================================
# History (options only; file paths in 03-history.zsh)
# ============================================================================

# @description Append history to file (don't overwrite)
setopt APPEND_HISTORY

# @description Write to history file immediately, not on shell exit
setopt INC_APPEND_HISTORY

# @description Share history between all active sessions
setopt SHARE_HISTORY

# @description Save timestamps and duration in history
setopt EXTENDED_HISTORY

# @description Don't store duplicate entries in history
setopt HIST_IGNORE_ALL_DUPS

# @description Remove older duplicate entries when adding new ones
setopt HIST_EXPIRE_DUPS_FIRST

# @description Don't record commands starting with a space
setopt HIST_IGNORE_SPACE

# @description Remove superfluous blanks from history entries
setopt HIST_REDUCE_BLANKS

# @description Don't display duplicates during search
setopt HIST_FIND_NO_DUPS

# @description Don't store the 'history' command itself
setopt HIST_NO_STORE

# @description Don't immediately execute history expansion result
setopt HIST_VERIFY

# @description Record function definitions in history
setopt HIST_NO_FUNCTIONS

# ============================================================================
# Input / Output
# ============================================================================

# @description Allow comments in interactive shell (# at beginning of word)
setopt INTERACTIVE_COMMENTS

# @description Do not overwrite existing files with > redirection
#              Use >| to force overwrite
setopt NO_CLOBBER

# @description Enable correction of commands
setopt CORRECT

# @description Do NOT enable correction of arguments (too aggressive)
unsetopt CORRECT_ALL

# @description Report status of background jobs immediately
setopt NOTIFY

# @description Don't print exit value for non-zero status
#              (Starship prompt handles this)
unsetopt PRINT_EXIT_VALUE

# @description Allow short forms of for, repeat, select, if, function
setopt SHORT_LOOPS

# @description Don't send HUP signal to background jobs on shell exit
setopt NO_HUP

# @description Don't report background job status on exit
setopt NO_CHECK_JOBS

# ============================================================================
# Job Control
# ============================================================================

# @description Enable background job control
setopt MONITOR

# @description Allow backgrounding of commands without disowning
setopt LONG_LIST_JOBS

# @description Resume background job if command matches a suspended job name
setopt AUTO_RESUME

# ============================================================================
# Prompt
# ============================================================================

# @description Enable parameter expansion, command substitution and
#              arithmetic expansion in prompts
setopt PROMPT_SUBST

# @description Remove right prompt from display when accepting a command line
#              (cleaner copy-paste from terminal)
setopt TRANSIENT_RPROMPT

# ============================================================================
# Scripts and Functions
# ============================================================================

# @description Allow function definitions in scripts and interactive use
setopt MULTI_FUNC_DEF

# @description Perform cd on directory names even in function scope
setopt AUTO_CD

# @description Pipe fails if any command in pipeline fails (not just last)
setopt PIPE_FAIL

# ============================================================================
# Zle (Z-Line Editor)
# ============================================================================

# @description Disable beep on error in line editor
setopt NO_BEEP

# @description Combine zero-length punctuation characters (combining chars)
setopt COMBINING_CHARS

# ============================================================================
# Disabled Options — Explicitly turned off for safety/preference
# ============================================================================

# @description Don't auto-use named directories
unsetopt AUTO_NAME_DIRS

# @description Don't change nice value for background jobs
unsetopt BG_NICE

# @description Don't use flow control (^S/^Q)
unsetopt FLOW_CONTROL

log_debug "ZSH options configured"
