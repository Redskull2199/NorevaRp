function postNUI(name, data, cb) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", `https://${GetParentResourceName()}/${name}`, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            if (cb) {
                try {
                    cb(JSON.parse(xhr.responseText));
                } catch(e) {}
            }
        }
    };
    xhr.send(JSON.stringify(data || {}));
}

let cachedBankData = null;
let currentLocales = {};

function applyLocales(locales) {
    if (!locales) return;
    currentLocales = locales;
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (locales[key]) {
            if (el.tagName === 'INPUT' && el.hasAttribute('placeholder')) {
                el.setAttribute('placeholder', locales[key]);
            } else {
                const icon = el.querySelector('i');
                if (icon) {
                    el.innerHTML = '';
                    el.appendChild(icon);
                    el.appendChild(document.createTextNode(' ' + locales[key]));
                } else {
                    el.innerText = locales[key];
                }
            }
        }
    });
}

let cashflowChart = null;

let particlesInitialized = false;

window.addEventListener('message', function (event) {
    let action = event.data.action;
    
    if (action === 'openBank') {
        if (event.data.locales) applyLocales(event.data.locales);
        document.getElementById('app').style.display = 'flex';
        document.getElementById('bank-ui').style.display = 'flex';
        document.getElementById('atm-ui').style.display = 'none';
        
        if (!particlesInitialized) {
            initParticles();
            particlesInitialized = true;
        }

        cachedBankData = event.data.data;
        updateBankUI(cachedBankData);
    } 
    else if (action === 'openAtmLogin') {
        if (event.data.locales) applyLocales(event.data.locales);
        document.getElementById('app').style.display = 'flex';
        document.getElementById('bank-ui').style.display = 'none';
        document.getElementById('atm-ui').style.display = 'flex';
        document.getElementById('atm-login').classList.add('active');
        document.getElementById('atm-main').classList.remove('active');
        
        if (!particlesInitialized) {
            initParticles();
            particlesInitialized = true;
        }

        atmPin = '';
        atmAmount = '';
        const pinDisp = document.getElementById('atm-pin-display');
        if (pinDisp) pinDisp.textContent = '_ _ _ _';
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

function closeUI() {
    const bankUI = document.getElementById('bank-ui');
    const atmUI = document.getElementById('atm-ui');
    
    if (bankUI.style.display !== 'none') {
        bankUI.classList.add('closing');
    }
    if (atmUI.style.display !== 'none') {
        atmUI.classList.add('closing');
    }

    setTimeout(() => {
        document.getElementById('app').style.display = 'none';
        bankUI.classList.remove('closing');
        atmUI.classList.remove('closing');
        postNUI('close', {});
    }, 280);
}

document.querySelectorAll('.close-btn').forEach(btn => {
    btn.addEventListener('click', closeUI);
});

const navBtns = document.querySelectorAll('.nav-btn');
const tabContents = document.querySelectorAll('.tab-content');

navBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = btn.getAttribute('data-target');
        
        navBtns.forEach(b => b.classList.remove('active'));
        tabContents.forEach(t => t.classList.remove('active'));
        
        btn.classList.add('active');
        document.getElementById(targetId).classList.add('active');

        if (targetId === 'transactions') {
            postNUI('getBankingData', {}, updateBankUI);
        }
    });
});

