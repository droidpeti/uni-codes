#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-railway-simulator}"

mkdir -p "$PROJECT_DIR/js"

cat > "$PROJECT_DIR/index.html" <<'EOF_HTML'
<!DOCTYPE html>
<html lang="hu">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vasúti Forgalomirányító és Váltóállomás Szimulátor</title>
  <link rel="stylesheet" href="./style.css">
</head>
<body>
  <main class="app">
    <section class="screen screen-menu" data-screen="menu" aria-labelledby="menu-title">
      <header class="menu-header">
        <h1 id="menu-title">Vasúti Forgalomirányító és Váltóállomás Szimulátor</h1>
        <p>A Nagy Csomóponti Pályaudvar új diszpécsert keres. Állítsd a váltókat, kapcsold a jelzőket, és juttasd célba a vonatokat balesetmentesen!</p>
      </header>

      <div class="menu-grid">
        <div class="menu-column">
          <form id="start-form" class="card" novalidate autocomplete="off">
            <h2>Új szimuláció</h2>

            <label class="field">
              <span>Diszpécser neve</span>
              <input id="player-name" name="player" type="text" maxlength="24" required placeholder="Pl. Kovács Anna">
            </label>

            <fieldset class="levels">
              <legend>Nehézségi szint</legend>
              <label class="level-option">
                <input type="radio" name="level" value="easy" checked>
                <span class="level-body">
                  <strong>Könnyű</strong>
                  <small>Kitérő vágány jelzőkkel · 2 váltó · 3 jelző · 4 szerelvény</small>
                </span>
              </label>
              <label class="level-option">
                <input type="radio" name="level" value="medium">
                <span class="level-body">
                  <strong>Közepes</strong>
                  <small>Rendező-pályaudvar · 3 váltó · 4 jelző · 5 szerelvény</small>
                </span>
              </label>
              <label class="level-option">
                <input type="radio" name="level" value="hard">
                <span class="level-body">
                  <strong>Nehéz</strong>
                  <small>Fejpályaudvari csúcsforgalom · 4 váltó · 6 jelző · 6 szerelvény</small>
                </span>
              </label>
            </fieldset>

            <p id="menu-message" class="menu-message" role="status" aria-live="polite"></p>

            <div class="button-row">
              <button class="btn btn-primary" type="submit">Szimuláció Indítása</button>
              <button class="btn" type="button" data-action="load">Mentett játékállás betöltése</button>
            </div>
          </form>

          <article class="card rules">
            <h2>Játékszabályzat és irányítás</h2>
            <h3>Cél</h3>
            <p>Minden szerelvényt a saját színének megfelelő peronra kell juttatni ütközés és kisiklás nélkül, a lehető legrövidebb idő alatt.</p>
            <h3>Irányítás</h3>
            <ul>
              <li><strong>Bal egérgomb a váltóra</strong> (kör alakú csomópont): a váltó a következő vágányágra áll. A sárga nyíl és a kiemelt vágányszakasz mutatja az aktív irányt.</li>
              <li><strong>Bal egérgomb a fényjelzőre:</strong> a jelző Vörös (Megállj!) és Zöld (Szabad az út!) állapot között vált.</li>
              <li><strong>Jobb egérgomb a vonatra:</strong> kézi vészfékezés. A vonat megáll és „FÉK” felirat jelenik meg fölötte. Újabb jobb kattintással a fék feloldódik.</li>
              <li><strong>P billentyű:</strong> szünet / folytatás.</li>
            </ul>
            <h3>Szabályok</h3>
            <ul>
              <li>Vörös jelzés előtt a vonat automatikusan megáll, kerete vörösre vált, és „TILOS” felirat jelenik meg. Zöld jelzésre folytatja az útját.</li>
              <li>Ha két szerelvény közelsége veszélyes zónába ér, pulzáló szaggatott kör figyelmeztet. Ha összeérnek, a vonatok megsemmisülnek, a játék véget ér.</li>
              <li>Ha a vonat vágányvégre fut, kisiklik, és hibapontot kapsz.</li>
              <li>Ha a vonat nem a saját színének megfelelő peronra érkezik, hibapontot kapsz.</li>
              <li>Az azonos vágányon haladó szerelvények automatikusan követési távolságot tartanak.</li>
              <li>A pályát befejezve az eredményed felkerül a helyi dicsőséglistára: előbb a hibátlan teljesítések, majd a leggyorsabb idők szerint.</li>
            </ul>
          </article>
        </div>

        <aside class="card leaderboard" aria-labelledby="board-title">
          <h2 id="board-title">Dicsőséglista</h2>
          <div class="board-tabs" role="group" aria-label="Pálya kiválasztása">
            <button class="tab" type="button" data-action="board-tab" data-level="easy" data-board-tab>Könnyű</button>
            <button class="tab" type="button" data-action="board-tab" data-level="medium" data-board-tab>Közepes</button>
            <button class="tab" type="button" data-action="board-tab" data-level="hard" data-board-tab>Nehéz</button>
          </div>
          <table class="board-table">
            <thead>
              <tr>
                <th scope="col">#</th>
                <th scope="col">Név</th>
                <th scope="col">Idő</th>
                <th scope="col">Hibák</th>
                <th scope="col">Dátum</th>
              </tr>
            </thead>
            <tbody id="board-body"></tbody>
          </table>
        </aside>
      </div>
    </section>

    <section class="screen screen-game" data-screen="game" aria-label="Játékképernyő" hidden>
      <header class="hud" aria-label="Játékadatok">
        <div class="hud-item">
          <span class="hud-label">Diszpécser</span>
          <strong id="hud-player"></strong>
        </div>
        <div class="hud-item hud-wide">
          <span class="hud-label">Pálya</span>
          <strong id="hud-level"></strong>
        </div>
        <div class="hud-item">
          <span class="hud-label">Játékidő</span>
          <strong id="hud-time">00:00</strong>
        </div>
        <div class="hud-item">
          <span class="hud-label">Célba ért</span>
          <strong id="hud-delivered"></strong>
        </div>
        <div class="hud-item hud-wide">
          <span class="hud-label">Hibák és késések</span>
          <strong id="hud-errors"></strong>
        </div>
      </header>

      <div class="game-body">
        <div class="board-wrap">
          <canvas id="board" width="1000" height="600" aria-label="Vágányhálózat"></canvas>
        </div>
        <aside class="side-panel">
          <h2>Menetrend</h2>
          <ol id="schedule-list" class="schedule-list"></ol>
          <h2>Események</h2>
          <ul id="event-log" class="event-log"></ul>
        </aside>
      </div>

      <footer class="controls">
        <button id="btn-pause" class="btn" type="button" data-action="pause">Szünet</button>
        <button class="btn" type="button" data-action="reset">Újraindítás</button>
        <button id="btn-save" class="btn" type="button" data-action="save">Játékállás mentése</button>
        <button class="btn" type="button" data-action="menu">Főmenü</button>
        <p id="hud-notice" class="notice" role="status" aria-live="polite"></p>
      </footer>
    </section>
  </main>

  <dialog id="modal" class="modal" aria-labelledby="modal-title">
    <div id="modal-card" class="modal-card" data-tone="info">
      <h2 id="modal-title"></h2>
      <p id="modal-text"></p>
      <div id="modal-actions" class="button-row"></div>
    </div>
  </dialog>

  <script type="module" src="./js/app.js"></script>
</body>
</html>
EOF_HTML

cat > "$PROJECT_DIR/style.css" <<'EOF_CSS'
* {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  min-height: 100%;
}

body {
  min-width: 1024px;
  min-height: 768px;
  font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  background: #0f131b;
  color: #e6ebf2;
  line-height: 1.45;
}

[hidden] {
  display: none !important;
}

h1,
h2,
h3 {
  margin: 0;
  line-height: 1.2;
}

h2 {
  font-size: 1.15rem;
  margin-bottom: 12px;
}

h3 {
  font-size: 0.95rem;
  margin: 14px 0 6px;
  color: #ffd54f;
}

p {
  margin: 0 0 8px;
}

ul,
ol {
  margin: 0;
  padding-left: 20px;
}

li {
  margin-bottom: 6px;
}

.screen {
  min-height: 100vh;
  padding: 20px 28px 28px;
}

.menu-header {
  margin-bottom: 20px;
}

.menu-header h1 {
  font-size: 1.7rem;
  margin-bottom: 8px;
}

.menu-header p {
  color: #aab4c3;
  max-width: 820px;
}

.menu-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr);
  gap: 22px;
  align-items: start;
}

.menu-column {
  display: flex;
  flex-direction: column;
  gap: 22px;
}

.card {
  background: #19202e;
  border: 1px solid #2a3550;
  border-radius: 12px;
  padding: 18px 22px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 16px;
  font-weight: 600;
}

.field input {
  padding: 10px 12px;
  font-size: 1rem;
  border-radius: 8px;
  border: 1px solid #3a4768;
  background: #0f131b;
  color: #e6ebf2;
}

.field input:focus {
  outline: 2px solid #4c8dff;
  outline-offset: 1px;
}

.levels {
  border: 1px solid #2a3550;
  border-radius: 10px;
  padding: 10px 14px 4px;
  margin: 0 0 14px;
}

.levels legend {
  padding: 0 6px;
  font-weight: 600;
}

.level-option {
  display: block;
  margin-bottom: 10px;
  cursor: pointer;
}

.level-option input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.level-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 10px 14px;
  border-radius: 8px;
  border: 2px solid #2a3550;
  background: #141a26;
}

