"use strict";
import slotInit from "./modules/slot.js";
import { fetchNui } from "./utils/fetchNui.js";

let isMyTurn = false;
let mustThrow = false;
let playerName = '';
let your_turn = '';
let waiting = '';


const giveBtn = document.querySelector('#give');
const throwBtn = document.querySelector('#throw');
const giveCenterBtn = document.querySelector('#give-center');
const finishBtn = document.querySelector('#finish-hand');
const startMenuOverlay = document.querySelector('.start-menu-overlay');
const startGameBtn = document.querySelector('#start-game');

const indicatorYourTurnSVG = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-flame-icon lucide-flame"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/></svg>`
const indicatorWaitSVG = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-clock8-icon lucide-clock-8 mr4"><path d="M12 6v6l-4 2"/><circle cx="12" cy="12" r="10"/></svg>`


window.addEventListener("message", (e) => {
  const data = e.data;
  if (!data || !data?.action) return;

  const bodyStyle = document.body.style;

  switch (data?.action) {
    case "toggle":
      bodyStyle.visibility = data.state === "visible" ? "visible" : "hidden";
      bodyStyle.display = data.state === "visible" ? "block" : "none";
      break;
    case "updateTurnUI":
      updateTurnUI(data);
      break;
    case "disableInteractions":
      setInteractionsEnabled(data.enabled);
      break;
    case "showStartMenu":
      toggleStartMenu(data?.status);
      break;
  }
});

// Oyun başlat menüsünü göster/gizle
function toggleStartMenu(show) {
  if (show) {
    startMenuOverlay.style.display = 'flex';
    return;
  }
  startMenuOverlay.style.display = 'none';
}


function updateTurnUI(data) {
  isMyTurn = data.isMyTurn;
  playerName = data.playerName;
  mustThrow = data.mustThrow || false;

  setInteractionsEnabled(isMyTurn);

  updateTurnIndicator();

  setTimeout(() => {
    updateButtonStates();
  }, 50);
}


function setInteractionsEnabled(enabled) {

  const buttons = document.querySelectorAll('#give, #throw, #give-center');
  const tiles = document.querySelectorAll('.tile-slot');

  buttons.forEach(btn => {
    btn.style.pointerEvents = enabled ? 'auto' : 'none';
    btn.style.opacity = enabled ? '1' : '0.5';
  });

  tiles.forEach(tile => {
    tile.style.pointerEvents = enabled ? 'auto' : 'none';
    tile.style.cursor = enabled ? 'pointer' : 'not-allowed';
  });

}

function forceButtonVisibility(button, show) {
  if (!button) return;

  if (show) {
    button.style.display = 'inline-flex';
    button.style.visibility = 'visible';
    button.style.pointerEvents = 'auto';
    return;
  }

  button.style.display = 'none';

}

function updateButtonStates() {

  if (!isMyTurn) {
    forceButtonVisibility(giveBtn, false);
    forceButtonVisibility(throwBtn, false);
    forceButtonVisibility(giveCenterBtn, false);
    forceButtonVisibility(finishBtn, false);
    return;
  }

  if (mustThrow) {
    forceButtonVisibility(giveBtn, false);
    forceButtonVisibility(giveCenterBtn, false);
    forceButtonVisibility(throwBtn, true);
    forceButtonVisibility(finishBtn, true);
  } else {
    forceButtonVisibility(giveBtn, true);
    forceButtonVisibility(giveCenterBtn, true);
    forceButtonVisibility(throwBtn, false);
    forceButtonVisibility(finishBtn, false);
  }
}


const turnIndicator = document.createElement('div');
turnIndicator.className = 'turn-indicator';
turnIndicator.innerHTML = '<div class="turn-info"></div>';
document.body.appendChild(turnIndicator);

function updateTurnIndicator() {
  const turnInfo = turnIndicator.querySelector('.turn-info');

  turnInfo.innerHTML = isMyTurn
    ? `<span class="your-turn">${indicatorYourTurnSVG} ${your_turn}</span>`
    : `<span class="waiting">${indicatorWaitSVG} ${waiting} ${playerName || ''}</span>`;
}

function setLocale(locale) {
  document.querySelector('.start-menu-title').textContent = locale.okey_menu.title || '';
  document.querySelector('.start-menu-description').textContent = locale.okey_menu.description || '';
  document.querySelector('.start-game-spn').textContent = locale.okey_menu.create_table || '';
  giveBtn.querySelector('span').textContent = locale.give_piece || '';
  throwBtn.querySelector('span').textContent = locale.throw_piece || '';
  giveCenterBtn.querySelector('span').textContent = locale.give_center_piece || '';
  finishBtn.querySelector('span').textContent = locale.open_hand || '';
  your_turn = locale.turn.your_turn || '';
  waiting = locale.turn.waiting || '';
}

const keyDownHandler = async (e) => {
  if (e.key === 'e' || e.key === 'E') {
    e.preventDefault();
    await fetchNui('exitTable');
  } else if (e.key === 'w' || e.key === 'W') {
    e.preventDefault();
    await fetchNui('lookAround');
  }
};

document.addEventListener("DOMContentLoaded", async () => {
  const data = await fetchNui('domReady', {})
  setLocale(data);
  slotInit();

  startGameBtn?.addEventListener('click', async () => {
    toggleStartMenu(false);
    await fetchNui('startGame');
  });

  finishBtn?.addEventListener('click', (e) => {
    if (isMyTurn && mustThrow) {
      forceButtonVisibility(finishBtn, false);
      forceButtonVisibility(throwBtn, false);
      fetchNui('openHand');
    }
  });

  document.addEventListener('keydown', keyDownHandler);

  setTimeout(() => {
    if (typeof isMyTurn !== 'undefined') {
      updateButtonStates();
    }
  }, 100);
});
