let menuData = [];
let currentSubmenu = null;
let particleInterval = null;

let userSettings = {
    particlesEnabled: true,
    menuColor: '#1e1e1e',
    secondaryColor: '#ffffff',
    particleColor: '#000000',
    menuOpacity: 0.85,
    menuScale: 1.0
};

try {
    const saved = localStorage.getItem('rm_settings');
    if (saved) {
        userSettings = { ...userSettings, ...JSON.parse(saved) };
    }
} catch(e) {}

function hexToRgb(hex) {
    let r = 0, g = 0, b = 0;
    if (hex.length === 7) {
        r = parseInt(hex.substring(1, 3), 16);
        g = parseInt(hex.substring(3, 5), 16);
        b = parseInt(hex.substring(5, 7), 16);
    }
    return `${r},${g},${b}`;
}

function saveSettings() {
    localStorage.setItem('rm_settings', JSON.stringify(userSettings));
}

const useCustomSounds = true;
const hoverAudio = new Audio('sounds/hover.mp3');
hoverAudio.volume = 0.3;
const clickAudio = new Audio('sounds/click.mp3');
clickAudio.volume = 0.5;

function playSoundEffect(type) {
    if (useCustomSounds) {
        try {
            if (type === 'hover') {
                hoverAudio.currentTime = 0;
                hoverAudio.play().catch(()=>{});
            } else if (type === 'click') {
                clickAudio.currentTime = 0;
                clickAudio.play().catch(()=>{});
            }
        } catch (e) {}
    } else {
        fetch(`https://${GetParentResourceName()}/playSound`, {
            method: 'POST',
            body: JSON.stringify({ name: type })
        }).catch(()=>{});
    }
}

const qbIcons = {
    'user': 'fa-solid fa-user',
    'address-book': 'fa-solid fa-address-book',
    'car': 'fa-solid fa-car',
    'cannabis': 'fa-solid fa-cannabis',
    'engine': 'fa-solid fa-gear',
    'door-open': 'fa-solid fa-door-open',
    'box-open': 'fa-solid fa-box-open',
    'running': 'fa-solid fa-person-running',
    'music': 'fa-solid fa-music',
    'chair': 'fa-solid fa-chair',
    'backpack': 'fa-solid fa-bag-shopping',
    'mobile': 'fa-solid fa-mobile-screen-button',
    'shirt': 'fa-solid fa-shirt',
    'mask': 'fa-solid fa-mask-face',
    'glasses': 'fa-solid fa-glasses',
    'hat': 'fa-solid fa-hat-cowboy',
    'vest': 'fa-solid fa-vest'
};

