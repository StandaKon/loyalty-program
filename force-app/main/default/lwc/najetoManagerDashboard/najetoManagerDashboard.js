import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getDashboard from '@salesforce/apex/LoyaltyDashboardController.getDashboard';
import { reduceError, formatLabel, formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_Dash_Title';
import PERIOD from '@salesforce/label/c.Loyalty_Dash_Period';
import THIS_MONTH from '@salesforce/label/c.Loyalty_Dash_This_Month';
import LAST_MONTH from '@salesforce/label/c.Loyalty_Dash_Last_Month';
import LAST_30_DAYS from '@salesforce/label/c.Loyalty_Dash_Last_30_Days';
import THIS_YEAR from '@salesforce/label/c.Loyalty_Dash_This_Year';
import REFRESH from '@salesforce/label/c.Loyalty_Dash_Refresh';
import UPDATED from '@salesforce/label/c.Loyalty_Dash_Updated';
import VS_PREVIOUS from '@salesforce/label/c.Loyalty_Dash_Vs_Previous';
import CURRENT_STATE from '@salesforce/label/c.Loyalty_Dash_Current_State';
import KPI_ACTIVE_MEMBERS from '@salesforce/label/c.Loyalty_Dash_Kpi_Active_Members';
import KPI_NEW_MEMBERS from '@salesforce/label/c.Loyalty_Dash_Kpi_New_Members';
import KPI_POINTS_AWARDED from '@salesforce/label/c.Loyalty_Dash_Kpi_Points_Awarded';
import KPI_POINTS_REDEEMED from '@salesforce/label/c.Loyalty_Dash_Kpi_Points_Redeemed';
import KPI_REDEMPTION_RATE from '@salesforce/label/c.Loyalty_Dash_Kpi_Redemption_Rate';
import KPI_VOUCHERS_ISSUED from '@salesforce/label/c.Loyalty_Dash_Kpi_Vouchers_Issued';
import KPI_ACTIVE_VOUCHERS from '@salesforce/label/c.Loyalty_Dash_Kpi_Active_Vouchers';
import KPI_BUDGET from '@salesforce/label/c.Loyalty_Dash_Kpi_Budget';
import BUDGET_OF from '@salesforce/label/c.Loyalty_Dash_Budget_Of';
import BUDGET_MISSING from '@salesforce/label/c.Loyalty_Dash_Budget_Missing';
import QUEUE_TITLE from '@salesforce/label/c.Loyalty_Dash_Queue_Title';
import QUEUE_TX_ERRORS from '@salesforce/label/c.Loyalty_Dash_Queue_Tx_Errors';
import QUEUE_PENDING from '@salesforce/label/c.Loyalty_Dash_Queue_Pending';
import QUEUE_EMAIL_ERRORS from '@salesforce/label/c.Loyalty_Dash_Queue_Email_Errors';
import QUEUE_ALL_CLEAR from '@salesforce/label/c.Loyalty_Dash_Queue_All_Clear';
import CAMPAIGNS_TITLE from '@salesforce/label/c.Loyalty_Dash_Campaigns_Title';
import CAMPAIGN from '@salesforce/label/c.Loyalty_Dash_Campaign';
import HITS from '@salesforce/label/c.Loyalty_Dash_Hits';
import MEMBERS from '@salesforce/label/c.Loyalty_Dash_Members';
import BONUS_POINTS from '@salesforce/label/c.Loyalty_Dash_Bonus_Points';
import CAMPAIGNS_EMPTY from '@salesforce/label/c.Loyalty_Dash_Campaigns_Empty';
import ADJUSTMENTS_TITLE from '@salesforce/label/c.Loyalty_Dash_Adjustments_Title';
import MEMBER from '@salesforce/label/c.Loyalty_BO_Member';
import POINTS from '@salesforce/label/c.Loyalty_Dash_Points';
import CATEGORY from '@salesforce/label/c.Loyalty_Dash_Category';
import CREATED_BY from '@salesforce/label/c.Loyalty_Dash_Created_By';
import DATE_LABEL from '@salesforce/label/c.Loyalty_Dash_Date';
import ADJUSTMENTS_EMPTY from '@salesforce/label/c.Loyalty_Dash_Adjustments_Empty';

const KPI_DEFINITIONS = {
    activeMembers: { label: KPI_ACTIVE_MEMBERS, icon: 'utility:groups' },
    newMembers: { label: KPI_NEW_MEMBERS, icon: 'utility:adduser' },
    pointsAwarded: { label: KPI_POINTS_AWARDED, icon: 'utility:add' },
    pointsRedeemed: { label: KPI_POINTS_REDEEMED, icon: 'utility:cart' },
    redemptionRate: { label: KPI_REDEMPTION_RATE, icon: 'utility:percent', isPercent: true },
    vouchersIssued: { label: KPI_VOUCHERS_ISSUED, icon: 'utility:knowledge_base' },
    activeVouchers: { label: KPI_ACTIVE_VOUCHERS, icon: 'utility:ticket' },
    budgetUsed: { label: KPI_BUDGET, icon: 'utility:moneybag', isBudget: true }
};

const QUEUE_LABELS = {
    transactionErrors: QUEUE_TX_ERRORS,
    pendingTransactions: QUEUE_PENDING,
    voucherEmailErrors: QUEUE_EMAIL_ERRORS
};

const formatCurrency = (value) => new Intl.NumberFormat('cs-CZ', { style: 'currency', currency: 'CZK', maximumFractionDigits: 0 }).format(value ?? 0);
const formatPercent = (value) => (value === null || value === undefined ? '–' : `${new Intl.NumberFormat('cs-CZ', { maximumFractionDigits: 1 }).format(value)} %`);

export default class NajetoManagerDashboard extends NavigationMixin(LightningElement) {
    labels = {
        TITLE,
        PERIOD,
        REFRESH,
        QUEUE_TITLE,
        QUEUE_ALL_CLEAR,
        CAMPAIGNS_TITLE,
        CAMPAIGN,
        HITS,
        MEMBERS,
        BONUS_POINTS,
        CAMPAIGNS_EMPTY,
        ADJUSTMENTS_TITLE,
        MEMBER,
        POINTS,
        CATEGORY,
        CREATED_BY,
        DATE_LABEL,
        ADJUSTMENTS_EMPTY
    };

    periodOptions = [
        { label: THIS_MONTH, value: 'THIS_MONTH' },
        { label: LAST_MONTH, value: 'LAST_MONTH' },
        { label: LAST_30_DAYS, value: 'LAST_30_DAYS' },
        { label: THIS_YEAR, value: 'THIS_YEAR' }
    ];

    period = 'THIS_MONTH';
    dashboard;
    errorMessage;
    isRefreshing = false;
    wiredDashboard;

    @wire(getDashboard, { period: '$period' })
    handleDashboard(result) {
        this.wiredDashboard = result;
        const { data, error } = result;
        if (data) {
            this.dashboard = data;
            this.errorMessage = undefined;
        } else if (error) {
            this.errorMessage = reduceError(error);
        }
    }

    get isLoading() {
        return !this.dashboard && !this.errorMessage;
    }

    get updatedText() {
        if (!this.dashboard?.generatedAt) {
            return '';
        }
        const time = new Intl.DateTimeFormat('cs-CZ', { dateStyle: 'short', timeStyle: 'short', timeZone: 'Europe/Prague' }).format(new Date(this.dashboard.generatedAt));
        return formatLabel(UPDATED, time);
    }

    get periodRangeText() {
        if (!this.dashboard) {
            return '';
        }
        const format = new Intl.DateTimeFormat('cs-CZ', { day: 'numeric', month: 'numeric', year: 'numeric', timeZone: 'UTC' });
        return `${format.format(new Date(this.dashboard.periodStart))} – ${format.format(new Date(this.dashboard.periodEnd))}`;
    }

    get kpiTiles() {
        return (this.dashboard?.kpis ?? []).map((kpi) => this.toTile(kpi));
    }

    toTile(kpi) {
        const definition = KPI_DEFINITIONS[kpi.key];
        const tile = {
            key: kpi.key,
            label: definition.label,
            icon: definition.icon,
            value: definition.isPercent ? formatPercent(kpi.value) : formatNumber(kpi.value),
            footnote: CURRENT_STATE,
            hasDelta: false,
            hasProgress: false
        };
        if (definition.isBudget) {
            tile.label = formatLabel(KPI_BUDGET, this.dashboard.budgetYear);
            tile.value = formatCurrency(kpi.value);
            if (kpi.previousValue) {
                tile.footnote = formatLabel(BUDGET_OF, formatCurrency(kpi.previousValue));
                tile.hasProgress = true;
                tile.progress = Math.min(100, Math.round((kpi.value / kpi.previousValue) * 100));
                tile.progressStyle = `width:${tile.progress}%`;
            } else {
                tile.footnote = BUDGET_MISSING;
            }
            return tile;
        }
        if (kpi.previousValue === null || kpi.previousValue === undefined) {
            return tile;
        }
        const difference = definition.isPercent ? kpi.value - kpi.previousValue : kpi.previousValue === 0 ? null : ((kpi.value - kpi.previousValue) / kpi.previousValue) * 100;
        tile.footnote = VS_PREVIOUS;
        if (difference === null || difference === undefined || Number.isNaN(difference)) {
            tile.deltaText = kpi.value > 0 ? `+${formatNumber(kpi.value)}` : '–';
            tile.hasDelta = true;
            tile.deltaIcon = kpi.value > 0 ? 'utility:arrowup' : 'utility:dash';
            tile.deltaClass = kpi.value > 0 ? 'kpi__delta kpi__delta_up' : 'kpi__delta';
            return tile;
        }
        const rounded = Math.round(difference * 10) / 10;
        const unit = definition.isPercent ? ' p. b.' : ' %';
        tile.hasDelta = true;
        tile.deltaText = `${rounded > 0 ? '+' : ''}${new Intl.NumberFormat('cs-CZ', { maximumFractionDigits: 1 }).format(rounded)}${unit}`;
        tile.deltaIcon = rounded > 0 ? 'utility:arrowup' : rounded < 0 ? 'utility:arrowdown' : 'utility:dash';
        tile.deltaClass = rounded > 0 ? 'kpi__delta kpi__delta_up' : rounded < 0 ? 'kpi__delta kpi__delta_down' : 'kpi__delta';
        return tile;
    }

    get queueItems() {
        return (this.dashboard?.queue ?? []).map((item) => ({
            ...item,
            label: QUEUE_LABELS[item.key],
            countText: formatNumber(item.count),
            itemClass: item.count > 0 ? 'queue__item queue__item_open' : 'queue__item queue__item_clear',
            icon: item.count > 0 ? 'utility:warning' : 'utility:success'
        }));
    }

    get isQueueClear() {
        return this.queueItems.every((item) => item.count === 0);
    }

    get topCampaigns() {
        return (this.dashboard?.topCampaigns ?? []).map((row) => ({
            ...row,
            hitsText: formatNumber(row.hits),
            membersText: formatNumber(row.members),
            pointsText: `+${formatNumber(row.points)}`
        }));
    }

    get hasTopCampaigns() {
        return this.topCampaigns.length > 0;
    }

    get recentAdjustments() {
        return (this.dashboard?.recentAdjustments ?? []).map((row) => ({
            ...row,
            pointsText: `${row.points > 0 ? '+' : ''}${formatNumber(row.points)}`,
            pointsClass: row.points > 0 ? 'loyalty-plus' : 'loyalty-minus'
        }));
    }

    get hasRecentAdjustments() {
        return this.recentAdjustments.length > 0;
    }

    handlePeriodChange(event) {
        this.period = event.detail.value;
    }

    async handleRefresh() {
        this.isRefreshing = true;
        try {
            await refreshApex(this.wiredDashboard);
        } catch (error) {
            this.errorMessage = reduceError(error);
        } finally {
            this.isRefreshing = false;
        }
    }

    handleQueueClick(event) {
        const { objectApiName, listViewName } = event.currentTarget.dataset;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: { objectApiName, actionName: 'list' },
            state: { filterName: listViewName }
        });
    }

    handleRecordClick(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: event.currentTarget.dataset.recordId, actionName: 'view' }
        });
    }
}
