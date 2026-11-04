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
