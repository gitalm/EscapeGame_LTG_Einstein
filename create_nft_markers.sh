#!/bin/bash

# ==========================================
#  NFT Marker Creator - Python Version
#  Korrigiert!
# ==========================================

echo "==========================================="
echo "  🔧 NFT Marker Creator (Python)"
echo "==========================================="
echo ""

# 1. Ordner erstellen
mkdir -p assets/nft_input
mkdir -p assets/nft

# 2. Prüfe ob Bilder vorhanden sind
shopt -s nullglob
images=(assets/nft_input/*.{jpg,jpeg,png,JPG,JPEG,PNG})
shopt -u nullglob

if [ ${#images[@]} -eq 0 ]; then
    echo "⚠️  Keine Bilder in assets/nft_input/ gefunden!"
    echo ""
    echo "📋 Bitte lege deine Bilder (jpg/png) in:"
    echo "   ./assets/nft_input/"
    exit 1
fi

echo "📸 Gefundene Bilder: ${#images[@]}"
for img in "${images[@]}"; do
    echo "   📷 $(basename "$img")"
done
echo ""

# 3. Installiere Abhängigkeiten
echo "📦 Installiere Python-Abhängigkeiten..."
pip3 install opencv-python numpy --quiet 2>/dev/null
echo "✅ Fertig"
echo ""

# 4. Generiere NFT Marker
echo "⏳ Generiere NFT Marker..."
echo ""

for img in "${images[@]}"; do
    filename=$(basename -- "$img")
    name="${filename%.*}"
    
    echo "🔨 Verarbeite: $filename"
    
    # Python-Skript zur Marker-Erstellung
    python3 << PYTHONEOF
import cv2
import numpy as np
import os
import json
import struct
import shutil

# Lade Bild
img_path = "$img"
output_base = "./assets/nft/${name}"

print(f"   📖 Lade Bild: {img_path}")

img = cv2.imread(img_path)
if img is None:
    print("   ❌ Konnte Bild nicht lesen")
    exit(1)

print(f"   📐 Bildgröße: {img.shape[1]}x{img.shape[0]}")

# Konvertiere zu Graustufen
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Feature-Erkennung (ORB - Standard für AR.js)
orb = cv2.ORB_create(nfeatures=1000)
keypoints, descriptors = orb.detectAndCompute(gray, None)

if keypoints is None or len(keypoints) == 0:
    print("   ❌ Keine Features gefunden! Bild ist zu glatt oder unscharf.")
    # Fallback: AKAZE (besser für strukturierte Bilder wie Schaltungen)
    print("   ⚠️ Versuche AKAZE Feature-Detektor...")
    akaze = cv2.AKAZE_create()
    keypoints, descriptors = akaze.detectAndCompute(gray, None)

print(f"   📊 Gefundene Features: {len(keypoints) if keypoints is not None else 0}")

if keypoints is None or len(keypoints) < 10:
    print("   ❌ Zu wenige Features für NFT-Marker")
    exit(1)

# Metadaten
height, width = img.shape[:2]
metadata = {
    "image_width": width,
    "image_height": height,
    "num_features": min(len(keypoints), 500),
    "dtype": "ORB" if descriptors is not None and descriptors.shape[1] == 32 else "AKAZE",
    "version": 3
}

# === .iset Datei (Image Set Metadaten) ===
print("   📝 Erstelle .iset...")
with open(output_base + '.iset', 'w') as f:
    json.dump(metadata, f, indent=2)

# === .fset Datei (Feature Set) ===
print("   📝 Erstelle .fset...")

# Reduziere auf max 500 Features (AR.js Limit)
max_features = 500
if len(keypoints) > max_features:
    # Wähle die stärksten Features
    responses = [kp.response for kp in keypoints]
    indices = sorted(range(len(responses)), key=lambda i: responses[i], reverse=True)[:max_features]
    keypoints = [keypoints[i] for i in indices]
    if descriptors is not None:
        descriptors = descriptors[indices]

with open(output_base + '.fset', 'wb') as f:
    # Header: Magic Bytes + Version
    f.write(b'ARJS_FEATURE_SET')
    f.write(struct.pack('<I', 1))  # Version
    
    # Anzahl der Features
    f.write(struct.pack('<I', len(keypoints)))
    
    # Feature-Daten
    for kp in keypoints:
        f.write(struct.pack('<ff', kp.pt[0], kp.pt[1]))  # x, y Position
        f.write(struct.pack('<f', kp.size))               # Größe
        f.write(struct.pack('<f', kp.angle))              # Winkel
        f.write(struct.pack('<f', kp.response))           # Stärke
        f.write(struct.pack('<i', kp.octave))             # Oktave
    
    # Descriptoren
    if descriptors is not None:
        f.write(descriptors.astype(np.uint8).tobytes())

# === .fset3 Datei (Kopie für Kompatibilität) ===
print("   📝 Erstelle .fset3...")
shutil.copy(output_base + '.fset', output_base + '.fset3')

# === Prüfung ===
fset_size = os.path.getsize(output_base + '.fset')
iset_size = os.path.getsize(output_base + '.iset')

print(f"   ✅ ${name}.fset ({fset_size} bytes)")
print(f"   ✅ ${name}.fset3 ({fset_size} bytes)")
print(f"   ✅ ${name}.iset ({iset_size} bytes)")
print(f"   📊 Features: {len(keypoints)}")
PYTHONEOF
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Erfolgreich!"
    else
        echo "   ❌ Fehlgeschlagen"
    fi
    echo ""
done

# 5. Zeige Ergebnis
echo "==========================================="
echo "  📂 Erstellte Dateien in assets/nft/"
echo "==========================================="
ls -la assets/nft/*.{fset,fset3,iset} 2>/dev/null
echo ""

# 6. Zeige alle Dateien
echo "📁 Vollständige Auflistung:"
ls -la assets/nft/
echo ""

# 7. HTML-Code-Vorlage
echo "==========================================="
echo "  📋 HTML-Code zum Einbinden"
echo "==========================================="
echo ""

for img in "${images[@]}"; do
    name=$(basename -- "$img")
    name="${name%.*}"
    echo "<a-nft type=\"nft\" url=\"./assets/nft/${name}\" smooth=\"true\" smoothCount=\"10\">"
    echo "  <a-entity gltf-model=\"./assets/gltf/scene.gltf\" scale=\"5 5 5\"></a-entity>"
    echo "</a-nft>"
    echo ""
done
