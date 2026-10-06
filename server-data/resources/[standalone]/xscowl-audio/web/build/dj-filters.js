window.addEventListener("message", (event) => {
    const data = event.data;
    const system = window.audioSystem;
    
    if (data.action === "updateFilterValue") {
        const { soundId, filterId, gain, frequency } = data;
        if (!system || !system.soundMap[soundId]) return;
        
        const sound = system.soundMap[soundId];
        
        function applyFilter() {
            if (!sound.sourceNode) {
                setTimeout(applyFilter, 200);
                return;
            }
            Object.values(sound.locationMap).forEach(loc => {
                const filter = loc.filters.find(f => f.id === filterId);
                if (filter) {
                    const now = sound.audioContext.currentTime;
                    if (gain !== undefined && gain !== null) {
                        filter.gain.cancelScheduledValues(now);
                        filter.gain.linearRampToValueAtTime(gain, now + 0.1);
                    }
                    if (frequency !== undefined && frequency !== null) {
                        filter.frequency.cancelScheduledValues(now);
                        filter.frequency.linearRampToValueAtTime(frequency, now + 0.1);
                    }
                }
            });
        }
        applyFilter();
    }
    
    if (data.action === "updateMasterEffect") {
        const { soundId, effect, value } = data;
        if (!system || !system.soundMap[soundId]) return;
        
        const sound = system.soundMap[soundId];
        
        function applyMasterEffect() {
            // Handle Tempo directly via iframe video
            if (effect === "tempo") {
                const iframe = document.getElementById(sound.uniqueId);
                if (iframe && iframe.contentWindow) {
                    const video = iframe.contentWindow.document.querySelector('video');
                    if (video) {
                        video.preservesPitch = false; // Turntable style pitch shift
                        video.playbackRate = value;
                    }
                }
                return;
            }
            
            if (!sound.sourceNode) {
                setTimeout(applyMasterEffect, 200);
                return;
            }
            
            // Ensure Master FX is initialized
            const fx = getOrCreateMasterFX(sound);
            const now = sound.audioContext.currentTime;
            
            if (effect === "pan") {
                fx.pan.pan.cancelScheduledValues(now);
                fx.pan.pan.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "flanger") {
                fx.flangerWet.gain.cancelScheduledValues(now);
                fx.flangerWet.gain.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "delay") {
                fx.delayWet.gain.cancelScheduledValues(now);
                fx.delayWet.gain.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "8d") {
                fx.eightDGain.gain.cancelScheduledValues(now);
                // 0.85 provides a very noticeable 8D effect without the 100% uncomfortable ear-suck
                fx.eightDGain.gain.linearRampToValueAtTime(value > 0 ? 0.85 : 0, now + 0.1);
            } else if (effect === "reverb") {
                fx.reverbWet.gain.cancelScheduledValues(now);
                fx.reverbWet.gain.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "tremolo") {
                fx.tremoloWet.gain.cancelScheduledValues(now);
                fx.tremoloWet.gain.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "phaser") {
                fx.phaserWet.gain.cancelScheduledValues(now);
                fx.phaserWet.gain.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "bitcrusher") {
                fx.crusherWet.gain.cancelScheduledValues(now);
                fx.crusherWet.gain.linearRampToValueAtTime(value, now + 0.1);
            } else if (effect === "karaoke") {
                fx.karaokeWet.gain.cancelScheduledValues(now);
                fx.karaokeWet.gain.linearRampToValueAtTime(value > 0 ? 1.0 : 0.0, now + 0.1);
                fx.karaokeDry.gain.cancelScheduledValues(now);
                fx.karaokeDry.gain.linearRampToValueAtTime(value > 0 ? 0.0 : 1.0, now + 0.1);
            }
        }
        applyMasterEffect();
    }
});

// Helper for Reverb Impulse Response
function createReverbIR(ctx, duration = 3.0, decay = 3.0) {
    const rate = ctx.sampleRate;
    const length = rate * duration;
    const impulse = ctx.createBuffer(2, length, rate);
    const left = impulse.getChannelData(0);
    const right = impulse.getChannelData(1);
    for (let i = 0; i < length; i++) {
        const factor = Math.pow(1 - i / length, decay);
        left[i] = (Math.random() * 2 - 1) * factor;
        right[i] = (Math.random() * 2 - 1) * factor;
    }
    return impulse;
}

// Helper for Bitcrusher Curve
function createBitcrusherCurve(bits) {
    const steps = Math.pow(2, bits);
    const curve = new Float32Array(44100);
    for (let i = 0; i < 44100; i++) {
        let x = (i * 2) / 44100 - 1;
        curve[i] = Math.round(x * steps) / steps;
    }
    return curve;
}

