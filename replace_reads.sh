#!/bin/bash

set -e

# ===========================
# Color-coded status labels
# ===========================
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
WARN="$(tput setaf 3)[WARN]$(tput sgr0)"
OK="$(tput setaf 2)[OK]$(tput sgr0)"
NOTE="$(tput setaf 6)[NOTE]$(tput sgr0)"
ACTION="$(tput setaf 5)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

# ===========================
# Log Details
# ===========================
LOG_FILE="$HOME/installer_log/replace_reads.log"

# ===========================
# 1️⃣ Clone the Hyprland-Dots repo
# ===========================
if [ -d "$HOME/Arch-Hyprland/Hyprland-Dots" ]; then
  echo "${NOTE} Folder 'Hyprland-Dots' already exists in ~/Arch-Hyprland, using it...${RESET}"
else
  echo "${NOTE} Cloning Hyprland-Dots repo into ~/Arch-Hyprland...${RESET}"
  if git clone --depth=1 https://github.com/ahmad9059/Hyprland-Dots.git "$HOME/Arch-Hyprland/Hyprland-Dots"; then
    echo "${OK} Repo cloned successfully.${RESET}"
  else
    echo "${ERROR} Failed to clone repo. Exiting.${RESET}"
    exit 1
  fi
fi

# ===========================
# 2️⃣ Variables to replace in copy.sh
# ===========================
TARGET_FILE="$HOME/Arch-Hyprland/Hyprland-Dots/copy.sh"

if [ ! -f "$TARGET_FILE" ]; then
  echo "${ERROR} $TARGET_FILE not found!${RESET}"
  exit 1
fi

# Preset values for copy.sh
keyboard_layout="y"
EDITOR_CHOICE="y"
res_choice=1
answer="y"
border_choice="y"
SDDM_WALL="y"
WALL="n"

# ===========================
# Apply substitutions
# ===========================
echo "${NOTE} Applying substitutions to $TARGET_FILE...${RESET}"
sed -i '/^[[:space:]]*git stash && git pull/d' ~/Arch-Hyprland/install-scripts/dotfiles-main.sh
sed -i \
  -e "s/^[[:space:]]*read keyboard_layout.*/keyboard_layout=\"$keyboard_layout\"/" \
  -e "s/^[[:space:]]*read EDITOR_CHOICE.*/EDITOR_CHOICE=\"$EDITOR_CHOICE\"/" \
  -e "s/^[[:space:]]*read res_choice.*/res_choice=$res_choice/" \
  -e "s/^[[:space:]]*read answer.*/answer=\"$answer\"/" \
  -e "s/^[[:space:]]*read border_choice.*/border_choice=\"$border_choice\"/" \
  -e "s/^[[:space:]]*read SDDM_WALL.*/SDDM_WALL=\"$SDDM_WALL\"/" \
  -e "s/^[[:space:]]*read WALL.*/WALL=\"$WALL\"/" \
  "$TARGET_FILE"

echo "${OK} Substitutions completed successfully in $TARGET_FILE ${RESET}"
