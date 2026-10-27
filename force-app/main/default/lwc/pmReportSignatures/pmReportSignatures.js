import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLatestReport from '@salesforce/apex/PMReportSignatureController.getLatestReport';
import saveSignatures from '@salesforce/apex/PMReportSignatureController.saveSignatures';

export default class PmReportSignatures extends LightningElement {
    _recordId;
    report;
    noReport = false;
    loading = true;
    saving = false;
    errorMessage;
    storeRepSignature;
    technicianSignature;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadReport();
        }
    }

    async loadReport() {
        try {
            this.report = await getLatestReport({ workOrderId: this._recordId });
            this.noReport = !this.report;
        } catch (e) {
            this.errorMessage = e.body ? e.body.message : e.message;
        } finally {
            this.loading = false;
        }
    }

    handleStoreRep(event) {
        this.storeRepSignature = event.detail.value;
    }

    handleTech(event) {
        this.technicianSignature = event.detail.value;
    }

    async handleSave() {
        if (!this.storeRepSignature || !this.technicianSignature) {
            this.errorMessage = 'Both signatures are required.';
            return;
        }
        this.saving = true;
        this.errorMessage = undefined;
        try {
            await saveSignatures({
                reportId: this.report.Id,
                storeRepSignature: this.storeRepSignature,
                technicianSignature: this.technicianSignature
            });
            this.dispatchEvent(new ShowToastEvent({ title: 'Signatures saved', variant: 'success' }));
            this.handleClose();
        } catch (e) {
            this.errorMessage = e.body ? e.body.message : e.message;
        } finally {
            this.saving = false;
        }
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
