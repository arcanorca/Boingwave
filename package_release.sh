#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly PLUGIN_ID="arcanorca.boingwave"
readonly SHADER_DIR="${SCRIPT_DIR}/contents/shaders"
readonly BUILD_DIR="${SCRIPT_DIR}/build"
readonly OUTPUT_FILE="${BUILD_DIR}/${PLUGIN_ID}.kpackage"

# Colors
readonly C_BOLD='\033[1m'
readonly C_CYAN='\033[0;36m'
readonly C_GREEN='\033[0;32m'
readonly C_PURPLE='\033[0;35m'
readonly C_RED='\033[0;31m'
readonly C_RESET='\033[0m'

echo -e "${C_BOLD}${C_PURPLE}:: Boingwave Release Packager ::${C_RESET}"

# 1. Compile Shaders
QT6_QSB="/usr/lib/qt6/bin/qsb"
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
    echo "Error: qsb not found. Please install qt6-shadertools." >&2
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

# 2. Package
echo -e " ${C_CYAN}*${C_RESET} Creating archives in ${C_BOLD}${BUILD_DIR}${C_RESET}..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

pushd "${SCRIPT_DIR}" >/dev/null
# KDE's kpackagetool6 requires standard ZIP archive structure for .kpackage / .plasmoid files.
zip -qr "${OUTPUT_FILE}" metadata.json contents README.md

# We also generate a tar.gz for standard archive distribution on KDE Store
tar -czf "${BUILD_DIR}/${PLUGIN_ID}.tar.gz" metadata.json contents README.md
popd >/dev/null

echo -e "\n${C_BOLD}${C_GREEN}[✓] Packaging complete! Ready for KDE Store:${C_RESET}"
echo -e "    ${C_PURPLE}→${C_RESET} ${OUTPUT_FILE}"
echo -e "    ${C_PURPLE}→${C_RESET} ${BUILD_DIR}/${PLUGIN_ID}.tar.gz"
