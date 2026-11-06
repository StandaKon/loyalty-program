/**
 * Builds the back-office home dashboard (B5): KPIs for a selected period compared with the previous period of the same
 * length, operational queues, monthly points trend, top campaigns and recent manual adjustments.
 * Periods are evaluated in Europe/Prague and use business dates (Joined_At, Occurred_At, Issued_At), never CreatedDate.
 * KPI definitions follow B1 §7: awarded = positive earning entry types; redeemed = |Redemption| - Refund.
 */
public inherited sharing class LoyaltyDashboardService {
    public static final String PERIOD_THIS_MONTH = 'THIS_MONTH';
    public static final String PERIOD_LAST_MONTH = 'LAST_MONTH';
    public static final String PERIOD_LAST_30_DAYS = 'LAST_30_DAYS';
    public static final String PERIOD_THIS_YEAR = 'THIS_YEAR';

    private static final String PROGRAM_TIME_ZONE = 'Europe/Prague';
    private static final Set<String> EARNING_TYPES = new Set<String>{ 'PurchaseBase', 'CampaignBonus', 'ProfileBonus', 'MarketingBonus' };
    private static final Integer TREND_MONTHS = 6;
    private static final Integer TOP_CAMPAIGNS = 5;
    private static final Integer RECENT_ADJUSTMENTS = 5;

    private final LoyaltyDashboardSelector selector;
    private final TimeZone programTimeZone = TimeZone.getTimeZone(PROGRAM_TIME_ZONE);

    public LoyaltyDashboardService() {
        this(new LoyaltyDashboardSelector());
    }

    @TestVisible
    private LoyaltyDashboardService(LoyaltyDashboardSelector selector) {
        this.selector = selector;
    }

    public class Kpi {
        @AuraEnabled
        public String key;
        @AuraEnabled
        public Decimal value;
        @AuraEnabled
        public Decimal previousValue;
    }

    public class QueueItem {
        @AuraEnabled
        public String key;
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public String listViewName;
    }

    public class TrendPoint {
        @AuraEnabled
        public Date monthStart;
        @AuraEnabled
        public Decimal awarded;
        @AuraEnabled
        public Decimal redeemed;
    }

    public class CampaignRow {
        @AuraEnabled
        public Id campaignId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer hits;
        @AuraEnabled
        public Integer members;
        @AuraEnabled
        public Decimal points;
    }

    public class AdjustmentRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public Id memberId;
        @AuraEnabled
        public String memberName;
        @AuraEnabled
        public Decimal points;
        @AuraEnabled
        public String category;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public Datetime occurredAt;
        @AuraEnabled
        public String createdBy;
    }

    public class Dashboard {
        @AuraEnabled
        public String period;
        @AuraEnabled
        public Date periodStart;
        @AuraEnabled
        public Date periodEnd;
        @AuraEnabled
        public Integer budgetYear;
        @AuraEnabled
        public List<Kpi> kpis = new List<Kpi>();
        @AuraEnabled
        public List<QueueItem> queue = new List<QueueItem>();
        @AuraEnabled
        public List<TrendPoint> trend = new List<TrendPoint>();
        @AuraEnabled
        public List<CampaignRow> topCampaigns = new List<CampaignRow>();
        @AuraEnabled
        public List<AdjustmentRow> recentAdjustments = new List<AdjustmentRow>();
        @AuraEnabled
        public Datetime generatedAt;
    }

    public Dashboard getDashboard(String period) {
        Date today = Date.valueOf(System.now().format('yyyy-MM-dd', PROGRAM_TIME_ZONE));
        Date[] range = getPeriod(period, today);
        Date[] previousRange = getPreviousPeriod(period, range);
        Datetime fromTime = toProgramStart(range[0]);
        Datetime toTime = toProgramStart(range[1].addDays(1));
        Datetime previousFrom = toProgramStart(previousRange[0]);
        Datetime previousTo = toProgramStart(previousRange[1].addDays(1));

        Dashboard dashboard = new Dashboard();
        dashboard.period = period;
        dashboard.periodStart = range[0];
        dashboard.periodEnd = range[1];
        dashboard.budgetYear = today.year();
        dashboard.generatedAt = System.now();

        Map<String, Decimal> points = selector.sumPointsByEntryType(fromTime, toTime);
        Map<String, Decimal> previousPoints = selector.sumPointsByEntryType(previousFrom, previousTo);
        Decimal awarded = sumAwarded(points);
        Decimal previousAwarded = sumAwarded(previousPoints);
        Decimal redeemed = sumRedeemed(points);
        Decimal previousRedeemed = sumRedeemed(previousPoints);
        AggregateResult issued = selector.sumIssuedVouchers(fromTime, toTime);
        AggregateResult previousIssued = selector.sumIssuedVouchers(previousFrom, previousTo);
        AggregateResult issuedThisYear = selector.sumIssuedVouchers(toProgramStart(Date.newInstance(today.year(), 1, 1)), toProgramStart(Date.newInstance(today.year() + 1, 1, 1)));

        dashboard.kpis.add(kpi('activeMembers', selector.countActiveMembers(), null));
        dashboard.kpis.add(kpi('newMembers', selector.countMembersJoined(fromTime, toTime), selector.countMembersJoined(previousFrom, previousTo)));
        dashboard.kpis.add(kpi('pointsAwarded', awarded, previousAwarded));
        dashboard.kpis.add(kpi('pointsRedeemed', redeemed, previousRedeemed));
        dashboard.kpis.add(kpi('redemptionRate', ratio(redeemed, awarded), ratio(previousRedeemed, previousAwarded)));
        dashboard.kpis.add(kpi('vouchersIssued', (Decimal) issued.get('voucherCount'), (Decimal) previousIssued.get('voucherCount')));
        dashboard.kpis.add(kpi('activeVouchers', selector.countVouchersByStatus('Issued'), null));
        dashboard.kpis.add(kpi('budgetUsed', (Decimal) issuedThisYear.get('totalValue') ?? 0, selector.sumPartnerBudgets(today.year())));

        Map<String, Id> listViewIds = selector.getListViewIds(new Set<String>{ 'Transactions_With_Error', 'Pending_Transactions', 'Voucher_Email_Errors' });
        dashboard.queue.add(queueItem('transactionErrors', selector.countTransactionsByStatus('Error'), 'Loyalty_Transaction__c', 'Transactions_With_Error'));
        dashboard.queue.add(queueItem('pendingTransactions', selector.countTransactionsByStatus('Pending'), 'Loyalty_Transaction__c', 'Pending_Transactions'));
        dashboard.queue.add(queueItem('voucherEmailErrors', selector.countVoucherEmailErrors(), 'Voucher__c', 'Voucher_Email_Errors'));

        Date firstTrendMonth = today.toStartOfMonth().addMonths(1 - TREND_MONTHS);
        for (Integer index = 0; index < TREND_MONTHS; index++) {
            Date monthStart = firstTrendMonth.addMonths(index);
            Map<String, Decimal> monthPoints = selector.sumPointsByEntryType(toProgramStart(monthStart), toProgramStart(monthStart.addMonths(1)));
            TrendPoint trendPoint = new TrendPoint();
            trendPoint.monthStart = monthStart;
            trendPoint.awarded = sumAwarded(monthPoints);
            trendPoint.redeemed = sumRedeemed(monthPoints);
            dashboard.trend.add(trendPoint);
        }

        for (AggregateResult result : selector.getTopCampaigns(fromTime, toTime, TOP_CAMPAIGNS)) {
            CampaignRow row = new CampaignRow();
            row.campaignId = (Id) result.get('campaignId');
            row.name = (String) result.get('campaignName');
            row.hits = (Integer) result.get('hits');
            row.members = (Integer) result.get('members');
            row.points = (Decimal) result.get('points');
            dashboard.topCampaigns.add(row);
        }

        for (Point_Ledger__c entry : selector.getRecentAdjustments(RECENT_ADJUSTMENTS)) {
            AdjustmentRow row = new AdjustmentRow();
            row.id = entry.Id;
            row.memberId = entry.Member__c;
            row.memberName = entry.Member__r?.Name;
            row.points = entry.Points__c;
            row.category = entry.Adjustment_Category__c;
            row.reason = entry.Reason__c;
            row.occurredAt = entry.Occurred_At__c;
            row.createdBy = entry.CreatedBy?.Name;
            dashboard.recentAdjustments.add(row);
        }
        return dashboard;
    }

    private Date[] getPeriod(String period, Date today) {
        if (period == PERIOD_LAST_MONTH) {
            Date start = today.toStartOfMonth().addMonths(-1);
            return new List<Date>{ start, start.addMonths(1).addDays(-1) };
        }
        if (period == PERIOD_LAST_30_DAYS) {
            return new List<Date>{ today.addDays(-29), today };
        }
        if (period == PERIOD_THIS_YEAR) {
            return new List<Date>{ Date.newInstance(today.year(), 1, 1), today };
        }
        return new List<Date>{ today.toStartOfMonth(), today };
    }

    // The previous period has the same length and ends right before the selected one (month-to-date vs. same days of last month).
    private Date[] getPreviousPeriod(String period, Date[] range) {
        if (period == PERIOD_LAST_30_DAYS) {
            return new List<Date>{ range[0].addDays(-30), range[0].addDays(-1) };
        }
        if (period == PERIOD_THIS_YEAR) {
            return new List<Date>{ range[0].addYears(-1), range[1].addYears(-1) };
        }
        return new List<Date>{ range[0].addMonths(-1), range[1].addMonths(-1) };
    }

    private Datetime toProgramStart(Date day) {
        Datetime gmtMidnight = Datetime.newInstanceGmt(day, Time.newInstance(0, 0, 0, 0));
        return gmtMidnight.addSeconds(-programTimeZone.getOffset(gmtMidnight) / 1000);
    }

    private Decimal sumAwarded(Map<String, Decimal> pointsByEntryType) {
        Decimal total = 0;
        for (String entryType : EARNING_TYPES) {
            Decimal points = pointsByEntryType.get(entryType) ?? 0;
            total += points > 0 ? points : 0;
        }
        return total;
    }

    private Decimal sumRedeemed(Map<String, Decimal> pointsByEntryType) {
        return Math.abs(pointsByEntryType.get('Redemption') ?? 0) - (pointsByEntryType.get('Refund') ?? 0);
    }

    private Decimal ratio(Decimal numerator, Decimal denominator) {
        return denominator == null || denominator == 0 ? null : (numerator / denominator * 100).setScale(1, RoundingMode.HALF_UP);
    }

    private Kpi kpi(String key, Decimal value, Decimal previousValue) {
        Kpi item = new Kpi();
        item.key = key;
        item.value = value;
        item.previousValue = previousValue;
        return item;
    }

    private QueueItem queueItem(String key, Integer count, String objectApiName, String listViewName) {
        QueueItem item = new QueueItem();
        item.key = key;
        item.count = count;
        item.objectApiName = objectApiName;
        item.listViewName = listViewName;
        return item;
    }
}
