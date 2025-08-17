# ===========================
# Apply personal changes (reverse from GitHub state)
# ===========================
echo "${NOTE} Applying personal local modifications...${RESET}"

# 1. Restore kb_options in UserSettings.conf
USERS_CONF="$HOME/dotfiles/.config/hypr/UserConfigs/UserSettings.conf"
if [ -f "$USERS_CONF" ]; then
  sed -i 's/kb_options = $/kb_options = ctrl:nocaps/' "$USERS_CONF"
fi

# 2. Restore hyprland.conf label block (LC_TIME and font_family)
HYPR_CONF="$HOME/dotfiles/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
  sed -i 's/LC_TIME=en_US.UTF-8/LC_TIME=ur_PK.UTF-8/' "$HYPR_CONF"
  sed -i 's/SF Pro Display Semibold/Noto Nastaliq Urdu/' "$HYPR_CONF"
fi

echo "${OK} Personal modifications applied locally.${RESET}"
