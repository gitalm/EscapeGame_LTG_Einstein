#!/bin/bash
# Installiere erst: npm install -g nft-marker-creator
echo "Generiere NFT Marker..."
mkdir -p assets/nft/output

for img in assets/nft/source/*.png; do
    echo "Verarbeite $img..."
    # Generiert Dateien im aktuellen Ordner
    nft-marker-creator -i "$img"
    # Verschieben in output
    mv *.fset *.fset3 *.iset assets/nft/output/
done
echo "Fertig! Dateien liegen in assets/nft/output/"
