#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Load local config (.env is git-ignored; copy .env.example to .env to configure)
# shellcheck source=/dev/null
[[ -f "${SCRIPT_DIR}/.env" ]] && source "${SCRIPT_DIR}/.env"
: "${REGISTRY:?REGISTRY is not set — copy .env.example to .env and set REGISTRY}"

# Active image definitions: "alias|Dockerfile|image-name|default-tag|variant"
# variant: "patch" marks images that apply updates on top of an earlier BUILD
# (e.g. -daily images) — PATCH_DATE is auto-injected as a build-arg for these,
# which setup_image_info.sh uses to populate the workspace status bar.
# Images not yet ready to build (noble-core, noble-desktop-basic, alpine-desktop-basic)
# are excluded until their Dockerfiles are stabilized.
IMAGE_DEFS=(
    "calibre|Dockerfile.calibre|${REGISTRY}/kasm-calibre|1.18.0-latest"
    "anycubic-slicer-next|Dockerfile.anycubic-slicer-next|${REGISTRY}/kasm-anycubic-slicer-next|1.18.0-latest"
    "dev-desktop|Dockerfile.dev-desktop|${REGISTRY}/kasm-noble-dev-desktop|1.18.0-latest"
    "dev-desktop-daily|Dockerfile.dev-desktop-daily|${REGISTRY}/kasm-noble-dev-desktop|1.18.0-daily|patch"
    "solvespace|Dockerfile.solvespace|${REGISTRY}/kasm-solvespace|1.18.0-latest"
    "minecraft|Dockerfile.minecraft|${REGISTRY}/kasm-minecraft|1.18.0-latest"
    "phantom-swamp-skunk|Dockerfile.phantom-swamp-skunk|${REGISTRY}/kasm-phantom-swamp-skunk|1.18.0-latest"
)

usage() {
    local exit_code="${1:-1}"
    cat <<EOF
Usage: $(basename "$0") <alias> [options]
       $(basename "$0") --all [options]
       $(basename "$0") --list

Options:
  --dev             Build with DEV=1 (enables sudo, debug output).
                    Automatically loads to KASM host unless --no-load is given.
                    Note: --dev and release images are NOT interchangeable.
  --push            Push image to Docker Hub after build
  --load            Load image to KASM host after build (explicit; implied by --dev)
  --no-load         Suppress the auto-load that --dev implies
  --tag TAG         Override the full image tag
  --no-cache        Pass --no-cache to docker build
  --build-arg ARG   Pass additional --build-arg (repeatable)

Aliases:
EOF
    for def in "${IMAGE_DEFS[@]}"; do
        IFS='|' read -r alias dockerfile image tag variant <<< "${def}"
        printf "  %-22s  %s:%s\n" "${alias}" "${image}" "${tag}"
    done
    echo
    echo "Examples:"
    echo "  $(basename "$0") calibre --dev              # build DEV=1, auto-load to KASM host"
    echo "  $(basename "$0") calibre --dev --no-load    # build DEV=1, local only"
    echo "  $(basename "$0") calibre --push             # build release (DEV=0), push to Hub"
    echo "  $(basename "$0") dev-desktop --push         # build dev-desktop release, push"
    echo "  $(basename "$0") dev-desktop-daily --push   # build daily, push"
    exit "${exit_code}"
}

get_config() {
    local target="$1"
    for def in "${IMAGE_DEFS[@]}"; do
        IFS='|' read -r alias dockerfile image tag variant <<< "${def}"
        if [[ "${alias}" == "${target}" ]]; then
            echo "${dockerfile}|${image}|${tag}|${variant}"
            return 0
        fi
    done
    echo "Error: unknown alias '${target}'" >&2
    echo "Run '$(basename "$0") --list' for available aliases." >&2
    exit 1
}

load_to_host() {
    local full_image="$1"
    : "${KASM_HOST:?KASM_HOST is not set — copy .env.example to .env and set KASM_HOST}"
    echo "Loading ${full_image} to ${KASM_HOST}..."
    docker save "${full_image}" | ssh "${KASM_HOST}" docker load
    echo "Loaded: ${full_image}"
}

