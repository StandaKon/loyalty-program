/**
 * Membership tiers Road (Okreska) and Highway (Dálnice) – B11, BR-60.
 * Qualifying points = PurchaseBase + CampaignBonus of the rolling period, minus reversals; activity bonuses,
 * adjustments and tier bonuses do not count. Upgrade right after the threshold is reached, monthly evaluation
 * may upgrade or downgrade. The points balance never changes with the tier.
 */
public inherited sharing class LoyaltyTierService {
    public static final String TIER_ROAD = 'Road';
    public static final String TIER_HIGHWAY = 'Highway';

    private final LoyaltyMemberSelector memberSelector;
    private final LoyaltyLedgerAnalysisSelector ledgerSelector;
    private final LoyaltySettingsSelector settingsSelector;

    public LoyaltyTierService() {
        this(new LoyaltyMemberSelector(), new LoyaltyLedgerAnalysisSelector(), new LoyaltySettingsSelector());
    }

    @TestVisible
    private LoyaltyTierService(LoyaltyMemberSelector memberSelector, LoyaltyLedgerAnalysisSelector ledgerSelector, LoyaltySettingsSelector settingsSelector) {
        this.memberSelector = memberSelector;
        this.ledgerSelector = ledgerSelector;
        this.settingsSelector = settingsSelector;
    }

    /**
     * Async so that a bulk import keeps one tier for all purchases of the same import (B2 bulk behaviour).
     */
    public static void enqueueUpgrade(Set<Id> memberIds) {
        if (memberIds.isEmpty() || Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }
        System.enqueueJob(new LoyaltyTierUpgradeQueueable(memberIds));
    }

    public Map<Id, Integer> getQualifyingPoints(Set<Id> memberIds) {
        Map<Id, Decimal> pointsByMemberId = ledgerSelector.getQualifyingPointsByMemberIds(memberIds, getPeriodStart());
        Map<Id, Integer> qualifyingByMemberId = new Map<Id, Integer>();
        for (Id memberId : memberIds) {
            qualifyingByMemberId.put(memberId, Math.max(0, (pointsByMemberId.get(memberId) ?? 0).intValue()));
        }
        return qualifyingByMemberId;
    }

    public Integer getThreshold() {
        Decimal threshold = settingsSelector.getDefault()?.Tier_Highway_Threshold__c;
        if (threshold == null || threshold <= 0) {
            throw new LoyaltyActionException('Loyalty_Settings__mdt Default has no positive Tier_Highway_Threshold__c');
        }
        return threshold.intValue();
    }

    public Integer getFuelBonusPercent() {
        Decimal multiplier = settingsSelector.getDefault()?.Tier_Highway_Fuel_Multiplier__c ?? 1;
        return ((multiplier - 1) * 100).round(System.RoundingMode.HALF_UP).intValue();
    }

    // Monthly evaluation happens on the first day of each month (scheduled LoyaltyTierEvaluationBatch).
    public static Date getNextEvaluationDate(Date today) {
        return today.toStartOfMonth().addMonths(1);
    }

    public void upgradeQualified(Set<Id> memberIds) {
        applyTiers(memberIds, false);
    }

    public void evaluate(Set<Id> memberIds) {
        applyTiers(memberIds, true);
    }

    private void applyTiers(Set<Id> memberIds, Boolean canDowngrade) {
        Integer threshold = getThreshold();
        List<Account> members = memberSelector.getByIdsForUpdate(memberIds);
        Map<Id, Integer> qualifyingByMemberId = getQualifyingPoints(memberIds);

        List<Account> changedMembers = new List<Account>();
        for (Account member : members) {
            Boolean isQualified = qualifyingByMemberId.get(member.Id) >= threshold;
            String currentTier = member.Loyalty_Tier__c ?? TIER_ROAD;
            String newTier = isQualified ? TIER_HIGHWAY : (canDowngrade ? TIER_ROAD : currentTier);
            if (newTier != member.Loyalty_Tier__c) {
                changedMembers.add(new Account(Id = member.Id, Loyalty_Tier__c = newTier));
            }
        }
        if (changedMembers.isEmpty()) {
            return;
        }
        for (Database.SaveResult result : Database.update(changedMembers, false, AccessLevel.SYSTEM_MODE)) {
            if (!result.isSuccess()) {
                System.debug(LoggingLevel.ERROR, 'Tier update failed for ' + result.getId() + ': ' + result.getErrors()[0].getMessage());
            }
        }
    }

    public Integer getQualificationMonths() {
        Decimal months = settingsSelector.getDefault()?.Tier_Qualification_Months__c;
        if (months == null || months <= 0) {
            throw new LoyaltyActionException('Loyalty_Settings__mdt Default has no positive Tier_Qualification_Months__c');
        }
        return months.intValue();
    }

    private Datetime getPeriodStart() {
        return Datetime.now().addMonths(-getQualificationMonths());
    }
}
