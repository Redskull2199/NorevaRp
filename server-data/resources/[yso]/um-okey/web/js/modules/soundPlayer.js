class SoundPlayer {
    constructor() {
        this.sounds = {};
        this.volume = 0.3;
        this.enabled = true;

        this.preloadSounds();
    }

    preloadSounds() {
        const tileSounds = [
            { name: 'tile_click_1', path: './sounds/tile_click_1.ogg' },
            { name: 'tile_click_2', path: './sounds/tile_click_2.ogg' },
        ];

        tileSounds.forEach(sound => {
            this.loadSound(sound.name, sound.path);
        });
    }

    loadSound(name, path) {
        const audio = new Audio(path);
        audio.preload = 'auto';
        audio.volume = this.volume;

        audio.addEventListener('canplaythrough', () => {
            this.sounds[name] = audio;
        });

        audio.addEventListener('error', (e) => {
            console.log(`[SoundPlayer] Failed to load: ${name}`, e);
        });
    }

    play(soundName, options = {}) {
        if (!this.enabled) return;

        const sound = this.sounds[soundName];
        if (!sound) {
            console.warn(`[SoundPlayer] Sound not found: ${soundName}`);
            return;
        }

        const audio = options.overlap ? sound.cloneNode() : sound;

        audio.volume = options.volume || this.volume;
        audio.playbackRate = options.pitch || 1.0;

        if (!options.overlap) {
            audio.currentTime = 0;
        }

        if (options.onEnd) {
            audio.addEventListener('ended', options.onEnd, { once: true });
        }

        audio.play().catch(e => {
            console.error(`[SoundPlayer] Failed to play: ${soundName}`, e);
        });

        return audio;
    }

    playRandomClick() {
        const clickSounds = ['tile_click_1', 'tile_click_2'];
        const randomSound = clickSounds[Math.floor(Math.random() * clickSounds.length)];

        const pitch = 0.9 + Math.random() * 0.2;

        this.play(randomSound, {
            pitch: pitch,
            overlap: true
        });
    }

    playSlide() {
        this.play('tile_slide', {
            volume: this.volume * 0.7
        });
    }

    playPlace() {
        this.play('tile_place', {
            overlap: true
        });
    }

    playPickup() {
        this.play('tile_pickup');
    }

    playThrow() {
        this.play('tile_throw');
    }

    playGameStart() {
        this.play('game_start', {
            volume: this.volume * 1.2
        });
    }

    playGameFinish() {
        this.play('game_finish', {
            volume: this.volume * 1.2
        });
    }

    playTurnNotification() {
        this.play('turn_notification', {
            volume: this.volume * 0.8
        });
    }

    setVolume(level) {
        this.volume = Math.max(0, Math.min(1, level));

        Object.values(this.sounds).forEach(audio => {
            audio.volume = this.volume;
        });
    }

    toggle() {
        this.enabled = !this.enabled;
        return this.enabled;
    }

    stop(soundName) {
        const sound = this.sounds[soundName];
        if (sound) {
            sound.pause();
            sound.currentTime = 0;
        }
    }

    stopAll() {
        Object.values(this.sounds).forEach(audio => {
            audio.pause();
            audio.currentTime = 0;
        });
    }
}

const soundPlayer = new SoundPlayer();

export default soundPlayer;