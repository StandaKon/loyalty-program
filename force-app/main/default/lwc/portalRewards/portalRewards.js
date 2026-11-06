import { LightningElement } from 'lwc';
import getRewardCatalog from '@salesforce/apex/PortalMemberController.getRewardCatalog';
import { formatLabel, formatPoints, isNotMemberError } from 'c/portalUtils';
import LABEL_TITLE from '@salesforce/label/c.Portal_Nav_Rewards';
import LABEL_NOT_MEMBER from '@salesforce/label/c.Portal_State_NotMember';
import LABEL_INTRO from '@salesforce/label/c.Portal_Rewards_Intro';
import LABEL_BALANCE from '@salesforce/label/c.Portal_Rewards_Balance';
import LABEL_EMPTY from '@salesforce/label/c.Portal_Rewards_Empty';
import LABEL_VALUE from '@salesforce/label/c.Portal_Rewards_Value';
import LABEL_AFFORDABLE from '@salesforce/label/c.Portal_Rewards_Affordable';
import LABEL_POINTS_MISSING from '@salesforce/label/c.Portal_Rewards_PointsMissing';

const CZK_FORMAT = new Intl.NumberFormat('cs-CZ', { style: 'currency', currency: 'CZK', maximumFractionDigits: 0 });

export default class PortalRewards extends LightningElement {
    catalog;
    isLoading = true;
    hasError = false;
    isNotMember = false;

    labels = {
        title: LABEL_TITLE,
        notMember: LABEL_NOT_MEMBER,
        intro: LABEL_INTRO,
        empty: LABEL_EMPTY
    };

    connectedCallback() {
        this.loadCatalog();
    }

    async loadCatalog() {
        this.isLoading = true;
        this.hasError = false;
        this.isNotMember = false;
        try {
            this.catalog = await getRewardCatalog();
        } catch (error) {
            this.catalog = undefined;
            this.isNotMember = isNotMemberError(error);
            this.hasError = !this.isNotMember;
        } finally {
            this.isLoading = false;
        }
    }

    get balanceLabel() {
        return formatLabel(LABEL_BALANCE, formatPoints(this.catalog?.balance));
    }

    get hasRewards() {
        return Boolean(this.catalog?.rewards?.length);
    }

    get rewardItems() {
        return (this.catalog?.rewards ?? []).map((reward) => ({
            ...reward,
            costLabel: formatPoints(reward.pointsCost),
            valueLabel: reward.valueCzk > 0 ? formatLabel(LABEL_VALUE, CZK_FORMAT.format(reward.valueCzk)) : undefined,
            progressStyle: `width: ${reward.progressPercent}%`,
            statusLabel: reward.isAffordable ? LABEL_AFFORDABLE : formatLabel(LABEL_POINTS_MISSING, formatPoints(reward.pointsMissing)),
            statusClass: reward.isAffordable ? 'reward__status reward__status_affordable' : 'reward__status'
        }));
    }
}
