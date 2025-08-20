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

# =============================
# Paths
# ============================
FONT_DIR="/tmp/San-Francisco-family"
SYSTEM_FONT_LOCATION="/usr/local/share/fonts/otf"
FONT_URL="https://github.com/thelioncape/San-Francisco-family.git"
FONTS=("SF Pro" "SF Serif" "SF Mono")

# ===========================
# Variables
# ===========================
TOKEN_URL="https://raw.githubusercontent.com/ahmad9059/Scripts/main/github_token.gpg"
TOKEN_FILE="/tmp/github_token.gpg"
DECRYPTED_FILE="$HOME/.personal_token"
CLIENT_ID_URL="https://raw.githubusercontent.com/ahmad9059/Scripts/main/client-id.gpg"
CLIENT_SECRET_URL="https://raw.githubusercontent.com/ahmad9059/Scripts/main/client-secret.gpg"
TOKEN_JSON_URL="https://raw.githubusercontent.com/ahmad9059/Scripts/main/token-json.gpg"
RCLONE_CONF="$HOME/.config/rclone/rclone.conf"
REMOTE_NAME="gdrive"

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
# Ask passphrase of GPG
# ===========================
read -p "Enter GPG passphrase: > " GPG_PASS

# Move cursor up one line, clear it, and show stars
tput cuu1 && tput el
echo "Enter GPG passphrase: ********"

# ============================
# Yay and Pacman Confirmation
# ============================
read -p "Do You Want to Install the Yay and Pacman Packages (yes/no): " REPLACEMENT

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
# Replace ans1 read
# sed -i "s/read -rp \"Type 'yes' or 'no' to continue: \" ans1/ans1='no'/g" "$HOME/dotfiles/dotfile_installer.sh"
sed -i "s/read -rp \"Type 'yes' or 'no' to continue: \" ans1/ans1='$REPLACEMENT'/g" "$HOME/dotfiles/dotfile_installer.sh"
# Replace ans2 read
# sed -i "s/read -rp \"Type 'yes' or 'no' to continue: \" ans2/ans2='no'/g" "$HOME/dotfiles/dotfile_installer.sh"
sed -i "s/read -rp \"Type 'yes' or 'no' to continue: \" ans2/ans2='$REPLACEMENT'/g" "$HOME/dotfiles/dotfile_installer.sh"
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
  if sed -i 's/kb_options = *$/kb_options = ctrl:nocaps/' "$USERS_CONF"; then
    echo "${OK} kb_options updated in UserSettings.conf"
  else
    echo "${ERROR} Failed to update UserSettings.conf"
  fi
else
  echo "${NOTE} UserSettings.conf not found, skipping."
fi

# 2. Restore hyprland.conf label block (LC_TIME and font_family)
HYPR_CONF="$HOME/.config/hypr/hyprlock.conf"
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

# ==============================
# Install San Francisco Fonts
# ==============================
echo -e "\n${ACTION} Cloning San Francisco fonts repository...${RESET}"
if git clone -n --depth=1 --filter=tree:0 "$FONT_URL" "$FONT_DIR"; then
  cd "$FONT_DIR" || {
    echo -e "${ERROR} Failed to enter font repo directory.${RESET}"
    exit 1
  }
  if git sparse-checkout set --no-cone "${FONTS[@]}" && git checkout; then
    echo -e "${OK} Repository cloned and sparse checkout successful.${RESET}"
  else
    echo -e "${ERROR} Failed during sparse checkout.${RESET}"
    exit 1
  fi
else
  echo -e "${ERROR} Failed to clone font repository.${RESET}"
  exit 1