function getIcon(iconName) {
    if (!iconName) return 'fa-solid fa-circle';
    if (qbIcons[iconName]) return qbIcons[iconName];
    if (iconName.startsWith('fa-')) return iconName;
    return `fa-solid fa-${iconName}`;
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'toggle') {
        const menu = document.getElementById('radial-menu');
        if (data.data.show) {
            menuData = data.data.items;
            menu.classList.remove('hidden');
            document.querySelector('.menu-container').classList.remove('closing');
            updateCenterButton();
            renderMenu(menuData);
            startParticles();
        } else {
            closeWithAnimation();
        }
    }
});

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('toggle-particles').checked = userSettings.particlesEnabled;
    document.getElementById('menu-color').value = userSettings.menuColor;
    document.getElementById('secondary-color').value = userSettings.secondaryColor;
    document.getElementById('particle-color').value = userSettings.particleColor;
    document.getElementById('menu-opacity').value = userSettings.menuOpacity;
    document.getElementById('menu-scale').value = userSettings.menuScale;

    const initialRgb = hexToRgb(userSettings.menuColor);
    document.documentElement.style.setProperty('--slice-color', `rgba(${initialRgb}, ${userSettings.menuOpacity})`);
    document.documentElement.style.setProperty('--slice-color-hover', `rgba(${initialRgb}, ${Math.min(userSettings.menuOpacity + 0.15, 1.0)})`);
    document.documentElement.style.setProperty('--menu-scale', userSettings.menuScale);
    document.documentElement.style.setProperty('--secondary-color', userSettings.secondaryColor);

    document.getElementById('settings-btn').addEventListener('click', () => {
        document.getElementById('settings-panel').classList.remove('hidden');
    });

    document.getElementById('close-settings-btn').addEventListener('click', () => {
        document.getElementById('settings-panel').classList.add('hidden');
    });

    document.getElementById('toggle-particles').addEventListener('change', (e) => {
        userSettings.particlesEnabled = e.target.checked;
        saveSettings();
        if (userSettings.particlesEnabled) {
            startParticles();
        } else {
            stopParticles();
        }
    });

    function updateGradients() {
        const rgb = hexToRgb(userSettings.secondaryColor);
        const grad1 = document.getElementById('slice-grad');
        const grad2 = document.getElementById('slice-grad-hover');
        if (grad1 && grad2) {
            grad1.innerHTML = `
                <stop offset="0%" stop-color="rgba(${rgb},0.6)" />
                <stop offset="100%" stop-color="rgba(${rgb},0.1)" />
            `;
            grad2.innerHTML = `
                <stop offset="0%" stop-color="rgba(${rgb},1.0)" />
                <stop offset="100%" stop-color="rgba(${rgb},0.4)" />
            `;
        }
    }

    document.getElementById('menu-color').addEventListener('input', (e) => {
        userSettings.menuColor = e.target.value;
        saveSettings();
        const rgb = hexToRgb(userSettings.menuColor);
        document.documentElement.style.setProperty('--slice-color', `rgba(${rgb}, ${userSettings.menuOpacity})`);
        document.documentElement.style.setProperty('--slice-color-hover', `rgba(${rgb}, ${Math.min(userSettings.menuOpacity + 0.15, 1.0)})`);
    });

    document.getElementById('secondary-color').addEventListener('input', (e) => {
        userSettings.secondaryColor = e.target.value;
        saveSettings();
        document.documentElement.style.setProperty('--secondary-color', userSettings.secondaryColor);
        updateGradients();
    });

    document.getElementById('menu-opacity').addEventListener('input', (e) => {
        userSettings.menuOpacity = parseFloat(e.target.value);
        saveSettings();
        const rgb = hexToRgb(userSettings.menuColor);
        document.documentElement.style.setProperty('--slice-color', `rgba(${rgb}, ${userSettings.menuOpacity})`);
        document.documentElement.style.setProperty('--slice-color-hover', `rgba(${rgb}, ${Math.min(userSettings.menuOpacity + 0.15, 1.0)})`);
    });

    document.getElementById('menu-scale').addEventListener('input', (e) => {
        userSettings.menuScale = parseFloat(e.target.value);
        saveSettings();
        document.documentElement.style.setProperty('--menu-scale', userSettings.menuScale);
    });

    document.getElementById('particle-color').addEventListener('input', (e) => {
        userSettings.particleColor = e.target.value;
        saveSettings();
    });
});

function closeWithAnimation() {
    const container = document.querySelector('.menu-container');
    container.classList.add('closing');
    document.getElementById('settings-panel').classList.add('hidden');
    stopParticles();
    setTimeout(() => {
        document.getElementById('radial-menu').classList.add('hidden');
        container.classList.remove('closing');
        clearMenu();
    }, 250);
}

function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
    const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
    return {
        x: centerX + (radius * Math.cos(angleInRadians)),
        y: centerY + (radius * Math.sin(angleInRadians))
    };
}

