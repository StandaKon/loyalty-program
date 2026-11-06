const moneyFormatter = new Intl.NumberFormat('cs-CZ', { maximumFractionDigits: 2 });
const state = { items: [], posTransactionId: null, isSubmitting: false };

const elements = Object.fromEntries(
    [
        'memberNumber', 'liters', 'pricePerLiter', 'customAmount', 'fuelTotal', 'summaryFuel', 'summaryShop',
        'grandTotal', 'payTotal', 'payButton', 'receiptLines', 'clearButton', 'fillDemoButton', 'connectionText',
        'resultModal', 'resultMember', 'resultPoints', 'resultFuelPoints', 'resultShopPoints',
        'resultCampaignPoints', 'resultBalance', 'resultReference', 'newPurchaseButton', 'toast', 'clock',
    ].map((id) => [id, document.getElementById(id)]),
);

document.querySelectorAll('#products button').forEach((button) => {
    button.addEventListener('click', () => {
        state.items.push({ id: crypto.randomUUID(), name: button.dataset.name, price: Number(button.dataset.price) });
        state.posTransactionId = null;
        render();
    });
});

[elements.liters, elements.pricePerLiter, elements.customAmount, elements.memberNumber].forEach((input) => {
    input.addEventListener('input', () => {
        state.posTransactionId = null;
        render();
    });
});

elements.receiptLines.addEventListener('click', (event) => {
    const removeButton = event.target.closest('[data-remove-id]');
    if (!removeButton) return;
    state.items = state.items.filter((item) => item.id !== removeButton.dataset.removeId);
    state.posTransactionId = null;
    render();
});

elements.clearButton.addEventListener('click', () => resetPurchase(false));
elements.newPurchaseButton.addEventListener('click', () => resetPurchase(true));
elements.fillDemoButton.addEventListener('click', fillDemoPurchase);
elements.payButton.addEventListener('click', submitPurchase);

setInterval(updateClock, 1000);
updateClock();
checkConnection();
restoreDraft();
render();

function totals() {
    const liters = numberValue(elements.liters);
    const fuelAmount = roundMoney(liters * numberValue(elements.pricePerLiter));
    const itemAmount = state.items.reduce((sum, item) => sum + item.price, 0);
    const otherAmount = roundMoney(itemAmount + numberValue(elements.customAmount));
    return { liters, fuelAmount, otherAmount, totalAmount: roundMoney(fuelAmount + otherAmount) };
}

function render() {
    const currentTotals = totals();
    elements.fuelTotal.textContent = formatMoney(currentTotals.fuelAmount);
    elements.summaryFuel.textContent = formatMoney(currentTotals.fuelAmount);
    elements.summaryShop.textContent = formatMoney(currentTotals.otherAmount);
    elements.grandTotal.textContent = formatMoney(currentTotals.totalAmount);
    elements.payTotal.textContent = formatMoney(currentTotals.totalAmount);
    elements.payButton.disabled = state.isSubmitting || !elements.memberNumber.value.trim() || currentTotals.totalAmount <= 0;
    elements.payButton.querySelector('span').textContent = state.isSubmitting ? 'Odesílám do Salesforce…' : 'Zaplatit';

    const lines = [];
    if (currentTotals.fuelAmount > 0) {
        lines.push(`<div class="receipt-line"><div><strong>Palivo</strong><br><small>${moneyFormatter.format(currentTotals.liters)} l</small></div><strong>${formatMoney(currentTotals.fuelAmount)}</strong><span></span></div>`);
    }
    state.items.forEach((item) => {
        lines.push(`<div class="receipt-line"><div><strong>${escapeHtml(item.name)}</strong></div><strong>${formatMoney(item.price)}</strong><button type="button" data-remove-id="${item.id}" aria-label="Odebrat ${escapeHtml(item.name)}">×</button></div>`);
    });
    const customAmount = numberValue(elements.customAmount);
    if (customAmount > 0) {
        lines.push(`<div class="receipt-line"><div><strong>Jiné zboží</strong></div><strong>${formatMoney(customAmount)}</strong><span></span></div>`);
    }
    elements.receiptLines.innerHTML = lines.length
        ? lines.join('')
        : '<div class="empty-receipt"><span>+</span><p>Přidej palivo nebo zboží</p></div>';
    saveDraft();
}

