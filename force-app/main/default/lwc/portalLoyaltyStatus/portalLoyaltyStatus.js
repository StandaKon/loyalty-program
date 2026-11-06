import { LightningElement } from 'lwc';
import getLoyaltyStatus from '@salesforce/apex/PortalMemberController.getLoyaltyStatus';
import { formatDate, formatLabel, formatNumber, formatPoints } from 'c/portalUtils';
import LABEL_TITLE from '@salesforce/label/c.Portal_Tier_Title';
import LABEL_ROAD_TITLE from '@salesforce/label/c.Portal_Tier_RoadTitle';
import LABEL_HIGHWAY_TITLE from '@salesforce/label/c.Portal_Tier_HighwayTitle';
import LABEL_POINTS_TO_HIGHWAY from '@salesforce/label/c.Portal_Tier_PointsToHighway';
import LABEL_PROGRESS from '@salesforce/label/c.Portal_Tier_Progress';
import LABEL_HIGHWAY_BENEFIT from '@salesforce/label/c.Portal_Tier_HighwayBenefit';
import LABEL_HIGHWAY_KEEP from '@salesforce/label/c.Portal_Tier_HighwayKeep';
import LABEL_HIGHWAY_RISK from '@salesforce/label/c.Portal_Tier_HighwayRisk';
import LABEL_RULE from '@salesforce/label/c.Portal_Tier_Rule';
import LABEL_EXPIRY_WARNING from '@salesforce/label/c.Portal_Expiry_Warning';
import LABEL_EXPIRY_RULE from '@salesforce/label/c.Portal_Expiry_Rule';

export default class PortalLoyaltyStatus extends LightningElement {
    status;

    labels = { title: LABEL_TITLE, expiryRule: LABEL_EXPIRY_RULE };

    // Optional extension of the overview: on failure the cards stay hidden and the overview keeps working.
    async connectedCallback() {
        try {
            this.status = await getLoyaltyStatus();
        } catch (error) {
            this.status = undefined;
        }
    }

    get hasExpiry() {
        return this.status?.expiringPoints > 0;
    }

    get expiryText() {
        return formatLabel(LABEL_EXPIRY_WARNING, formatPoints(this.status.expiringPoints), formatDate(this.status.expiryDate));
    }

    get tierCardClass() {
        return this.status.isHighway ? 'card card_tier card_highway' : 'card card_tier card_road';
    }

    get tierTitle() {
        return this.status.isHighway ? LABEL_HIGHWAY_TITLE : LABEL_ROAD_TITLE;
    }

    get progressStyle() {
        return `width: ${this.status.progressPercent}%`;
    }

    get pointsToHighwayText() {
        return formatLabel(LABEL_POINTS_TO_HIGHWAY, formatPoints(this.status.pointsToHighway));
    }

    get progressText() {
        return formatLabel(LABEL_PROGRESS, this.status.qualificationMonths, formatNumber(this.status.qualifyingPoints), formatNumber(this.status.threshold));
    }

    get highwayBenefitText() {
        return formatLabel(LABEL_HIGHWAY_BENEFIT, this.status.fuelBonusPercent);
    }

    get highwayStatusText() {
        const evaluationDate = formatDate(this.status.nextEvaluationDate);
        if (this.status.pointsToHighway > 0) {
            return formatLabel(LABEL_HIGHWAY_RISK, formatPoints(this.status.pointsToHighway), evaluationDate);
        }
        return formatLabel(
            LABEL_HIGHWAY_KEEP,
            formatNumber(this.status.threshold),
            this.status.qualificationMonths,
            formatNumber(this.status.qualifyingPoints),
            evaluationDate
        );
    }

    get ruleText() {
        return formatLabel(LABEL_RULE, formatNumber(this.status.threshold), this.status.qualificationMonths);
    }
}
