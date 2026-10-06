const { createApp } = Vue;

createApp({
    data() {
        return {
            floors: [],
            currentFloor: 1,
            isAnimating: false,
            activeButton: null,
            animationInterval: null,
            targetFloor: null,
            targetFloorButton: null,
            targetFloorCode: null,
            targetFloorData: null,
            showModal: false,
            passwordInput: '',
            errorMessage: '',
            floorTravelTime: 2500,
            startDelay: 5000,
            directionUpActive: false,
            directionDownActive: false,
            digit1: '1',
            digit2: ''
        };
    },
    computed: {
        leftColumnFloors() {
            return this.floors.filter((floor, index) => index % 2 === 0);
        },
        rightColumnFloors() {
            return this.floors.filter((floor, index) => index % 2 !== 0);
        }
    },
    mounted() {
        document.body.style.display = 'none';
        
        document.addEventListener('keydown', this.handleEscape);
        window.addEventListener('message', this.handleMessage);
        
        this.updateFloorDisplay(this.currentFloor);
    },
    beforeUnmount() {
        document.removeEventListener('keydown', this.handleEscape);
        window.removeEventListener('message', this.handleMessage);
    },
    methods: {
        fetchNui(eventName, data = {}) {
            return fetch(`https://${GetParentResourceName()}/${eventName}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
        },
        handleEscape(event) {
            if (event.key === 'Escape' && !this.activeButton) {
                this.closeElevatorUI();
            }
        },
        handleMessage(event) {
            const data = event.data;
            if (data.action === 'SHOW_UI') {
                this.initializeElevatorUI({
                    current: data.current,
                    floors: data.floors
                });
                this.openElevatorUI();
            }
        },
        closeElevatorUI() {
            this.fetchNui('CLOSE_UI');
            document.body.classList.add('hidden');
            setTimeout(() => {
                document.body.style.display = 'none';
            }, 500);
        },
        openElevatorUI() {
            document.body.style.display = 'flex';
            setTimeout(() => {
                document.body.classList.remove('hidden');
            }, 10);
        },
        playSound(soundId) {
            const sound = document.getElementById(soundId);
            sound.pause();
            sound.currentTime = 0;
            sound.play();
        },
        handleFloorClick(floor, index) {
            if (this.activeButton !== null) return;

            this.targetFloor = floor.number;
            this.targetFloorButton = index;

            this.targetFloorCode = floor.code ? String(floor.code) : null;
            this.targetFloorData = floor;

            if (floor.code) {
                this.openModal();
            } else {
                this.proceedToFloor(floor);
            }
        },
        proceedToFloor(floor) {
            if (this.targetFloor !== this.currentFloor && !this.isAnimating) {
                const coords = {
                    x: Math.round(floor.pos.x * 100) / 100,
                    y: Math.round(floor.pos.y * 100) / 100,
                    z: Math.round(floor.pos.z * 100) / 100
                };
                
                this.fetchNui('USE_ELEVATOR', { coords: coords });

                this.playSound('button-sound');
                this.playSound('ambient-sound');

                if (this.activeButton !== null) {
                    this.activeButton = null;
                }
                this.activeButton = this.targetFloorButton;
                
                setTimeout(() => this.animateFloorChange(this.currentFloor, this.targetFloor, coords), this.startDelay);
            }
        },
        openModal() {
            this.showModal = true;
            this.errorMessage = '';
            this.passwordInput = '';
        },
        closeModal() {
            this.showModal = false;
        },
        submitPassword() {
            if (this.passwordInput === this.targetFloorCode) {
                this.closeModal();
                this.proceedToFloor(this.targetFloorData);
            } else {
                this.errorMessage = 'Incorrect code!';
                setTimeout(() => {
                    this.errorMessage = '';
                }, 3000);
            }
        },
        updateFloorDisplay(floor) {
            const floorStr = floor.toString();
            if (floorStr.length === 1) {
                this.digit1 = floorStr;
                this.digit2 = '';
            } else {
                this.digit1 = floorStr[0];
                this.digit2 = floorStr[1];
            }
        },
        animateFloorChange(from, to, pos) {
            this.isAnimating = true;
            let step = from < to ? 1 : -1;
            
            this.directionUpActive = step === 1;
            this.directionDownActive = step === -1;

            this.animationInterval = setInterval(() => {
                this.currentFloor += step;
                this.updateFloorDisplay(this.currentFloor);

                if (this.currentFloor === to) {
                    clearInterval(this.animationInterval);
                    this.directionUpActive = false;
                    this.directionDownActive = false;
                    this.isAnimating = false;

                    const teleportPos = {
                        x: pos.x,
                        y: pos.y,
                        z: pos.z
                    };
                    
                    this.fetchNui('TELEPORT', { pos: teleportPos });

                    const ambientSound = document.getElementById('ambient-sound');
                    ambientSound.pause();

                    setTimeout(() => {
                        this.playSound('arrival-sound');
                        this.activeButton = null;
                    }, 500);
                }
            }, this.floorTravelTime);
        },
        stopElevator() {
            this.playSound('button-sound');

            if (this.isAnimating) {
                clearInterval(this.animationInterval);
                this.directionUpActive = false;
                this.directionDownActive = false;
                this.isAnimating = false;
                
                if (this.activeButton !== null) {
                    const currentFloorData = this.floors[this.currentFloor];
                    if (currentFloorData && currentFloorData.pos) {
                        const pos = {
                            x: Math.round(currentFloorData.pos.x * 100) / 100,
                            y: Math.round(currentFloorData.pos.y * 100) / 100,
                            z: Math.round(currentFloorData.pos.z * 100) / 100
                        };
                        this.fetchNui('TELEPORT', { pos: pos });
                    }
                    
                    const ambientSound = document.getElementById('ambient-sound');
                    ambientSound.pause();
                    this.playSound('arrival-sound');
                    this.activeButton = null;
                }
            }
        },
        initializeElevatorUI(data) {
            this.floors = data.floors;
            this.currentFloor = data.current;
            this.updateFloorDisplay(this.currentFloor);
        },
        isActiveFloor(index) {
            return this.activeButton === index;
        }
    }
}).mount('#app');