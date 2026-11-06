import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import getContext from '@salesforce/apex/VoucherCancellationController.getContext';
import cancelVoucher from '@salesforce/apex/VoucherCancellationController.cancelVoucher';
import { reduceError, formatLabel, formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_BO_Cancel_Title';
import MEMBER from '@salesforce/label/c.Loyalty_BO_Member';
import CODE from '@salesforce/label/c.Loyalty_BO_Cancel_Code';
import REWARD from '@salesforce/label/c.Loyalty_BO_Cancel_Reward';
import STATUS from '@salesforce/label/c.Loyalty_BO_Cancel_Status';
import REFUND from '@salesforce/label/c.Loyalty_BO_Cancel_Refund';
import WARNING from '@salesforce/label/c.Loyalty_BO_Cancel_Warning';
import POINTS_UNIT from '@salesforce/label/c.Loyalty_BO_Points_Unit';
import CATEGORY from '@salesforce/label/c.Loyalty_BO_Reason_Category';
import COMMENT_OPTIONAL from '@salesforce/label/c.Loyalty_BO_Comment_Optional';
import SELECT_PLACEHOLDER from '@salesforce/label/c.Loyalty_BO_Select_Placeholder';
import SUBMIT from '@salesforce/label/c.Loyalty_BO_Cancel_Submit';
import CLOSE from '@salesforce/label/c.Loyalty_BO_Close';
import SUCCESS from '@salesforce/label/c.Loyalty_BO_Cancel_Success';
import NO_PERMISSION from '@salesforce/label/c.Loyalty_BO_No_Permission_Info';
import NOT_ISSUED from '@salesforce/label/c.Loyalty_BO_Error_Voucher_Not_Issued';

const MAX_COMMENT_LENGTH = 255;

export default class VoucherCancelAction extends LightningElement {
    labels = { TITLE, MEMBER, CODE, REWARD, STATUS, REFUND, WARNING, CATEGORY, COMMENT_OPTIONAL, SELECT_PLACEHOLDER, SUBMIT, CLOSE, NO_PERMISSION, NOT_ISSUED };
    maxCommentLength = MAX_COMMENT_LENGTH;

    context;
    category;
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

    get canCancel() {
        return this.context?.canCancel === true && this.context?.isIssued === true;
    }

    get isSubmitDisabled() {
        return !this.canCancel || this.isSaving;
    }

    get refundText() {
        return `+${formatNumber(this.context?.pointsSpent)} ${POINTS_UNIT}`;
    }

    get infoMessage() {
        if (this.context?.canCancel !== true) {
            return NO_PERMISSION;
        }
        return this.context?.isIssued === true ? undefined : NOT_ISSUED;
    }

    async loadContext() {
        this.isLoading = true;
        this.errorMessage = undefined;
        try {
            this.context = await getContext({ voucherId: this._recordId });
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleCategoryChange(event) {
        this.category = event.detail.value;
    }

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    async handleSubmit() {
        const isValid = [...this.template.querySelectorAll('[data-validate]')].reduce((valid, input) => input.reportValidity() && valid, true);
        if (!isValid) {
            return;
        }
        this.isSaving = true;
        this.errorMessage = undefined;
        try {
            const refundedPoints = await cancelVoucher({ voucherId: this._recordId, category: this.category, comment: this.comment });
            this.dispatchEvent(new ShowToastEvent({ title: TITLE, message: formatLabel(SUCCESS, formatNumber(refundedPoints)), variant: 'success' }));
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