function describeDonutSlice(cx, cy, rInner, rOuter, startAngle, endAngle, numItems) {
    if (numItems === 1) {
        return [
            "M", cx, cy - rOuter,
            "A", rOuter, rOuter, 0, 1, 0, cx, cy + rOuter,
            "A", rOuter, rOuter, 0, 1, 0, cx, cy - rOuter,
            "M", cx, cy - rInner,
            "A", rInner, rInner, 0, 1, 1, cx, cy + rInner,
            "A", rInner, rInner, 0, 1, 1, cx, cy - rInner,
            "Z"
        ].join(" ");
    }

    const gap = 2;
    const trueStart = startAngle + gap / 2;
    const trueEnd = endAngle - gap / 2;

    const startOuter = polarToCartesian(cx, cy, rOuter, trueEnd);
    const endOuter = polarToCartesian(cx, cy, rOuter, trueStart);
    const startInner = polarToCartesian(cx, cy, rInner, trueEnd);
    const endInner = polarToCartesian(cx, cy, rInner, trueStart);

    const largeArcFlag = trueEnd - trueStart <= 180 ? "0" : "1";

    return [
        "M", startOuter.x, startOuter.y,
        "A", rOuter, rOuter, 0, largeArcFlag, 0, endOuter.x, endOuter.y,
        "L", endInner.x, endInner.y,
        "A", rInner, rInner, 0, largeArcFlag, 1, startInner.x, startInner.y,
        "Z"
    ].join(" ");
}

function renderMenu(items) {
    const svg = document.getElementById('menu-svg');
    const iconsContainer = document.getElementById('menu-icons');

    const secondaryRgb = hexToRgb(userSettings.secondaryColor);
    svg.innerHTML = `
        <defs>
            <linearGradient id="slice-grad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="rgba(${secondaryRgb},0.6)" />
                <stop offset="100%" stop-color="rgba(${secondaryRgb},0.1)" />
            </linearGradient>
            <linearGradient id="slice-grad-hover" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="rgba(${secondaryRgb},1.0)" />
                <stop offset="100%" stop-color="rgba(${secondaryRgb},0.4)" />
            </linearGradient>
        </defs>
    `;
    iconsContainer.innerHTML = '';

    const numItems = items.length;
    if (numItems === 0) return;

    const angleStep = 360 / numItems;
    const innerRadius = 55;
    const outerRadius = 240;
    const iconRadius = (innerRadius + outerRadius) / 2 + 10;

    items.forEach((item, i) => {
        const startAngle = i * angleStep;
        const endAngle = (i + 1) * angleStep;

        const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
        const d = describeDonutSlice(250, 250, innerRadius, outerRadius, startAngle, endAngle, numItems);
        path.setAttribute("d", d);
        path.setAttribute("class", "slice-path");

        path.style.opacity = '0';
        path.style.transform = 'scale(0.8)';
        setTimeout(() => {
            path.style.opacity = '1';
            path.style.transform = 'scale(1)';
        }, i * 30);

        path.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            playSoundEffect('click');
            handleItemClick(item);
        });

        path.addEventListener("mouseenter", () => {
            playSoundEffect('hover');
            const el = document.getElementById(`icon-wrap-${i}`);
            if (el) el.classList.add('hovered');
        });
        path.addEventListener("mouseleave", () => {
            const el = document.getElementById(`icon-wrap-${i}`);
            if (el) el.classList.remove('hovered');
        });

        svg.appendChild(path);

        const midAngle = startAngle + angleStep / 2;
        const iconPos = polarToCartesian(250, 250, iconRadius, midAngle);

        const iconWrap = document.createElement('div');
        iconWrap.className = 'icon-wrap';
        iconWrap.id = `icon-wrap-${i}`;
        iconWrap.style.left = `${iconPos.x}px`;
        iconWrap.style.top = `${iconPos.y}px`;

        iconWrap.innerHTML = `
            <i class="menu-icon ${getIcon(item.icon)}"></i>
            <div class="menu-title">${item.title}</div>
        `;

        iconWrap.style.opacity = '0';
        iconWrap.style.transform = `translate(-50%, -50%) scale(0.8)`;
        setTimeout(() => {
            iconWrap.style.opacity = '0.8';
            iconWrap.style.transform = `translate(-50%, -50%) scale(1)`;
        }, i * 30);

        iconsContainer.appendChild(iconWrap);
    });
}

function handleItemClick(item) {
    if (item.items && item.items.length > 0) {
        currentSubmenu = item;
        renderMenu(item.items);
        updateCenterButton();
    } else if (item.event) {
        fetch(`https://${GetParentResourceName()}/selectItem`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                event: item.event,
                type: item.type,
                id: item.id,
                shouldClose: item.shouldClose !== false
            })
        }).catch(() => {});
    }
}

