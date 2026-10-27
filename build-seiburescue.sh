#!/bin/bash
# ==============================================================================
# SeibuRescue - Automated ISO Image Build Script
# Supports:
#   1) SeibuRescue 64-bit (Ubuntu 24.04 Noble - amd64) [Branch: main]
#   2) SeibuRescue 32-bit (Ubuntu 18.04 Bionic - i386)  [Branch: main]
#   3) SeibuRescue Restore-Only 64-bit (Noble - amd64)  [Branch: restore-only]
#   4) SeibuRescue Restore-Only 32-bit (Bionic - i386)   [Branch: restore-only]
# ==============================================================================

set -e

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "===================================================================="
    echo "              SEIBURESCUE - ISO IMAGE BUILDER                       "
    echo "===================================================================="
    echo -e "${NC}"
}

check_prerequisites() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Docker is not installed on this system.${NC}"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Docker daemon is not running or your user does not have permission.${NC}"
        echo -e "${YELLOW}Try running with sudo or add your user to the docker group: sudo usermod -aG docker \$USER${NC}"
        exit 1
    fi

    # Check if the builder.image Docker image exists
    if ! docker image inspect builder.image >/dev/null 2>&1; then
        echo -e "${YELLOW}[NOTICE] Docker build image 'builder.image' was not found.${NC}"
        echo -e "${BLUE}Building Docker build environment container...${NC}"
        docker build -t builder.image docker/
        echo -e "${GREEN}[OK] 'builder.image' successfully created.${NC}"
    fi
}

switch_branch() {
    local target_branch="$1"
    local current_branch
    current_branch="$(git rev-parse --abbrev-ref HEAD)"

    if [ "$current_branch" != "$target_branch" ]; then
        echo -e "${BLUE}[GIT] Switching to branch '${target_branch}' (current: '${current_branch}')...${NC}"
        
        # Check for uncommitted changes in tracked files
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo -e "${YELLOW}[NOTICE] Uncommitted changes detected on current branch.${NC}"
            echo -e "${YELLOW}Stashing changes temporarily with 'git stash'...${NC}"
            git stash
        fi
        
        git checkout "$target_branch"
        git pull origin "$target_branch" || true
    else
        echo -e "${GREEN}[GIT] Already on branch '${target_branch}'.${NC}"
    fi
}

build_version() {
    local version_name="$1"
    local branch="$2"
    local make_target="$3"
    local source_iso="$4"
    local target_iso="$5"

    local start_time
    start_time=$(date +%s)

    echo -e "\n${CYAN}====================================================================${NC}"
    echo -e "${BOLD}Starting build:  ${GREEN}${version_name}${NC}"
    echo -e "Git Branch:      ${YELLOW}${branch}${NC}"
    echo -e "Makefile Target: ${YELLOW}${make_target}${NC}"
    echo -e "Target ISO:      ${GREEN}${target_iso}${NC}"
    echo -e "${CYAN}====================================================================${NC}\n"

    switch_branch "$branch"

    echo -e "${BLUE}[1/3] Cleaning previous build files to avoid conflicts...${NC}"
    docker run --rm --privileged -v "$SCRIPT_DIR:/home/rescuezilla" builder.image bash -c \
        "umount -lf /home/rescuezilla/build/${make_target//-/.}/chroot/dev/ 2>/dev/null || true; \
         rm -rf /home/rescuezilla/build/${make_target//-/.}" || true

    echo -e "${BLUE}[2/3] Running 'make ${make_target}' inside Docker container...${NC}"
    docker run --rm --privileged -v "$SCRIPT_DIR:/home/rescuezilla" builder.image make -C /home/rescuezilla "$make_target"

    echo -e "${BLUE}[3/3] Verifying and linking generated ISO image...${NC}"
    if [ -f "$SCRIPT_DIR/build/$source_iso" ]; then
        ln -sf "build/$source_iso" "$SCRIPT_DIR/$target_iso"
        
        local file_size
        file_size=$(du -h "$SCRIPT_DIR/$target_iso" | cut -f1)
        
        local sha256
        sha256=$(sha256sum "$SCRIPT_DIR/$target_iso" | awk '{print $1}')
        echo "$sha256  $target_iso" > "$SCRIPT_DIR/${target_iso}.sha256"

        local end_time
        end_time=$(date +%s)
        local elapsed=$(( end_time - start_time ))

        echo -e "\n${GREEN}${BOLD}✔ Build completed successfully in $((elapsed / 60))m $((elapsed % 60))s!${NC}"
        echo -e "  ISO File:    ${BOLD}$SCRIPT_DIR/$target_iso${NC}"
        echo -e "  File Size:   ${BOLD}$file_size${NC}"
        echo -e "  SHA256:      ${BOLD}$sha256${NC}"
        echo -e "  Checksum in: ${BOLD}$SCRIPT_DIR/${target_iso}.sha256${NC}\n"
    else
        echo -e "${RED}[ERROR] Expected output file not found: build/$source_iso${NC}"
        return 1
    fi
}

