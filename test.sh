#!/bin/bash
set -e

# === Variables ===
RCLONE_CONF="$HOME/.config/rclone/rclone.conf"
REMOTE_NAME="gdrive"
CLIENT_ID=""
CLIENT_SECRET=""

TOKEN_JSON=''

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
