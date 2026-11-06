import { LightningElement } from 'lwc';
import getActivities from '@salesforce/apex/PortalActivityController.getActivities';
import saveVehicleProfile from '@salesforce/apex/PortalActivityController.saveVehicleProfile';
import setMarketingConsent from '@salesforce/apex/PortalActivityController.setMarketingConsent';
import { formatLabel, formatPoints, isNotMemberError } from 'c/portalUtils';
import LABEL_TITLE from '@salesforce/label/c.Portal_Nav_Profile';
import LABEL_NOT_MEMBER from '@salesforce/label/c.Portal_State_NotMember';
import LABEL_ERROR_GENERIC from '@salesforce/label/c.Portal_Error_Generic';
import LABEL_VEHICLE_TITLE from '@salesforce/label/c.Portal_Profile_VehicleTitle';
import LABEL_MAKE from '@salesforce/label/c.Portal_Profile_Make';
import LABEL_MODEL from '@salesforce/label/c.Portal_Profile_Model';
import LABEL_FUEL_TYPE from '@salesforce/label/c.Portal_Profile_FuelType';
import LABEL_YEAR from '@salesforce/label/c.Portal_Profile_Year';
import LABEL_REGISTRATION from '@salesforce/label/c.Portal_Profile_Registration';
import LABEL_SELECT_FUEL from '@salesforce/label/c.Portal_Profile_SelectFuel';
import LABEL_SAVE from '@salesforce/label/c.Portal_Profile_Save';
import LABEL_SAVED from '@salesforce/label/c.Portal_Profile_Saved';
import LABEL_BONUS_HINT from '@salesforce/label/c.Portal_Profile_BonusHint';
import LABEL_BONUS_AWARDED from '@salesforce/label/c.Portal_Profile_BonusAwarded';
import LABEL_CONSENT_TITLE from '@salesforce/label/c.Portal_Profile_ConsentTitle';
import LABEL_CONSENT_LABEL from '@salesforce/label/c.Portal_Profile_ConsentLabel';
import LABEL_CONSENT_BONUS_HINT from '@salesforce/label/c.Portal_Profile_ConsentBonusHint';
import LABEL_CONSENT_GRANTED from '@salesforce/label/c.Portal_Profile_ConsentGranted';
import LABEL_CONSENT_WITHDRAWN from '@salesforce/label/c.Portal_Profile_ConsentWithdrawn';
import LABEL_CONSENT_BONUS_AWARDED from '@salesforce/label/c.Portal_Profile_ConsentBonusAwarded';
import LABEL_ERROR_INVALID from '@salesforce/label/c.Portal_Profile_Error_Invalid';

export default class PortalProfile extends LightningElement {
    activities;
    vehicle = {};
    isLoading = true;
    isSaving = false;
    hasError = false;
    isNotMember = false;
    vehicleMessage;
    vehicleError;
    consentMessage;
    consentError;

    labels = {
        title: LABEL_TITLE,
        notMember: LABEL_NOT_MEMBER,
        vehicleTitle: LABEL_VEHICLE_TITLE,
        make: LABEL_MAKE,
        model: LABEL_MODEL,
        fuelType: LABEL_FUEL_TYPE,
        year: LABEL_YEAR,
        registration: LABEL_REGISTRATION,
        selectFuel: LABEL_SELECT_FUEL,
        save: LABEL_SAVE,
        consentTitle: LABEL_CONSENT_TITLE,
        consentLabel: LABEL_CONSENT_LABEL
    };

    connectedCallback() {
        this.loadActivities();
    }

    async loadActivities() {
        this.isLoading = true;
        this.hasError = false;
        this.isNotMember = false;
        try {
            this.applyActivities(await getActivities());
        } catch (error) {
            this.activities = undefined;
            this.isNotMember = isNotMemberError(error);
            this.hasError = !this.isNotMember;
        } finally {
            this.isLoading = false;
        }
    }

    applyActivities(activities) {
        this.activities = activities;
        this.vehicle = { ...(activities?.vehicle ?? {}) };
    }

    get fuelTypeOptions() {
        return this.activities?.fuelTypeOptions ?? [];
    }

    get maxVehicleYear() {
        return new Date().getFullYear() + 1;
    }

    get profileBonusHint() {
        return this.activities?.hasProfileBonus ? undefined : formatLabel(LABEL_BONUS_HINT, formatPoints(this.activities?.profileBonusPoints));
    }

    get marketingBonusHint() {
        return this.activities?.hasMarketingBonus ? undefined : formatLabel(LABEL_CONSENT_BONUS_HINT, formatPoints(this.activities?.marketingBonusPoints));
    }

    handleVehicleChange(event) {
        const { name, value } = event.target;
        this.vehicle = { ...this.vehicle, [name]: value };
        this.vehicleMessage = undefined;
        this.vehicleError = undefined;
    }

    async handleSaveVehicle(event) {
        event.preventDefault();
        if (this.isSaving) {
            return;
        }
        const isValid = [...this.template.querySelectorAll('form lightning-input, form lightning-combobox')].reduce(
            (allValid, input) => input.reportValidity() && allValid,
            true
        );
        if (!isValid) {
            this.vehicleError = LABEL_ERROR_INVALID;
            return;
        }

        this.isSaving = true;
        this.vehicleError = undefined;
        this.vehicleMessage = undefined;
        try {
            const activities = await saveVehicleProfile({ vehicle: this.buildVehicleRequest() });
            this.applyActivities(activities);
            this.vehicleMessage = activities.awardedPoints > 0 ? formatLabel(LABEL_BONUS_AWARDED, formatPoints(activities.awardedPoints)) : LABEL_SAVED;
        } catch (error) {
            this.vehicleError = this.toErrorMessage(error);
        } finally {
            this.isSaving = false;
        }
    }

    async handleConsentChange(event) {
        const isGranted = event.target.checked;
        if (this.isSaving) {
            event.target.checked = !isGranted;
            return;
        }
        this.isSaving = true;
        this.consentError = undefined;
        this.consentMessage = undefined;
        try {
            const activities = await setMarketingConsent({ isGranted });
            this.applyActivities(activities);
            if (activities.awardedPoints > 0) {
                this.consentMessage = formatLabel(LABEL_CONSENT_BONUS_AWARDED, formatPoints(activities.awardedPoints));
            } else {
                this.consentMessage = isGranted ? LABEL_CONSENT_GRANTED : LABEL_CONSENT_WITHDRAWN;
            }
        } catch (error) {
            event.target.checked = !isGranted;
            this.consentError = this.toErrorMessage(error);
        } finally {
            this.isSaving = false;
        }
    }

    buildVehicleRequest() {
        const year = String(this.vehicle.year ?? '').trim();
        return {
            make: this.vehicle.make?.trim() || null,
            model: this.vehicle.model?.trim() || null,
            fuelType: this.vehicle.fuelType || null,
            year: year ? Number(year) : null,
            registration: this.vehicle.registration?.trim() || null
        };
    }

    toErrorMessage(error) {
        return error?.body?.message || LABEL_ERROR_GENERIC;
    }
}