function updateBankUI(data) {
    if (!data) return;

    const balanceNum = Number(data.balance) || 0;
    document.getElementById('user-name').textContent = data.name;
    document.getElementById('bank-balance').textContent = `$${balanceNum.toLocaleString()}`;

    const cardNameDisplay = document.getElementById('card-name-display');
    if (cardNameDisplay) {
        cardNameDisplay.textContent = data.card && data.card.card_name ? data.card.card_name : 'YOUR NAME HERE';
    }

    const cardNumberDisplay = document.querySelector('.card-number');
    if (cardNumberDisplay) {
        cardNumberDisplay.textContent = data.card && data.card.card_number ? data.card.card_number : '•••• •••• •••• ••••';
    }

    const cardCreationForm = document.getElementById('card-creation-form');
    const cardManagement = document.getElementById('card-management');
    const cardInfoName = document.getElementById('card-info-name');

    if (data.card && data.card.card_name && data.card.pin) {
        if (cardCreationForm) cardCreationForm.style.display = 'none';
        if (cardManagement) cardManagement.style.display = 'grid';
        if (cardInfoName) cardInfoName.textContent = data.card.card_name;
    } else {
        if (cardCreationForm) cardCreationForm.style.display = 'block';
        if (cardManagement) cardManagement.style.display = 'none';
    }

    const txList = document.getElementById('tx-list');
    const historyList = document.getElementById('history-list');
    txList.innerHTML = '';
    if(historyList) historyList.innerHTML = '';

    let dailyMap = new Map();
    let txHtml = '';
    let historyHtml = '';

    if (data.transactions && data.transactions.length > 0) {
        data.transactions.forEach((tx, index) => {
            const isPositive = (tx.type === 'deposit' || tx.type === 'transfer_in');
            const amountClass = isPositive ? 'positive' : 'negative';
            const sign = isPositive ? '+' : '-';

            const txAmount = Number(tx.amount) || 0;
            const dateObj = new Date(tx.date);
            const dateFull = dateObj.toLocaleString();
            const dateShort = dateObj.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });

            const html = `
                <li>
                    <div class="tx-info">
                        <span class="tx-title">${tx.title}</span>
                        <span class="tx-date">${dateFull}</span>
                    </div>
                    <div class="tx-amount ${amountClass}">${sign}$${txAmount.toLocaleString()}</div>
                </li>
            `;

            historyHtml += html;
            if (index < 4) {
                txHtml += html;
            }

            if (!dailyMap.has(dateShort)) {
                dailyMap.set(dateShort, { income: 0, outcome: 0 });
            }
            if (isPositive) {
                dailyMap.get(dateShort).income += txAmount;
            } else {
                dailyMap.get(dateShort).outcome += txAmount;
            }
        });

    } else {
        const emptyLi = '<li><div class="tx-info"><span class="tx-title">No recent transactions.</span></div></li>';
        txHtml = emptyLi;
        historyHtml = emptyLi;
        const today = new Date().toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
        dailyMap.set(today, { income: 0, outcome: 0 });
    }

    txList.innerHTML = txHtml;
    if(historyList) historyList.innerHTML = historyHtml;

    let labels = Array.from(dailyMap.keys()).reverse();
    let incomeData = [];
    let outcomeData = [];

    labels.forEach(l => {
        incomeData.push(dailyMap.get(l).income);
        outcomeData.push(dailyMap.get(l).outcome);
    });

    if(labels.length > 14) {
        labels = labels.slice(-14);
        incomeData = incomeData.slice(-14);
        outcomeData = outcomeData.slice(-14);
    }

    renderChart(labels, incomeData, outcomeData);
}

function renderChart(labels, incomeData, outcomeData) {
    const ctx = document.getElementById('cashflowChart').getContext('2d');
    
    if (cashflowChart) {
        cashflowChart.destroy();
    }

    cashflowChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Income',
                    data: incomeData,
                    backgroundColor: '#32d74b',
                    borderRadius: 4
                },
                {
                    label: 'Outcome',
                    data: outcomeData,
                    backgroundColor: '#ff453a',
                    borderRadius: 4
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
                mode: 'index',
            },
            plugins: {
                legend: { 
                    display: true,
                    labels: { color: '#8e8e93', usePointStyle: true, boxWidth: 8 }
                },
                tooltip: {
                    backgroundColor: 'rgba(0,0,0,0.8)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    borderColor: 'rgba(255,255,255,0.2)',
                    borderWidth: 1,
                    callbacks: {
                        label: function(context) {
                            return context.dataset.label + ': $' + context.parsed.y.toLocaleString();
                        }
                    }
                }
            },
            scales: {
                x: { 
                    display: true,
                    grid: { display: false },
                    ticks: { color: '#8e8e93' }
                },
                y: { 
                    display: true,
                    position: 'right',
                    grid: { 
                        color: 'rgba(255,255,255,0.05)',
                        drawBorder: false
                    },
                    ticks: {
                        color: '#8e8e93',
                        callback: function(value) {
                            if (value >= 1000) {
                                return '$' + (value/1000).toFixed(1) + 'k';
                            }
                            return '$' + value;
                        }
                    }
                }
            }
        }
    });
}

document.getElementById('btn-deposit').addEventListener('click', () => {
    const amount = document.getElementById('deposit-amount').value;
    if (amount) {
        postNUI('deposit', { amount: amount }, resp => {
            if (resp && resp.success) {
                updateBankUI(resp.data);
                let msg = currentLocales['deposit_success'] ? currentLocales['deposit_success'].replace('%s', amount) : `Deposited $${amount}`;
                showNotification('success', msg);
            } else if (resp && resp.message) {
                showNotification('error', resp.message);
            }
        });
        document.getElementById('deposit-amount').value = '';
    }
});

document.getElementById('btn-withdraw').addEventListener('click', () => {
    const amount = document.getElementById('withdraw-amount').value;
    if (amount) {
        postNUI('withdraw', { amount: amount }, resp => {
            if (resp && resp.success) {
                updateBankUI(resp.data);
                let msg = currentLocales['withdraw_success'] ? currentLocales['withdraw_success'].replace('%s', amount) : `Withdrew $${amount}`;
                showNotification('success', msg);
            } else if (resp && resp.message) {
                showNotification('error', resp.message);
            }
        });
        document.getElementById('withdraw-amount').value = '';
    }
});

