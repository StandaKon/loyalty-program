import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import getContext from '@salesforce/apex/PurchaseSimulationController.getContext';
import simulatePurchase from '@salesforce/apex/PurchaseSimulationController.simulatePurchase';
import { reduceError, formatLabel, formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_BO_Sim_Title';
import MEMBER from '@salesforce/label/c.Loyalty_BO_Member';
import CURRENT_BALANCE from '@salesforce/label/c.Loyalty_BO_Current_Balance';
import NEW_BALANCE from '@salesforce/label/c.Loyalty_BO_New_Balance';
import POINTS_UNIT from '@salesforce/label/c.Loyalty_BO_Points_Unit';
import LITERS from '@salesforce/label/c.Loyalty_BO_Sim_Liters';
import FUEL_AMOUNT from '@salesforce/label/c.Loyalty_BO_Sim_Fuel_Amount';
import OTHER_AMOUNT from '@salesforce/label/c.Loyalty_BO_Sim_Other_Amount';
import TOTAL from '@salesforce/label/c.Loyalty_BO_Sim_Total';
import PURCHASED_AT from '@salesforce/label/c.Loyalty_BO_Sim_Purchased_At';
import SUBMIT from '@salesforce/label/c.Loyalty_BO_Sim_Submit';
import NEW_PURCHASE from '@salesforce/label/c.Loyalty_BO_Sim_New';
import CLOSE from '@salesforce/label/c.Loyalty_BO_Close';
import PROCESSED from '@salesforce/label/c.Loyalty_BO_Sim_Processed';
import PROCESSING_ERROR from '@salesforce/label/c.Loyalty_BO_Sim_Error';
import BASE_FUEL from '@salesforce/label/c.Loyalty_BO_Sim_Base_Fuel';
import BASE_OTHER from '@salesforce/label/c.Loyalty_BO_Sim_Base_Other';
import CAMPAIGN from '@salesforce/label/c.Loyalty_BO_Sim_Campaign';
import TOTAL_POINTS from '@salesforce/label/c.Loyalty_BO_Sim_Total_Points';
import MEMBER_NOT_ACTIVE from '@salesforce/label/c.Loyalty_BO_Error_Member_Not_Active';
import TOTAL_ZERO from '@salesforce/label/c.Loyalty_BO_Error_Total_Zero';
import FUEL_LITERS from '@salesforce/label/c.Loyalty_BO_Error_Fuel_Liters';

const toNumber = (value) => (value === '' || value === null || value === undefined ? 0 : Number(value));

export default class PurchaseSimulationAction extends LightningElement {
    labels = {
        TITLE,
        MEMBER,
        CURRENT_BALANCE,
        NEW_BALANCE,
        LITERS,
        FUEL_AMOUNT,
        OTHER_AMOUNT,
        TOTAL,
        PURCHASED_AT,
        SUBMIT,
        NEW_PURCHASE,
        CLOSE,
        BASE_FUEL,
        BASE_OTHER,
        CAMPAIGN,
        TOTAL_POINTS,
        MEMBER_NOT_ACTIVE
    };

    context;
    liters;
    fuelAmount;
    otherAmount;
    purchasedAt = new Date().toISOString();
    result;
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

    get isActive() {
        return this.context?.isActive === true;
    }

    get isInactive() {
        return this.context?.isActive === false;
    }

    get showForm() {
        return this.isActive && !this.result;
    }

    get isSubmitDisabled() {
        return !this.showForm || this.isSaving;
    }

    get maxPurchasedAt() {
        return new Date().toISOString();
    }

    get totalText() {
        return new Intl.NumberFormat('cs-CZ', { style: 'currency', currency: 'CZK' }).format(toNumber(this.fuelAmount) + toNumber(this.otherAmount));
    }

    get balanceText() {
        return `${formatNumber(this.context?.balance)} ${POINTS_UNIT}`;
    }

    get resultMessage() {
        if (!this.result) {
            return undefined;
        }
        return this.result.isProcessed
            ? formatLabel(PROCESSED, this.result.transactionName)
            : formatLabel(PROCESSING_ERROR, this.result.transactionName, this.result.errorMessage);
    }

    get resultClass() {
        return this.result?.isProcessed ? 'loyalty-success slds-m-bottom_small' : 'loyalty-summary loyalty-error slds-m-bottom_small';
    }

    get resultRows() {
        if (!this.result?.isProcessed) {
            return [];
        }
        return [
            { key: 'fuel', label: BASE_FUEL, value: `+${formatNumber(this.result.baseFuelPoints)}`, valueClass: 'loyalty-plus' },
            { key: 'other', label: BASE_OTHER, value: `+${formatNumber(this.result.baseOtherPoints)}`, valueClass: 'loyalty-plus' },
            { key: 'campaign', label: CAMPAIGN, value: `+${formatNumber(this.result.campaignPoints)}`, valueClass: 'loyalty-plus' },
            { key: 'total', label: TOTAL_POINTS, value: `+${formatNumber(this.result.totalPoints)}`, valueClass: 'loyalty-plus' },
            { key: 'balance', label: NEW_BALANCE, value: `${formatNumber(this.result.newBalance)} ${POINTS_UNIT}`, valueClass: 'loyalty-value' }
        ];
    }

    async loadContext() {
        this.isLoading = true;
        this.errorMessage = undefined;
        try {
            this.context = await getContext({ memberId: this._recordId });
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleInputChange(event) {
        this[event.target.dataset.field] = event.target.value;
    }

    validateAmounts() {
        const liters = toNumber(this.liters);
        const fuelAmount = toNumber(this.fuelAmount);
        let message = '';
        if (fuelAmount + toNumber(this.otherAmount) <= 0) {
            message = TOTAL_ZERO;
        } else if (fuelAmount > 0 !== liters > 0) {
            message = FUEL_LITERS;
        }
        const fuelInput = this.template.querySelector('[data-field="fuelAmount"]');
        fuelInput.setCustomValidity(message);
        return fuelInput.reportValidity();
    }

    async handleSubmit() {
        const areInputsValid = [...this.template.querySelectorAll('[data-validate]')].reduce((valid, input) => input.reportValidity() && valid, true);
        if (!areInputsValid || !this.validateAmounts()) {
            return;
        }
        this.isSaving = true;
        this.errorMessage = undefined;
        try {
            this.result = await simulatePurchase({
                memberId: this._recordId,
                liters: toNumber(this.liters),
                fuelAmount: toNumber(this.fuelAmount),
                otherAmount: toNumber(this.otherAmount),
                purchasedAt: this.purchasedAt
            });
            this.dispatchEvent(new RefreshEvent());
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isSaving = false;
        }
    }

    handleNewPurchase() {
        this.context = { ...this.context, balance: this.result?.newBalance ?? this.context.balance };
        this.result = undefined;
        this.liters = undefined;
        this.fuelAmount = undefined;
        this.otherAmount = undefined;
        this.purchasedAt = new Date().toISOString();
        this.errorMessage = undefined;
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