build_image() {
    local alias="$1"
    local do_push="$2"
    local dev_build="$3"
    local do_load="$4"
    local override_tag="$5"
    local no_cache="$6"
    shift 6
    local extra_build_args=("$@")

    local config
    config=$(get_config "${alias}")
    IFS='|' read -r dockerfile image default_tag variant <<< "${config}"

    if [[ -n "${override_tag}" ]]; then
        local tag="${override_tag}"
    elif [[ "${dev_build}" == "1" ]]; then
        local tag="${default_tag%%-*}-dev"
    else
        local tag="${default_tag}"
    fi

    local full_image="${image}:${tag}"
    mkdir -p "${SCRIPT_DIR}/logs"
    local log_file="${SCRIPT_DIR}/logs/$(date -u '+%Y%m%dT%H%M%SZ')-${alias}.build.log"

    echo "========================================"
    echo "  Building: ${full_image}"
    echo "  From:     ${dockerfile}"
    echo "  DEV=1:    ${dev_build}"
    echo "  Log:      $(basename "${log_file}")"
    echo "========================================"

    local build_cmd=(docker build -f "${dockerfile}" -t "${full_image}" --progress=plain)
    [[ "${dev_build}" == "1" ]] && build_cmd+=(--build-arg "DEV=1")
    [[ "${variant}" == "patch" ]] && build_cmd+=(--build-arg "PATCH_DATE=$(date -u '+%Y-%m-%d %H:%M.%S %Z')")
    [[ "${no_cache}" == "1" ]] && build_cmd+=(--no-cache)
    for arg in "${extra_build_args[@]+"${extra_build_args[@]}"}"; do
        build_cmd+=(--build-arg "${arg}")
    done
    build_cmd+=(.)

    "${build_cmd[@]}" 2>&1 | tee "${log_file}"

    if [[ "${do_load}" == "1" ]]; then
        load_to_host "${full_image}"
    fi

    if [[ "${do_push}" == "1" ]]; then
        echo "Pushing ${full_image}..."
        docker push "${full_image}"
    fi

    echo "Done: ${full_image}"
}

[[ $# -eq 0 ]] && usage

DO_PUSH=0
DEV_BUILD=0
DO_LOAD=""    # "" = auto, "1" = force on, "0" = force off
NO_CACHE=0
OVERRIDE_TAG=""
EXTRA_BUILD_ARGS=()
TARGET=""
BUILD_ALL=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --push)      DO_PUSH=1 ;;
        --dev)       DEV_BUILD=1 ;;
        --load)      DO_LOAD=1 ;;
        --no-load)   DO_LOAD=0 ;;
        --no-cache)  NO_CACHE=1 ;;
        --all)       BUILD_ALL=1 ;;
        --list)      usage 0 ;;
        --tag)       OVERRIDE_TAG="${2:?--tag requires an argument}"; shift ;;
        --build-arg) EXTRA_BUILD_ARGS+=("${2:?--build-arg requires an argument}"); shift ;;
        -*)          echo "Unknown option: $1" >&2; usage ;;
        *)           TARGET="$1" ;;
    esac
    shift
done

# Resolve DO_LOAD: --dev implies load unless --no-load given
if [[ -z "${DO_LOAD}" ]]; then
    DO_LOAD="${DEV_BUILD}"
fi

if [[ "${BUILD_ALL}" == "1" ]]; then
    for def in "${IMAGE_DEFS[@]}"; do
        IFS='|' read -r alias _ _ _ <<< "${def}"
        build_image "${alias}" "${DO_PUSH}" "${DEV_BUILD}" "${DO_LOAD}" "${OVERRIDE_TAG}" "${NO_CACHE}" "${EXTRA_BUILD_ARGS[@]+"${EXTRA_BUILD_ARGS[@]}"}"
    done
elif [[ -n "${TARGET}" ]]; then
    build_image "${TARGET}" "${DO_PUSH}" "${DEV_BUILD}" "${DO_LOAD}" "${OVERRIDE_TAG}" "${NO_CACHE}" "${EXTRA_BUILD_ARGS[@]+"${EXTRA_BUILD_ARGS[@]}"}"
else
    usage
fi