.level-body small {
  color: #9aa6b8;
}

.level-option input:checked + .level-body {
  border-color: #4c8dff;
  background: #1b2740;
}

.level-option input:focus-visible + .level-body {
  outline: 2px solid #ffd54f;
  outline-offset: 2px;
}

.menu-message {
  min-height: 1.4em;
  color: #ff8a80;
  font-weight: 600;
}

.button-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.btn {
  padding: 10px 18px;
  font-size: 0.95rem;
  font-weight: 600;
  border-radius: 8px;
  border: 1px solid #3a4768;
  background: #232d44;
  color: #e6ebf2;
  cursor: pointer;
}

.btn:hover:not(:disabled) {
  background: #2c3856;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn:focus-visible,
.tab:focus-visible {
  outline: 2px solid #ffd54f;
  outline-offset: 2px;
}

.btn-primary {
  background: #2f80ed;
  border-color: #2f80ed;
  color: #ffffff;
}

.btn-primary:hover:not(:disabled) {
  background: #4a93f5;
}

.rules p,
.rules li {
  color: #c9d1dd;
}

.board-tabs {
  display: flex;
  gap: 6px;
  margin-bottom: 12px;
}

.tab {
  flex: 1;
  padding: 8px 10px;
  border-radius: 8px;
  border: 1px solid #3a4768;
  background: #141a26;
  color: #c9d1dd;
  font-weight: 600;
  cursor: pointer;
}

.tab.active {
  background: #2f80ed;
  border-color: #2f80ed;
  color: #ffffff;
}

.board-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.board-table th,
.board-table td {
  padding: 7px 6px;
  text-align: left;
  border-bottom: 1px solid #2a3550;
}

.board-table th {
  color: #9aa6b8;
  font-weight: 600;
}

.board-table .empty {
  text-align: center;
  color: #9aa6b8;
  padding: 18px 6px;
}

.board-table .clean {
  color: #34c759;
}

.screen-game {
  display: flex;
  flex-direction: column;
  gap: 10px;
  height: 100vh;
  padding: 10px 16px;
}

.hud {
  display: flex;
  gap: 10px;
}

.hud-item {
  display: flex;
  flex-direction: column;
  padding: 6px 14px;
  background: #19202e;
  border: 1px solid #2a3550;
  border-radius: 10px;
  min-width: 100px;
}

.hud-wide {
  flex: 1;
}

.hud-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #9aa6b8;
}

.hud-item strong {
  font-size: 1rem;
  white-space: nowrap;
}

.game-body {
  flex: 1;
  min-height: 0;
  display: flex;
  gap: 12px;
}

.board-wrap {
  flex: 1;
  min-width: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #0b0e14;
  border: 1px solid #2a3550;
  border-radius: 10px;
}

#board {
  display: block;
  width: auto;
  height: auto;
  max-width: 100%;
  max-height: calc(100vh - 190px);
  border-radius: 6px;
  cursor: pointer;
}

.side-panel {
  width: 250px;
  flex-shrink: 0;
  overflow-y: auto;
  padding: 12px 14px;
  background: #19202e;
  border: 1px solid #2a3550;
  border-radius: 10px;
}

.side-panel h2 {
  font-size: 0.95rem;
  margin-bottom: 8px;
}

.schedule-list,
.event-log {
  list-style: none;
  margin: 0 0 16px;
  padding: 0;
}

.schedule-item {
  display: grid;
  grid-template-columns: 12px 28px 1fr auto;
  align-items: center;
  gap: 6px;
  margin-bottom: 5px;
  padding: 4px 6px;
  border-radius: 6px;
  background: #141a26;
  font-size: 0.8rem;
}

.schedule-item .dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.schedule-item .time {
  color: #9aa6b8;
}

.schedule-item[data-status="ok"] .status {
  color: #34c759;
}

.schedule-item[data-status="bad"] .status {
  color: #ff453a;
}

.schedule-item[data-status="active"] .status {
  color: #ffd54f;
}

.schedule-item[data-status="pending"] .status {
  color: #9aa6b8;
}

.event-log li {
  margin-bottom: 4px;
  font-size: 0.8rem;
  color: #c9d1dd;
}

.controls {
  display: flex;
  align-items: center;
  gap: 10px;
}

.notice {
  margin: 0 0 0 8px;
  color: #ffd54f;
  font-weight: 600;
}

.modal {
  border: 0;
  padding: 0;
  width: min(480px, 92vw);
  border-radius: 14px;
  background: #19202e;
  color: #e6ebf2;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6);
}

.modal::backdrop {
  background: rgba(5, 8, 14, 0.7);
}

.modal-card {
  padding: 24px 26px;
  border-top: 6px solid #4c8dff;
  border-radius: 14px;
}

.modal-card[data-tone="danger"] {
  border-top-color: #ff453a;
}

.modal-card[data-tone="success"] {
  border-top-color: #34c759;
}

.modal-card[data-tone="warning"] {
  border-top-color: #ffd60a;
}

.modal-card h2 {
  font-size: 1.4rem;
  margin-bottom: 12px;
}

.modal-card p {
  white-space: pre-line;
  margin-bottom: 18px;
  color: #c9d1dd;
}
EOF_CSS

cat > "$PROJECT_DIR/js/state.js" <<'EOF_STATE'
export const COLORS = {
  blue: { name: 'Kék', fill: '#2f80ed' },
  orange: { name: 'Narancs', fill: '#f2994a' },
  green: { name: 'Zöld', fill: '#27ae60' },
  purple: { name: 'Lila', fill: '#9b59b6' }
};

export const CONFIG = {
  width: 1000,
  height: 600,
  collisionDistance: 22,
  warningDistance: 75,
  followStop: 52,
  followFree: 110,
  signalMargin: 12,
  acceleration: 110,
  deceleration: 320,
  spawnClearance: 60,
  switchHitRadius: 20,
  signalHitRadius: 18,
  trainHitRadius: 22,
  signalOffset: 18,
  logLimit: 6,
  saveVersion: 1
};

export class GameStateError extends Error {
  constructor(message) {
    super(message);
    this.name = 'GameStateError';
  }
}

const OUTCOMES = ['ok', 'wrong', 'derail'];

const EFFECT_DURATIONS = {
  explosion: 1.8,
  derail: 1.4,
  arrival: 0.9,
  wrong: 1.1
};

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function polylineLength(points) {
  let total = 0;
  for (let index = 1; index < points.length; index += 1) {
    total += Math.hypot(points[index][0] - points[index - 1][0], points[index][1] - points[index - 1][1]);
  }
  return total;
}

export function pointOnEdge(edge, dist) {
  const points = edge.points;
  let remaining = clamp(dist, 0, edge.length);
  for (let index = 1; index < points.length; index += 1) {
    const [x0, y0] = points[index - 1];
    const [x1, y1] = points[index];
    const segment = Math.hypot(x1 - x0, y1 - y0);
    if (remaining <= segment || index === points.length - 1) {
      const ratio = segment === 0 ? 0 : Math.min(remaining / segment, 1);
      return {
        x: x0 + (x1 - x0) * ratio,
        y: y0 + (y1 - y0) * ratio,
        angle: Math.atan2(y1 - y0, x1 - x0)
      };
    }
    remaining -= segment;
  }
  const last = points[points.length - 1];
  return { x: last[0], y: last[1], angle: 0 };
}

