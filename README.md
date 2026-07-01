# EscapeGame_LTG_Einstein

Ein interaktives **Augmented Reality (AR) Escape Game** für den Physikunterricht.

Die Schüler:innen suchen mit dem Smartphone nach versteckten Target-Bildern im Schulhaus. Wird ein Target gefunden, erscheint **Albert Einstein** als 3D-Modell und stellt eine Physik-Frage. Nur wer alle Fragen richtig beantwortet, entkommt! 🎉

---

## 📱 Spielanleitung

### Für Lehrkräfte – Vorbereitung

1. **Target-Bilder ausdrucken**
   - Erstelle 3–5 hochkontrastreiche Bilder (Schachbrettmuster, bunte Formen, QR-ähnliche Designs)
   - Drucke sie auf DIN A4 aus und laminiere sie (optional)
   - Verteile sie an verschiedenen Stationen im Schulhaus
   - **Tipp:** Die Bilder sollten nicht zu symmetrisch sein und viele Ecken/Kanten haben

2. **targets.mind erstellen**
   - Gehe auf: https://hiukim.github.io/mind-ar-js-doc/tools/compile
   - Lade deine Target-Bilder hoch
   - Klicke auf "Compile" → lade `targets.mind` herunter
   - Lege die Datei in den Hauptordner des Projekts

3. **3D-Modell vorbereiten**
   - Lade das Einstein-Modell herunter: https://sketchfab.com/3d-models/toon-albert-einstein-animated-719cafaad4b94a4ea13b5a23e66075a5
   - Entpacke die ZIP-Datei in einen Ordner (z. B. `einstein/` oder `assets/einstein/`)
   - Die Struktur sollte sein: `ordnername/scene.gltf`, `ordnername/scene.bin`, `ordnername/textures/`

4. **Auf GitHub hosten**
   - Alle Dateien in ein Repository laden
   - GitHub Pages aktivieren (Settings → Pages → Branch: main → / (root))
   - Nach 1–2 Minuten ist die App live unter: `https://deinname.github.io/EscapeGame_LTG_Einstein/`

5. **QR-Code erstellen**
   - Generiere einen QR-Code, der auf die GitHub Pages URL zeigt
   - Hänge den QR-Code im Schulhaus auf (z. B. am Physiksaal-Eingang)

### Für Schüler:innen – Spielablauf

1. QR-Code mit dem Handy scannen
2. Kamera-Zugriff erlauben
3. Durch das Schulhaus gehen und nach den Target-Bildern suchen
4. Handy auf ein Target-Bild halten → **Einstein erscheint!** 🧑‍🔬
5. Physik-Frage lesen und Antwort auswählen
6. Bei richtiger Antwort: weiter zum nächsten Target
7. Bei falscher Antwort: nochmal versuchen
8. Alle Fragen richtig → **ESCAPE!** 🏆

---

## 📁 Dateistruktur
