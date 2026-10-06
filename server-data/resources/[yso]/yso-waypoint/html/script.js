const waypoint = document.getElementById('waypoint');
const distanceText = waypoint.querySelector('.distance');
const settingsPanel = document.getElementById('settings-panel');

// Smooth pozisyon interpolasyonu
let currentX = 0.5, currentY = 0.5;
let targetX  = 0.5, targetY  = 0.5;
let isVisible = false;
const LERP_SPEED = 0.18; // 0 = hareketsiz, 1 = anlık — 0.18 akıcı görünür

function lerp(a, b, t) { return a + (b - a) * t; }

function animatePosition() {
    if (isVisible) {
        currentX = lerp(currentX, targetX, LERP_SPEED);
        currentY = lerp(currentY, targetY, LERP_SPEED);
        waypoint.style.left = (currentX * 100) + '%';
        waypoint.style.top  = (currentY * 100) + '%';
    }
    requestAnimationFrame(animatePosition);
}
animatePosition();

const toggleInput = document.getElementById('toggle-waypoint');
const colorInput = document.getElementById('color-picker');
const shapeInput = document.getElementById('shape-selector'); 
const unitInput = document.getElementById('unit-selector');

const colorPreview = document.getElementById('color-preview-circle');
const colorCodeText = document.getElementById('color-code-text');

let currentUnitSystem = 'metric'; 

function updateLocales(locales) {
    if (!locales) return;

    const setText = (id, text) => {
        const el = document.getElementById(id);
        if (el && text) el.textContent = text;
    };

    setText('txt-title', locales.settings_title);
    setText('lbl-indicator', locales.label_indicator);
    setText('desc-indicator', locales.desc_indicator);
    setText('lbl-color', locales.label_color);
    setText('desc-color', locales.desc_color);
    setText('lbl-shape', locales.label_shape);
    setText('desc-shape', locales.desc_shape);
    setText('lbl-unit', locales.label_unit);
    setText('desc-unit', locales.desc_unit);
    setText('btn-save', locales.btn_save);

    setText('opt-circle', locales.shape_circle);
    setText('opt-rounded', locales.shape_rounded);
    setText('opt-square', locales.shape_square);
    setText('opt-diamond', locales.shape_diamond);
    setText('opt-rectangle', locales.shape_rectangle);
    setText('opt-metric', locales.unit_metric);
    setText('opt-imperial', locales.unit_imperial);
}

function updateColor(color) {
    if (!color) return;
    document.documentElement.style.setProperty('--accent', color);
    colorPreview.style.backgroundColor = color;
    if (colorCodeText) {
        colorCodeText.textContent = color.toUpperCase ? color.toUpperCase() : color;
    }
}

function updateShape(shape) {
    if (shape) waypoint.setAttribute('data-shape', shape);
}

colorInput.addEventListener('input', (e) => updateColor(e.target.value));
shapeInput.addEventListener('change', (e) => updateShape(e.target.value));

const closeBtn = document.getElementById('btn-close');
if (closeBtn) {
    closeBtn.addEventListener('click', () => {
        settingsPanel.style.display = 'none';
        
        const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'waypoint-script';
        fetch(`https://${resourceName}/closeSettings`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ save: false }) 
        }).catch(err => {});
    });
}
document.getElementById('btn-save').addEventListener('click', () => {
    const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'waypoint-script';
    
    fetch(`https://${resourceName}/closeSettings`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({
            save: true, 
            enabled: toggleInput.checked,
            color: colorInput.value,
            shape: shapeInput.value, 
            unit: unitInput.value
        })
    }).catch(err => console.log('Fetch Error:', err));
    
    currentUnitSystem = unitInput.value;
    settingsPanel.style.display = 'none';
});

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'loadSettings' || data.action === 'openSettings') {
        
        if (data.locales) updateLocales(data.locales);

        if (data.enabled !== undefined) toggleInput.checked = data.enabled;
        else if (data.currentEnabled !== undefined) toggleInput.checked = data.currentEnabled;
        
        const clr = data.color || data.currentColor || '#3b82f6';
        colorInput.value = clr;
        updateColor(clr);

        const shp = data.shape || data.currentShape || 'circle';
        shapeInput.value = shp;
        updateShape(shp);

        const unt = data.unit || data.currentUnit || 'metric';
        unitInput.value = unt;
        currentUnitSystem = unt;
        
        if (data.action === 'openSettings') {
            settingsPanel.style.display = 'block';
        }
    }
    
    else if (data.action === 'update') {
        if (data.show) {
            // Hedef koordinatı güncelle — animatePosition() lerp ile takip eder
            targetX = data.x;
            targetY = data.y;
            isVisible = true;
            
            let distMeters = data.distance;
            let displayUrl = "";
            let unitSystem = data.unitSystem || currentUnitSystem;

            if (unitSystem === 'imperial') {
                let distYards = distMeters * 1.09361;
                displayUrl = distYards >= 1760 ? (distYards / 1760).toFixed(1) + ' mi' : Math.floor(distYards) + ' yd';
            } else {
                displayUrl = distMeters >= 1000 ? (distMeters / 1000).toFixed(1) + ' km' : Math.floor(distMeters) + ' m';
            }

            distanceText.textContent = displayUrl;
            waypoint.classList.add('active');
        } else {
            isVisible = false;
            waypoint.classList.remove('active');
        }
    }
});