const LEVEL_DEFINITIONS = [
  {
    id: 'easy',
    name: 'Kitérő vágány jelzőkkel',
    difficulty: 'Könnyű',
    nodes: [
      { id: 'E1', type: 'entry', x: 50, y: 300 },
      { id: 'S1', type: 'switch', x: 200, y: 300 },
      { id: 'M1', type: 'merge', x: 480, y: 300 },
      { id: 'S2', type: 'switch', x: 650, y: 300 },
      { id: 'PA', type: 'station', x: 930, y: 190, color: 'blue', label: 'A' },
      { id: 'PB', type: 'station', x: 930, y: 410, color: 'orange', label: 'B' }
    ],
    edges: [
      { id: 'e1', from: 'E1', to: 'S1' },
      { id: 'e2', from: 'S1', to: 'M1' },
      { id: 'e3', from: 'S1', to: 'M1', via: [[250, 230], [430, 230]] },
      { id: 'e4', from: 'M1', to: 'S2' },
      { id: 'e5', from: 'S2', to: 'PA', via: [[740, 190]] },
      { id: 'e6', from: 'S2', to: 'PB', via: [[740, 410]] }
    ],
    signals: [
      { id: 'G1', edge: 'e2', t: 0.5, initial: 'green' },
      { id: 'G2', edge: 'e3', t: 0.5, initial: 'red' },
      { id: 'G3', edge: 'e4', t: 0.5, initial: 'red' }
    ],
    schedule: [
      { id: 'T1', entry: 'E1', time: 2, speed: 80, color: 'blue' },
      { id: 'T2', entry: 'E1', time: 12, speed: 100, color: 'orange' },
      { id: 'T3', entry: 'E1', time: 23, speed: 70, color: 'orange' },
      { id: 'T4', entry: 'E1', time: 34, speed: 90, color: 'blue' }
    ]
  },
  {
    id: 'medium',
    name: 'Rendező-pályaudvar',
    difficulty: 'Közepes',
    nodes: [
      { id: 'EA', type: 'entry', x: 50, y: 180 },
      { id: 'EB', type: 'entry', x: 50, y: 420 },
      { id: 'SA', type: 'switch', x: 240, y: 180 },
      { id: 'SB', type: 'switch', x: 240, y: 420 },
      { id: 'M1', type: 'merge', x: 520, y: 180 },
      { id: 'M2', type: 'merge', x: 520, y: 420 },
      { id: 'SC', type: 'switch', x: 700, y: 180 },
      { id: 'XC', type: 'buffer', x: 800, y: 180 },
      { id: 'PA', type: 'station', x: 920, y: 110, color: 'blue', label: 'A' },
      { id: 'PB', type: 'station', x: 920, y: 250, color: 'orange', label: 'B' },
      { id: 'PC', type: 'station', x: 920, y: 420, color: 'green', label: 'C' }
    ],
    edges: [
      { id: 'a1', from: 'EA', to: 'SA' },
      { id: 'b1', from: 'EB', to: 'SB' },
      { id: 'a2', from: 'SA', to: 'M1' },
      { id: 'a3', from: 'SA', to: 'M2' },
      { id: 'b2', from: 'SB', to: 'M2' },
      { id: 'b3', from: 'SB', to: 'M1' },
      { id: 'm1', from: 'M1', to: 'SC' },
      { id: 'm2', from: 'M2', to: 'PC' },
      { id: 'c1', from: 'SC', to: 'PA', via: [[740, 110]] },
      { id: 'c2', from: 'SC', to: 'PB', via: [[740, 250]] },
      { id: 'c3', from: 'SC', to: 'XC' }
    ],
    signals: [
      { id: 'L1', edge: 'a2', t: 0.55, initial: 'green' },
      { id: 'L2', edge: 'a3', t: 0.3, initial: 'red' },
      { id: 'L3', edge: 'b2', t: 0.55, initial: 'green' },
      { id: 'L4', edge: 'b3', t: 0.3, initial: 'red' }
    ],
    schedule: [
      { id: 'T1', entry: 'EA', time: 2, speed: 85, color: 'green' },
      { id: 'T2', entry: 'EB', time: 4, speed: 65, color: 'blue' },
      { id: 'T3', entry: 'EA', time: 9, speed: 105, color: 'orange' },
      { id: 'T4', entry: 'EB', time: 13, speed: 75, color: 'green' },
      { id: 'T5', entry: 'EA', time: 17, speed: 95, color: 'blue' }
    ]
  },
  {
    id: 'hard',
    name: 'Fejpályaudvari csúcsforgalom',
    difficulty: 'Nehéz',
    nodes: [
      { id: 'E1', type: 'entry', x: 50, y: 170 },
      { id: 'E2', type: 'entry', x: 50, y: 430 },
      { id: 'W1', type: 'switch', x: 210, y: 170 },
      { id: 'W2', type: 'switch', x: 210, y: 430 },
      { id: 'MT', type: 'merge', x: 480, y: 170 },
      { id: 'MB', type: 'merge', x: 480, y: 430 },
      { id: 'W3', type: 'switch', x: 620, y: 170 },
      { id: 'W4', type: 'switch', x: 620, y: 430 },
      { id: 'MP', type: 'merge', x: 800, y: 370 },
      { id: 'XB', type: 'buffer', x: 710, y: 430 },
      { id: 'P1', type: 'station', x: 920, y: 110, color: 'blue', label: '1' },
      { id: 'P2', type: 'station', x: 920, y: 230, color: 'orange', label: '2' },
      { id: 'P3', type: 'station', x: 920, y: 370, color: 'green', label: '3' },
      { id: 'P4', type: 'station', x: 920, y: 500, color: 'purple', label: '4' }
    ],
    edges: [
      { id: 'f1', from: 'E1', to: 'W1' },
      { id: 'f2', from: 'E2', to: 'W2' },
      { id: 't1', from: 'W1', to: 'MT' },
      { id: 't2', from: 'W1', to: 'MB' },
      { id: 'u1', from: 'W2', to: 'MB' },
      { id: 'u2', from: 'W2', to: 'MT' },
      { id: 'mt', from: 'MT', to: 'W3' },
      { id: 'mb', from: 'MB', to: 'W4' },
      { id: 'w3a', from: 'W3', to: 'P1', via: [[680, 110]] },
      { id: 'w3b', from: 'W3', to: 'P2', via: [[680, 230]] },
      { id: 'w3c', from: 'W3', to: 'MP', via: [[740, 330]] },
      { id: 'w4a', from: 'W4', to: 'MP', via: [[690, 370]] },
      { id: 'w4b', from: 'W4', to: 'P4', via: [[680, 500]] },
      { id: 'w4c', from: 'W4', to: 'XB' },
      { id: 'p3', from: 'MP', to: 'P3' }
    ],
    signals: [
      { id: 'H1', edge: 't1', t: 0.55, initial: 'green' },
      { id: 'H2', edge: 't2', t: 0.3, initial: 'red' },
      { id: 'H3', edge: 'u1', t: 0.55, initial: 'green' },
      { id: 'H4', edge: 'u2', t: 0.3, initial: 'red' },
      { id: 'H5', edge: 'mt', t: 0.5, initial: 'green' },
      { id: 'H6', edge: 'mb', t: 0.5, initial: 'green' }
    ],
    schedule: [
      { id: 'T1', entry: 'E1', time: 1.5, speed: 90, color: 'orange' },
      { id: 'T2', entry: 'E2', time: 3, speed: 80, color: 'purple' },
      { id: 'T3', entry: 'E1', time: 6, speed: 100, color: 'green' },
      { id: 'T4', entry: 'E2', time: 8, speed: 70, color: 'blue' },
      { id: 'T5', entry: 'E1', time: 11, speed: 95, color: 'purple' },
      { id: 'T6', entry: 'E2', time: 13, speed: 85, color: 'green' }
    ]
  }
];

function buildLevel(definition) {
  const nodes = {};
  for (const node of definition.nodes) {
    nodes[node.id] = { ...node, outs: [] };
  }

  const edges = {};
  for (const edge of definition.edges) {
    const from = nodes[edge.from];
    const to = nodes[edge.to];
    if (!from || !to) {
      throw new GameStateError(`Edge ${edge.id} references a missing node`);
    }
    const points = [[from.x, from.y], ...(edge.via ?? []), [to.x, to.y]];
    edges[edge.id] = {
      id: edge.id,
      from: edge.from,
      to: edge.to,
      points,
      length: polylineLength(points)
    };
    from.outs.push(edge.id);
  }

  const signals = {};
  for (const item of definition.signals) {
    const edge = edges[item.edge];
    if (!edge) {
      throw new GameStateError(`Signal ${item.id} references a missing edge`);
    }
    const dist = edge.length * item.t;
    const track = pointOnEdge(edge, dist);
    const offsetAngle = track.angle + Math.PI / 2;
    signals[item.id] = {
      id: item.id,
      edge: item.edge,
      dist,
      initial: item.initial,
      trackX: track.x,
      trackY: track.y,
      x: track.x + Math.cos(offsetAngle) * CONFIG.signalOffset,
      y: track.y + Math.sin(offsetAngle) * CONFIG.signalOffset,
      angle: track.angle
    };
  }

  const stationByColor = {};
  for (const node of Object.values(nodes)) {
    if (node.type === 'station') {
      stationByColor[node.color] = node;
    }
  }

  for (const item of definition.schedule) {
    const entry = nodes[item.entry];
    if (!stationByColor[item.color]) {
      throw new GameStateError(`Train ${item.id} has no matching station`);
    }
    if (!entry || entry.type !== 'entry' || entry.outs.length !== 1) {
      throw new GameStateError(`Train ${item.id} has an invalid entry point`);
    }
  }

  return {
    id: definition.id,
    name: definition.name,
    difficulty: definition.difficulty,
    nodes,
    edges,
    signals,
    schedule: definition.schedule,
    stationByColor,
    nodeList: Object.values(nodes),
    edgeList: Object.values(edges),
    signalList: Object.values(signals)
  };
}

export const LEVELS = LEVEL_DEFINITIONS.map(buildLevel);

export function getLevel(levelId) {
  const level = LEVELS.find((item) => item.id === levelId);
  if (!level) {
    throw new GameStateError(`Unknown level: ${levelId}`);
  }
  return level;
}

export function createGame(levelId, playerName) {
  const level = getLevel(levelId);
  const switches = {};
  for (const node of level.nodeList) {
    if (node.type === 'switch') {
      switches[node.id] = node.initial ?? 0;
    }
  }
  const signals = {};
  for (const signal of level.signalList) {
    signals[signal.id] = signal.initial;
  }
  return {
    playerName,
    levelId,
    status: 'running',
    time: 0,
    switches,
    signals,
    trains: [],
    spawned: [],
    outcomes: {},
    delivered: 0,
    errors: 0,
    derailments: 0,
    total: level.schedule.length,
    effects: [],
    warnings: [],
    log: [],
    crash: null
  };
}

function pushLog(game, text) {
  game.log.unshift({ time: game.time, text });
  if (game.log.length > CONFIG.logLimit) {
    game.log.pop();
  }
}

function pushEffect(game, type, x, y) {
  game.effects.push({
    type,
    x,
    y,
    age: 0,
    duration: EFFECT_DURATIONS[type],
    persist: type === 'explosion'
  });
}

function nextEdgeId(game, level, nodeId) {
  const node = level.nodes[nodeId];
  if (node.type === 'switch') {
    return node.outs[game.switches[node.id]];
  }
  return node.outs[0];
}

function nextSignal(level, train) {
  let found = null;
  for (const signal of level.signalList) {
    if (signal.edge !== train.edgeId || signal.dist <= train.dist) {
      continue;
    }
    if (found === null || signal.dist < found.dist) {
      found = signal;
    }
  }
  return found;
}

