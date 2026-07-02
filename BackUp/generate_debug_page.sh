#!/bin/bash

echo "🔍 Erstelle korrigierte Debug-Testseite..."

cat > debug_test.html << 'HTMLEND'
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>🧪 Physik Escape - Debug</title>
  
  <!-- BIBLIOTHEKEN -->
  <script src="./aframe.min.js"></script>
  <script src="./aframe-ar-nft.js"></script>
  <script src="./three.min.js.js"></script>
  <script src="./jsQR.js"></script>
  
  <style>
    body { font-family: sans-serif; background: #1a1a2e; color: #fff; padding: 20px; }
    h1 { color: #4fc3f7; }
    .card { background: rgba(255,255,255,0.08); border: 1px solid #4fc3f7; border-radius: 15px; padding: 15px; margin: 15px 0; }
    .ok { color: #66bb6a; }
    .missing { color: #ef5350; }
    .warn { color: #ffa726; }
    table { width: 100%; border-collapse: collapse; margin: 10px 0; }
    th, td { padding: 8px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.1); }
    .badge { display: inline-block; padding: 3px 10px; border-radius: 10px; font-size: 0.8em; margin: 2px; }
    .badge-ok { background: #66bb6a; color: #000; }
    .badge-missing { background: #ef5350; }
    img { max-width: 200px; border-radius: 8px; }
  </style>
</head>
<body>

  <h1>🧪 Physik Escape - Debug Konsole</h1>

  <!-- BIBLIOTHEKEN -->
  <div class="card">
    <h2>📦 Bibliotheken</h2>
    <table id="libTable">
      <tr><th>Bibliothek</th><th>Geladen?</th><th>Details</th></tr>
    </table>
  </div>

  <!-- NFT MARKER -->
  <div class="card">
    <h2>🏷️ NFT Marker</h2>
    <div id="nftStatus">⏳ Prüfe...</div>
  </div>

  <!-- DATEIEN -->
  <div class="card">
    <h2>📁 Dateien</h2>
    <table id="fileTable">
      <tr><th>Datei</th><th>Status</th></tr>
    </table>
  </div>

  <!-- FRAGEN -->
  <div class="card">
    <h2>📝 Fragen</h2>
    <div id="questionStatus">⏳ Lade...</div>
  </div>

  <script>
    // ==========================================
    // 1. BIBLIOTHEKEN PRÜFEN (VERBESSERT)
    // ==========================================
    
    function checkLibraries() {
      const table = document.getElementById('libTable');
      
      const checks = [
        {
          name: 'A-Frame',
          loaded: () => typeof AFRAME !== 'undefined',
          detail: () => { try { return 'Version ' + AFRAME.version; } catch(e) { return '❌'; } }
        },
        {
          name: 'Three.js',
          loaded: () => typeof THREE !== 'undefined',
          detail: () => { try { return 'Revision r' + THREE.REVISION; } catch(e) { return '❌'; } }
        },
        {
          name: 'jsQR',
          loaded: () => typeof jsQR !== 'undefined',
          detail: () => { try { return '✅ Verfügbar'; } catch(e) { return '❌'; } }
        }
      ];
      
      // AR.js NFT speziell prüfen
      let arjsLoaded = false;
      let arjsDetail = '❌ Nicht geladen';
      
      try {
        if (typeof AFRAME !== 'undefined') {
          // Prüfe ob AR.js Komponenten registriert sind
          const registeredComponents = Object.keys(AFRAME.components || {});
          arjsLoaded = registeredComponents.includes('nft') || 
                       registeredComponents.some(c => c.includes('ar') || c.includes('nft'));
          
          if (arjsLoaded) {
            arjsDetail = '✅ NFT-Komponente gefunden';
          } else {
            arjsDetail = '❌ Keine NFT-Komponente (AR.js geladen? Datei: aframe-ar-nft.js)';
          }
        }
      } catch(e) {
        arjsDetail = '❌ Fehler: ' + e.message;
      }
      
      // Tabelle füllen
      checks.forEach(c => {
        const ok = c.loaded();
        const row = table.insertRow();
        row.innerHTML = `
          <td><strong>${c.name}</strong></td>
          <td class="${ok ? 'ok' : 'missing'}">${ok ? '✅ Geladen' : '❌ Fehlt'}</td>
          <td>${c.detail()}</td>
        `;
      });
      
      // AR.js NFT separat
      const row = table.insertRow();
      row.innerHTML = `
        <td><strong>AR.js NFT</strong></td>
        <td class="${arjsLoaded ? 'ok' : 'missing'}">${arjsLoaded ? '✅ Geladen' : '❌ Fehlt'}</td>
        <td>${arjsDetail}</td>
      `;
      
      if (!arjsLoaded) {
        console.warn('AR.js NFT nicht geladen! Mögliche Ursachen:');
        console.warn('- Datei existiert nicht als ./aframe-ar-nft.js');
        console.warn('- Falsche Datei (Marker statt NFT Version)');
        console.warn('- CORS-Probleme bei lokaler Datei');
      }
    }

    // ==========================================
    // 2. NFT MARKER PRÜFEN
    // ==========================================
    
    async function checkNFT() {
      const container = document.getElementById('nftStatus');
      
      // ALLE möglichen Pfade prüfen (wg. Groß-/Kleinschreibung)
      const paths = [
        // Korrekte Pfade
        { name: 'schaltung.fset', path: './assets/nft/schaltung.fset' },
        { name: 'schaltung.fset3', path: './assets/nft/schaltung.fset3' },
        { name: 'schaltung.iset', path: './assets/nft/schaltung.iset' },
        // Alternative (falls in falschem Ordner)
        { name: 'schaltung.fset (alt)', path: './nft/schaltung.fset' },
        { name: 'schaltung.fset (root)', path: './schaltung.fset' }
      ];
      
      let html = '';
      let foundCount = 0;
      
      for (const f of paths) {
        try {
          const res = await fetch(f.path, { method: 'HEAD' });
          if (res.ok) {
            html += `<span class="badge badge-ok">✅ ${f.name}</span>\n`;
            foundCount++;
          } else {
            html += `<span style="color:#666;">❌ ${f.name}</span>\n`;
          }
        } catch(e) {
          html += `<span style="color:#666;">❌ ${f.name} (Fehler)</span>\n`;
        }
      }
      
      html += `<br><br>`;
      if (foundCount >= 3) {
        html += `<strong class="ok">✅ NFT Marker gefunden (${foundCount}/3+)</strong>`;
      } else {
        html += `<strong class="missing">❌ NFT Marker unvollständig (${foundCount}/3 benötigt)</strong>`;
        html += `<br><br>📁 Bitte prüfe: ls -la assets/nft/`;
      }
      
      container.innerHTML = html;
    }

    // ==========================================
    // 3. DATEIEN PRÜFEN
    // ==========================================
    
    async function checkFiles() {
      const table = document.getElementById('fileTable');
      
      // Wichtige Dateien aus deinem ls -R
      const files = [
        { name: 'aframe.min.js', path: './aframe.min.js' },
        { name: 'aframe-ar-nft.js', path: './aframe-ar-nft.js' },
        { name: 'three.min.js.js', path: './three.min.js.js' },
        { name: 'jsQR.js', path: './jsQR.js' },
        { name: 'data.json', path: './data.json' },
        { name: 'scene.gltf', path: './assets/gltf/scene.gltf' },
        { name: 'schaltung.fset', path: './assets/nft/schaltung.fset' },
        { name: 'schaltung.fset3', path: './assets/nft/schaltung.fset3' },
        { name: 'schaltung.iset', path: './assets/nft/schaltung.iset' },
        { name: 'target_0.png', path: './qr_codes/target_0.png' },
        { name: 'target_1.png', path: './qr_codes/target_1.png' },
        { name: 'target_2.png', path: './qr_codes/target_2.png' },
        { name: 'target_3.png', path: './qr_codes/target_3.png' }
      ];
      
      for (const f of files) {
        try {
          const res = await fetch(f.path, { method: 'HEAD' });
          const row = table.insertRow();
          if (res.ok) {
            row.innerHTML = `<td style="font-family:monospace;">${f.name}</td><td class="ok">✅ OK</td>`;
          } else {
            row.innerHTML = `<td style="font-family:monospace;">${f.name}</td><td class="missing">❌ Fehlt (${res.status})</td>`;
          }
        } catch(e) {
          const row = table.insertRow();
          row.innerHTML = `<td style="font-family:monospace;">${f.name}</td><td class="missing">❌ Kein Zugriff</td>`;
        }
      }
    }

    // ==========================================
    // 4. FRAGEN LADEN
    // ==========================================
    
    async function loadQuestions() {
      const container = document.getElementById('questionStatus');
      
      try {
        const res = await fetch('./data.json');
        const data = await res.json();
        
        if (!data.targets || data.targets.length === 0) {
          container.innerHTML = '<p class="missing">❌ Keine Targets!</p>';
          return;
        }
        
        let html = `<p class="ok">✅ ${data.targets.length} Targets</p>`;
        let total = 0;
        
        data.targets.forEach(t => {
          const qCount = (t.questions || []).length;
          total += qCount;
          html += `
            <div style="margin:5px 0;background:rgba(255,255,255,0.05);padding:8px;border-radius:5px;">
              <strong>${t.icon} ${t.name}</strong> — ${qCount} Fragen
            </div>`;
        });
        
        html += `<p><strong class="ok">Gesamt: ${total} Fragen</strong></p>`;
        container.innerHTML = html;
        
      } catch(e) {
        container.innerHTML = `<p class="missing">❌ ${e.message}</p>`;
      }
    }

    // ==========================================
    // START
    // ==========================================
    
    document.addEventListener('DOMContentLoaded', () => {
      setTimeout(() => {
        checkLibraries();
        checkNFT();
        checkFiles();
        loadQuestions();
      }, 1000);
    });
  </script>
</body>
</html>
HTMLEND

echo "✅ Debug-Seite erstellt!"
echo ""
echo "📋 Server: python3 -m http.server 8000"
echo "🌐 Browser: http://localhost:8000/debug_test.html"
