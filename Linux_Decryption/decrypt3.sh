#!/bin/bash

DESKTOP="$HOME/Desktop"
TEMP_PRIVKEY="/tmp/temp_priv.pem"

# === Write hardcoded RSA PRIVATE KEY ===
cat > "$TEMP_PRIVKEY" <<EOF
-----BEGIN RSA PRIVATE KEY-----
put your private key in here 
-----END RSA PRIVATE KEY-----
EOF

echo "[+] Starting decryption..."

for ENC_FILE in "$DESKTOP"/*.pdf.enc "$DESKTOP"/*.png.enc; do
    [ -f "$ENC_FILE" ] || continue

    BASENAME="${ENC_FILE%.enc}"
    KEY_FILE="$BASENAME.key.enc"
    OUT_FILE="${BASENAME##*/}"

    if [ ! -f "$KEY_FILE" ]; then
        echo "[!] Key file not found for $ENC_FILE"
        continue
    fi

    echo "[+] Decrypting: $ENC_FILE"

    openssl pkeyutl -decrypt -inkey "$TEMP_PRIVKEY" -pkeyopt rsa_padding_mode:oaep \
        -in "$KEY_FILE" -out "$BASENAME.kiv.bin"

    dd if="$BASENAME.kiv.bin" bs=1 count=32 of="$BASENAME.key.bin" 2>/dev/null
    dd if="$BASENAME.kiv.bin" bs=1 skip=32 count=16 of="$BASENAME.iv.bin" 2>/dev/null

    openssl enc -d -aes-256-cbc -in "$ENC_FILE" -out "$DESKTOP/$OUT_FILE" \
        -K "$(xxd -p "$BASENAME.key.bin" | tr -d '\n')" \
        -iv "$(xxd -p "$BASENAME.iv.bin" | tr -d '\n')"

    echo "[✔] Decrypted to $OUT_FILE"

    # Cleanup
    rm -f "$BASENAME.kiv.bin" "$BASENAME.key.bin" "$BASENAME.iv.bin" "$ENC_FILE" "$KEY_FILE"
done

rm -f "$TEMP_PRIVKEY"
echo "[✔] All decryption complete."