function findLeader(game, level, train, maxLook) {
  let edgeId = train.edgeId;
  let base = -train.dist;
  for (let hop = 0; hop < 8 && edgeId; hop += 1) {
    const edge = level.edges[edgeId];
    let best = null;
    for (const other of game.trains) {
      if (other === train || other.edgeId !== edgeId) {
        continue;
      }
      const gap = base + other.dist;
      if (gap > 0 && gap <= maxLook && (best === null || gap < best.gap)) {
        best = { train: other, gap };
      }
    }
    if (best) {
      return best;
    }
    base += edge.length;
    if (base > maxLook) {
      return null;
    }
    edgeId = nextEdgeId(game, level, edge.to);
  }
  return null;
}

function createTrain(level, item, edge) {
  const point = pointOnEdge(edge, 0);
  return {
    id: item.id,
    color: item.color,
    destination: level.stationByColor[item.color].id,
    speed: item.speed,
    v: item.speed,
    edgeId: edge.id,
    dist: 0,
    x: point.x,
    y: point.y,
    angle: point.angle,
    braked: false,
    waiting: false,
    following: null
  };
}

function spawnTrains(game, level) {
  for (const item of level.schedule) {
    if (item.time > game.time || game.spawned.includes(item.id)) {
      continue;
    }
    const entry = level.nodes[item.entry];
    const edge = level.edges[entry.outs[0]];
    const blocked = game.trains.some((train) => train.edgeId === edge.id && train.dist < CONFIG.spawnClearance);
    if (blocked) {
      continue;
    }
    game.spawned.push(item.id);
    game.trains.push(createTrain(level, item, edge));
  }
}

function finalizeTrain(train, edge, outcome) {
  const point = pointOnEdge(edge, edge.length);
  train.x = point.x;
  train.y = point.y;
  train.angle = point.angle;
  train.edgeId = edge.id;
  return { ...outcome, x: point.x, y: point.y };
}

function advanceTrain(game, level, train, dt) {
  const edge = level.edges[train.edgeId];
  let target = train.braked ? 0 : train.speed;
  let limit = Infinity;
  train.waiting = false;
  train.following = null;

  const signal = nextSignal(level, train);
  if (signal && game.signals[signal.id] === 'red') {
    const stopAt = Math.max(train.dist, signal.dist - CONFIG.signalMargin);
    const gap = stopAt - train.dist;
    limit = stopAt;
    if (gap <= 0.5) {
      target = 0;
      train.waiting = true;
    } else {
      target = Math.min(target, Math.max(18, gap * 2.2));
    }
  }

  const leader = findLeader(game, level, train, CONFIG.followFree);
  if (leader) {
    train.following = leader.train.id;
    const factor = clamp((leader.gap - CONFIG.followStop) / (CONFIG.followFree - CONFIG.followStop), 0, 1);
    target = Math.min(target, train.speed * factor);
  }

  const delta = target - train.v;
  train.v = Math.max(0, train.v + clamp(delta, -CONFIG.deceleration * dt, CONFIG.acceleration * dt));

  let travel = train.v * dt;
  if (train.dist + travel > limit) {
    travel = Math.max(0, limit - train.dist);
    if (target === 0) {
      train.v = 0;
    }
  }
  train.dist += travel;

  let current = edge;
  while (train.dist >= current.length) {
    const node = level.nodes[current.to];
    if (node.type === 'station') {
      return finalizeTrain(train, current, { kind: 'station', node });
    }
    const nextId = nextEdgeId(game, level, node.id);
    if (!nextId) {
      return finalizeTrain(train, current, { kind: 'derail', node });
    }
    train.dist -= current.length;
    train.edgeId = nextId;
    current = level.edges[nextId];
  }

  const point = pointOnEdge(current, train.dist);
  train.x = point.x;
  train.y = point.y;
  train.angle = point.angle;
  return null;
}

function resolveOutcome(game, train, outcome) {
  if (outcome.kind === 'station') {
    if (outcome.node.color === train.color) {
      game.delivered += 1;
      game.outcomes[train.id] = 'ok';
      pushEffect(game, 'arrival', outcome.x, outcome.y);
      pushLog(game, `${train.id} beérkezett: ${outcome.node.label}. peron`);
    } else {
      game.errors += 1;
      game.outcomes[train.id] = 'wrong';
      pushEffect(game, 'wrong', outcome.x, outcome.y);
      pushLog(game, `${train.id} rossz peronra futott: ${outcome.node.label}`);
    }
    return;
  }
  game.errors += 1;
  game.derailments += 1;
  game.outcomes[train.id] = 'derail';
  pushEffect(game, 'derail', outcome.x, outcome.y);
  pushLog(game, `${train.id} kisiklott`);
}

function moveTrains(game, level, dt) {
  const remaining = [];
  for (const train of game.trains) {
    const outcome = advanceTrain(game, level, train, dt);
    if (outcome) {
      resolveOutcome(game, train, outcome);
    } else {
      remaining.push(train);
    }
  }
  game.trains = remaining;
}

function detectProximity(game) {
  game.warnings = [];
  const trains = game.trains;
  const destroyed = new Set();
  for (let first = 0; first < trains.length; first += 1) {
    for (let second = first + 1; second < trains.length; second += 1) {
      const a = trains[first];
      const b = trains[second];
      const distance = Math.hypot(a.x - b.x, a.y - b.y);
      if (distance <= CONFIG.collisionDistance) {
        destroyed.add(a);
        destroyed.add(b);
        if (!game.crash) {
          game.crash = { a: a.id, b: b.id, x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
        }
      } else if (distance <= CONFIG.warningDistance && a.following !== b.id && b.following !== a.id) {
        game.warnings.push({
          a: a.id,
          b: b.id,
          ax: a.x,
          ay: a.y,
          bx: b.x,
          by: b.y,
          x: (a.x + b.x) / 2,
          y: (a.y + b.y) / 2,
          distance
        });
      }
    }
  }
  if (destroyed.size > 0) {
    for (const train of destroyed) {
      pushEffect(game, 'explosion', train.x, train.y);
    }
    game.trains = trains.filter((train) => !destroyed.has(train));
    game.warnings = [];
    game.status = 'crashed';
    pushLog(game, `Ütközés: ${game.crash.a} és ${game.crash.b}`);
  }
}

export function processedCount(game) {
  return Object.keys(game.outcomes).length;
}

export function stepGame(game, dt) {
  if (game.status !== 'running') {
    return;
  }
  const level = getLevel(game.levelId);
  game.time += dt;
  spawnTrains(game, level);
  moveTrains(game, level, dt);
  detectProximity(game);
  if (game.status === 'running' && processedCount(game) >= game.total && game.trains.length === 0) {
    game.status = 'finished';
  }
}

export function advanceEffects(game, dt) {
  for (const effect of game.effects) {
    effect.age += dt;
  }
  game.effects = game.effects.filter((effect) => effect.persist || effect.age < effect.duration);
}

export function toggleSwitch(game, nodeId) {
  const level = getLevel(game.levelId);
  const node = level.nodes[nodeId];
  if (!node || node.type !== 'switch') {
    throw new GameStateError(`Unknown switch: ${nodeId}`);
  }
  game.switches[nodeId] = (game.switches[nodeId] + 1) % node.outs.length;
}

export function toggleSignal(game, signalId) {
  if (!(signalId in game.signals)) {
    throw new GameStateError(`Unknown signal: ${signalId}`);
  }
  game.signals[signalId] = game.signals[signalId] === 'red' ? 'green' : 'red';
}

export function toggleBrake(game, trainId) {
  const train = game.trains.find((item) => item.id === trainId);
  if (!train) {
    throw new GameStateError(`Unknown train: ${trainId}`);
  }
  train.braked = !train.braked;
}

export function findSwitchAt(level, x, y) {
  let best = null;
  for (const node of level.nodeList) {
    if (node.type !== 'switch') {
      continue;
    }
    const distance = Math.hypot(node.x - x, node.y - y);
    if (distance <= CONFIG.switchHitRadius && (best === null || distance < best.distance)) {
      best = { id: node.id, distance };
    }
  }
  return best ? best.id : null;
}

export function findSignalAt(level, x, y) {
  let best = null;
  for (const signal of level.signalList) {
    const distance = Math.hypot(signal.x - x, signal.y - y);
    if (distance <= CONFIG.signalHitRadius && (best === null || distance < best.distance)) {
      best = { id: signal.id, distance };
    }
  }
  return best ? best.id : null;
}

export function findTrainAt(game, x, y) {
  let best = null;
  for (const train of game.trains) {
    const distance = Math.hypot(train.x - x, train.y - y);
    if (distance <= CONFIG.trainHitRadius && (best === null || distance < best.distance)) {
      best = { train, distance };
    }
  }
  return best ? best.train : null;
}

export function serializeGame(game) {
  return {
    version: CONFIG.saveVersion,
    savedAt: new Date().toISOString(),
    playerName: game.playerName,
    levelId: game.levelId,
    time: game.time,
    switches: { ...game.switches },
    signals: { ...game.signals },
    spawned: [...game.spawned],
    outcomes: { ...game.outcomes },
    delivered: game.delivered,
    errors: game.errors,
    derailments: game.derailments,
    trains: game.trains.map((train) => ({
      id: train.id,
      color: train.color,
      destination: train.destination,
      speed: train.speed,
      currentSpeed: train.v,
      edgeId: train.edgeId,
      dist: train.dist,
      x: train.x,
      y: train.y,
      heading: train.angle,
      braked: train.braked
    }))
  };
}

function requireNumber(value, label, min = 0) {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < min) {
    throw new GameStateError(`Invalid ${label}`);
  }
  return value;
}

