#!/bin/bash

# Ordner erstellen, falls nicht vorhanden
mkdir -p qr_codes

# Liste der IDs
ids=("0" "1" "2" "3")

echo "Generiere QR-Codes..."

for id in "${ids[@]}"; do
    filename="qr_codes/target_$id.png"
    data="physik-escape-$id"
    
    # -s: Größe der Pixel (höher = größer)
    # -o: Output Datei
    qrencode -s 10 -o "$filename" "$data"
    
    echo "Erstellt: $filename (Inhalt: $data)"
done

echo "Fertig! Alle QR-Codes liegen im Ordner 'qr_codes'."
