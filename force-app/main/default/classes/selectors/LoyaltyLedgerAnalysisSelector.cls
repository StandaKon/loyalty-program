/**
 * Ledger reads of the optional B11 features (tiers, points expiry, purchase reversal).
 * System mode: server processes evaluate any member; the portal passes only the member resolved from UserInfo.
 */
public inherited sharing class LoyaltyLedgerAnalysisSelector {
    private static final Set<String> QUALIFYING_ENTRY_TYPES = new Set<String>{ 'PurchaseBase', 'CampaignBonus' };
    private static final String ENTRY_TYPE_REVERSAL = 'Reversal';

    /**
     * Purchase points of the rolling period. A reversal counts in the period of its original purchase.
     */
    public Map<Id, Decimal> getQualifyingPointsByMemberIds(Set<Id> memberIds, Datetime fromMoment) {
        Map<Id, Decimal> pointsByMemberId = new Map<Id, Decimal>();
        for (AggregateResult result : [
            SELECT Member__c memberId, SUM(Points__c) points
            FROM Point_Ledger__c
            WHERE
                Member__c IN :memberIds
                AND ((Entry_Type__c IN :QUALIFYING_ENTRY_TYPES AND Occurred_At__c >= :fromMoment)
                OR (Entry_Type__c = :ENTRY_TYPE_REVERSAL AND Transaction__r.Purchased_At__c >= :fromMoment))
            WITH SYSTEM_MODE
            GROUP BY Member__c
        ]) {
            pointsByMemberId.put((Id) result.get('memberId'), (Decimal) result.get('points'));
        }
        return pointsByMemberId;
    }

    public List<Point_Ledger__c> getEntriesByMemberIds(Set<Id> memberIds) {
        return [
            SELECT Id, Member__c, Points__c, Occurred_At__c
            FROM Point_Ledger__c
            WHERE Member__c IN :memberIds
            WITH SYSTEM_MODE
            ORDER BY Occurred_At__c ASC
        ];
    }

    public List<Point_Ledger__c> getEntriesByTransactionId(Id transactionId) {
        return [
            SELECT Id, Member__c, Points__c, Entry_Type__c, Unique_Key__c
            FROM Point_Ledger__c
            WHERE Transaction__c = :transactionId
            WITH SYSTEM_MODE
        ];
    }
}