export function restoreGame(data) {
  if (!data || typeof data !== 'object' || data.version !== CONFIG.saveVersion) {
    throw new GameStateError('Unsupported save data');
  }
  const level = getLevel(data.levelId);
  const playerName = typeof data.playerName === 'string' ? data.playerName.trim() : '';
  if (!playerName) {
    throw new GameStateError('Missing player name');
  }

  const game = createGame(level.id, playerName);
  game.time = requireNumber(data.time, 'time');

  for (const node of level.nodeList) {
    if (node.type !== 'switch') {
      continue;
    }
    const value = data.switches?.[node.id];
    if (!Number.isInteger(value) || value < 0 || value >= node.outs.length) {
      throw new GameStateError(`Invalid switch state: ${node.id}`);
    }
    game.switches[node.id] = value;
  }

  for (const signal of level.signalList) {
    const value = data.signals?.[signal.id];
    if (value !== 'red' && value !== 'green') {
      throw new GameStateError(`Invalid signal state: ${signal.id}`);
    }
    game.signals[signal.id] = value;
  }

  const scheduleIds = level.schedule.map((item) => item.id);
  if (!Array.isArray(data.spawned) || data.spawned.some((id) => !scheduleIds.includes(id))) {
    throw new GameStateError('Invalid schedule progress');
  }
  game.spawned = [...new Set(data.spawned)];

  if (!data.outcomes || typeof data.outcomes !== 'object') {
    throw new GameStateError('Invalid outcomes');
  }
  for (const [id, outcome] of Object.entries(data.outcomes)) {
    if (!game.spawned.includes(id) || !OUTCOMES.includes(outcome)) {
      throw new GameStateError(`Invalid outcome: ${id}`);
    }
    game.outcomes[id] = outcome;
  }

  if (!Array.isArray(data.trains)) {
    throw new GameStateError('Invalid trains');
  }
  const seen = new Set();
  for (const saved of data.trains) {
    const item = level.schedule.find((entry) => entry.id === saved?.id);
    const edge = level.edges[saved?.edgeId];
    if (!item || !edge || seen.has(item.id) || !game.spawned.includes(item.id) || item.id in game.outcomes) {
      throw new GameStateError('Invalid train entry');
    }
    if (saved.color !== item.color || saved.destination !== level.stationByColor[item.color].id) {
      throw new GameStateError(`Invalid train destination: ${item.id}`);
    }
    const dist = requireNumber(saved.dist, 'train position');
    if (dist > edge.length) {
      throw new GameStateError(`Train position out of range: ${item.id}`);
    }
    const currentSpeed = clamp(requireNumber(saved.currentSpeed, 'train speed'), 0, item.speed);
    seen.add(item.id);
    const train = createTrain(level, item, edge);
    const point = pointOnEdge(edge, dist);
    train.dist = dist;
    train.v = currentSpeed;
    train.x = point.x;
    train.y = point.y;
    train.angle = point.angle;
    train.braked = saved.braked === true;
    game.trains.push(train);
  }

  const processed = Object.keys(game.outcomes).length;
  if (game.spawned.length !== processed + game.trains.length) {
    throw new GameStateError('Inconsistent train counts');
  }

  const values = Object.values(game.outcomes);
  game.delivered = values.filter((value) => value === 'ok').length;
  game.errors = values.length - game.delivered;
  game.derailments = values.filter((value) => value === 'derail').length;
  if (data.delivered !== game.delivered || data.errors !== game.errors || data.derailments !== game.derailments) {
    throw new GameStateError('Inconsistent counters');
  }

  return game;
}
EOF_STATE

cat > "$PROJECT_DIR/js/render.js" <<'EOF_RENDER'
import { COLORS, CONFIG, getLevel, pointOnEdge } from './state.js';

const elementCache = new Map();

export function select(selector) {
  if (!elementCache.has(selector)) {
    const element = document.querySelector(selector);
    if (!element) {
      throw new Error(`Missing element: ${selector}`);
    }
    elementCache.set(selector, element);
  }
  return elementCache.get(selector);
}

