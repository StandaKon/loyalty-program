public inherited sharing class PointLedgerSelector {
    // System mode: back-office services check idempotency keys and source entries regardless of the caller's FLS.
    public Point_Ledger__c getByUniqueKey(String uniqueKey) {
        List<Point_Ledger__c> entries = [
            SELECT Id, Member__c, Points__c, Entry_Type__c, Voucher__c, Unique_Key__c
            FROM Point_Ledger__c
            WHERE Unique_Key__c = :uniqueKey
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return entries.isEmpty() ? null : entries[0];
    }

    public Point_Ledger__c getRedemptionByVoucherId(Id voucherId) {
        List<Point_Ledger__c> entries = [
            SELECT Id, Member__c, Points__c, Entry_Type__c, Voucher__c, Unique_Key__c
            FROM Point_Ledger__c
            WHERE Voucher__c = :voucherId AND Entry_Type__c = 'Redemption'
            WITH SYSTEM_MODE
            ORDER BY CreatedDate
            LIMIT 1
        ];
        return entries.isEmpty() ? null : entries[0];
    }

    public Set<Id> getCampaignIdsWithEntries(Set<Id> campaignIds) {
        Set<Id> usedCampaignIds = new Set<Id>();
        for (AggregateResult result : [
            SELECT Campaign__c campaignId
            FROM Point_Ledger__c
            WHERE Campaign__c IN :campaignIds
            WITH SYSTEM_MODE
            GROUP BY Campaign__c
        ]) {
            usedCampaignIds.add((Id) result.get('campaignId'));
        }
        return usedCampaignIds;
    }
}
