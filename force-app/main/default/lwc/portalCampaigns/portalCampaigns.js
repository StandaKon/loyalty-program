import { LightningElement } from 'lwc';
import getActiveCampaigns from '@salesforce/apex/PortalMemberController.getActiveCampaigns';
import LABEL_TITLE from '@salesforce/label/c.Portal_Campaigns_Title';
import LABEL_INTRO from '@salesforce/label/c.Portal_Promo_Intro';

export default class PortalCampaigns extends LightningElement {
    campaigns = [];
    isLoading = true;
    hasError = false;

    labels = { title: LABEL_TITLE, intro: LABEL_INTRO };

    connectedCallback() {
        this.loadCampaigns();
    }

    get hasCampaigns() {
        return this.campaigns.length > 0;
    }

    async loadCampaigns() {
        this.isLoading = true;
        this.hasError = false;
        try {
            this.campaigns = (await getActiveCampaigns()) ?? [];
        } catch (error) {
            this.campaigns = [];
            this.hasError = true;
        } finally {
            this.isLoading = false;
        }
    }
}