function setText(selector, value) {
  const element = select(selector);
  if (element.textContent !== value) {
    element.textContent = value;
  }
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

export function formatTime(seconds) {
  const total = Math.max(0, Math.floor(seconds));
  const minutes = String(Math.floor(total / 60)).padStart(2, '0');
  const rest = String(total % 60).padStart(2, '0');
  return `${minutes}:${rest}`;
}

function withState(context, draw) {
  context.save();
  try {
    draw();
  } finally {
    context.restore();
  }
}

function roundedRect(context, x, y, width, height, radius) {
  context.beginPath();
  context.moveTo(x + radius, y);
  context.arcTo(x + width, y, x + width, y + height, radius);
  context.arcTo(x + width, y + height, x, y + height, radius);
  context.arcTo(x, y + height, x, y, radius);
  context.arcTo(x, y, x + width, y, radius);
  context.closePath();
}

function tracePolyline(context, points) {
  context.beginPath();
  context.moveTo(points[0][0], points[0][1]);
  for (let index = 1; index < points.length; index += 1) {
    context.lineTo(points[index][0], points[index][1]);
  }
}

function traceSpan(context, edge, start, end) {
  const first = pointOnEdge(edge, start);
  context.beginPath();
  context.moveTo(first.x, first.y);
  for (let dist = start + 6; dist < end; dist += 6) {
    const point = pointOnEdge(edge, dist);
    context.lineTo(point.x, point.y);
  }
  const last = pointOnEdge(edge, end);
  context.lineTo(last.x, last.y);
}

function drawBackground(context) {
  withState(context, () => {
    context.fillStyle = '#161c28';
    context.fillRect(0, 0, CONFIG.width, CONFIG.height);
    context.strokeStyle = '#1d2535';
    context.lineWidth = 1;
    context.beginPath();
    for (let x = 0; x <= CONFIG.width; x += 50) {
      context.moveTo(x, 0);
      context.lineTo(x, CONFIG.height);
    }
    for (let y = 0; y <= CONFIG.height; y += 50) {
      context.moveTo(0, y);
      context.lineTo(CONFIG.width, y);
    }
    context.stroke();
  });
}

function drawTrack(context, edge) {
  withState(context, () => {
    context.lineJoin = 'round';
    context.lineCap = 'butt';
    context.beginPath();
    for (let dist = 6; dist < edge.length; dist += 14) {
      const point = pointOnEdge(edge, dist);
      const dx = Math.cos(point.angle + Math.PI / 2) * 9;
      const dy = Math.sin(point.angle + Math.PI / 2) * 9;
      context.moveTo(point.x - dx, point.y - dy);
      context.lineTo(point.x + dx, point.y + dy);
    }
    context.strokeStyle = '#4b4136';
    context.lineWidth = 3;
    context.stroke();

    tracePolyline(context, edge.points);
    context.strokeStyle = '#98a3b1';
    context.lineWidth = 7;
    context.stroke();

    tracePolyline(context, edge.points);
    context.strokeStyle = '#232a36';
    context.lineWidth = 3;
    context.stroke();
  });
}

function drawSwitchRoutes(context, level, node, game) {
  const selected = game.switches[node.id];
  for (const highlight of [false, true]) {
    node.outs.forEach((edgeId, index) => {
      if ((index === selected) !== highlight) {
        return;
      }
      const edge = level.edges[edgeId];
      withState(context, () => {
        context.lineJoin = 'round';
        context.lineCap = 'round';
        traceSpan(context, edge, 14, Math.min(64, edge.length));
        if (highlight) {
          context.strokeStyle = '#ffd54f';
          context.lineWidth = 5;
        } else {
          context.strokeStyle = '#161c28';
          context.lineWidth = 9;
          context.globalAlpha = 0.75;
        }
        context.stroke();
      });
    });
  }
}

function drawLabel(context, text, x, y, size, color) {
  withState(context, () => {
    context.font = `700 ${size}px "Segoe UI", sans-serif`;
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillStyle = color;
    context.fillText(text, x, y);
  });
}

function drawNode(context, level, node, game) {
  if (node.type === 'entry') {
    withState(context, () => {
      roundedRect(context, node.x - 38, node.y - 18, 28, 36, 6);
      context.fillStyle = '#39404f';
      context.fill();
      context.strokeStyle = '#6b7686';
      context.lineWidth = 2;
      context.stroke();
    });
    drawLabel(context, 'BE', node.x - 24, node.y, 11, '#e6ebf2');
  } else if (node.type === 'merge') {
    withState(context, () => {
      context.beginPath();
      context.arc(node.x, node.y, 5, 0, Math.PI * 2);
      context.fillStyle = '#98a3b1';
      context.fill();
    });
  } else if (node.type === 'buffer') {
    withState(context, () => {
      context.fillStyle = '#e53935';
      context.fillRect(node.x - 3, node.y - 14, 6, 28);
      context.fillStyle = '#ffffff';
      context.fillRect(node.x - 3, node.y - 4, 6, 8);
    });
    drawLabel(context, 'vágányvég', node.x, node.y + 28, 11, '#ff8a80');
  } else if (node.type === 'station') {
    const color = COLORS[node.color];
    withState(context, () => {
      roundedRect(context, node.x - 34, node.y - 19, 68, 38, 8);
      context.fillStyle = color.fill;
      context.fill();
      context.strokeStyle = '#ffffff';
      context.lineWidth = 2;
      context.stroke();
    });
    drawLabel(context, node.label, node.x, node.y, 22, '#ffffff');
    drawLabel(context, `Peron ${node.label} · ${color.name}`, node.x, node.y + 32, 11, '#cfd6e0');
  } else if (node.type === 'switch') {
    const edge = level.edges[node.outs[game.switches[node.id]]];
    const heading = pointOnEdge(edge, 12).angle;
    withState(context, () => {
      context.beginPath();
      context.arc(node.x, node.y, 14, 0, Math.PI * 2);
      context.fillStyle = '#0f131b';
      context.fill();
      context.lineWidth = 3;
      context.strokeStyle = '#ffd54f';
      context.stroke();
    });
    withState(context, () => {
      context.translate(node.x, node.y);
      context.rotate(heading);
      context.beginPath();
      context.moveTo(9, 0);
      context.lineTo(-5, -7);
      context.lineTo(-5, 7);
      context.closePath();
      context.fillStyle = '#ffd54f';
      context.fill();
    });
  }
}

function drawSignal(context, signal, state) {
  withState(context, () => {
    context.beginPath();
    context.moveTo(signal.trackX, signal.trackY);
    context.lineTo(signal.x, signal.y);
    context.strokeStyle = '#6b7686';
    context.lineWidth = 2;
    context.stroke();
  });
  withState(context, () => {
    roundedRect(context, signal.x - 9, signal.y - 19, 18, 38, 5);
    context.fillStyle = '#0b0e14';
    context.fill();
    context.strokeStyle = '#6b7686';
    context.lineWidth = 2;
    context.stroke();
  });
  const lamps = [
    { y: signal.y - 8, lit: state === 'red', on: '#ff3b30', off: '#4a1512' },
    { y: signal.y + 8, lit: state === 'green', on: '#34c759', off: '#12361c' }
  ];
  for (const lamp of lamps) {
    withState(context, () => {
      context.beginPath();
      context.arc(signal.x, lamp.y, 5.5, 0, Math.PI * 2);
      context.fillStyle = lamp.lit ? lamp.on : lamp.off;
      if (lamp.lit) {
        context.shadowColor = lamp.on;
        context.shadowBlur = 12;
      }
      context.fill();
    });
  }
}

function drawTrain(context, level, train) {
  const station = level.nodes[train.destination];
  withState(context, () => {
    context.translate(train.x, train.y);
    context.rotate(train.angle);
    roundedRect(context, -16, -7, 32, 14, 4);
    context.fillStyle = COLORS[train.color].fill;
    context.fill();
    context.lineWidth = train.waiting ? 3 : 2;
    context.strokeStyle = train.waiting ? '#ff3b30' : '#0b0e14';
    context.stroke();
    context.fillStyle = 'rgba(255, 255, 255, 0.85)';
    context.fillRect(9, -4, 5, 8);
  });

  withState(context, () => {
    context.font = '700 11px "Segoe UI", sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.lineWidth = 3;
    context.strokeStyle = '#0b0e14';
    context.strokeText(station.label, train.x - 2, train.y);
    context.fillStyle = '#ffffff';
    context.fillText(station.label, train.x - 2, train.y);
  });

  let caption = '';
  let captionColor = '';
  if (train.braked) {
    caption = 'FÉK';
    captionColor = '#ff9f0a';
  } else if (train.waiting) {
    caption = 'TILOS';
    captionColor = '#ff453a';
  }
  if (caption) {
    withState(context, () => {
      context.font = '700 11px "Segoe UI", sans-serif';
      const width = context.measureText(caption).width + 12;
      roundedRect(context, train.x - width / 2, train.y - 30, width, 16, 4);
      context.fillStyle = 'rgba(11, 14, 20, 0.9)';
      context.fill();
      context.strokeStyle = captionColor;
      context.lineWidth = 1.5;
      context.stroke();
      context.textAlign = 'center';
      context.textBaseline = 'middle';
      context.fillStyle = captionColor;
      context.fillText(caption, train.x, train.y - 22);
    });
  }
}

function drawWarnings(context, game, now) {
  const pulse = (Math.sin(now / 120) + 1) / 2;
  const color = pulse > 0.5 ? '#ffd60a' : '#ff453a';
  for (const warning of game.warnings) {
    withState(context, () => {
      context.setLineDash([8, 6]);
      context.lineWidth = 3;
      context.strokeStyle = color;
      context.globalAlpha = 0.55 + 0.45 * pulse;
      context.beginPath();
      context.arc(warning.x, warning.y, warning.distance / 2 + 26, 0, Math.PI * 2);
      context.stroke();
      for (const [x, y] of [[warning.ax, warning.ay], [warning.bx, warning.by]]) {
        context.beginPath();
        context.arc(x, y, 24, 0, Math.PI * 2);
        context.stroke();
      }
    });
  }
}

function drawBurst(context, progress, maxRadius, inner, outer) {
  const radius = maxRadius * (0.35 + 0.65 * Math.min(1, progress * 2.5));
  const spikes = 12;
  context.beginPath();
  for (let index = 0; index < spikes * 2; index += 1) {
    const length = index % 2 === 0 ? radius : radius * 0.55;
    const angle = (Math.PI * index) / spikes;
    const x = Math.cos(angle) * length;
    const y = Math.sin(angle) * length;
    if (index === 0) {
      context.moveTo(x, y);
    } else {
      context.lineTo(x, y);
    }
  }
  context.closePath();
  const gradient = context.createRadialGradient(0, 0, 2, 0, 0, radius);
  gradient.addColorStop(0, inner);
  gradient.addColorStop(1, outer);
  context.fillStyle = gradient;
  context.fill();
  context.lineWidth = 2;
  context.strokeStyle = '#ffffff';
  context.stroke();
}

function drawRing(context, progress, color) {
  context.beginPath();
  context.arc(0, 0, 14 + 34 * progress, 0, Math.PI * 2);
  context.lineWidth = 4;
  context.strokeStyle = color;
  context.stroke();
}

function drawEffects(context, game) {
  for (const effect of game.effects) {
    const progress = clamp(effect.age / effect.duration, 0, 1);
    withState(context, () => {
      context.translate(effect.x, effect.y);
      context.globalAlpha = effect.persist ? 1 : 1 - progress * 0.85;
      if (effect.type === 'explosion') {
        drawBurst(context, progress, 46, '#fff59d', '#ff3b30');
      } else if (effect.type === 'derail') {
        drawBurst(context, progress, 30, '#ffe0b2', '#e65100');
      } else {
        drawRing(context, progress, effect.type === 'arrival' ? '#34c759' : '#ff453a');
      }
    });
  }
}

function drawPauseOverlay(context) {
  withState(context, () => {
    context.fillStyle = 'rgba(5, 8, 14, 0.55)';
    context.fillRect(0, 0, CONFIG.width, CONFIG.height);
  });
  drawLabel(context, 'SZÜNET', CONFIG.width / 2, CONFIG.height / 2, 56, '#ffffff');
}

export function drawGame(context, game, now, paused) {
  const level = getLevel(game.levelId);
  context.clearRect(0, 0, CONFIG.width, CONFIG.height);
  drawBackground(context);
  for (const edge of level.edgeList) {
    drawTrack(context, edge);
  }
  for (const node of level.nodeList) {
    if (node.type === 'switch') {
      drawSwitchRoutes(context, level, node, game);
    }
  }
  for (const node of level.nodeList) {
    drawNode(context, level, node, game);
  }
  for (const signal of level.signalList) {
    drawSignal(context, signal, game.signals[signal.id]);
  }
  for (const train of game.trains) {
    drawTrain(context, level, train);
  }
  drawWarnings(context, game, now);
  drawEffects(context, game);
  if (paused) {
    drawPauseOverlay(context);
  }
}

function trainStatus(game, id) {
  const outcome = game.outcomes[id];
  if (outcome === 'ok') {
    return { text: 'Beérkezett', key: 'ok' };
  }
  if (outcome === 'wrong') {
    return { text: 'Rossz peron', key: 'bad' };
  }
  if (outcome === 'derail') {
    return { text: 'Kisiklott', key: 'bad' };
  }
  if (game.spawned.includes(id)) {
    return { text: 'Úton', key: 'active' };
  }
  return { text: 'Várakozik', key: 'pending' };
}

let scheduleSignature = '';
let logSignature = '';

function renderSchedule(game, level) {
  const rows = level.schedule.map((item) => ({ item, status: trainStatus(game, item.id) }));
  const signature = `${game.levelId}|${rows.map((row) => row.status.text).join(',')}`;
  if (signature === scheduleSignature) {
    return;
  }
  scheduleSignature = signature;
  const list = select('#schedule-list');
  list.replaceChildren();
  for (const { item, status } of rows) {
    const station = level.stationByColor[item.color];
    const entry = document.createElement('li');
    entry.className = 'schedule-item';
    entry.dataset.status = status.key;

    const dot = document.createElement('span');
    dot.className = 'dot';
    dot.style.backgroundColor = COLORS[item.color].fill;

    const id = document.createElement('span');
    id.textContent = item.id;

    const target = document.createElement('span');
    target.textContent = `→ ${station.label}. peron · ${formatTime(item.time)}`;
    target.className = 'time';

    const label = document.createElement('span');
    label.className = 'status';
    label.textContent = status.text;

    entry.append(dot, id, target, label);
    list.append(entry);
  }
}

function renderLog(game) {
  const signature = `${game.levelId}|${game.log.length}|${game.log[0]?.text ?? ''}|${game.log[0]?.time ?? ''}`;
  if (signature === logSignature) {
    return;
  }
  logSignature = signature;
  const list = select('#event-log');
  list.replaceChildren();
  for (const entry of game.log) {
    const item = document.createElement('li');
    item.textContent = `[${formatTime(entry.time)}] ${entry.text}`;
    list.append(item);
  }
}

export function resetHudCache() {
  scheduleSignature = '';
  logSignature = '';
}

export function renderHud(game, ui) {
  const level = getLevel(game.levelId);
  setText('#hud-player', game.playerName);
  setText('#hud-level', `${level.name} — ${level.difficulty}`);
  setText('#hud-time', formatTime(game.time));
  setText('#hud-delivered', `${game.delivered} / ${game.total}`);
  setText(
    '#hud-errors',
    `${game.errors} (rossz peron: ${game.errors - game.derailments}, kisiklás: ${game.derailments})`
  );
  setText('#hud-notice', ui.notice);
  setText('#btn-pause', ui.paused ? 'Folytatás' : 'Szünet');
  select('#btn-pause').disabled = game.status !== 'running';
  select('#btn-save').disabled = game.status !== 'running';
  renderSchedule(game, level);
  renderLog(game);
}

export function showScreen(name) {
  for (const screen of document.querySelectorAll('[data-screen]')) {
    screen.hidden = screen.dataset.screen !== name;
  }
}

export function setMenuMessage(text) {
  setText('#menu-message', text);
}

export function showModal({ title, text, tone, actions }) {
  const dialog = select('#modal');
  setText('#modal-title', title);
  setText('#modal-text', text);
  select('#modal-card').dataset.tone = tone ?? 'info';
  const container = select('#modal-actions');
  container.replaceChildren();
  for (const action of actions) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = action.primary ? 'btn btn-primary' : 'btn';
    button.dataset.action = action.action;
    button.textContent = action.label;
    container.append(button);
  }
  if (!dialog.open) {
    try {
      dialog.showModal();
    } catch (error) {
      console.error('Modal dialog could not be shown modally', error);
      dialog.setAttribute('open', '');
    }
  }
}

