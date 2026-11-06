import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import getContext from '@salesforce/apex/TransactionReversalController.getContext';
import reverseTransaction from '@salesforce/apex/TransactionReversalController.reverseTransaction';
import { reduceError, formatLabel, formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_BO_Reversal_Title';
import TRANSACTION from '@salesforce/label/c.Loyalty_BO_Reversal_Transaction';
import POINTS from '@salesforce/label/c.Loyalty_BO_Reversal_Points';
import WARNING from '@salesforce/label/c.Loyalty_BO_Reversal_Warning';
import SUBMIT from '@salesforce/label/c.Loyalty_BO_Reversal_Submit';
import SUCCESS from '@salesforce/label/c.Loyalty_BO_Reversal_Success';
import ALREADY from '@salesforce/label/c.Loyalty_BO_Reversal_Error_Already';
import NOT_PROCESSED from '@salesforce/label/c.Loyalty_BO_Reversal_Error_NotProcessed';
import NOTHING from '@salesforce/label/c.Loyalty_BO_Reversal_Error_Nothing';
import POINTS_UNIT from '@salesforce/label/c.Loyalty_BO_Points_Unit';
import CATEGORY from '@salesforce/label/c.Loyalty_BO_Reason_Category';
import COMMENT_OPTIONAL from '@salesforce/label/c.Loyalty_BO_Comment_Optional';
import SELECT_PLACEHOLDER from '@salesforce/label/c.Loyalty_BO_Select_Placeholder';
import CLOSE from '@salesforce/label/c.Loyalty_BO_Close';
import NO_PERMISSION from '@salesforce/label/c.Loyalty_BO_No_Permission_Info';

const MAX_COMMENT_LENGTH = 200;
const STATUS_PROCESSED = 'Processed';

export default class TransactionReversalAction extends LightningElement {
    labels = { TITLE, TRANSACTION, POINTS, WARNING, SUBMIT, CATEGORY, COMMENT_OPTIONAL, SELECT_PLACEHOLDER, CLOSE };
    maxCommentLength = MAX_COMMENT_LENGTH;

    context;
    reasonCode;
    comment;
    errorMessage;
    isLoading = true;
    isSaving = false;
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        if (value && value !== this._recordId) {
            this._recordId = value;
            this.loadContext();
        }
    }

    get infoMessage() {
        if (this.context?.canReverse !== true) {
            return NO_PERMISSION;
        }
        if (this.context.status !== STATUS_PROCESSED) {
            return NOT_PROCESSED;
        }
        if (this.context.isReversed) {
            return ALREADY;
        }
        return this.context.points > 0 ? undefined : NOTHING;
    }

    get canReverse() {
        return Boolean(this.context) && !this.infoMessage;
    }

    get isSubmitDisabled() {
        return !this.canReverse || this.isSaving;
    }

    get pointsText() {
        return `−${formatNumber(this.context?.points)} ${POINTS_UNIT}`;
    }

    async loadContext() {
        this.isLoading = true;
        this.errorMessage = undefined;
        try {
            this.context = await getContext({ transactionId: this._recordId });
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleReasonChange(event) {
        this.reasonCode = event.detail.value;
    }

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    async handleSubmit() {
        const isValid = [...this.template.querySelectorAll('[data-validate]')].reduce((valid, input) => input.reportValidity() && valid, true);
        if (!isValid || this.isSaving) {
            return;
        }
        this.isSaving = true;
        this.errorMessage = undefined;
        try {
            const removedPoints = await reverseTransaction({ transactionId: this._recordId, reasonCode: this.reasonCode, comment: this.comment });
            this.dispatchEvent(new ShowToastEvent({ title: TITLE, message: formatLabel(SUCCESS, formatNumber(removedPoints)), variant: 'success' }));
            this.dispatchEvent(new RefreshEvent());
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isSaving = false;
        }
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
