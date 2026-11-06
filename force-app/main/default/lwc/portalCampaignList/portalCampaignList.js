import { LightningElement, api } from 'lwc';
import { formatDate, formatLabel } from 'c/portalUtils';
import LABEL_VALID_TO from '@salesforce/label/c.Portal_Campaigns_ValidTo';
import LABEL_NO_END from '@salesforce/label/c.Portal_Campaigns_NoEnd';

export default class PortalCampaignList extends LightningElement {
    @api campaigns = [];

    get rows() {
        return (this.campaigns ?? []).map((campaign, index) => ({
            id: campaign.id ?? `campaign-${index}`,
            name: campaign.name,
            memberText: campaign.memberText,
            validityLabel: campaign.validTo ? formatLabel(LABEL_VALID_TO, formatDate(campaign.validTo)) : LABEL_NO_END
        }));
    }
}