function getOrCreateMasterFX(sound) {
    if (sound._djMaster) return sound._djMaster;
    
    const ctx = sound.audioContext;
    const input = ctx.createGain();
    
    // Flanger
    const flangerDry = ctx.createGain();
    const flangerWet = ctx.createGain();
    const flangerDelay = ctx.createDelay(1.0);
    const flangerFeedback = ctx.createGain();
    const flangerOsc = ctx.createOscillator();
    const flangerOscGain = ctx.createGain();
    
    flangerOsc.type = 'sine';
    flangerOsc.frequency.value = 0.25;
    flangerOscGain.gain.value = 0.005;
    flangerDelay.delayTime.value = 0.005;
    flangerFeedback.gain.value = 0.5;
    flangerWet.gain.value = 0;
    
    flangerOsc.connect(flangerOscGain);
    flangerOscGain.connect(flangerDelay.delayTime);
    flangerOsc.start();
    
    // Delay
    const delayDry = ctx.createGain();
    const delayWet = ctx.createGain();
    
    // Strict Vocal isolation (Highpass + Lowpass) for Delay Input
    // This ensures kick drums and cymbals do not echo
    const delayHighpass = ctx.createBiquadFilter();
    delayHighpass.type = "highpass";
    delayHighpass.frequency.value = 350; // Cut off all bass and kick
    delayHighpass.Q.value = 1.0; 
    
    const delayLowpass = ctx.createBiquadFilter();
    delayLowpass.type = "lowpass";
    delayLowpass.frequency.value = 3500; // Cut off cymbals and high hats
    
    // Simple Delay Effect
    const delayNode = ctx.createDelay(2.0);
    const delayFeedback = ctx.createGain();
    
    delayNode.delayTime.value = 0.35; // 350ms 
    delayFeedback.gain.value = 0.45; // 45% feedback
    delayWet.gain.value = 0;
    
    // Stereo Pan
    const pan = ctx.createStereoPanner();
    
    // 8D Audio Effect (Auto-Panner)
    const eightDPan = ctx.createStereoPanner();
    const eightDOsc = ctx.createOscillator();
    const eightDGain = ctx.createGain();
    
    eightDOsc.type = 'sine';
    eightDOsc.frequency.value = 0.12; 
    eightDGain.gain.value = 0; 
    
    eightDOsc.connect(eightDGain);
    eightDGain.connect(eightDPan.pan);
    eightDOsc.start();

    // Reverb (Stadium Effect)
    const reverbDry = ctx.createGain();
    const reverbWet = ctx.createGain();
    const convolver = ctx.createConvolver();
    convolver.buffer = createReverbIR(ctx, 4.0, 3.0); // 4 seconds tail
    reverbWet.gain.value = 0;

    // Tremolo (Helicopter/Chopper Effect)
    const tremoloDry = ctx.createGain();
    const tremoloWet = ctx.createGain();
    const tremoloMod = ctx.createGain();
    const tremoloOsc = ctx.createOscillator();
    tremoloOsc.type = 'sine';
    tremoloOsc.frequency.value = 10; // 10 Hz chop
    tremoloOsc.connect(tremoloMod.gain);
    tremoloOsc.start();
    tremoloWet.gain.value = 0;

    // Phaser (Space Swoosh)
    const phaserDry = ctx.createGain();
    const phaserWet = ctx.createGain();
    const ap1 = ctx.createBiquadFilter();
    const ap2 = ctx.createBiquadFilter();
    const ap3 = ctx.createBiquadFilter();
    ap1.type = ap2.type = ap3.type = "allpass";
    
    const phaserOsc = ctx.createOscillator();
    const phaserOscGain = ctx.createGain();
    phaserOsc.type = 'sine';
    phaserOsc.frequency.value = 0.3; // Swoosh speed
    phaserOscGain.gain.value = 1000;
    phaserOsc.connect(phaserOscGain);
    phaserOscGain.connect(ap1.frequency);
    phaserOscGain.connect(ap2.frequency);
    phaserOscGain.connect(ap3.frequency);
    phaserOsc.start();
    ap1.connect(ap2); ap2.connect(ap3);
    phaserWet.gain.value = 0;

    // Bitcrusher (Retro 8-bit Effect)
    const crusherDry = ctx.createGain();
    const crusherWet = ctx.createGain();
    const waveShaper = ctx.createWaveShaper();
    waveShaper.curve = createBitcrusherCurve(8); // 8-bit sound (much smoother than 4-bit)
    crusherWet.gain.value = 0;

    // Karaoke (Advanced Center Cancellation with 3-Band Preservation)
    const karaokeDry = ctx.createGain();
    const karaokeWet = ctx.createGain();
    
    // 1. Filters to preserve bass/kick (sub 200Hz)
    const lowPreserve = ctx.createBiquadFilter();
    lowPreserve.type = "lowpass";
    lowPreserve.frequency.value = 200;
    
    // 2. Filters to preserve highs/cymbals (above 8000Hz)
    const highPreserve = ctx.createBiquadFilter();
    highPreserve.type = "highpass";
    highPreserve.frequency.value = 8000;
    
    // 3. Vocal Band (Mid-range for cancellation)
    const vocalBandLowCut = ctx.createBiquadFilter();
    vocalBandLowCut.type = "highpass";
    vocalBandLowCut.frequency.value = 200;
    
    const vocalBandHighCut = ctx.createBiquadFilter();
    vocalBandHighCut.type = "lowpass";
    vocalBandHighCut.frequency.value = 8000;

    const splitter = ctx.createChannelSplitter(2);
    const inverter = ctx.createGain();
    inverter.gain.value = -1; 
    
    karaokeWet.gain.value = 0;
    karaokeDry.gain.value = 1;
    
    const output = ctx.createGain();
    
    // Core Routing
    input.connect(karaokeDry);
    
    // Karaoke Routing
    input.connect(lowPreserve);
    lowPreserve.connect(karaokeWet);
    
    input.connect(highPreserve);
    highPreserve.connect(karaokeWet);
    
    // Mid-range goes to center cancellation
    input.connect(vocalBandLowCut);
    vocalBandLowCut.connect(vocalBandHighCut);
    vocalBandHighCut.connect(splitter);
    
    splitter.connect(inverter, 0); 
    inverter.connect(karaokeWet); 
    splitter.connect(karaokeWet, 1);
    
    const fxInput = ctx.createGain();
    karaokeDry.connect(fxInput);
    karaokeWet.connect(fxInput);
    
    // Connect to FX Chain
    fxInput.connect(flangerDry);
    fxInput.connect(flangerDelay);
    flangerDelay.connect(flangerFeedback);
    flangerFeedback.connect(flangerDelay);
    flangerDelay.connect(flangerWet);
    
    const flangerSum = ctx.createGain();
    flangerDry.connect(flangerSum);
    flangerWet.connect(flangerSum);
    
    flangerSum.connect(delayDry);
    
    // Sadece vokalleri (orta frekansları) delay'e gönder
    flangerSum.connect(delayHighpass);
    delayHighpass.connect(delayLowpass);
    delayLowpass.connect(delayNode);
    
    // Delay loop
    delayNode.connect(delayFeedback);
    delayFeedback.connect(delayNode);
    delayNode.connect(delayWet);
    
    const delaySum = ctx.createGain();
    delayDry.connect(delaySum);
    delayWet.connect(delaySum);

    // Reverb Loop
    delaySum.connect(reverbDry);
    delaySum.connect(convolver);
    convolver.connect(reverbWet);

    const reverbSum = ctx.createGain();
    reverbDry.connect(reverbSum);
    reverbWet.connect(reverbSum);

    // Tremolo Loop
    reverbSum.connect(tremoloDry);
    reverbSum.connect(tremoloMod);
    tremoloMod.connect(tremoloWet);

    const tremoloSum = ctx.createGain();
    tremoloDry.connect(tremoloSum);
    tremoloWet.connect(tremoloSum);

    // Phaser Loop
    tremoloSum.connect(phaserDry);
    tremoloSum.connect(ap1);
    ap3.connect(phaserWet);

    const phaserSum = ctx.createGain();
    phaserDry.connect(phaserSum);
    phaserWet.connect(phaserSum);

    // Bitcrusher Loop
    phaserSum.connect(crusherDry);
    phaserSum.connect(waveShaper);
    waveShaper.connect(crusherWet);

    const crusherSum = ctx.createGain();
    crusherDry.connect(crusherSum);
    crusherWet.connect(crusherSum);

    // Final Stage
    crusherSum.connect(pan);
    pan.connect(eightDPan);
    eightDPan.connect(output);
    
    sound._djMaster = {
        input, output,
        flangerWet, delayWet, pan, eightDGain,
        reverbWet, tremoloWet, phaserWet, crusherWet,
        karaokeDry, karaokeWet
    };
    
    sound.sourceNode.disconnect();
    const origConnect = sound.sourceNode.connect;
    
    sound.sourceNode.connect = function(destination) {
        return sound._djMaster.output.connect(destination);
    };
    
    Object.values(sound.locationMap).forEach(loc => {
        sound.sourceNode.connect(loc.getFirstChainNode());
    });
    
    origConnect.call(sound.sourceNode, input);
    
    return sound._djMaster;
}
