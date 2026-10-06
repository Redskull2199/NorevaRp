function showSection(sectionName) {
    const sections = document.querySelectorAll('.section');
    const buttons = document.querySelectorAll('.nav-button');
    const loadingIndicator = document.getElementById('loading');

    sections.forEach(section => {
        section.style.display = 'none';
    });

    buttons.forEach(button => {
        button.classList.remove('active');
    });
    const activeSection = document.getElementById(sectionName);
    if (activeSection) {
        activeSection.style.display = 'block';
    }

    const activeButton = document.querySelector(`.nav-button[onclick="showSection('${sectionName}')"]`);
    if (activeButton) {
        activeButton.classList.add('active'); 
    }


    if (sectionName === 'society-invoices') {
        fetch(`https://d-invoices/getSocietyInvoices`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(response => response.json()).then(data => {
            updateSocietyInvoices(data.invoices)
    });
    }
}



window.addEventListener('message', function(event) {
    const data = event.data;
    const invoiceMenu = document.getElementById('invoice-menu');
    
    if (data.type === 'showInvoiceMenu') {
        document.body.style.display = 'flex';
        invoiceMenu.style.display = 'flex';
        document.getElementById('overlay').style.display = 'block';
        showSection('dashboard');
        invoiceMenu.classList.remove('hide');

    } else if (data.type === 'updateDashboard') {
        updateDashboard(data);

    } else if (data.type === 'updateYourBillings') {
        updateYourBillings(data.bills);

    } else if (data.type === 'updateHistory') {
        updateHistory(data.history);
    } else if (data.type === 'hideInvoiceMenu') {
        document.body.style.display = 'none';
        invoiceMenu.style.display = 'none';
        document.getElementById('overlay').style.display = 'none';
    } else if (data.type === 'showCreateBillMenu') {
        document.body.style.display = 'flex';
        invoiceMenu.style.display = 'flex';
        invoiceMenu.classList.remove('hide');
        showSection('create-bill');
    } else if (data.type === 'showSocietyInvoices') {
        const societyInvoicesButton = document.querySelector("button[onclick=\"showSection('society-invoices')\"]");
        const societyInvoicesSection = document.getElementById('society-invoices');

        if (data.show) {
            if (societyInvoicesButton) societyInvoicesButton.style.display = 'block'; 
            if (societyInvoicesSection) societyInvoicesSection.style.display = 'none'; 
        } else {
            if (societyInvoicesButton) societyInvoicesButton.style.display = 'none';
            if (societyInvoicesSection) societyInvoicesSection.style.display = 'none'; 
        }
    }
});


function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}



function submitBill() {
    const playerId = document.getElementById('player-id-input').value;
    const amount = document.getElementById('amount-input').value;
    const reason = document.getElementById('reason-input').value;
    const comment = document.getElementById('comment-input').value;

    fetch('https://d-invoices/submitBill', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: playerId,
            amount: amount,
            reason: reason,
            comment: comment,
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to create bill');
        }
        return response.json();
    })
    .then(() => {
        document.getElementById('create-bill-form').reset();
        closeMenu();
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred while creating the bill. Please try again.');
    });
}

function updateDashboard(data) {
    document.getElementById('total-bills').textContent = data.totalBills || 0;
    document.getElementById('paid-bills').textContent = data.paidBills || 0;
    document.getElementById('unpaid-bills').textContent = data.unpaidBills || 0;
}

function updateYourBillings(bills) {
    const billingsList = document.getElementById('billings-list');
    billingsList.innerHTML = '';

    if (!Array.isArray(bills)) {
        console.error('Invalid bills data:', bills);
        return;
    }

    bills.forEach(bill => {
        if (bill.status === 'Ödenmemiş') { 
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${bill.id}</td>
                <td>$${bill.amount}</td>
                <td>${bill.status}</td>
                <td>${bill.reason}</td>
                <td>${bill.organization}</td>
                <td>${bill.created_at ? formatDate(bill.created_at) : 'N/A'}</td>     
            `;
            row.onclick = function() {
                payBillModal(bill);
            };
            billingsList.appendChild(row);
        }
    });
}

function updateHistory(history) {
    const historyList = document.getElementById('history-list');
    historyList.innerHTML = '';

    if (!Array.isArray(history)) {
        console.error('Invalid history data:', history);
        return; 
    }

    history.forEach(bill => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${bill.id}</td>
            <td>$${bill.amount}</td>
            <td>${bill.status}</td>
            <td>${bill.reason}</td> 
            <td>${bill.organization}</td>
            <td>${bill.created_at ? formatDate(bill.created_at) : 'N/A'}</td>                
        `;
        historyList.appendChild(row);
    });
}

function cancelInvoice(invoiceId) {
    fetch(`https://d-invoices/cancelInvoice`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ invoiceId: invoiceId })
    }).then(response => {
        if (!response.ok) {
            fetchBillsAndHistory()
        }
        return response.json();
    }).catch(error => console.error('Error sending cancel request:', error));
}


function updateSocietyInvoices(invoices) {
    const societyInvoicesList = document.getElementById('society-invoices-list');
    societyInvoicesList.innerHTML = '';

    if (!invoices || !Array.isArray(invoices)) {
        console.error('Invalid invoices data:', invoices);
        return; 
    }

    invoices.forEach(invoice => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${invoice.id}</td>
            <td>$${invoice.amount}</td>
            <td>${invoice.status}</td>
            <td>${invoice.reason}</td>
           <td>${invoice.receiver}</td>
            <td>${invoice.organization}</td>
            <td>
                <button class="action-btn" onclick="cancelInvoice(${invoice.id})">Cancel</button>
            </td>
        `;
        societyInvoicesList.appendChild(row);
    });
}



function payBill(billId) {
    fetch(`https://d-invoices/payBill`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ billId: billId })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to pay bill');
        }
        return response.json();
    })
    .then(() => {
        fetchBillsAndHistory(); 
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred while paying the bill. Please try again.');
    });
    closePayBillModal();
}


function fetchBillsAndHistory() {
    $.post('https://d-invoices/fetchBills', JSON.stringify({}));
    $.post('https://d-invoices/fetchHistory', JSON.stringify({}));
    $.post('https://d-invoices/getSocietyInvoices', JSON.stringify({}));
}


function payBillModal(bill) {
    const modal = document.getElementById('payment-modal');
    modal.style.display = 'flex';
    const buttonContainer = document.getElementById('paybill-buttons');
    buttonContainer.innerHTML = ''; 

    // Create and append the 'Pay' button
    const payButton = document.createElement('button');
    payButton.className = 'action-btn';
    payButton.textContent = 'Pay';
    payButton.onclick = function() {
        payBill(bill.id); 
        closePayBillModal(); 
    };
    

    const cancelButton = document.createElement('button');
    cancelButton.className = 'action-btn';
    cancelButton.textContent = 'Cancel';
    cancelButton.onclick = function() {
        closeModal(); 
    };


    buttonContainer.appendChild(payButton);
    buttonContainer.appendChild(cancelButton);
}

function closePayBillModal() {
    const modal = document.getElementById('payment-modal');
    modal.style.display = 'none';
}


function closeMenu() {
    const invoiceMenu = document.getElementById('invoice-menu');
    invoiceMenu.classList.add('hide');
    setTimeout(() => {
        document.body.style.display = 'none';
        invoiceMenu.style.display = 'none';
        document.getElementById('overlay').style.display = 'none';
        $.post('https://d-invoices/closeMenu', JSON.stringify({}));
    }, 500); 
}
