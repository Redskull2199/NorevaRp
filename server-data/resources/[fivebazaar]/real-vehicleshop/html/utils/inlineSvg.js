export default {
    props: {
        src: {
            type: String,
            required: false
        },
        fill: {
            type: String,
            default: 'currentColor'
        },
        value: {
            type: Number,
            required: false
        }
    },
    data() {
        return {
            svg: ''
        }
    },
    async mounted() {
        if (this.src) {
            const res = await fetch(this.src);
            const html = await res.text();
            this.svg = html;
        }
    },
    async updated() {
        if (this.src) {
            const res = await fetch(this.src);
            const html = await res.text();
            this.svg = html;
        }
    },
    computed: {
        dynamicSVG() {
            if (!this.value) return '';

            return `
                <svg xmlns="http://www.w3.org/2000/svg" width="348" height="57" viewBox="0 0 348 57" fill="none" class="h-full w-full" preserveAspectRatio="none">
                    ${this.value >= 100 ? `
                        <path d="M0 0H600V57H0V0Z" fill="#00F0FF" fill-opacity="0.73"/>
                        <path d="M0 0H600V57H0V0Z" fill="#00F0FF"/>
                    ` : `
                        <path d="M0 0H347.5L305 57H0V0Z" fill="#00F0FF" fill-opacity="0.73"/>
                        <path d="M0 0H347.5L305 57H0V0Z" fill="#00F0FF"/>
                    `}
                </svg>
            `
        }
    },
    template: `
        <div v-html="src ? svg : dynamicSVG" :style="{fill:fill}" />
    `
}