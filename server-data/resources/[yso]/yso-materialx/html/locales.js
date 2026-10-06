let currentLocale = "en"; // 'tr' or 'en'

const locales = {
  tr: {
    "menu-header": "Material X Menü",
    "status-text": "Durum",
    "player-count-text": "Oyuncu Sayısı",
    "time-left-text": "Kalan Süre",
    "lock-status-text": "Giriş Kilidi",
    "scoreboard-text": "Skor Tablosu",
    "scoreboard-desc": "Liderlik tablosuna erişin ve ilk 10'u görün.",
    "team-menu-text": "Takım Menüsü",
    "team-menu-desc": "Takım menüsüne erişin.",
    "select-weapon-text": "Silah Seç",
    "select-weapon-desc": "Etkinlikte kullanacağınız silahı seçin.",
    "repair-weapon-text": "Silah Tamir Et",
    "repair-weapon-desc": "Buraya tıklayarak silahınızı tamir edebilirsiniz.",
    "admin-panel-text": "Admin Paneli",
    "admin-panel-desc": "Yönetici menüsüne buradan erişebilirsiniz.",
    "join-event": "Etkinliğe Katıl",
    "leave-event": "Etkinlikten Ayrıl",
    "admin-panel-header": "Admin Paneli",
    "admin-panel-subtext": "Bir yönetici olarak, paneldeki ayarları kullanarak etkinliği yapılandırın.",
    "event-status": "Etkinlik Durumu",
    "event-status-desc": "Etkinlik girişlerini ayarlar.",
    "game-status": "Oyun Durumu",
    "game-status-desc": "Etkinliğin başlama/durma durumunu ayarlar.",
    "lock-status": "Kilit Durumu",
    "lock-status-desc": "Etkinlik katılım kilitlerini ayarlar.",
    "admin-mode": "Admin Modu",
    "admin-mode-desc": "Bölgedeyken aldığınız hasarı ayarlar.",
    "scoreboard-header": "Skor Tablosu",
    "rank-head": "Sıra",
    "name-head": "İsim",
    "kill-head": "Leş",
    "select-weapon-header": "Silah Seç",
    "select-weapon-subtext": "Etkinlikte kullanmak istediğiniz silahı seçin.",
    "team-menu-header": "Takım Menüsü",
    "team-menu-subtext": "Kendi takımınızı oluşturun veya mevcut bir takıma katılın.",
    "join-team": "Takıma Katıl",
    "create-team": "Takım Kur",
    "my-team-header": "Takım Menüm",
    "my-team-subtext": "Takımınızı buradan yönetebilirsiniz.",
    "invites-header": "Takım Davetleri",
    "invites-subtext": "Gelen takım istekleri burada listelenir.",
    "invite-player-header": "Oyuncu Davet Et",
    "invite-btn": "Davet Gönder",
    "killed-text": "ÖLDÜRÜLDÜ",
    "active": "Aktif",
    "inactive": "Pasif",
    "locked": "KİLİTLİ",
    "unlocked": "AÇIK",
    "selected": "Seçildi",
    "select": "Seç",
    "leader-label": "Lider",
    "member-label": "Üye",
    "waiting-zone": "BEKLENİYOR"
  },
  en: {
    "menu-header": "Material X Menu",
    "status-text": "Status",
    "player-count-text": "Player Count",
    "time-left-text": "Time Left",
    "lock-status-text": "Lock Status",
    "scoreboard-text": "Scoreboard",
    "scoreboard-desc": "Access the leaderboard and view the top 10.",
    "team-menu-text": "Team Menu",
    "team-menu-desc": "Access the team menu.",
    "select-weapon-text": "Select Weapon",
    "select-weapon-desc": "Choose which weapon you want to use.",
    "repair-weapon-text": "Repair Weapon",
    "repair-weapon-desc": "You can repair your weapon by clicking here.",
    "admin-panel-text": "Admin Panel",
    "admin-panel-desc": "You can access the admin menu by clicking the button.",
    "join-event": "Join Event",
    "leave-event": "Leave Event",
    "admin-panel-header": "Admin Panel",
    "admin-panel-subtext": "As an administrator, configure the settings for the event.",
    "event-status": "Event Status",
    "event-status-desc": "Sets up event entries.",
    "game-status": "Game Status",
    "game-status-desc": "Sets the start/stop status.",
    "lock-status": "Lock Status",
    "lock-status-desc": "Sets the locks for participation.",
    "admin-mode": "Admin Mode",
    "admin-mode-desc": "Sets the damage you take in area.",
    "scoreboard-header": "Scoreboard",
    "rank-head": "Rank",
    "name-head": "Name",
    "kill-head": "Kill",
    "select-weapon-header": "Select Weapon",
    "select-weapon-subtext": "Choose which weapon you want to use.",
    "team-menu-header": "Team Menu",
    "team-menu-subtext": "Create your own team or join one.",
    "join-team": "Join Team",
    "create-team": "Create Team",
    "my-team-header": "My Team Menu",
    "my-team-subtext": "You can manage your team from here.",
    "invites-header": "Team Invites",
    "invites-subtext": "Requests are listed here.",
    "invite-player-header": "Invite Player",
    "invite-btn": "Send Invite",
    "killed-text": "KILLED",
    "active": "Active",
    "inactive": "Inactive",
    "locked": "LOCKED",
    "unlocked": "UNLOCKED",
    "selected": "Selected",
    "select": "Select",
    "leader-label": "Leader",
    "member-label": "Member",
    "waiting-zone": "WAITING"
  }
};

function _L(key) {
  return locales[currentLocale][key] || key;
}

function switchLocale() {
  const elements = document.querySelectorAll("[data-locale]");
  elements.forEach((el) => {
    const key = el.getAttribute("data-locale");
    if (locales[currentLocale][key]) {
      if (el.tagName === "INPUT") {
        el.setAttribute("placeholder", locales[currentLocale][key]);
      } else {
        el.textContent = locales[currentLocale][key];
      }
    }
  });
}

function changeLocale(lang) {
  if (locales[lang] && currentLocale !== lang) {
    currentLocale = lang;
    switchLocale();
  }
}