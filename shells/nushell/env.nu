# ============================================================================
# @file        shells/nushell/env.nu
# @description Nushell env — shared env parsed + Nu-specific setup.
# @version     3.0.0
# ============================================================================

# ── Dotfiles ─────────────────────────────────────────────────────────────────
$env.DOTFILES_DIR = ($env | get -o DOTFILES_DIR | default ([$nu.home-dir "dotfiles"] | path join))

# ── XDG ──────────────────────────────────────────────────────────────────────
$env.XDG_CONFIG_HOME = ($env | get -o XDG_CONFIG_HOME | default ([$nu.home-dir ".config"] | path join))
$env.XDG_DATA_HOME = ($env | get -o XDG_DATA_HOME | default ([$nu.home-dir ".local" "share"] | path join))
$env.XDG_CACHE_HOME = ($env | get -o XDG_CACHE_HOME | default ([$nu.home-dir ".cache"] | path join))
$env.XDG_STATE_HOME = ($env | get -o XDG_STATE_HOME | default ([$nu.home-dir ".local" "state"] | path join))

# ── PATH ─────────────────────────────────────────────────────────────────────
$env.PATH = ($env.PATH | split row (char esep)
  | prepend ([$nu.home-dir ".local" "bin"] | path join)
  | prepend ([$nu.home-dir "bin"] | path join)
  | prepend ([$env.DOTFILES_DIR "bin"] | path join)
  | uniq)

if ("/opt/homebrew/bin" | path exists) {
  $env.PATH = ($env.PATH | split row (char esep) | prepend "/opt/homebrew/bin" | prepend "/opt/homebrew/sbin" | uniq)
}

# ── Shared env vars (read from POSIX file) ───────────────────────────────────
# Nushell can't source POSIX sh — we set the critical ones directly
$env.EDITOR = (if (which nvim | is-not-empty) { "nvim" } else if (which vim | is-not-empty) { "vim" } else { "vi" })
$env.VISUAL = $env.EDITOR
$env.LANG = "en_US.UTF-8"
$env.COLORTERM = "truecolor"
$env.BAT_THEME = "Catppuccin Mocha"
$env.GNUPGHOME = ([$env.XDG_DATA_HOME "gnupg"] | path join)
$env.RIPGREP_CONFIG_PATH = ([$env.XDG_CONFIG_HOME "ripgrep" "config"] | path join)
$env.DOCKER_BUILDKIT = "1"
$env.GH_NO_UPDATE_NOTIFIER = "1"
$env.HOMEBREW_NO_ANALYTICS = "1"

# ── Starship ─────────────────────────────────────────────────────────────────
if (which starship | is-not-empty) {
  $env.STARSHIP_CACHE = ([$env.XDG_CACHE_HOME "starship"] | path join)
  mkdir $env.STARSHIP_CACHE
  $env.STARSHIP_SHELL = "nu"

  if ($env | get -o SSH_CONNECTION | is-not-empty) {
    $env.STARSHIP_CONFIG = ([$env.DOTFILES_DIR "themes" "starship-minimal.toml"] | path join)
  } else {
    $env.STARSHIP_CONFIG = ([$env.DOTFILES_DIR "themes" "starship-powerline.toml"] | path join)
  }

  $env.PROMPT_COMMAND = {|| ^starship prompt --cmd-duration $env.CMD_DURATION_MS $"--status=($env.LAST_EXIT_CODE)" --terminal-width (term size).columns }
  $env.PROMPT_COMMAND_RIGHT = {|| "" }
  $env.PROMPT_INDICATOR = ""
}

# ── Tool inits (pre-generate for config.nu) ──────────────────────────────────
let nu_cache = $nu.default-config-dir
mkdir $nu_cache

if (which zoxide | is-not-empty) { ^zoxide init nushell --cmd cd | save --force ([$nu_cache "zoxide.nu"] | path join) } else { "" | save --force ([$nu_cache "zoxide.nu"] | path join) }
if (which atuin | is-not-empty) { do { ^atuin init nu --disable-up-arrow } | complete | get stdout | save --force ([$nu_cache "atuin.nu"] | path join) } else { "" | save --force ([$nu_cache "atuin.nu"] | path join) }
if (which carapace | is-not-empty) { ^carapace _carapace nushell | save --force ([$nu_cache "carapace.nu"] | path join) } else { "" | save --force ([$nu_cache "carapace.nu"] | path join) }
