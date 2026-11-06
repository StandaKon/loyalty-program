import { LightningElement, api } from 'lwc';
import LABEL_TITLE from '@salesforce/label/c.Portal_Placeholder_Title';
import LABEL_TEXT from '@salesforce/label/c.Portal_Placeholder_Text';
import LABEL_EARN_POINTS from '@salesforce/label/c.Portal_Nav_EarnPoints';
import LABEL_REWARDS from '@salesforce/label/c.Portal_Nav_Rewards';
import LABEL_VOUCHERS from '@salesforce/label/c.Portal_Nav_Vouchers';
import LABEL_PROFILE from '@salesforce/label/c.Portal_Nav_Profile';

const SECTION_TITLES = {
    earnPoints: LABEL_EARN_POINTS,
    rewards: LABEL_REWARDS,
    vouchers: LABEL_VOUCHERS,
    profile: LABEL_PROFILE
};

export default class PortalPlaceholder extends LightningElement {
    @api section = 'earnPoints';

    labels = { title: LABEL_TITLE, text: LABEL_TEXT };

    get sectionTitle() {
        return SECTION_TITLES[this.section] ?? LABEL_TITLE;
    }
}
