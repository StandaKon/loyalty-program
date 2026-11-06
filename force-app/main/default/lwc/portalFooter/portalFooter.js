import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { PAGES } from 'c/portalUtils';
import LABEL_TAGLINE from '@salesforce/label/c.Portal_Footer_Tagline';
import LABEL_TERMS from '@salesforce/label/c.Portal_Footer_Terms';
import LABEL_PRIVACY from '@salesforce/label/c.Portal_Footer_Privacy';

export default class PortalFooter extends NavigationMixin(LightningElement) {
    labels = { tagline: LABEL_TAGLINE, terms: LABEL_TERMS, privacy: LABEL_PRIVACY };
    currentYear = new Date().getFullYear();

    handleNavigate(event) {
        const pageName = PAGES[event.currentTarget.dataset.page];
        if (!pageName) {
            return;
        }
        event.preventDefault();
        this[NavigationMixin.Navigate]({ type: 'comm__namedPage', attributes: { name: pageName } });
    }
}
