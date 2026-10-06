import { fetchNui } from "../utils/fetchNui.js";
import soundPlayer from "./soundPlayer.js";

let lastSelectedSlot = null;

export default function slotInit() {

  const istaka = document.querySelector('.istaka');

  const createRow = (className, start, end) => {
    const row = document.createElement('div');
    row.className = `row ${className}`;

    for (let i = start; i <= end; i++) {
      row.appendChild(
        Object.assign(document.createElement('div'), {
          className: 'slot',
          id: `slot-${i}`
        })
      );
    }
    return row;
  };

  istaka.appendChild(createRow('top-row', 1, 13));
  istaka.appendChild(createRow('bottom-row', 14, 26));


  document.querySelector('.istaka').addEventListener('click', (e) => {
    const slotEl = e.target.closest('.slot');
    if (slotEl) {
      const slotId = parseInt(slotEl.id.split('-')[1]);
      if (!isNaN(slotId)) {
        slotClick(slotId);
      }
    }
  });

  const slotClick = async function (id) {
    if (id > 26 || id < 1 || typeof id !== "number") {
      return;
    }

    lastSelectedSlot = id || null;

    soundPlayer.playRandomClick();
    await fetchNui("selectedSlotNumber", id);
  };

  document.querySelector('#give').addEventListener('click', async () => {
    soundPlayer.playRandomClick();
    await fetchNui("recievePiece");
  });

  document.querySelector('#throw').addEventListener('click', async () => {
    if (!lastSelectedSlot) return;

    if (lastSelectedSlot > 26 || lastSelectedSlot < 1 || typeof lastSelectedSlot !== "number") {
      return;
    }

    soundPlayer.playRandomClick();
    await fetchNui("throwPiece", lastSelectedSlot);

    lastSelectedSlot = null;
  });

  document.querySelector('#give-center').addEventListener('click', async () => {
    soundPlayer.playRandomClick();
    await fetchNui("getNewPieceCenter");
  });
}