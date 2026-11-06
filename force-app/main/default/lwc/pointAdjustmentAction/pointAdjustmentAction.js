import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import getContext from '@salesforce/apex/PointAdjustmentController.getContext';
import adjustPoints from '@salesforce/apex/PointAdjustmentController.adjustPoints';
import { reduceError, formatLabel, generateRequestKey, formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_BO_Adjust_Title';
import MEMBER from '@salesforce/label/c.Loyalty_BO_Member';
import CURRENT_BALANCE from '@salesforce/label/c.Loyalty_BO_Current_Balance';
import NEW_BALANCE from '@salesforce/label/c.Loyalty_BO_New_Balance';
import POINTS_UNIT from '@salesforce/label/c.Loyalty_BO_Points_Unit';
import POINTS from '@salesforce/label/c.Loyalty_BO_Adjust_Points';
import POINTS_HELP from '@salesforce/label/c.Loyalty_BO_Adjust_Points_Help';
import CATEGORY from '@salesforce/label/c.Loyalty_BO_Reason_Category';
import COMMENT from '@salesforce/label/c.Loyalty_BO_Comment';
import SELECT_PLACEHOLDER from '@salesforce/label/c.Loyalty_BO_Select_Placeholder';
import SUBMIT from '@salesforce/label/c.Loyalty_BO_Adjust_Submit';
import CLOSE from '@salesforce/label/c.Loyalty_BO_Close';
import SUCCESS from '@salesforce/label/c.Loyalty_BO_Adjust_Success';
import NO_PERMISSION from '@salesforce/label/c.Loyalty_BO_No_Permission_Info';
import POINTS_ZERO from '@salesforce/label/c.Loyalty_BO_Error_Points_Zero';
import INSUFFICIENT_BALANCE from '@salesforce/label/c.Loyalty_BO_Error_Insufficient_Balance';

const MAX_COMMENT_LENGTH = 255;

export default class PointAdjustmentAction extends LightningElement {
    labels = { TITLE, MEMBER, CURRENT_BALANCE, NEW_BALANCE, POINTS_UNIT, POINTS, POINTS_HELP, CATEGORY, COMMENT, SELECT_PLACEHOLDER, SUBMIT, CLOSE, NO_PERMISSION };
    maxCommentLength = MAX_COMMENT_LENGTH;

    context;
    points;
    category;
    comment;
    errorMessage;
    isLoading = true;
    isSaving = false;
    requestKey;
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

    get canAdjust() {
        return this.context?.canAdjust === true;
    }

    get isSubmitDisabled() {
        return !this.canAdjust || this.isSaving;
    }

    get balanceText() {
        return `${formatNumber(this.context?.balance)} ${POINTS_UNIT}`;
    }

    get hasValidPoints() {
        return Number.isInteger(this.points) && this.points !== 0;
    }

    get newBalance() {
        return (this.context?.balance ?? 0) + (this.hasValidPoints ? this.points : 0);
    }

    get newBalanceText() {
        return `${formatNumber(this.newBalance)} ${POINTS_UNIT}`;
    }

    get newBalanceClass() {
        if (!this.hasValidPoints) {
            return 'loyalty-value';
        }
        return this.points > 0 && this.newBalance >= 0 ? 'loyalty-plus' : 'loyalty-minus';
    }

    async loadContext() {
        this.isLoading = true;
        this.errorMessage = undefined;
        try {
            this.context = await getContext({ memberId: this._recordId });
            this.requestKey = generateRequestKey();
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handlePointsChange(event) {
        const value = event.target.value;
        this.points = value === '' || value === null ? undefined : Number(value);
        this.validatePoints(event.target);
    }

    handleCategoryChange(event) {
        this.category = event.detail.value;
    }

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    validatePoints(input) {
        let message = '';
        if (this.points !== undefined && !this.hasValidPoints) {
            message = POINTS_ZERO;
        } else if (this.hasValidPoints && this.newBalance < 0) {
            message = formatLabel(INSUFFICIENT_BALANCE, formatNumber(this.context.balance));
        }
        input.setCustomValidity(message);
        input.reportValidity();
    }

    isFormValid() {
        const pointsInput = this.template.querySelector('[data-id="points"]');
        if (pointsInput) {
            this.validatePoints(pointsInput);
        }
        return [...this.template.querySelectorAll('[data-validate]')].reduce((isValid, input) => input.reportValidity() && isValid, true);
    }

    async handleSubmit() {
        if (!this.isFormValid()) {
            return;
        }
        this.isSaving = true;
        this.errorMessage = undefined;
        try {
            const newBalance = await adjustPoints({
                memberId: this._recordId,
                points: this.points,
                category: this.category,
                comment: this.comment,
                requestKey: this.requestKey
            });
            this.dispatchEvent(new ShowToastEvent({ title: TITLE, message: formatLabel(SUCCESS, formatNumber(newBalance)), variant: 'success' }));
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
