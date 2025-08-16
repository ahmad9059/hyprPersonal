#!/bin/bash
set -e

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
