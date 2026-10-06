const wrapper    = document.getElementById("wrapper");
const inner      = document.getElementById("inner");
const subtitleEl = document.getElementById("subtitle");
const titleEl    = document.getElementById("title");

let hideTimer = null;

const POS_CLASSES  = ["pos-bottom", "pos-top", "pos-center"];
const ANIM_CLASSES = ["anim-slide", "anim-fade", "anim-zoom"];

function hexToRgba(hex, alpha) {
    let c = (hex || "#D4A843").replace("#", "");
    if (c.length === 3) c = c[0]+c[0]+c[1]+c[1]+c[2]+c[2];
    const r = parseInt(c.slice(0, 2), 16);
    const g = parseInt(c.slice(2, 4), 16);
    const b = parseInt(c.slice(4, 6), 16);
    return `rgba(${r},${g},${b},${alpha})`;
}

function showNotification(subtitle, title, displayTime, animation, position, color) {
    if (hideTimer) { clearTimeout(hideTimer); hideTimer = null; }

    const dt  = displayTime || 3500;
    const col = color || "#D4A843";

    subtitleEl.textContent = subtitle || "";
    titleEl.textContent    = title    || "";

    titleEl.style.color      = col;
    titleEl.style.textShadow =
        `0 0 22px ${hexToRgba(col, 0.55)},` +
        `0 0 44px ${hexToRgba(col, 0.22)},` +
        `2px 2px 4px rgba(0,0,0,1),`        +
        `-1px -1px 3px rgba(0,0,0,1)`;

    wrapper.classList.remove(...POS_CLASSES, "show");
    wrapper.classList.add(`pos-${position || "bottom"}`);

    inner.classList.remove(...ANIM_CLASSES);
    inner.classList.add(`anim-${animation || "slide"}`);
    inner.style.setProperty("--dt", `${dt / 1000}s`);

    void inner.offsetWidth;
    wrapper.classList.add("show");

    hideTimer = setTimeout(function() {
        wrapper.classList.remove("show");
        hideTimer = null;
    }, dt);
}

window.addEventListener("message", function(event) {
    const d = event.data;
    if (!d || d.action !== "showNotification") return;
    showNotification(d.subtitle, d.title, d.displayTime, d.animation, d.position, d.color);
});

fetch("https://zone-bildirim/ready", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({})
}).catch(function() {});
