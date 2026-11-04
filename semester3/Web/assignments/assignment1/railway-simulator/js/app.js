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
