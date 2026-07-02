#!/bin/bash

echo "🔍 Erstelle korrigierte Debug-Testseite..."

cat > debug_test.html << 'HTMLEND'
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>🧪 Physik Escape - Debug</title>
  
  <!-- BIBLIOTHEKEN MIT RICHTIGEN DATEINAMEN -->
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
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; }
    .badge { display: inline-block; padding: 3px 10px; border-radius: 10px; font-size: 0.8em; margin: 2px; }
    .badge-ok { background: #66bb6a; color: #000; }
    .badge-missing { background: #ef5350; }
    .badge-warn { background: #ffa726; color: #000; }
    table { width: 100%; border-collapse: collapse; margin: 10px 0; font-size: 0.9em; }
    th, td { padding: 6px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.1); }
    img { max-width: 200px; border-radius: 8px; }
    .btn { background: #4fc3f7; color: #000; border: none; padding: 8px 20px; border-radius: 20px; font-weight: bold; cursor: pointer; margin: 3px; }
    .summary { display: flex; gap: 20px; flex-wrap: wrap; }
    .summary-item { background: rgba(255,255,255,0.05); padding: 10px 15px; border-radius: 10px; }
    .summary-item .number { font-size: 1.5em; font-weight: bold; }
    .file-row { display: flex; align-items: center; gap: 10px; padding: 5px 0; }
  </style>
</head>
<body>

  <h1>🧪 Physik Escape - Debug Konsole</h1>
  
  <!-- ZUSAMMENFASSUNG -->
  <div class="card summary">
    <div class="summary-item">
      <div class="number ok" id="countFilesOk">0</div>
      <div>✅ Dateien OK</div>
    </div>
    <div class="summary-item">
      <div class="number missing" id="countFilesMissing">0</div>
      <div>❌ Fehlen</div>
    </div>
    <div class="summary-item">
      <div class="number ok" id="countNFT">0</div>
      <div>🏷️ NFT Marker</div>
    </div>
    <div class="summary-item">
      <div class="number ok" id="countQuestions">0</div>
      <div>📝 Fragen</div>
    </div>
  </div>

  <!-- BIBLIOTHEKEN STATUS -->
  <div class="card">
    <h2>📦 Bibliotheken</h2>
    <table id="libTable">
      <tr><th>Bibliothek</th><th>Datei</th><th>Status</th><th>Version</th></tr>
    </table>
  </div>

  <!-- DATEIEN -->
  <div class="card">
    <h2>📁 Datei-Check</h2>
    <div class="grid" id="fileGrid"></div>
  </div>

  <!-- NFT MARKER -->
  <div class="card">
    <h2>🏷️ NFT Marker (assets/nft/)</h2>
    <div id="nftStatus">⏳ Prüfe NFT Marker...</div>
  </div>

  <!-- FRAGEN -->
  <div class="card">
    <h2>📝 Fragen aus data.json</h2>
    <div id="questionStatus">⏳ Lade Fragen...</div>
  </div>

  <!-- QR-CODES -->
  <div class="card">
    <h2>📱 QR-Codes</h2>
    <div class="grid" id="qrGrid"></div>
  </div>

  <script>
    // Stats
    const stats = { ok: 0, missing: 0 };
    
    function updateStats() {
      document.getElementById('countFilesOk').textContent = stats.ok;
      document.getElementById('countFilesMissing').textContent = stats.missing;
    }

    // ==========================================
    // 1. BIBLIOTHEKEN
    // ==========================================
    
    function checkLibraries() {
      const table = document.getElementById('libTable');
      
      // Die Dateinamen aus deinem ls -R
      const libs = [
        { 
          name: 'A-Frame', 
          file: 'aframe.min.js',
          loaded: () => typeof AFRAME !== 'undefined',
          version: () => { try { return AFRAME.version; } catch(e) { return '?'; } }
        },
        { 
          name: 'AR.js NFT', 
          file: 'aframe-ar-nft.js',
          loaded: () => { 
            try { 
              return typeof AFRAME !== 'undefined' && 
                     AFRAME.components && 
                     'nft' in AFRAME.components; 
            } catch(e) { return false; } 
          },
          version: () => { 
            try { 
              if (typeof AFRAME !== 'undefined' && AFRAME.components && 'nft' in AFRAME.components) {
                return 'NFT ✅'; 
              }
              return 'NFT ❌';
            } catch(e) { return '?'; } 
          }
        },
        { 
          name: 'Three.js', 
          file: 'three.min.js.js',
          loaded: () => typeof THREE !== 'undefined',
          version: () => { try { return 'r' + THREE.REVISION; } catch(e) { return '?'; } }
        },
        { 
          name: 'jsQR', 
          file: 'jsQR.js',
          loaded: () => typeof jsQR !== 'undefined',
          version: () => { try { return 'verfügbar'; } catch(e) { return '?'; } }
        }
      ];
      
      libs.forEach(lib => {
        const loaded = lib.loaded();
        const row = table.insertRow();
        row.innerHTML = `
          <td><strong>${lib.name}</strong></td>
          <td style="font-family:monospace;">${lib.file}</td>
          <td class="${loaded ? 'ok' : 'missing'}">${loaded ? '✅ Geladen' : '❌ Fehlt'}</td>
          <td>${lib.version()}</td>
        `;
        
        if (loaded) stats.ok++; else stats.missing++;
      });
      
      updateStats();
    }

    // ==========================================
    // 2. DATEIEN PRÜFEN
    // ==========================================
    
    async function checkFiles() {
      const grid = document.getElementById('fileGrid');
      
      const categories = [
        {
          title: '📦 Bibliotheken',
          files: [
            { name: 'aframe.min.js', path: './aframe.min.js' },
            { name: 'aframe-ar-nft.js', path: './aframe-ar-nft.js' },
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
            { name: 'Normal.png', path: './assets/gltf/textures/Material.001_normal.png' },
            { name: 'Metallic.png', path: './assets/gltf/textures/Material.001_metallicRoughness.png' }
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
          title: '🏷️ Pattern (.patt)',
          files: [
            { name: 'pattern-magnet.patt', path: './assets/patt/pattern-magnet.patt' },
            { name: 'pattern-optik.patt', path: './assets/patt/pattern-optik.patt' },
            { name: 'pattern-farbe.patt', path: './assets/patt/pattern-farbe.patt' },
            { name: 'pattern-parallelschaltung.patt', path: './assets/patt/pattern-parallelschaltung.patt' }
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
          div.className = 'file-row';
          
          try {
            const res = await fetch(file.path, { method: 'HEAD' });
            if (res.ok) {
              stats.ok++;
              div.innerHTML = `<span class="ok">✅</span> <span style="font-family:monospace;flex-grow:1;">${file.name}</span> <span class="badge badge-ok">OK</span>`;
            } else {
              stats.missing++;
              div.innerHTML = `<span class="missing">❌</span> <span style="font-family:monospace;flex-grow:1;">${file.name}</span> <span class="badge badge-missing">Fehlt</span>`;
            }
          } catch(e) {
            stats.missing++;
            div.innerHTML = `<span class="missing">❌</span> <span style="font-family:monospace;flex-grow:1;">${file.name}</span> <span class="badge badge-missing">Kein Zugriff</span>`;
          }
          
          updateStats();
          card.appendChild(div);
        }
        
        grid.appendChild(card);
      }
    }

    // ==========================================
    // 3. NFT MARKER
    // ==========================================
    
    async function checkNFT() {
      const container = document.getElementById('nftStatus');
      
      const files = [
        { name: 'schaltung.fset', path: './assets/nft/schaltung.fset' },
        { name: 'schaltung.fset3', path: './assets/nft/schaltung.fset3' },
        { name: 'schaltung.iset', path: './assets/nft/schaltung.iset' }
      ];
      
      let allOk = true;
      let html = '';
      
      for (const f of files) {
        try {
          const res = await fetch(f.path, { method: 'HEAD' });
          if (res.ok) {
            html += `✅ ${f.name} `;
          } else {
            html += `❌ ${f.name} `;
            allOk = false;
          }
        } catch(e) {
          html += `❌ ${f.name} (kein Zugriff) `;
          allOk = false;
        }
      }
      
      html += `<br><br><span class="${allOk ? 'ok' : 'missing'}">
        <strong>${allOk ? '✅ NFT Marker komplett' : '❌ NFT Marker unvollständig'}</strong>
      </span>`;
      
      container.innerHTML = html;
      document.getElementById('countNFT').textContent = allOk ? 3 : files.filter((_,i) => html.includes(`✅ ${files[i]?.name}`)).length;
    }

    // ==========================================
    // 4. FRAGEN
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
        
        let totalQuestions = 0;
        let html = `<p class="ok">✅ ${data.targets.length} Targets gefunden</p>`;
        
        data.targets.forEach(target => {
          const qCount = target.questions ? target.questions.length : 0;
          totalQuestions += qCount;
          
          html += `
            <div style="margin:10px 0;padding:10px;background:rgba(255,255,255,0.05);border-radius:8px;">
              <strong>${target.icon || '📍'} ${target.name}</strong> - ${qCount} Fragen
              <table>
                <tr><th>#</th><th>Frage</th><th>Richtig</th><th>Tipp</th></tr>
                ${(target.questions || []).map((q, i) => `
                  <tr>
                    <td>${i+1}</td>
                    <td>${q.question.substring(0, 40)}...</td>
                    <td class="ok">${q.answers[q.correct]}</td>
                    <td style="color:#ffa726;">${q.hint || '-'}</td>
                  </tr>
                `).join('')}
              </table>
            </div>`;
        });
        
        container.innerHTML = html;
        document.getElementById('countQuestions').textContent = totalQuestions;
      } catch(e) {
        container.innerHTML = `<p class="missing">❌ Fehler: ${e.message}</p>`;
      }
    }

    // ==========================================
    // 5. QR-CODES
    // ==========================================
    
    function showQRCodes() {
      const grid = document.getElementById('qrGrid');
      const names = ['Magnetismus 🧲', 'Stromkreise ⚡', 'Optik 🔦', 'Farben 🌈'];
      
      for (let i = 0; i < 4; i++) {
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `
          <h3>Target ${i}: ${names[i]}</h3>
          <img src="./qr_codes/target_${i}.png" 
               onerror="this.outerHTML='<p class=\\'missing\\'>❌ QR-Code target_${i}.png fehlt</p>'"
               style="max-width:180px;border-radius:10px;">
          <p style="color:#aaa;font-size:0.8em;">qr_codes/target_${i}.png</p>
        `;
        grid.appendChild(card);
      }
    }

    // ==========================================
    // START
    // ==========================================
    
    document.addEventListener('DOMContentLoaded', () => {
      // Warte, bis Bibliotheken geladen sind
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

echo "✅ Debug-Seite erstellt mit korrigierten Pfaden!"
echo ""
echo "📋 Server starten: python3 -m http.server 8000"
echo "🌐 Browser: http://localhost:8000/debug_test.html"
