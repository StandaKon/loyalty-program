import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import getMember360 from '@salesforce/apex/Member360Controller.getMember360';
import POINTS_BALANCE_FIELD from '@salesforce/schema/Account.Points_Balance__c';
import { reduceError, formatLabel, formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_M360_Title';
import BALANCE from '@salesforce/label/c.Loyalty_M360_Balance';
import EARNED from '@salesforce/label/c.Loyalty_M360_Earned';
import REDEEMED from '@salesforce/label/c.Loyalty_M360_Redeemed';
import PURCHASES from '@salesforce/label/c.Loyalty_M360_Purchases';
import TOTAL_SPEND from '@salesforce/label/c.Loyalty_M360_Total_Spend';
import LAST_PURCHASE from '@salesforce/label/c.Loyalty_M360_Last_Purchase';
import NONE from '@salesforce/label/c.Loyalty_M360_None';
import ACTIVE_VOUCHERS from '@salesforce/label/c.Loyalty_Dash_Kpi_Active_Vouchers';
import CHART_TITLE from '@salesforce/label/c.Loyalty_M360_Chart_Title';
import PROFILE_TITLE from '@salesforce/label/c.Loyalty_M360_Profile_Title';
import NO_VEHICLE from '@salesforce/label/c.Loyalty_M360_No_Vehicle';
import YEAR from '@salesforce/label/c.Loyalty_M360_Year';
import PROFILE_COMPLETE from '@salesforce/label/c.Loyalty_M360_Profile_Complete';
import PROFILE_INCOMPLETE from '@salesforce/label/c.Loyalty_M360_Profile_Incomplete';
import CONSENT_TERMS from '@salesforce/label/c.Loyalty_M360_Consent_Terms';
import CONSENT_MARKETING from '@salesforce/label/c.Loyalty_M360_Consent_Marketing';
import CONSENT_MISSING from '@salesforce/label/c.Loyalty_M360_Consent_Missing';
import CONSENT_NO_ACCESS from '@salesforce/label/c.Loyalty_M360_Consent_No_Access';
import VERSION from '@salesforce/label/c.Loyalty_M360_Version';
import TIMELINE_TITLE from '@salesforce/label/c.Loyalty_M360_Timeline_Title';
import TIMELINE_EMPTY from '@salesforce/label/c.Loyalty_M360_Timeline_Empty';

const ENTRY_ICONS = {
    PurchaseBase: 'utility:cart',
    CampaignBonus: 'utility:campaign',
    ProfileBonus: 'utility:user',
    MarketingBonus: 'utility:email',
    Redemption: 'utility:knowledge_base',
    Refund: 'utility:undo',
    Adjustment: 'utility:edit'
};

const CONSENT_TYPES = [
    { type: 'Terms', label: CONSENT_TERMS },
    { type: 'Marketing', label: CONSENT_MARKETING }
];

const dateFormatter = new Intl.DateTimeFormat('cs-CZ', { day: 'numeric', month: 'numeric', year: 'numeric', timeZone: 'Europe/Prague' });
const formatDate = (value) => (value ? dateFormatter.format(new Date(value)) : NONE);
const formatCurrency = (value) => new Intl.NumberFormat('cs-CZ', { style: 'currency', currency: 'CZK', maximumFractionDigits: 0 }).format(value ?? 0);

export default class NajetoMember360 extends NavigationMixin(LightningElement) {
    @api recordId;

    labels = { TITLE, CHART_TITLE, PROFILE_TITLE, CONSENT_NO_ACCESS, TIMELINE_TITLE, TIMELINE_EMPTY };

    view;
    errorMessage;
    wiredView;

    @wire(getMember360, { memberId: '$recordId' })
    handleView(result) {
        this.wiredView = result;
        if (result.data) {
            this.view = result.data;
            this.errorMessage = undefined;
        } else if (result.error) {
            this.errorMessage = reduceError(result.error);
        }
    }

    // Refreshes the view after quick actions (adjustment, simulation) change the balance on the record.
    @wire(getRecord, { recordId: '$recordId', fields: [POINTS_BALANCE_FIELD] })
    handleBalanceChange({ data }) {
        if (data && this.view && data.fields.Points_Balance__c.value !== this.view.kpis.balance) {
            refreshApex(this.wiredView);
        }
    }

    get isLoading() {
        return !this.view && !this.errorMessage;
    }

    get kpiTiles() {
        const kpis = this.view?.kpis ?? {};
        return [
            { key: 'balance', label: BALANCE, value: formatNumber(kpis.balance), icon: 'utility:moneybag', isHighlighted: true },
            { key: 'earned', label: EARNED, value: `+${formatNumber(kpis.earned)}`, icon: 'utility:add', valueClass: 'kpi__value loyalty-plus' },
            { key: 'redeemed', label: REDEEMED, value: formatNumber(kpis.redeemed), icon: 'utility:knowledge_base' },
            { key: 'purchases', label: PURCHASES, value: formatNumber(kpis.purchases), icon: 'utility:cart' },
            { key: 'spend', label: TOTAL_SPEND, value: formatCurrency(kpis.totalSpend), icon: 'utility:money' },
            { key: 'lastPurchase', label: LAST_PURCHASE, value: formatDate(kpis.lastPurchase), icon: 'utility:date_input' },
            { key: 'vouchers', label: ACTIVE_VOUCHERS, value: formatNumber(kpis.activeVouchers), icon: 'utility:ticket' }
        ].map((tile) => ({
            ...tile,
            tileClass: tile.isHighlighted ? 'kpi kpi_highlighted' : 'kpi',
            valueClass: tile.valueClass ?? 'kpi__value'
        }));
    }

    get vehicleText() {
        const profile = this.view?.profile;
        if (!profile?.vehicle) {
            return NO_VEHICLE;
        }
        const parts = [profile.vehicle, profile.fuelType, profile.vehicleYear ? formatLabel(YEAR, profile.vehicleYear) : null, profile.registration];
        return parts.filter((part) => part).join(' · ');
    }

    get profileStatus() {
        const isComplete = this.view?.profile?.isComplete === true;
        return {
            label: isComplete ? PROFILE_COMPLETE : PROFILE_INCOMPLETE,
            icon: isComplete ? 'utility:success' : 'utility:warning',
            rowClass: isComplete ? 'fact fact_ok' : 'fact fact_warn'
        };
    }

    get canReadConsents() {
        return this.view?.canReadConsents === true;
    }

    get consentRows() {
        const consents = this.view?.consents ?? [];
        return CONSENT_TYPES.map(({ type, label }) => {
            const consent = consents.find((row) => row.consentType === type);
            if (!consent) {
                return { key: type, label, detail: CONSENT_MISSING, icon: 'utility:dash', rowClass: 'fact' };
            }
            const version = consent.revision ? ` · ${formatLabel(VERSION, consent.revision)}` : '';
            return {
                key: type,
                label,
                detail: `${consent.action ?? ''} · ${formatDate(consent.capturedAt)}${version}`,
                icon: consent.isAccepted ? 'utility:success' : 'utility:close',
                rowClass: consent.isAccepted ? 'fact fact_ok' : 'fact fact_warn'
            };
        });
    }

    get timelineRows() {
        return (this.view?.timeline ?? []).map((row) => ({
            ...row,
            icon: ENTRY_ICONS[row.entryType] ?? 'utility:record',
            pointsText: `${row.points > 0 ? '+' : ''}${formatNumber(row.points)}`,
            pointsClass: row.points > 0 ? 'timeline__points loyalty-plus' : row.points < 0 ? 'timeline__points loyalty-minus' : 'timeline__points',
            dateText: formatDate(row.occurredAt),
            hasSource: Boolean(row.sourceId)
        }));
    }

    get hasTimeline() {
        return this.timelineRows.length > 0;
    }

    handleSourceClick(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: event.currentTarget.dataset.recordId, actionName: 'view' }
        });
    }
}
