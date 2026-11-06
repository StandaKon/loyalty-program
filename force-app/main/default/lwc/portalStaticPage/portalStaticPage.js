import { LightningElement, api } from 'lwc';
import LABEL_TERMS_TITLE from '@salesforce/label/c.Portal_Terms_Title';
import LABEL_TERMS_BODY from '@salesforce/label/c.Portal_Terms_Body';
import LABEL_PRIVACY_TITLE from '@salesforce/label/c.Portal_Privacy_Title';
import LABEL_PRIVACY_BODY from '@salesforce/label/c.Portal_Privacy_Body';

const CONTENT = {
    terms: { title: LABEL_TERMS_TITLE, body: LABEL_TERMS_BODY },
    privacy: { title: LABEL_PRIVACY_TITLE, body: LABEL_PRIVACY_BODY }
};

export default class PortalStaticPage extends LightningElement {
    @api pageType = 'terms';

    get content() {
        return CONTENT[this.pageType] ?? CONTENT.terms;
    }

    get title() {
        return this.content.title;
    }

    get body() {
        return this.content.body;
    }
}
