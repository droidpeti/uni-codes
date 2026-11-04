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
