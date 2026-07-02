#!/bin/bash

echo "🔍 Erstelle korrigierte Debug-Testseite..."

cat > debug_test.html << 'HTMLEND'
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>🧪 Physik Escape - Debug</title>
  
  <!-- BIBLIOTHEKEN HIER LADEN (wichtig für die Prüfung!) -->
  <script src="./aframe.min.js"></script>
  <script src="./aframe-ar-nft.js.js"></script>
  <script src="./three.min.js.js"></script>
  <script src="./jsQR.js"></script>
  
  <style>
    body { font-family: sans-serif; background: #1a1a2e; color: #fff; padding: 20px; }
    h1 { color: #4fc3f7; }
    .card { background: rgba(255,255,255,0.08); border: 1px solid #4fc3f7; border-radius: 15px; padding: 15px; margin: 15px 0; }
    .ok { color: #66bb6a; }
    .missing { color: #ef5350; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; }
    .badge { display: inline-block; padding: 3px 10px; border-radius: 10px; font-size: 0.8em; margin: 2px; }
    .badge-ok { background: #66bb6a; color: #000; }
    .badge-missing { background: #ef5350; }
    table { width: 100%; border-collapse: collapse; margin: 10px 0; }
    th, td { padding: 6px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.1); }
    img { max-width: 200px; border-radius: 8px; }
    .btn { background: #4fc3f7; color: #000; border: none; padding: 8px 20px; border-radius: 20px; font-weight: bold; cursor: pointer; margin: 3px; }
  </style>
</head>
<body>

  <h1>🧪 Physik Escape - Debug</h1>

  <!-- BIBLIOTHEKEN STATUS -->
  <div class="card">
    <h2>📦 Bibliotheken (Datei + Lade-Status)</h2>
    <div id="libStatus"></div>
  </div>

  <!-- NFT MARKER -->
  <div class="card">
    <h2>🏷️ NFT Marker (assets/nft/)</h2>
    <div id="nftStatus">Prüfe...</div>
  </div>

  <!-- DATEIEN -->
  <div class="card">
    <h2>📁 Dateien</h2>
    <div class="grid" id="fileGrid"></div>
  </div>

  <!-- FRAGEN -->
  <div class="card">
    <h2>📝 Fragen aus data.json</h2>
    <div id="questionStatus">Lade...</div>
  </div>

  <!-- QR-CODES -->
  <div class="card">
    <h2>📱 QR-Codes</h2>
    <div class="grid" id="qrGrid"></div>
  </div>

  <script>
    // ==========================================
    // 1. BIBLIOTHEKEN PRÜFEN
    // ==========================================
    
    function checkLibraries() {
      const container = document.getElementById('libStatus');
      
      const libs = [
        { 
          name: 'A-Frame', 
          file: 'aframe.min.js',
          loaded: () => typeof AFRAME !== 'undefined',
          version: () => { try { return AFRAME.version; } catch(e) { return '?'; } }
        },
        { 
          name: 'AR.js NFT', 
          file: 'aframe-ar-nft.js.js',
          loaded: () => { 
            try { return typeof AFRAME !== 'undefined' && AFRAME.components && 'nft' in AFRAME.components; } 
            catch(e) { return false; } 
          },
          version: () => { try { return 'NFT verfügbar'; } catch(e) { return '?'; } }
        },
        { 
          name: 'Three.js', 
          file: 'three.min.js.js',
          loaded: () => typeof THREE !== 'undefined',
          version: () => { try { return THREE.REVISION; } catch(e) { return '?'; } }
        },
        { 
          name: 'jsQR', 
          file: 'jsQR.js',
          loaded: () => typeof jsQR !== 'undefined',
          version: () => { try { return 'verfügbar'; } catch(e) { return '?'; } }
        }
      ];
      
      let html = '<table><tr><th>Bibliothek</th><th>Datei</th><th>Geladen?</th><th>Version</th></tr>';
      
      libs.forEach(lib => {
        const loaded = lib.loaded();
        html += `<tr>
          <td><strong>${lib.name}</strong></td>
          <td style="font-family:monospace;">${lib.file}</td>
          <td class="${loaded ? 'ok' : 'missing'}">${loaded ? '✅ Geladen' : '❌ Nicht geladen'}</td>
          <td>${lib.version()}</td>
        </tr>`;
      });
      
      html += '</table>';
      container.innerHTML = html;
    }

    // ==========================================
    // 2. NFT MARKER PRÜFEN
    // ==========================================
    
    async function checkNFT() {
      const container = document.getElementById('nftStatus');
      
      const files = [
        { name: 'schaltung.fset',  path: './assets/nft/schaltung.fset' },
        { name: 'schaltung.fset3', path: './assets/nft/schaltung.fset3' },
        { name: 'schaltung.iset',  path: './assets/nft/schaltung.iset' }
      ];
      
      let html = '';
      let allOk = true;
      
      for (const f of files) {
        try {
          const res = await fetch(f.path, { method: 'HEAD' });
          if (res.ok) {
            html += `<span class="badge badge-ok">✅ ${f.name}</span> `;
          } else {
            html += `<span class="badge badge-missing">❌ ${f.name}</span> `;
            allOk = false;
          }
        } catch(e) {
          html += `<span class="badge badge-missing">❌ ${f.name} (kein Zugriff)</span> `;
          allOk = false;
        }
      }
      
      html += `<br><br><strong>${allOk ? '✅ NFT Marker komplett (3/3)' : '❌ NFT Marker unvollständig'}</strong>`;
      container.innerHTML = html;
    }

    // ==========================================
    // 3. DATEIEN PRÜFEN (mit fetch)
    // ==========================================
    
    async function checkFiles() {
      const grid = document.getElementById('fileGrid');
      
      const categories = [
        {
          title: '📦 Bibliotheken',
          files: [
            { name: 'aframe.min.js', path: './aframe.min.js' },
            { name: 'aframe-ar-nft.js.js', path: './aframe-ar-nft.js.js' },
            { name: 'three.min.js.js', path: './three.min.js.js' },
            { name: 'jsQR.js', path: './jsQR.js' }
          ]
        },
        {
          title: '📊 Daten',
          files: [
            { name: 'data.json', path: './data.json' }
          ]
        },
        {
          title: '🧑‍🔬 Einstein 3D',
          files: [
            { name: 'scene.gltf', path: './assets/gltf/scene.gltf' },
            { name: 'scene.bin', path: './assets/gltf/scene.bin' },
            { name: 'BaseColor.png', path: './assets/gltf/textures/Material.001_baseColor.png' },
            { name: 'Normal.png', path: './assets/gltf/textures/Material.001_normal.png' }
          ]
        },
        {
          title: '🏷️ NFT Marker',
          files: [
            { name: 'schaltung.fset', path: './assets/nft/schaltung.fset' },
            { name: 'schaltung.fset3', path: './assets/nft/schaltung.fset3' },
            { name: 'schaltung.iset', path: './assets/nft/schaltung.iset' }
          ]
        },
        {
          title: '📱 QR-Codes',
          files: [
            { name: 'target_0.png', path: './qr_codes/target_0.png' },
            { name: 'target_1.png', path: './qr_codes/target_1.png' },
            { name: 'target_2.png', path: './qr_codes/target_2.png' },
            { name: 'target_3.png', path: './qr_codes/target_3.png' }
          ]
        }
      ];
      
      for (const cat of categories) {
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `<h3>${cat.title}</h3>`;
        
        for (const file of cat.files) {
          const div = document.createElement('div');
          div.style.display = 'flex';
          div.style.alignItems = 'center';
          div.style.gap = '10px';
          div.style.padding = '5px 0';
          
          try {
            const res = await fetch(file.path, { method: 'HEAD' });
            if (res.ok) {
              div.innerHTML = `<span class="ok">✅</span> <span style="font-family:monospace;flex-grow:1;">${file.name}</span> <span class="badge badge-ok">OK</span>`;
            } else {
              div.innerHTML = `<span class="missing">❌</span> <span style="font-family:monospace;flex-grow:1;">${file.name}</span> <span class="badge badge-missing">Fehlt</span>`;
            }
          } catch(e) {
            div.innerHTML = `<span class="missing">❌</span> <span style="font-family:monospace;flex-grow:1;">${file.name}</span> <span class="badge badge-missing">Kein Zugriff</span>`;
          }
          
          card.appendChild(div);
        }
        
        grid.appendChild(card);
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
          container.innerHTML = '<p class="missing">❌ Keine Targets in data.json!</p>';
          return;
        }
        
        let html = `<p>✅ ${data.targets.length} Targets gefunden</p>`;
        
        data.targets.forEach(target => {
          html += `
            <div style="margin:10px 0;padding:10px;background:rgba(255,255,255,0.05);border-radius:8px;">
              <strong>${target.icon || '📍'} ${target.name}</strong> - ${target.questions ? target.questions.length : 0} Fragen
              <table>
                <tr><th>#</th><th>Frage</th><th>Antworten</th><th>Richtig</th><th>Tipp</th></tr>
                ${(target.questions || []).map((q, i) => `
                  <tr>
                    <td>${i+1}</td>
                    <td>${q.question.substring(0, 35)}...</td>
                    <td>${q.answers.length}</td>
                    <td class="ok">${q.answers[q.correct]}</td>
                    <td style="color:#ffa726;">${q.hint || '-'}</td>
                  </tr>
                `).join('')}
              </table>
            </div>`;
        });
        
        container.innerHTML = html;
      } catch(e) {
        container.innerHTML = `<p class="missing">❌ Fehler: ${e.message}</p>`;
      }
    }

    // ==========================================
    // 5. QR-CODES ANZEIGEN
    // ==========================================
    
    function showQRCodes() {
      const grid = document.getElementById('qrGrid');
      const names = ['Magnetismus 🧲', 'Stromkreise ⚡', 'Optik 🔦', 'Farben 🌈'];
      
      for (let i = 0; i < 4; i++) {
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `
          <h3>Target ${i}: ${names[i]}</h3>
          <img src="./qr_codes/target_${i}.png" onerror="this.outerHTML='<p class=\\'missing\\'>❌ QR-Code target_${i}.png fehlt</p>'">
          <p style="color:#aaa;font-size:0.8em;">qr_codes/target_${i}.png</p>
        `;
        grid.appendChild(card);
      }
    }

    // ==========================================
    // START
    // ==========================================
    
    document.addEventListener('DOMContentLoaded', () => {
      // Wichtig: Kurze Verzögerung, damit Bibliotheken geladen sind
      setTimeout(() => {
        checkLibraries();
        checkNFT();
        checkFiles();
        loadQuestions();
        showQRCodes();
      }, 500);
      
      console.log('🔍 Debug-Seite gestartet');
    });
  </script>
</body>
</html>
HTMLEND

echo "✅ Debug-Seite erstellt: debug_test.html"
echo ""
echo "📋 Server starten: python3 -m http.server 8000"
echo "🌐 Browser: http://localhost:8000/debug_test.html"
