#!/usr/bin/env bash
cmd_doctor() {
    [ -f "${DOTFILES_DIR}/scripts/doctor.sh" ] && bash "${DOTFILES_DIR}/scripts/doctor.sh" || _err "doctor.sh not found"
}
