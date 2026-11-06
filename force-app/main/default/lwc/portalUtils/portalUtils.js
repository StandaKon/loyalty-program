import LABEL_POINTS_ONE from '@salesforce/label/c.Portal_Points_One';
import LABEL_POINTS_FEW from '@salesforce/label/c.Portal_Points_Few';
import LABEL_POINTS_MANY from '@salesforce/label/c.Portal_Points_Many';
import LABEL_TYPE_PURCHASE_BASE from '@salesforce/label/c.Portal_MovementType_PurchaseBase';
import LABEL_TYPE_CAMPAIGN_BONUS from '@salesforce/label/c.Portal_MovementType_CampaignBonus';
import LABEL_TYPE_PROFILE_BONUS from '@salesforce/label/c.Portal_MovementType_ProfileBonus';
import LABEL_TYPE_MARKETING_BONUS from '@salesforce/label/c.Portal_MovementType_MarketingBonus';
import LABEL_TYPE_REDEMPTION from '@salesforce/label/c.Portal_MovementType_Redemption';
import LABEL_TYPE_REFUND from '@salesforce/label/c.Portal_MovementType_Refund';
import LABEL_TYPE_ADJUSTMENT from '@salesforce/label/c.Portal_MovementType_Adjustment';
import LABEL_TYPE_OTHER from '@salesforce/label/c.Portal_MovementType_Other';
import LABEL_TYPE_EXPIRATION from '@salesforce/label/c.Portal_MovementType_Expiration';
import LABEL_TYPE_REVERSAL from '@salesforce/label/c.Portal_MovementType_Reversal';
import LABEL_TYPE_TIER_BONUS from '@salesforce/label/c.Portal_MovementType_TierBonus';

export const PAGES = Object.freeze({
    overview: 'Home',
    history: 'Historie_bodu__c',
    campaigns: 'Akce__c',
    earnPoints: 'Ziskej_body__c',
    rewards: 'Odmeny__c',
    vouchers: 'Moje_vouchery__c',
    profile: 'Profil__c',
    terms: 'Podminky__c',
    privacy: 'Ochrana_osobnich_udaju__c',
    login: 'Login',
    register: 'Register'
});

const MINUS_SIGN = '−';
const NUMBER_FORMAT = new Intl.NumberFormat('cs-CZ', { maximumFractionDigits: 0 });
const ISO_DATE_PATTERN = /^(\d{4})-(\d{2})-(\d{2})/;

const MOVEMENT_TYPE_LABELS = {
    PurchaseBase: LABEL_TYPE_PURCHASE_BASE,
    CampaignBonus: LABEL_TYPE_CAMPAIGN_BONUS,
    ProfileBonus: LABEL_TYPE_PROFILE_BONUS,
    MarketingBonus: LABEL_TYPE_MARKETING_BONUS,
    Redemption: LABEL_TYPE_REDEMPTION,
    Refund: LABEL_TYPE_REFUND,
    Adjustment: LABEL_TYPE_ADJUSTMENT,
    Expiration: LABEL_TYPE_EXPIRATION,
    Reversal: LABEL_TYPE_REVERSAL,
    TierBonus: LABEL_TYPE_TIER_BONUS
};

export function formatNumber(value) {
    return NUMBER_FORMAT.format(Math.abs(Number(value) || 0));
}

export function pointsUnit(value) {
    const count = Math.abs(Number(value) || 0);
    if (count === 1) {
        return LABEL_POINTS_ONE;
    }
    if (count >= 2 && count <= 4) {
        return LABEL_POINTS_FEW;
    }
    return LABEL_POINTS_MANY;
}

export function formatPoints(value) {
    return `${formatNumber(value)}\u00a0${pointsUnit(value)}`;
}

export function formatSignedPoints(value) {
    const points = Number(value) || 0;
    if (points > 0) {
        return `+${formatNumber(points)}`;
    }
    if (points < 0) {
        return `${MINUS_SIGN}${formatNumber(points)}`;
    }
    return '0';
}

export function formatDate(isoDate) {
    const match = ISO_DATE_PATTERN.exec(isoDate ?? '');
    if (!match) {
        return '';
    }
    const [, year, month, day] = match;
    return `${Number(day)}.\u00a0${Number(month)}.\u00a0${year}`;
}

export function formatLabel(label, ...args) {
    return args.reduce((text, arg, index) => text.replace(`{${index}}`, arg ?? ''), label ?? '');
}

// Must match PortalMemberController.ERROR_CODE_NOT_MEMBER.
const NOT_MEMBER_ERROR_CODE = 'PORTAL_NOT_MEMBER';

export function isNotMemberError(error) {
    return error?.body?.message === NOT_MEMBER_ERROR_CODE;
}

export function movementTypeLabel(type) {
    return MOVEMENT_TYPE_LABELS[type] ?? LABEL_TYPE_OTHER;
}
