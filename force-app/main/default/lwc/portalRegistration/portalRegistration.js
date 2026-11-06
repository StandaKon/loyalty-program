import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import registerMember from '@salesforce/apex/PortalRegistrationController.registerMember';
import { PAGES } from 'c/portalUtils';
import LABEL_TITLE from '@salesforce/label/c.Portal_Register_Title';
import LABEL_SUBTITLE from '@salesforce/label/c.Portal_Register_Subtitle';
import LABEL_FIRST_NAME from '@salesforce/label/c.Portal_Register_FirstName';
import LABEL_LAST_NAME from '@salesforce/label/c.Portal_Register_LastName';
import LABEL_EMAIL from '@salesforce/label/c.Portal_Register_Email';
import LABEL_PASSWORD from '@salesforce/label/c.Portal_Register_Password';
import LABEL_PASSWORD_HELP from '@salesforce/label/c.Portal_Register_PasswordHelp';
import LABEL_TERMS_CONSENT from '@salesforce/label/c.Portal_Register_TermsConsent';
import LABEL_MARKETING_CONSENT from '@salesforce/label/c.Portal_Register_MarketingConsent';
import LABEL_SUBMIT from '@salesforce/label/c.Portal_Register_Submit';
import LABEL_HAVE_ACCOUNT from '@salesforce/label/c.Portal_Register_HaveAccount';
import LABEL_TERMS from '@salesforce/label/c.Portal_Footer_Terms';
import LABEL_PRIVACY from '@salesforce/label/c.Portal_Footer_Privacy';
import LABEL_ERROR_REQUIRED from '@salesforce/label/c.Portal_Register_Error_Required';
import LABEL_ERROR_TERMS from '@salesforce/label/c.Portal_Register_Error_TermsRequired';
import LABEL_ERROR_GENERIC from '@salesforce/label/c.Portal_Register_Error_Generic';

export default class PortalRegistration extends NavigationMixin(LightningElement) {
    formData = {
        firstName: '',
        lastName: '',
        email: '',
        password: '',
        termsAccepted: false,
        marketingConsent: false
    };
    isSubmitting = false;
    errorMessage;
    termsUrl;
    privacyUrl;

    labels = {
        title: LABEL_TITLE,
        subtitle: LABEL_SUBTITLE,
        firstName: LABEL_FIRST_NAME,
        lastName: LABEL_LAST_NAME,
        email: LABEL_EMAIL,
        password: LABEL_PASSWORD,
        passwordHelp: LABEL_PASSWORD_HELP,
        termsConsent: LABEL_TERMS_CONSENT,
        marketingConsent: LABEL_MARKETING_CONSENT,
        submit: LABEL_SUBMIT,
        haveAccount: LABEL_HAVE_ACCOUNT,
        terms: LABEL_TERMS,
        privacy: LABEL_PRIVACY
    };

    async connectedCallback() {
        this.termsUrl = await this.generatePageUrl(PAGES.terms);
        this.privacyUrl = await this.generatePageUrl(PAGES.privacy);
    }

    generatePageUrl(pageName) {
        return this[NavigationMixin.GenerateUrl]({ type: 'comm__namedPage', attributes: { name: pageName } });
    }

    handleChange(event) {
        const { name, type, checked, value } = event.target;
        this.formData = { ...this.formData, [name]: type === 'checkbox' ? checked : value };
        this.errorMessage = undefined;
    }

    async handleSubmit(event) {
        event.preventDefault();
        if (this.isSubmitting) {
            return;
        }
        const validationMessage = this.validateForm();
        if (validationMessage) {
            this.errorMessage = validationMessage;
            return;
        }

        this.isSubmitting = true;
        this.errorMessage = undefined;
        try {
            const loginUrl = await registerMember({ request: this.buildRequest() });
            if (loginUrl) {
                window.location.assign(loginUrl);
            } else {
                this.navigateTo(PAGES.login);
            }
        } catch (error) {
            this.errorMessage = error?.body?.message || LABEL_ERROR_GENERIC;
            this.isSubmitting = false;
        }
    }

    validateForm() {
        const fieldsValid = [...this.template.querySelectorAll('lightning-input')].reduce(
            (allValid, input) => input.reportValidity() && allValid,
            true
        );
        if (!this.formData.termsAccepted) {
            return LABEL_ERROR_TERMS;
        }
        return fieldsValid ? undefined : LABEL_ERROR_REQUIRED;
    }

    buildRequest() {
        return {
            firstName: this.formData.firstName.trim(),
            lastName: this.formData.lastName.trim(),
            email: this.formData.email.trim(),
            password: this.formData.password,
            termsAccepted: this.formData.termsAccepted,
            marketingConsent: this.formData.marketingConsent
        };
    }

    handleGoToLogin() {
        this.navigateTo(PAGES.login);
    }

    navigateTo(pageName) {
        this[NavigationMixin.Navigate]({ type: 'comm__namedPage', attributes: { name: pageName } });
    }
}
