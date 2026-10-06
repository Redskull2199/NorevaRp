const menu = document.getElementById('tow-menu');
const countdownTimer = document.getElementById('countdown-timer');
const progressBar = document.getElementById('progress-bar');
const statusText = document.getElementById('tow-status-text');
const statusIndicator = document.getElementById('status-indicator');

let maxTime = 15;
let currentTime = 15;

window.addEventListener('message', function(event) {
    const data = event.data;
    switch(data.action) {
        case 'openMenu':
            openMenu(data);
            break;
        case 'updateCountdown':
            updateCountdown(data.time);
            break;
        case 'updateStatus':
            updateStatus(data.status, data.statusColor);
            break;
        case 'closeMenu':
            closeMenu();
            break;
    }
});

function openMenu(data) {
    maxTime = data.time || 15;
    currentTime = maxTime;
    countdownTimer.classList.remove('warning', 'critical');
    statusIndicator.style.background = '#60a5fa';
    statusText.textContent = 'Yola çıktı...';

    progressBar.style.width = '0%';
    menu.classList.remove('hidden');
    updateCountdown(currentTime);
}

function updateCountdown(time) {
    currentTime = time;
    countdownTimer.textContent = time;
    countdownTimer.classList.remove('warning', 'critical');

    if (time <= 5 && time > 3) {
        countdownTimer.classList.add('warning');
        statusText.textContent = 'Yaklaşıyor...';
        statusIndicator.style.background = '#93c5fd';
    } else if (time <= 3 && time > 1) {
        countdownTimer.classList.add('critical');
        statusText.textContent = 'Araçlar çekildi.';
        statusIndicator.style.background = '#60a5fa';
    } else if (time <= 1) {
        countdownTimer.classList.add('critical');
        statusText.textContent = 'Yerel çekiciler şehirden ayrıldı.';
        statusIndicator.style.background = '#60a5fa';
    } else {
        statusText.textContent = 'Yola çıktı...';
    }
    updateProgress();
}

function updateStatus(text, color) {
    statusText.textContent = text;
    if (color) {
        statusIndicator.style.background = color;
        statusIndicator.style.animation = 'none';
    }
}

function updateProgress() {
    const percentage = ((maxTime - currentTime) / maxTime) * 100;
    progressBar.style.width = percentage + '%';
}

function closeMenu() {
    menu.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({})
    }).catch(err => console.log('Menu kapatma sinyali gönderildi.'));
}