document.getElementById('btn-transfer').addEventListener('click', () => {
    const id = document.getElementById('transfer-id').value;
    const amount = document.getElementById('transfer-amount').value;

    if (!id || !amount) {
        showNotification('error', 'Please enter target ID and amount');
        return;
    }

    const amountNum = Number(amount);
    if (isNaN(amountNum) || amountNum <= 0) {
        showNotification('error', 'Please enter a valid amount');
        return;
    }

    postNUI('transfer', { target: id, amount: amount }, resp => {
        if (resp && resp.success) {
            updateBankUI(resp.data);
            document.getElementById('transfer-id').value = '';
            document.getElementById('transfer-amount').value = '';
            showNotification('success', 'Transfer successful!');
        } else if (resp && resp.message) {
            showNotification('error', resp.message);
        } else {
            showNotification('error', 'Transfer failed');
        }
    });
});

document.getElementById('btn-create-card').addEventListener('click', () => {
    const name = document.getElementById('card-name-input').value;
    const pin = document.getElementById('pin-input').value;

    if (name && name.trim().length > 0 && pin.length === 4) {
        postNUI('createCard', { card_name: name, pin: pin }, resp => {
            if (resp.success) {
                const status = document.getElementById('creation-status');
                status.style.display = 'block';
                status.style.color = '#32d74b';
                status.textContent = 'Card created successfully!';
                setTimeout(() => { status.style.display = 'none'; }, 3000);
                document.getElementById('card-name-input').value = '';
                document.getElementById('pin-input').value = '';
                updateBankUI(resp.data);
            } else {
                const status = document.getElementById('creation-status');
                status.style.display = 'block';
                status.style.color = '#ff453a';
                status.textContent = resp.message || 'Failed to create card';
                setTimeout(() => { status.style.display = 'none'; }, 3000);
            }
        }).catch(err => {
            console.error('Create card error:', err);
            const status = document.getElementById('creation-status');
            status.style.display = 'block';
            status.style.color = '#ff453a';
            status.textContent = 'Error creating card';
            setTimeout(() => { status.style.display = 'none'; }, 3000);
        });
    } else {
        const status = document.getElementById('creation-status');
        status.style.display = 'block';
        status.style.color = '#ff453a';
        status.textContent = 'Please enter a valid name and 4-digit PIN';
        setTimeout(() => { status.style.display = 'none'; }, 3000);
    }
});

document.getElementById('btn-reset-pin').addEventListener('click', () => {
    const currentPin = document.getElementById('current-pin').value;
    const newPin = document.getElementById('new-pin').value;

    if (currentPin.length === 4 && newPin.length === 4) {
        postNUI('resetPin', { current_pin: currentPin, new_pin: newPin }, resp => {
            if (resp.success) {
                const status = document.getElementById('pin-status');
                status.style.display = 'block';
                status.style.color = '#32d74b';
                status.textContent = 'PIN reset successfully!';
                setTimeout(() => { status.style.display = 'none'; }, 3000);
                document.getElementById('current-pin').value = '';
                document.getElementById('new-pin').value = '';
                updateBankUI(resp.data);
            } else {
                const status = document.getElementById('pin-status');
                status.style.display = 'block';
                status.style.color = '#ff453a';
                status.textContent = resp.message || 'Failed to reset PIN';
                setTimeout(() => { status.style.display = 'none'; }, 3000);
            }
        }).catch(err => {
            console.error('Reset PIN error:', err);
            const status = document.getElementById('pin-status');
            status.style.display = 'block';
            status.style.color = '#ff453a';
            status.textContent = 'Error resetting PIN';
            setTimeout(() => { status.style.display = 'none'; }, 3000);
        });
    }
});

let atmPin = '';
let atmAmount = '';

function updatePinDisplay() {
    const display = document.getElementById('atm-pin-display');
    if (!display) return;
    const filled = '●'.repeat(atmPin.length);
    const empty = '_ '.repeat(4 - atmPin.length).trim();
    display.textContent = atmPin.length === 0 ? '_ _ _ _' : (filled + (atmPin.length < 4 ? ' ' + empty : ''));
}

function updateAmountDisplay() {
    const display = document.getElementById('atm-amount-display');
    if (!display) return;
    display.textContent = atmAmount === '' ? '0' : '$' + Number(atmAmount).toLocaleString();
}