async function submitPurchase() {
    const memberNumber = elements.memberNumber.value.trim().toUpperCase();
    const currentTotals = totals();
    if (!memberNumber || currentTotals.totalAmount <= 0 || state.isSubmitting) return;

    state.isSubmitting = true;
    state.posTransactionId ||= createPosTransactionId();
    render();

    try {
        const response = await fetch('/api/transactions', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                memberNumber,
                posTransactionId: state.posTransactionId,
                purchasedAt: new Date(Date.now() - 1000).toISOString(),
                liters: currentTotals.liters,
                fuelAmount: currentTotals.fuelAmount,
                otherAmount: currentTotals.otherAmount,
                totalAmount: currentTotals.totalAmount,
            }),
        });
        const result = await response.json();
        if (!response.ok) throw new Error(result.message || 'Salesforce transakci odmítl.');
        showResult(result);
    } catch (error) {
        showToast(error.message || 'Platbu se nepodařilo odeslat.');
    } finally {
        state.isSubmitting = false;
        render();
    }
}

function showResult(result) {
    elements.resultMember.textContent = `Člen ${result.memberNumber}`;
    elements.resultPoints.textContent = `+${result.awardedPoints ?? 0}`;
    elements.resultFuelPoints.textContent = `+${result.baseFuelPoints ?? 0}`;
    elements.resultShopPoints.textContent = `+${result.baseOtherPoints ?? 0}`;
    elements.resultCampaignPoints.textContent = `+${result.campaignPoints ?? 0}`;
    elements.resultBalance.textContent = `${result.memberBalance ?? 0} bodů`;
    elements.resultReference.textContent = result.isReplay
        ? `Opakovaný požadavek – vrácen původní výsledek ${result.posTransactionId}`
        : `Transakce ${result.posTransactionId}`;
    elements.resultModal.hidden = false;
}

function fillDemoPurchase() {
    elements.liters.value = '45';
    elements.pricePerLiter.value = '38';
    elements.customAmount.value = '0';
    state.items = [
        { id: crypto.randomUUID(), name: 'Káva', price: 60 },
        { id: crypto.randomUUID(), name: 'Bageta', price: 90 },
        { id: crypto.randomUUID(), name: 'Voda', price: 30 },
    ];
    state.posTransactionId = null;
    elements.memberNumber.focus();
    render();
}

function resetPurchase(keepMember) {
    state.items = [];
    state.posTransactionId = null;
    elements.liters.value = '0';
    elements.pricePerLiter.value = '38';
    elements.customAmount.value = '0';
    if (!keepMember) elements.memberNumber.value = '';
    elements.resultModal.hidden = true;
    localStorage.removeItem('eneoil-pos-draft');
    render();
}

async function checkConnection() {
    const container = elements.connectionText.parentElement;
    try {
        const response = await fetch('/api/status');
        const status = await response.json();
        container.classList.toggle('connected', status.connected);
        container.classList.toggle('failed', !status.connected);
        elements.connectionText.textContent = status.mode === 'demo'
            ? 'Demo režim'
            : status.connected ? 'Salesforce připojen' : 'Salesforce odpojen';
    } catch {
        container.classList.add('failed');
        elements.connectionText.textContent = 'Server odpojen';
    }
}

function saveDraft() {
    localStorage.setItem('eneoil-pos-draft', JSON.stringify({
        memberNumber: elements.memberNumber.value,
        liters: elements.liters.value,
        pricePerLiter: elements.pricePerLiter.value,
        customAmount: elements.customAmount.value,
        items: state.items,
    }));
}

function restoreDraft() {
    try {
        const draft = JSON.parse(localStorage.getItem('eneoil-pos-draft'));
        if (!draft) return;
        elements.memberNumber.value = draft.memberNumber || '';
        elements.liters.value = draft.liters || '0';
        elements.pricePerLiter.value = draft.pricePerLiter || '38';
        elements.customAmount.value = draft.customAmount || '0';
        state.items = Array.isArray(draft.items) ? draft.items : [];
    } catch {
        localStorage.removeItem('eneoil-pos-draft');
    }
}

function createPosTransactionId() {
    const timestamp = new Date().toISOString().replace(/\D/g, '').slice(0, 17);
    return `ENE-POS01-${timestamp}-${crypto.randomUUID().slice(0, 8).toUpperCase()}`;
}

function updateClock() {
    elements.clock.textContent = new Intl.DateTimeFormat('cs-CZ', { dateStyle: 'medium', timeStyle: 'medium' }).format(new Date());
}

function showToast(message) {
    elements.toast.textContent = message;
    elements.toast.hidden = false;
    clearTimeout(showToast.timeoutId);
    showToast.timeoutId = setTimeout(() => { elements.toast.hidden = true; }, 6500);
}

function numberValue(element) {
    const value = Number(element.value);
    return Number.isFinite(value) && value >= 0 ? value : 0;
}

function roundMoney(value) { return Math.round((value + Number.EPSILON) * 100) / 100; }
function formatMoney(value) { return `${moneyFormatter.format(value)} Kč`; }
function escapeHtml(value) {
    return String(value).replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character]);
}
