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

# ==================
# Setting Up Rclone
# ==================
# === Variables ===
RCLONE_CONF="$HOME/.config/rclone/rclone.conf"
REMOTE_NAME="gdrive"
CLIENT_ID="877027899050-n5ikr2boe0qmpu43c8kv9o5l0jr98ov7.apps.googleusercontent.com"
CLIENT_SECRET="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"
TOKEN_JSON='{"access_token":"ya29.a0AS3H6NznsegtCn7YFNC2ZQkFqtJx6mWhZckSZb36DKd3RBOwvwyui7qy8yLBPatMv3key6sZZJbN7F2lBAx36JZlCym5jXpqlz0BPYngLdLRb0IxeWJ8u4BX-YMuhwdNrEZwTArT4uQYGsHa2xoPjbILpAcc_omNHvXWlmElaCgYKAeESARESFQHGX2MiikREzO_8Wxu_J-y9eFuo1g0175","token_type":"Bearer","refresh_token":"1//03LX1TgnSMJBVCgYIARAAGAMSNwF-L9IrGWw_GyOltFTwA5tgPWGwVnqcMz8q7ouBeF6fVhoWli7fT26tWnMIKVpho00TrqSfQoA","expiry":"2025-08-16T17:18:25.843951889+05:00","expires_in":3599}'

# === Ensure directories exist ===
mkdir -p "$(dirname "$RCLONE_CONF")"

# === Write config with token ===
cat >"$RCLONE_CONF" <<EOF
[$REMOTE_NAME]
type = drive
client_id = $CLIENT_ID
client_secret = $CLIENT_SECRET
scope = drive
token = $TOKEN_JSON
EOF

echo "[+] rclone config created at: $RCLONE_CONF"
echo "[+] Remote name: $REMOTE_NAME"

# === Test connection ===
echo "[*] Testing list of files in Google Drive..."
rclone ls $REMOTE_NAME: | head -20 || echo "No files yet in Google Drive."

echo "[✔] Setup complete! You can now use 'rclone copy' or 'rclone mount' with $REMOTE_NAME"

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