document.querySelectorAll('[data-val]').forEach(btn => {
    btn.addEventListener('click', () => {
        const val = btn.getAttribute('data-val');
        if (val === 'clear') {
            atmPin = atmPin.slice(0, -1);
            updatePinDisplay();
        } else if (val === 'enter') {
            if (atmPin.length === 4) {
                postNUI('loginAtm', { pin: atmPin }, resp => {
                    if (resp && resp.success) {
                        document.getElementById('atm-login').classList.remove('active');
                        document.getElementById('atm-main').classList.add('active');
                        updateAtmUI(resp.data);
                        atmAmount = '';
                        updateAmountDisplay();
                    } else {
                        atmPin = '';
                        updatePinDisplay();
                        showNotification('error', currentLocales['wrong_pin'] || 'Incorrect PIN');
                    }
                });
            }
        } else {
            if (atmPin.length < 4) {
                atmPin += val;
                updatePinDisplay();
            }
        }
    });
});

document.querySelectorAll('[data-atm-val]').forEach(btn => {
    btn.addEventListener('click', () => {
        const val = btn.getAttribute('data-atm-val');
        if (val === 'clear') {
            atmAmount = atmAmount.slice(0, -1);
            updateAmountDisplay();
        } else if (val === 'enter') {
           
        } else {
            if (atmAmount.length < 8) {
                atmAmount += val;
                updateAmountDisplay();
            }
        }
    });
});

function updateAtmUI(data) {
    if (!data) return;
    const balanceNum = Number(data.balance) || 0;
    document.getElementById('atm-balance').textContent = `$${balanceNum.toLocaleString()}`;
}

document.getElementById('btn-atm-withdraw').addEventListener('click', () => {
    const amount = atmAmount;
    if (amount && Number(amount) > 0) {
        postNUI('withdraw', { amount: amount }, resp => {
            if (resp && resp.success) {
                updateAtmUI(resp.data);
                let msg = currentLocales['withdraw_success'] ? currentLocales['withdraw_success'].replace('%s', amount) : `Withdrew $${amount}`;
                showNotification('success', msg);
            } else if (resp && resp.message) {
                showNotification('error', resp.message);
            }
        });
        atmAmount = '';
        updateAmountDisplay();
    }
});

document.getElementById('btn-atm-deposit').addEventListener('click', () => {
    const amount = atmAmount;
    if (amount && Number(amount) > 0) {
        postNUI('deposit', { amount: amount }, resp => {
            if (resp && resp.success) {
                updateAtmUI(resp.data);
                let msg = currentLocales['deposit_success'] ? currentLocales['deposit_success'].replace('%s', amount) : `Deposited $${amount}`;
                showNotification('success', msg);
            } else if (resp && resp.message) {
                showNotification('error', resp.message);
            }
        });
        atmAmount = '';
        updateAmountDisplay();
    }
});


function showNotification(type, message) {
    const container = document.getElementById('notification-container');
    console.log('showNotification called:', type, message, container);
    if (!container) {
        console.error('Notification container not found!');
        return;
    }

    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div class="notification-icon">
            ${type === 'success' ? '<i class="fas fa-check-circle"></i>' : '<i class="fas fa-exclamation-circle"></i>'}
        </div>
        <div class="notification-message">${message}</div>
        <div class="notification-close"><i class="fas fa-times"></i></div>
    `;

    container.appendChild(notification);
    console.log('Notification added to container');

    setTimeout(() => {
        notification.classList.add('fade-out');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 4000);

    notification.querySelector('.notification-close').addEventListener('click', () => {
        notification.classList.add('fade-out');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    });
}

function initParticles() {
    if(typeof particlesJS !== 'undefined') {
        particlesJS('particles-js', {
            'particles': {
                'number': {'value': 80, 'density': {'enable': true, 'value_area': 800}},
                'color': {'value': '#000000'},
                'shape': {
                    'type': 'circle'
                },
                'opacity': {'value': 0.8, 'random': false, 'anim': {'enable': false}},
                'size': {'value': 2, 'random': true, 'anim': {'enable': false}},
                'line_linked': {'enable': false, 'distance': 150, 'color': '#000000', 'opacity': 0.2, 'width': 1},
                'move': {'enable': true, 'speed': 2, 'direction': 'bottom', 'random': true, 'straight': false, 'out_mode': 'out', 'bounce': false}
            },
            'interactivity': {
                'detect_on': 'canvas',
                'events': {
                    'onhover': {'enable': true, 'mode': 'grab'},
                    'onclick': {'enable': true, 'mode': 'push'},
                    'resize': true
                },
                'modes': {
                    'grab': {'distance': 140, 'line_linked': {'opacity': 1}},
                    'push': {'particles_nb': 4}
                }
            },
            'retina_detect': true
        });
    }
}

const particlesToggle = document.getElementById('particles-toggle');
if (particlesToggle) {
    particlesToggle.addEventListener('change', (e) => {
        const particlesDiv = document.getElementById('particles-js');
        if (particlesDiv) {
            particlesDiv.style.display = e.target.checked ? 'block' : 'none';
        }
    });
}