export function hideModal() {
  const dialog = select('#modal');
  if (dialog.open) {
    dialog.close();
  }
}

function formatDate(iso) {
  const date = new Date(iso);
  return Number.isNaN(date.getTime()) ? '—' : date.toLocaleDateString('hu-HU');
}

export function renderLeaderboard(levelId, entries) {
  const level = getLevel(levelId);
  setText('#board-title', `Dicsőséglista — ${level.name}`);
  for (const tab of document.querySelectorAll('[data-board-tab]')) {
    const active = tab.dataset.level === levelId;
    tab.classList.toggle('active', active);
    tab.setAttribute('aria-pressed', String(active));
  }
  const body = select('#board-body');
  body.replaceChildren();
  if (entries.length === 0) {
    const row = document.createElement('tr');
    const cell = document.createElement('td');
    cell.colSpan = 5;
    cell.className = 'empty';
    cell.textContent = 'Még nincs rögzített eredmény.';
    row.append(cell);
    body.append(row);
    return;
  }
  entries.forEach((entry, index) => {
    const row = document.createElement('tr');
    const values = [
      String(index + 1),
      entry.name,
      formatTime(entry.time),
      entry.errors === 0 ? 'hibátlan' : String(entry.errors),
      formatDate(entry.date)
    ];
    values.forEach((value, column) => {
      const cell = document.createElement('td');
      cell.textContent = value;
      if (column === 3 && entry.errors === 0) {
        cell.className = 'clean';
      }
      row.append(cell);
    });
    body.append(row);
  });
}
EOF_RENDER

cat > "$PROJECT_DIR/js/app.js" <<'EOF_APP'
import {
  LEVELS,
  GameStateError,
  advanceEffects,
  createGame,
  findSignalAt,
  findSwitchAt,
  findTrainAt,
  getLevel,
  restoreGame,
  serializeGame,
  stepGame,
  toggleBrake,
  toggleSignal,
  toggleSwitch
} from './state.js';
import {
  drawGame,
  formatTime,
  hideModal,
  renderHud,
  renderLeaderboard,
  resetHudCache,
  select,
  setMenuMessage,
  showModal,
  showScreen
} from './render.js';

const MAX_STEP = 0.05;
const NOTICE_DURATION = 3200;
const MAX_NAME_LENGTH = 24;
const BOARD_SIZE = 10;

const STORAGE_KEYS = {
  save: 'railDispatcher.save',
  board: (levelId) => `railDispatcher.board.${levelId}`
};

const app = {
  game: null,
  paused: false,
  lastTimestamp: 0,
  frameId: 0,
  endHandled: false,
  notice: null,
  boardLevelId: LEVELS[0].id
};

let canvas = null;
let context = null;

function readStorage(key) {
  try {
    const raw = window.localStorage.getItem(key);
    return raw === null ? null : JSON.parse(raw);
  } catch (error) {
    console.error(`Storage read failed for ${key}`, error);
    return null;
  }
}

function writeStorage(key, value) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
    return true;
  } catch (error) {
    console.error(`Storage write failed for ${key}`, error);
    return false;
  }
}

function isValidEntry(entry) {
  return (
    entry !== null &&
    typeof entry === 'object' &&
    typeof entry.name === 'string' &&
    Number.isFinite(entry.time) &&
    Number.isInteger(entry.errors) &&
    typeof entry.date === 'string'
  );
}

function compareEntries(a, b) {
  return Number(a.errors > 0) - Number(b.errors > 0) || a.time - b.time || a.errors - b.errors;
}

function loadBoard(levelId) {
  const data = readStorage(STORAGE_KEYS.board(levelId));
  if (!Array.isArray(data)) {
    return [];
  }
  return data.filter(isValidEntry).sort(compareEntries);
}

function recordResult(game) {
  const entries = loadBoard(game.levelId);
  const entry = {
    name: game.playerName,
    time: Math.round(game.time * 10) / 10,
    errors: game.errors,
    date: new Date().toISOString()
  };
  entries.push(entry);
  entries.sort(compareEntries);
  const trimmed = entries.slice(0, BOARD_SIZE);
  const stored = writeStorage(STORAGE_KEYS.board(game.levelId), trimmed);
  const rank = trimmed.indexOf(entry);
  return { stored, rank: rank === -1 ? null : rank + 1 };
}

function refreshBoard() {
  renderLeaderboard(app.boardLevelId, loadBoard(app.boardLevelId));
}

function notify(text) {
  app.notice = { text, until: performance.now() + NOTICE_DURATION };
}

function activeNotice(timestamp) {
  if (!app.notice) {
    return '';
  }
  if (timestamp > app.notice.until) {
    app.notice = null;
    return '';
  }
  return app.notice.text;
}

function readPlayerName() {
  return select('#player-name').value.trim().replace(/\s+/g, ' ').slice(0, MAX_NAME_LENGTH);
}

function readSelectedLevel() {
  const checked = document.querySelector('input[name="level"]:checked');
  return checked ? checked.value : LEVELS[0].id;
}

function canvasPoint(event) {
  const rect = canvas.getBoundingClientRect();
  return {
    x: ((event.clientX - rect.left) * canvas.width) / rect.width,
    y: ((event.clientY - rect.top) * canvas.height) / rect.height
  };
}

function stopLoop() {
  if (app.frameId) {
    cancelAnimationFrame(app.frameId);
    app.frameId = 0;
  }
}

function startGame(game) {
  app.game = game;
  app.paused = false;
  app.endHandled = false;
  app.notice = null;
  resetHudCache();
  hideModal();
  showScreen('game');
  app.lastTimestamp = performance.now();
  if (!app.frameId) {
    app.frameId = requestAnimationFrame(frame);
  }
}

function handleStart() {
  const name = readPlayerName();
  if (!name) {
    setMenuMessage('A játék indításához add meg a neved!');
    select('#player-name').focus();
    return;
  }
  setMenuMessage('');
  startGame(createGame(readSelectedLevel(), name));
}

function handleLoad() {
  const data = readStorage(STORAGE_KEYS.save);
  if (!data) {
    setMenuMessage('Nincs elmentett játékállás.');
    return;
  }
  try {
    const game = restoreGame(data);
    setMenuMessage('');
    startGame(game);
    notify('Játékállás betöltve.');
  } catch (error) {
    console.error('Loading the saved game failed', error);
    if (error instanceof GameStateError) {
      setMenuMessage('A mentett játékállás sérült vagy érvénytelen.');
    } else {
      setMenuMessage('A betöltés közben váratlan hiba történt.');
    }
  }
}

function saveGame() {
  const game = app.game;
  if (!game || game.status !== 'running') {
    notify('Csak futó játékállás menthető.');
    return;
  }
  try {
    const stored = writeStorage(STORAGE_KEYS.save, serializeGame(game));
    notify(stored ? 'Játékállás elmentve.' : 'A mentés nem sikerült: a böngészőtár nem elérhető.');
  } catch (error) {
    console.error('Saving the game failed', error);
    notify('A mentés nem sikerült.');
  }
}

function togglePause() {
  if (!app.game || app.game.status !== 'running') {
    return;
  }
  app.paused = !app.paused;
}

function resetGame() {
  if (!app.game) {
    return;
  }
  startGame(createGame(app.game.levelId, app.game.playerName));
}

