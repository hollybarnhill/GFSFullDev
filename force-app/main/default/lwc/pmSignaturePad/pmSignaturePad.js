import { LightningElement, api } from 'lwc';

export default class PmSignaturePad extends LightningElement {
    @api label = 'Signature';
    @api required = false;
    @api value;

    errorMessage;
    drawing = false;
    sized = false;

    renderedCallback() {
        const canvas = this.canvas();
        if (!this.sized) {
            const rect = canvas.getBoundingClientRect();
            canvas.width = rect.width;
            canvas.height = rect.height;
            this.sized = true;
            this.bind(canvas);
        }
    }

    canvas() {
        return this.template.querySelector('canvas');
    }

    bind(canvas) {
        const ctx = canvas.getContext('2d');
        ctx.lineWidth = 2;
        ctx.lineCap = 'round';
        ctx.strokeStyle = '#000';

        const point = (e) => {
            const r = canvas.getBoundingClientRect();
            return { x: e.clientX - r.left, y: e.clientY - r.top };
        };

        canvas.addEventListener('pointerdown', (e) => {
            this.drawing = true;
            canvas.setPointerCapture(e.pointerId);
            const p = point(e);
            ctx.beginPath();
            ctx.moveTo(p.x, p.y);
        });
        canvas.addEventListener('pointermove', (e) => {
            if (!this.drawing) return;
            const p = point(e);
            ctx.lineTo(p.x, p.y);
            ctx.stroke();
        });
        const end = () => {
            if (!this.drawing) return;
            this.drawing = false;
            this.value = canvas.toDataURL('image/png');
            this.errorMessage = undefined;
            this.dispatchEvent(new CustomEvent('change', { detail: { value: this.value } }));
        };
        canvas.addEventListener('pointerup', end);
        canvas.addEventListener('pointercancel', end);
    }

    handleClear() {
        const canvas = this.canvas();
        canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
        this.value = undefined;
        this.dispatchEvent(new CustomEvent('change', { detail: { value: undefined } }));
    }

    @api
    validate() {
        if (this.required && !this.value) {
            this.errorMessage = 'A signature is required.';
            return { isValid: false, errorMessage: this.errorMessage };
        }
        return { isValid: true };
    }
}
