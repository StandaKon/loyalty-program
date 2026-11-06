import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getCatalogue from '@salesforce/apex/RewardsPortalController.getCatalogue';
import redeem from '@salesforce/apex/RewardsPortalController.redeem';
import TITLE from '@salesforce/label/c.Loyalty_Rewards_Title';
import INTRO from '@salesforce/label/c.Loyalty_Rewards_Intro';
import BALANCE from '@salesforce/label/c.Loyalty_Rewards_Balance';
import VALUE from '@salesforce/label/c.Loyalty_Rewards_Value';
import REDEEM from '@salesforce/label/c.Loyalty_Rewards_Redeem';
import MISSING from '@salesforce/label/c.Loyalty_Rewards_Missing';
import PROCESSING from '@salesforce/label/c.Loyalty_Rewards_Processing';
import SUCCESS from '@salesforce/label/c.Loyalty_Rewards_Success';
import EMPTY from '@salesforce/label/c.Loyalty_Rewards_Empty';
import CLOSE from '@salesforce/label/c.Loyalty_BO_Close';
import { reduceError, formatLabel, formatNumber } from 'c/loyaltyActionUtils';

export default class RewardCatalogue extends LightningElement {
    labels = { title: TITLE, intro: INTRO, balance: BALANCE, processing: PROCESSING, empty: EMPTY, close: CLOSE };
    rewards = []; errorMessage; isLoading = true; isSaving = false; selectedReward; wiredResult;

    @wire(getCatalogue)
    wiredCatalogue(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.rewards = data.map((reward) => ({ ...reward, valueLabel: formatLabel(VALUE, formatNumber(reward.valueCzk)), actionLabel: formatLabel(REDEEM, formatNumber(reward.pointsCost)), missingLabel: formatLabel(MISSING, formatNumber(reward.missingPoints)) }));
            this.errorMessage = undefined;
        } else if (error) { this.rewards = []; this.errorMessage = reduceError(error); }
        this.isLoading = false;
    }

    get hasRewards() { return this.rewards.length > 0; }
    get isEmpty() { return !this.isLoading && !this.errorMessage && !this.hasRewards; }
    get balance() { return this.hasRewards ? formatNumber(this.rewards[0].memberBalance) : '0'; }

    handleSelect(event) {
        const reward = this.rewards.find((item) => item.id === event.currentTarget.dataset.id);
        this.selectedReward = reward ? { ...reward, requestKey: crypto.randomUUID() } : undefined;
    }
    handleClose() { if (!this.isSaving) this.selectedReward = undefined; }
    async handleConfirm() {
        if (!this.selectedReward?.id || this.isSaving) return;
        this.isSaving = true; this.errorMessage = undefined;
        try {
            const result = await redeem({ rewardId: this.selectedReward.id, requestKey: this.selectedReward.requestKey });
            this.dispatchEvent(new ShowToastEvent({ title: TITLE, message: formatLabel(SUCCESS, result.voucher.code, formatNumber(result.balance)), variant: 'success' }));
            this.selectedReward = undefined;
            await refreshApex(this.wiredResult);
        } catch (error) { this.errorMessage = reduceError(error); }
        finally { this.isSaving = false; }
    }
}