function clearMenu() {
    document.getElementById('menu-svg').innerHTML = '';
    document.getElementById('menu-icons').innerHTML = '';
    currentSubmenu = null;
    updateCenterButton();
}

function updateCenterButton() {
    const btn = document.getElementById('center-btn');
    const btnIcon = btn.querySelector('i');
    if (!btnIcon) return;

    if (currentSubmenu) {
        btnIcon.className = 'fa-solid fa-arrow-right';
        btn.classList.remove('is-main');
        btn.classList.add('is-sub');
        btnIcon.style.transition = 'color 0.3s, transform 0.1s ease-out';
    } else {
        btnIcon.className = 'fa-solid fa-xmark';
        btn.classList.remove('is-sub');
        btn.classList.add('is-main');
        btn.style.setProperty('--icon-rot', '0deg');
        btnIcon.style.transition = 'all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55)';
    }
}

document.addEventListener('mousemove', (e) => {
    if (!document.getElementById('radial-menu').classList.contains('hidden')) {
        const centerX = window.innerWidth / 2;
        const centerY = window.innerHeight / 2;
        const dx = e.clientX - centerX;
        const dy = e.clientY - centerY;
        const angle = Math.atan2(dy, dx);

        const btn = document.getElementById('center-btn');

        const distance = Math.min(12, Math.hypot(dx, dy) / 15);
        const px = Math.cos(angle) * distance;
        const py = Math.sin(angle) * distance;
        btn.style.setProperty('--px', `${px}px`);
        btn.style.setProperty('--py', `${py}px`);

        if (currentSubmenu) {
            btn.style.setProperty('--icon-rot', `${angle * 180 / Math.PI}deg`);
        }
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' || e.key === 'Esc') {
        e.preventDefault();
        e.stopPropagation();

        if (currentSubmenu) {
            currentSubmenu = null;
            renderMenu(menuData);
            updateCenterButton();
        } else {
            closeUI();
        }
    }
});

document.getElementById('center-btn').addEventListener('click', () => {
    if (currentSubmenu) {
        currentSubmenu = null;
        renderMenu(menuData);
        updateCenterButton();
    } else {
        closeUI();
    }
});

function closeUI() {
    closeWithAnimation();
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => {});
}

function GetParentResourceName() {
    try {
        if (typeof window.GetParentResourceName === 'function') {
            return window.GetParentResourceName();
        }
    } catch(e) {}
    const hostname = window.location.hostname || '';
    if (hostname.startsWith('cfx-nui-')) {
        return hostname.replace('cfx-nui-', '');
    }
    return hostname || 'radialmenu';
}

function startParticles() {
    if (!userSettings.particlesEnabled) return;
    const container = document.getElementById('particles-container');
    if (!container) return;
    container.innerHTML = '';
    for(let i=0; i<15; i++) {
        createParticle(container);
    }
    particleInterval = setInterval(() => {
        if (!document.getElementById('radial-menu').classList.contains('hidden')) {
            createParticle(container);
            if(Math.random() > 0.4) createParticle(container);
        } else {
            clearInterval(particleInterval);
        }
    }, 120);
}

function stopParticles() {
    clearInterval(particleInterval);
    const container = document.getElementById('particles-container');
    if (container) container.innerHTML = '';
}

function createParticle(container) {
    const particle = document.createElement('div');
    particle.className = 'particle';
    const rgb = hexToRgb(userSettings.particleColor);
    particle.style.background = `rgba(${rgb}, 0.7)`;
    const size = Math.random() * 3 + 3;
    particle.style.width = `${size}px`;
    particle.style.height = `${size}px`;
    const posX = Math.random() * window.innerWidth;
    particle.style.left = `${posX}px`;
    const duration = Math.random() * 2.5 + 2;
    particle.style.animationDuration = `${duration}s`;
    const drift = (Math.random() - 0.5) * 200;
    particle.style.setProperty('--drift', `${drift}px`);
    container.appendChild(particle);
    setTimeout(() => {
        if (particle.parentNode) particle.remove();
    }, duration * 1000);
}
