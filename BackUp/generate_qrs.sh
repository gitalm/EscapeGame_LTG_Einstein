#!/bin/bash
# Verzeichnis für QR-Codes in assets anlegen
mkdir -p assets/qr_codes

ids=("0" "1" "2" "3")
echo "Generiere QR-Codes nach assets/qr_codes/..."

for id in "${ids[@]}"; do
    qrencode -s 10 -o "assets/qr_codes/target_$id.png" "physik-escape-$id"
done
echo "Fertig."
