#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly PLUGIN_ID="arcanorca.boingwave"
readonly SHADER_DIR="${SCRIPT_DIR}/contents/shaders"
readonly INSTALL_DIR="${HOME}/.local/share/plasma/wallpapers/${PLUGIN_ID}"
readonly QT6_QSB="/usr/lib/qt6/bin/qsb"

# Colors for cool terminal output
readonly C_BOLD='\033[1m'
readonly C_CYAN='\033[0;36m'
readonly C_GREEN='\033[0;32m'
readonly C_PURPLE='\033[0;35m'
readonly C_RED='\033[0;31m'
readonly C_RESET='\033[0m'

clear
echo -e "${C_PURPLE}${C_BOLD}"
echo "  ____   ___ ___ _   _  ____ __        __  _  __     _______ "
echo " | __ ) / _ \_ _| \ | |/ ___|\ \      / / / \ \ \   / / ____|"
echo " |  _ \| | | | ||  \| | |  _  \ \ /\ / / / _ \ \ \ / /|  _|  "
echo " | |_) | |_| | || |\  | |_| |  \ V  V / / ___ \ \ V / | |___ "
echo " |____/ \___/___|_| \_|\____|   \_/\_/ /_/   \_\ \_/  |_____|"
echo -e "                                         ${C_RESET}${C_CYAN}by arcanorca${C_RESET}\n"

echo -e "${C_BOLD}${C_PURPLE}:: Local Deployment ::${C_RESET}"

QSB_BIN="${QSB_BIN:-}"
if [[ -z "${QSB_BIN}" ]]; then
    if command -v qsb >/dev/null 2>&1; then
        QSB_BIN="$(command -v qsb)"
    elif [[ -x "${QT6_QSB}" ]]; then
        QSB_BIN="${QT6_QSB}"
    elif command -v qsb-qt6 >/dev/null 2>&1; then
        QSB_BIN="$(command -v qsb-qt6)"
    fi
fi

if [[ -z "${QSB_BIN}" ]]; then
    echo -e "${C_RED}Error: qsb not found (checked PATH, ${QT6_QSB}, qsb-qt6).${C_RESET}" >&2
    exit 1
fi

if [[ ! -f "${SHADER_DIR}/main.qml" && ! -d "${SHADER_DIR}" ]]; then
    echo -e "${C_RED}Error: missing shaders directory.${C_RESET}" >&2
    exit 1
fi

echo -e " ${C_CYAN}*${C_RESET} Compiling shaders..."
pushd "${SHADER_DIR}" >/dev/null
for frag in *.frag; do
    base="${frag%.*}"
    echo -n "   - ${base}.frag ... "
    if "${QSB_BIN}" --glsl "100 es,120,150" --hlsl 50 --msl 12 -O -o "${base}.qsb" "${frag}" >/dev/null 2>&1; then
        echo -e "${C_GREEN}OK${C_RESET}"
    else
        echo -e "${C_RED}FAILED${C_RESET}"
        exit 1
    fi
done
popd >/dev/null

echo -e " ${C_CYAN}*${C_RESET} Synchronizing files to Plasma wallpaper directory..."
mkdir -p "${INSTALL_DIR}"

if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete \
        --exclude ".git/" \
        --exclude ".gitignore" \
        "${SCRIPT_DIR}/" "${INSTALL_DIR}/"
else
    rm -rf "${INSTALL_DIR}"
    mkdir -p "${INSTALL_DIR}"
    cp -a "${SCRIPT_DIR}/." "${INSTALL_DIR}/"
fi

echo -e " ${C_CYAN}*${C_RESET} Restarting Plasma shell to apply changes..."
systemctl --user restart plasma-plasmashell.service

echo -e "\n${C_BOLD}${C_GREEN}[✓] Boingwave deployed successfully!${C_RESET}"
echo -e "    ${C_BOLD}Path:${C_RESET} ${INSTALL_DIR}"
