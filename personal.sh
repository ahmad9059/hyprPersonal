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
CYAN="$(tput setaf 6)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"

# ===========================
# Log Details
# ===========================
mkdir -p "$HOME/installer_log"
LOG_FILE="$HOME/installer_log/boot_file.log"

# ===========================
# Ask for sudo once, keep it alive
# ===========================
echo "${NOTE} Asking for sudo password...${RESET}"
sudo -v

keep_sudo_alive() {
  while true; do
    sudo -n true
    sleep 30
  done
}

keep_sudo_alive &
SUDO_KEEP_ALIVE_PID=$!

trap 'kill $SUDO_KEEP_ALIVE_PID' EXIT

# ===========================
# Define script directory
# ===========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===========================
# Clone Arch-Hyprland repo
# ===========================
if [ -d "$HOME/Arch-Hyprland" ]; then
  echo "${NOTE} Folder 'Arch-Hyprland' already exists in HOME, using it...${RESET}"
else
  echo "${NOTE} Cloning Arch-Hyprland repo into HOME...${RESET}"
  if git clone --depth=1 https://github.com/ahmad9059/Arch-Hyprland.git "$HOME/Arch-Hyprland"; then
    echo "${OK} Repo cloned successfully.${RESET}"
  else
    echo "${ERROR} Failed to clone Arch-Hyprland repo. Exiting.${RESET}"
    exit 1
  fi
fi

# ===========================
# Run Arch-Hyprland installer
# ===========================
echo "${NOTE} Running Arch-Hyprland/install.sh with preset answers...${RESET}"
cd "$HOME/Arch-Hyprland"
sed -i '/^[[:space:]]*read HYP$/c\HYP="n"' ~/Arch-Hyprland/install.sh
sed -i '345i \
wget -q -O ~/Arch-Hyprland/install-scripts/zsh.sh https://raw.githubusercontent.com/ahmad9059/Scripts/main/zsh.sh\n\
wget -q -O /tmp/replace_reads.sh https://raw.githubusercontent.com/ahmad9059/Scripts/main/replace_reads.sh\n\
chmod +x /tmp/replace_reads.sh\n\
bash /tmp/replace_reads.sh ' ~/Arch-Hyprland/install.sh
chmod +x install.sh
bash install.sh
echo "${OK} Arch-Hyprland script Installed!${RESET}"

# ===========================
# dotfile banner Banner
# ===========================
clear

echo -e "\n"
echo -e "${MAGENTA}┌┬┐┌─┐┌┬┐┌─┐┬┬  ┌─┐┌─┐┌─┐  ┬┌┐┌┌─┐┌┬┐┌─┐┬  ┬  ┌─┐┬─┐${RESET}"
echo -e "${MAGENTA} │││ │ │ ├┤ ││  ├┤ └─┐└─┐  ││││└─┐ │ ├─┤│  │  ├┤ ├┬┘${RESET}"
echo -e "${MAGENTA}─┴┘└─┘ ┴ └  ┴┴─┘└─┘└─┘└─┘  ┴┘└┘└─┘ ┴ ┴ ┴┴─┘┴─┘└─┘┴└─${RESET}"
echo -e "${CYAN}✻─────────────────────ahmad9059──────────────────────✻${RESET}"
echo -e "\n"

# ===========================
# Clone dotfiles repo
# ===========================
if [ -d "$HOME/dotfiles" ]; then
  echo "${NOTE} Folder 'dotfiles' already exists in HOME, using it...${RESET}"
else
  echo "${NOTE} Cloning dotfiles repo into ~...${RESET}"
  if git clone --depth=1 https://github.com/ahmad9059/dotfiles.git "$HOME/dotfiles"; then
    echo "${OK} Repo cloned successfully.${RESET}"
  else
    echo "${ERROR} Failed to clone dotfiles repo. Exiting.${RESET}"
    exit 1
  fi
fi

# ===========================
# Run dotfiles installer
# ===========================
echo "${NOTE} Running dotfiles/install.sh with preset answers...${RESET}"
cd "$HOME/dotfiles"
chmod +x dotfile_installer.sh
bash dotfile_installer.sh
echo "${OK} Dotfiles Installation Completed${RESET}"

# ===========================
# Apply personal changes (reverse from GitHub state)
# ===========================
echo "${NOTE} Applying personal local modifications...${RESET}"

# 1. Restore kb_options in UserSettings.conf
USERS_CONF="$HOME/.config/hypr/UserConfigs/UserSettings.conf"
if [ -f "$USERS_CONF" ]; then
  echo "${ACTION} Updating kb_options in UserSettings.conf..."
  if sed -i 's/kb_options = $/kb_options = ctrl:nocaps/' "$USERS_CONF"; then
    echo "${OK} kb_options updated in UserSettings.conf"
  else
    echo "${ERROR} Failed to update UserSettings.conf"
  fi
else
  echo "${NOTE} UserSettings.conf not found, skipping."
fi

# 2. Restore hyprland.conf label block (LC_TIME and font_family)
HYPR_CONF="$HOME/dotfiles/.config/hypr/hyprlock.conf"
if [ -f "$HYPR_CONF" ]; then
  echo "${ACTION} Updating LC_TIME and font_family in hyprlock.conf..."
  sed -i 's/LC_TIME=en_US.UTF-8/LC_TIME=ur_PK.UTF-8/' "$HYPR_CONF"
  sed -i 's/SF Pro Display Semibold/Noto Nastaliq Urdu/' "$HYPR_CONF"
  echo "${OK} LC_TIME and font_family updated in hyprlock.conf"
fi

# 3.Set Only Time Locale to Pakistan (Urdu)
echo -e "${ACTION} Setting ur_PK.UTF-8 locale for time...${RESET}" | tee -a "$LOG_FILE"
{
  sudo sed -i 's/^#\s*\(ur_PK.*UTF-8\)/\1/' /etc/locale.gen
  sudo locale-gen
  if ! grep -q "^LC_TIME=ur_PK.UTF-8" /etc/locale.conf 2>/dev/null; then
    echo "LC_TIME=ur_PK.UTF-8" | sudo tee -a /etc/locale.conf >/dev/null
  fi
} >>"$LOG_FILE" 2>&1 || {
  echo -e "${ERROR} Failed to set LC_TIME=ur_PK.UTF-8. See $LOG_FILE for details.${RESET}"
  exit 1
}
echo -e "${OK} LC_TIME=ur_PK.UTF-8 set successfully.${RESET}" | tee -a "$LOG_FILE"

echo "${OK} Personal modifications applied locally.${RESET}"

# ===========================
# Ask for Reboot
# ===========================

read -p "Do you want to reboot now? [y/N]: " REBOOT_CHOICE

if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
  echo "$OK Rebooting..."
  sudo reboot
else
  echo "$OK You chose NOT to reboot. Please reboot later."
fi