function returnToMenu() {
  stopLoop();
  app.game = null;
  app.paused = false;
  hideModal();
  showScreen('menu');
  setMenuMessage('');
  refreshBoard();
}

function handleGameEnd(game) {
  app.endHandled = true;
  const actions = [
    { label: 'Újrapróbálom', action: 'reset', primary: true },
    { label: 'Főmenü', action: 'menu' }
  ];
  if (game.status === 'crashed') {
    showModal({
      title: 'Katasztrófa! Vonatütközés',
      text: `A(z) ${game.crash.a} és a(z) ${game.crash.b} szerelvény összeütközött.\nJátékidő: ${formatTime(game.time)}`,
      tone: 'danger',
      actions
    });
    return;
  }
  const result = recordResult(game);
  const clean = game.errors === 0;
  const lines = [
    `Játékos: ${game.playerName}`,
    `Idő: ${formatTime(game.time)}`,
    `Hibák: ${game.errors} (kisiklás: ${game.derailments})`
  ];
  if (result.rank !== null) {
    lines.push(`Helyezés a dicsőséglistán: ${result.rank}.`);
  }
  if (!result.stored) {
    lines.push('Az eredményt nem sikerült elmenteni.');
  }
  showModal({
    title: clean ? 'Hibátlan teljesítés!' : 'Szimuláció teljesítve hibákkal',
    text: lines.join('\n'),
    tone: clean ? 'success' : 'warning',
    actions
  });
}

function frame(timestamp) {
  app.frameId = requestAnimationFrame(frame);
  try {
    const game = app.game;
    if (!game) {
      return;
    }
    const dt = Math.min(Math.max((timestamp - app.lastTimestamp) / 1000, 0), MAX_STEP);
    app.lastTimestamp = timestamp;
    if (!app.paused) {
      stepGame(game, dt);
      advanceEffects(game, dt);
    }
    drawGame(context, game, timestamp, app.paused);
    renderHud(game, { paused: app.paused, notice: activeNotice(timestamp) });
    if (game.status !== 'running' && !app.endHandled) {
      handleGameEnd(game);
    }
  } catch (error) {
    console.error('Frame failed', error);
  }
}

function handleBoardClick(event) {
  const game = app.game;
  if (!game || game.status !== 'running' || app.paused) {
    return;
  }
  const point = canvasPoint(event);
  const level = getLevel(game.levelId);
  const signalId = findSignalAt(level, point.x, point.y);
  if (signalId) {
    toggleSignal(game, signalId);
    return;
  }
  const switchId = findSwitchAt(level, point.x, point.y);
  if (switchId) {
    toggleSwitch(game, switchId);
  }
}

function handleBoardBrake(event) {
  const game = app.game;
  if (!game || game.status !== 'running' || app.paused) {
    return;
  }
  const point = canvasPoint(event);
  const train = findTrainAt(game, point.x, point.y);
  if (train) {
    toggleBrake(game, train.id);
  }
}

function runAction(action, element) {
  switch (action) {
    case 'load':
      handleLoad();
      break;
    case 'board-tab':
      app.boardLevelId = element.dataset.level;
      refreshBoard();
      break;
    case 'pause':
      togglePause();
      break;
    case 'reset':
      resetGame();
      break;
    case 'save':
      saveGame();
      break;
    case 'menu':
      returnToMenu();
      break;
    default:
      console.warn(`Unknown action: ${action}`);
  }
}

function handleClick(event) {
  try {
    const target = event.target;
    if (!(target instanceof Element)) {
      return;
    }
    const actionElement = target.closest('[data-action]');
    if (actionElement) {
      runAction(actionElement.dataset.action, actionElement);
      return;
    }
    if (target === canvas) {
      handleBoardClick(event);
    }
  } catch (error) {
    console.error('Click handling failed', error);
  }
}

function handleContextMenu(event) {
  try {
    const target = event.target;
    if (!(target instanceof Element) || !target.closest('.board-wrap')) {
      return;
    }
    event.preventDefault();
    if (target === canvas) {
      handleBoardBrake(event);
    }
  } catch (error) {
    console.error('Context menu handling failed', error);
  }
}

function handleSubmit(event) {
  event.preventDefault();
  try {
    handleStart();
  } catch (error) {
    console.error('Starting the game failed', error);
    setMenuMessage('A játék indítása nem sikerült.');
  }
}

function handleKeydown(event) {
  if (!app.game || event.target instanceof HTMLInputElement) {
    return;
  }
  if (event.key === 'p' || event.key === 'P') {
    togglePause();
  }
}

function init() {
  try {
    canvas = select('#board');
    context = canvas.getContext('2d');
    if (!context) {
      throw new Error('Canvas 2D context is not available');
    }
    document.addEventListener('click', handleClick);
    document.addEventListener('contextmenu', handleContextMenu);
    document.addEventListener('submit', handleSubmit);
    document.addEventListener('keydown', handleKeydown);
    select('#modal').addEventListener('cancel', (event) => event.preventDefault());
    showScreen('menu');
    refreshBoard();
  } catch (error) {
    console.error('Initialization failed', error);
  }
}

init();
EOF_APP

cat > "$PROJECT_DIR/README.md" <<'EOF_README'
# Vasúti Forgalomirányító Szimulátor — WEBPROG Beadandó


## Hallgatói Adatok

    **Név:** <Hallgató Neve>

    **Neptun kód:** <NEPTUN>

    **Szak / Képzés:** Programtervező informatikus BSc (ELTE IK)

    **Bemutató videó linkje (OneDrive):** [Videó megtekintése](https://...)
    **A futtatható program linkje (Vercel, Netlify, Firebase, stb.):** <https://...>


---


## Hallgatói Nyilatkozat és AI Használat

Kijelentem, hogy ez a megoldás a saját szellemi munkám. Nem másoltam és nem vettem át harmadik féltől származó kész kódrészleteket jogosulatlanul. Tudomásul veszem az ELTE HKR 377/A. § szerinti szabályzatot: a nem megengedett segítség igénybevétele vagy a másolat készítése fegyelmi eljárást és a tárgy automatikus elutasítását vonja maga után.


### AI Eszközök Használata (Jelöld a megfelelőt):

    [ ] A feladatot teljesen önállóan, AI segítség nélkül készítettem el.

    [ ] Használtam mesterséges intelligenciát (pl. ChatGPT, GitHub Copilot) tanácsadóként.

  * *Részletezés:* <Írd le 2-3 mondatban, mire használtad az AI-t (pl. ötletelés, szintaxiskeresés, hibakeresés).>


Tudomásul veszem, hogy a személyes szóbeli kódvédésen a kód minden egyes sorát önállóan, segédeszköz nélkül meg kell tudnom magyarázni.


---


## Önellenőrző Lista (Checklist)


### Kezdőképernyő & Általános Funkciók

    [ ] Játékosnév bekérése és validálása

    [ ] 3 különböző nehézségi szintű pálya kiválasztása

    [ ] Játékszabályzat és irányítás megtekintése

    [ ] Pályánkénti dicsőséglista (helyi ranglista) localStorage-ban

    [ ] Korábbi játékállás visszatöltése a főmenüből



### Játékmenet & Felület (Canvas)

    [ ] Folyamatosan frissülő játékidő (stopper) kijelzése

    [ ] Célba ért vonatok és hiba/késésszámláló dinamikus HUD-ja

    [ ] Topológiai vágányhálózat és állomások kirajzolása Canvas 2D-ben

    [ ] Váltók állítása bal egérgombbal (vizuális irányjelzéssel)

    [ ] Vasúti fényjelzők (kétoptikás) szabad/tilos állítása bal kattintással

    [ ] Szerelvények vészfékezése / feloldása jobb egérgombbal

    [ ] Jobb egérgombos böngészőmenü letiltva a játéktéren



### Szimuláció, Logika & Hibakezelés

    [ ] Menetrend szerinti automatikus vonatindítás eltérő sebességekkel

    [ ] Vörös jelzőnél kötelező és automatikus megállás

    [ ] Közelgő ütközés valós idejű vizuális figyelmeztetése (sárga/piros aura)

    [ ] Vonatütközések azonnali detektálása és Game Over kezelése

    [ ] Kisiklás kezelése helytelen váltóállás vagy nyitott vágányvég esetén

    [ ] Helytelen célperonra futás büntetése

    [ ] Játék végi győzelmi / vereségi értesítés egyedi modális ablakban (alert nélkül)



### Kódminőség & Architektúra

    [ ] Szigorú "1 HTML + 1 CSS + 3 JS" moduláris struktúra (state, render, app)

    [ ] Nincs var kulcsszó a teljes forráskódban

    [ ] Nincsenek getElementById, DOMContentLoaded, alert() hívások

    [ ] Tiszta Vanilla JS (nincs külső könyvtár vagy framework)

    [ ] Játékállás mentése és visszatöltése localStorage segítségével

    [ ] A 3-5 perces narrált bemutató videó feltöltve és megosztható OneDrive linken
    [ ] Online deployment, a program elérhető valamilyen online platformon, ennek elérhetőségét feltüntettem itt a README.md file elején
EOF_README

if command -v zip >/dev/null 2>&1; then
  ARCHIVE_NAME="$(basename "$PROJECT_DIR").zip"
  (cd "$PROJECT_DIR" && rm -f "../$ARCHIVE_NAME" && zip -qr "../$ARCHIVE_NAME" index.html style.css js README.md)
  echo "Archive created: $ARCHIVE_NAME"
fi

echo "Project generated in: $PROJECT_DIR"