main_menu() {
    banner
    echo -e "${BOLD}Select the SeibuRescue version you want to build:${NC}\n"
    echo -e "  ${BOLD}1)${NC} ${GREEN}SeibuRescue 64-bit${NC} (Ubuntu 24.04 Noble - amd64)    [Branch: main]"
    echo -e "  ${BOLD}2)${NC} ${GREEN}SeibuRescue 32-bit${NC} (Ubuntu 18.04 Bionic - i386)     [Branch: main]"
    echo -e "  ${BOLD}3)${NC} ${YELLOW}SeibuRescue Restore-Only 64-bit${NC} (Noble - amd64)     [Branch: restore-only]"
    echo -e "  ${BOLD}4)${NC} ${YELLOW}SeibuRescue Restore-Only 32-bit${NC} (Bionic - i386)      [Branch: restore-only]"
    echo -e "  ${BOLD}5)${NC} ${CYAN}Build all 4 versions sequentially${NC}"
    echo -e "  ${BOLD}6)${NC} Exit\n"

    read -rp "Enter your choice [1-6]: " choice

    case "$choice" in
        1)
            build_version "SeibuRescue 64-bit (Full)" "main" "noble" "rescuezilla.amd64.noble.iso" "SeibuRescue-24.04-amd64.iso"
            ;;
        2)
            build_version "SeibuRescue 32-bit (Full)" "main" "bionic-i386" "rescuezilla.i386.bionic.iso" "SeibuRescue-18.04-i386.iso"
            ;;
        3)
            build_version "SeibuRescue Restore-Only 64-bit" "restore-only" "noble" "rescuezilla.amd64.noble.iso" "SeibuRescue-RestoreOnly-24.04-amd64.iso"
            ;;
        4)
            build_version "SeibuRescue Restore-Only 32-bit" "restore-only" "bionic-i386" "rescuezilla.i386.bionic.iso" "SeibuRescue-RestoreOnly-18.04-i386.iso"
            ;;
        5)
            echo -e "\n${BOLD}${CYAN}Starting sequential batch build of all 4 variants...${NC}\n"
            build_version "SeibuRescue 64-bit (Full)" "main" "noble" "rescuezilla.amd64.noble.iso" "SeibuRescue-24.04-amd64.iso"
            build_version "SeibuRescue 32-bit (Full)" "main" "bionic-i386" "rescuezilla.i386.bionic.iso" "SeibuRescue-18.04-i386.iso"
            build_version "SeibuRescue Restore-Only 64-bit" "restore-only" "noble" "rescuezilla.amd64.noble.iso" "SeibuRescue-RestoreOnly-24.04-amd64.iso"
            build_version "SeibuRescue Restore-Only 32-bit" "restore-only" "bionic-i386" "rescuezilla.i386.bionic.iso" "SeibuRescue-RestoreOnly-18.04-i386.iso"
            echo -e "\n${GREEN}${BOLD}✔ All 4 ISO images have been successfully built!${NC}\n"
            ;;
        6|q|Q)
            echo -e "\n${BLUE}Operation cancelled.${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${NC}\n"
            sleep 2
            main_menu
            ;;
    esac
}

check_prerequisites
main_menu