fi
echo -e "\n${ACTION} Copying font files...${RESET}"
sudo mkdir -p "$SYSTEM_FONT_LOCATION"/sf-{pro,serif,mono}
sudo cp "$FONT_DIR"/SF\ Pro/*.otf "$SYSTEM_FONT_LOCATION/sf-pro" &&
  sudo cp "$FONT_DIR"/SF\ Serif/*.otf "$SYSTEM_FONT_LOCATION/sf-serif" &&
  sudo cp "$FONT_DIR"/SF\ Mono/*.otf "$SYSTEM_FONT_LOCATION/sf-mono"
if [ $? -eq 0 ]; then
  rm -rf "$FONT_DIR"
  echo -e "${OK} Fonts installed successfully to $SYSTEM_FONT_LOCATION.${RESET}"
else
  echo -e "${ERROR} Failed to copy fonts.${RESET}"
  exit 1
fi
echo -e "\n${NOTE} Updating font cache...${RESET}"
if sudo fc-cache -f -v; then
  echo -e "${OK} Font cache updated.${RESET}"
else
  echo -e "${WARN} Could not update font cache.${RESET}"
fi

# ==============================
# Setup Chaotic AUR Repository
# ==============================
echo -e "\n${ACTION} Setting up Chaotic AUR repository...${RESET}" | tee -a "$LOG_FILE"
# Import Chaotic AUR key
if sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com &&
  sudo pacman-key --lsign-key 3056513887B78AEB; then
  echo -e "${OK} Chaotic AUR key imported successfully.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to import Chaotic AUR key.${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi
# Install keyring and mirrorlist
if sudo pacman -U --noconfirm \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then
  echo -e "${OK} Chaotic AUR keyring and mirrorlist installed.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to install Chaotic AUR keyring/mirrorlist.${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi
# Add chaotic-aur repo if not already present
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null
  echo -e "${OK} Chaotic AUR repository added to pacman.conf.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${NOTE} Chaotic AUR repository already exists in pacman.conf.${RESET}" | tee -a "$LOG_FILE"
fi
# Sync and update
if sudo pacman -Syu --needed --noconfirm; then
  echo -e "${OK} System updated with Chaotic AUR enabled.${RESET}" | tee -a "$LOG_FILE"
else
  echo -e "${ERROR} Failed to update system after adding Chaotic AUR.${RESET}" | tee -a "$LOG_FILE"
  exit 1
fi

# ===========================
# GitHub Cli SetUp
# ===========================

echo "${ACTION} Downloading encrypted GitHub token...${RESET}"
if ! curl -fsSL "$TOKEN_URL" -o "$TOKEN_FILE"; then
  echo "${ERROR} Failed to download token file.${RESET}"
  exit 1
fi
echo "${OK} Downloaded.${RESET}"
echo "${ACTION} Decrypting token...${RESET}"
if ! echo -n "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 -o "$DECRYPTED_FILE" -d "$TOKEN_FILE"; then
  echo "${ERROR} Failed to decrypt token.${RESET}"
  exit 1
fi
echo "${OK} Token decrypted.${RESET}"
GH_TOKEN=$(cat "$DECRYPTED_FILE")
rm -f "$DECRYPTED_FILE"
echo "${ACTION} Logging into GitHub CLI...${RESET}"
if ! gh auth login --with-token <<<"$GH_TOKEN"; then
  echo "${ERROR} GitHub CLI login failed.${RESET}"
  exit 1
fi
echo "${OK} GitHub CLI logged in.${RESET}"
# ===========================
# Verify GitHub Login
# ===========================
echo -e "\n${ACTION} Verifying GitHub login...${RESET}"
if gh auth status >/dev/null 2>&1; then
  echo -e "${OK} GitHub CLI is authenticated as: $(gh auth status | grep 'Logged in to' | awk '{print $NF}')${RESET}"
else
  echo -e "${ERROR} GitHub CLI is not logged in. Please run 'gh auth login'.${RESET}"
  exit 1
fi
# List GitHub Repositories
echo -e "\n${ACTION} Fetching list of your repositories...${RESET}"
if gh repo list --limit 10 >/tmp/repos.txt 2>/dev/null; then
  echo -e "${OK} Here are your top 10 repositories:${RESET}"
  cat /tmp/repos.txt
else
  echo -e "${ERROR} Failed to fetch repositories. Check GitHub authentication.${RESET}"
fi
# Optional GitHub CLI settings
gh config set git_protocol https
gh config set editor "$GIT_EDITOR"
echo -e "${OK} GitHub CLI config done.${RESET}"

# ===========================
# Rclone Setup
# ===========================

# Temp directory
TMP_DIR="/tmp" # reuse /tmp
mkdir -p "$TMP_DIR" is optional since /tmp always exists
download_and_decrypt() {
  local url="$1"
  local outfile="$2"
  local name="$3"
  echo "${ACTION} Downloading $name..."
  if ! curl -fsSL "$url" -o "$outfile.gpg" >>"$LOG_FILE" 2>&1; then
    echo "${ERROR} Failed to download $name. See log: $LOG_FILE"
    exit 1
  fi
  echo "${OK} $name downloaded."
  echo "${ACTION} Decrypting $name..."
  if ! echo -n "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 \
    -o "$outfile" -d "$outfile.gpg" >>"$LOG_FILE" 2>&1; then
    echo "${ERROR} Failed to decrypt $name. See log: $LOG_FILE"
    exit 1
  fi
  echo "${OK} $name decrypted."
}
# Download & decrypt all secrets
download_and_decrypt "$CLIENT_ID_URL" "$TMP_DIR/client_id" "Client ID"
download_and_decrypt "$CLIENT_SECRET_URL" "$TMP_DIR/client_secret" "Client Secret"
download_and_decrypt "$TOKEN_JSON_URL" "$TMP_DIR/token_json" "Token JSON"
CLIENT_ID=$(cat "$TMP_DIR/client_id")
CLIENT_SECRET=$(cat "$TMP_DIR/client_secret")
TOKEN_JSON=$(cat "$TMP_DIR/token_json")
# Ensure config directory exists
mkdir -p "$(dirname "$RCLONE_CONF")"
mkdir -p "$HOME/gdrive"
# Write rclone config
echo "${ACTION} Writing rclone config..."
cat >"$RCLONE_CONF" <<EOF
[$REMOTE_NAME]
type = drive
client_id = $CLIENT_ID
client_secret = $CLIENT_SECRET
scope = drive
token = $TOKEN_JSON
EOF
echo "${OK} rclone config created at: $RCLONE_CONF"
echo "${OK} Remote name: $REMOTE_NAME"
# Test connection
echo "${ACTION} Testing list of files in Google Drive..."
if rclone ls "$REMOTE_NAME:" >>"$LOG_FILE" 2>&1 | head -20; then
  echo "${OK} Connection successful."
else
  echo "${WARN} No files yet or connection issue. See log: $LOG_FILE"
fi
echo "${OK} Setup complete! You can now use 'rclone copy' or 'rclone mount' with $REMOTE_NAME"
echo "${NOTE} Detailed logs are saved at: $LOG_FILE"

echo -e "\n\n${OK} === Personal modifications applied locally. === ${RESET}"

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
