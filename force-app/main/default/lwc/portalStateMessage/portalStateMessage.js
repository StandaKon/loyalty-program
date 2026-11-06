import { LightningElement, api } from 'lwc';
import LABEL_LOADING from '@salesforce/label/c.Portal_State_Loading';
import LABEL_ERROR from '@salesforce/label/c.Portal_Error_Generic';
import LABEL_RETRY from '@salesforce/label/c.Portal_Action_Retry';

const VARIANT_LOADING = 'loading';
const VARIANT_ERROR = 'error';

export default class PortalStateMessage extends LightningElement {
    @api variant = 'empty';
    @api message;

    labels = { retry: LABEL_RETRY };

    get isLoading() {
        return this.variant === VARIANT_LOADING;
    }

    get isError() {
        return this.variant === VARIANT_ERROR;
    }

    get loadingText() {
        return this.message || LABEL_LOADING;
    }

    get errorText() {
        return this.message || LABEL_ERROR;
    }

    handleRetry() {
        this.dispatchEvent(new CustomEvent('retry'));
    }
}
