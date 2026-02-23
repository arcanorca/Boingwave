#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly PLUGIN_ID="com.custom.boingwave"
readonly SHADER_DIR="${SCRIPT_DIR}/contents/shaders"
readonly INSTALL_DIR="${HOME}/.local/share/plasma/wallpapers/${PLUGIN_ID}"
readonly QT6_QSB="/usr/lib/qt6/bin/qsb"

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
    echo "Error: qsb not found (checked PATH, ${QT6_QSB}, qsb-qt6)." >&2
    exit 1
fi

if [[ ! -f "${SHADER_DIR}/main.qml" && ! -d "${SHADER_DIR}" ]]; then
    echo "Error: missing shaders directory." >&2
    exit 1
fi

pushd "${SHADER_DIR}" >/dev/null
for frag in *.frag; do
    base="${frag%.*}"
    "${QSB_BIN}" --glsl "100 es,120,150" --hlsl 50 --msl 12 -O -o "${base}.qsb" "${frag}"
done
popd >/dev/null

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

systemctl --user restart plasma-plasmashell.service

echo "Boingwave deployed to ${INSTALL_DIR}"
