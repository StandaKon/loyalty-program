/**
 * Aggregated program figures for the back-office home dashboard (B5).
 *
 * Runs without sharing and in system mode on purpose: the dashboard shows program-wide totals, which must not depend
 * on the member records shared with the viewing manager. It returns aggregates only; the single record-level list
 * (recent manual adjustments) shows data that both back-office permission sets can read anyway.
 */
public without sharing class LoyaltyDashboardSelector {
    public Integer countActiveMembers() {
        return [SELECT COUNT() FROM Account WHERE Member_Number__c != NULL AND Membership_Status__c = 'Active' WITH SYSTEM_MODE];
    }

    public Integer countMembersJoined(Datetime fromTime, Datetime toTime) {
        return [SELECT COUNT() FROM Account WHERE Member_Number__c != NULL AND Joined_At__c >= :fromTime AND Joined_At__c < :toTime WITH SYSTEM_MODE];
    }

    public Map<String, Decimal> sumPointsByEntryType(Datetime fromTime, Datetime toTime) {
        Map<String, Decimal> pointsByEntryType = new Map<String, Decimal>();
        for (AggregateResult result : [
            SELECT Entry_Type__c entryType, SUM(Points__c) points
            FROM Point_Ledger__c
            WHERE Occurred_At__c >= :fromTime AND Occurred_At__c < :toTime
            WITH SYSTEM_MODE
            GROUP BY Entry_Type__c
        ]) {
            pointsByEntryType.put((String) result.get('entryType'), (Decimal) result.get('points'));
        }
        return pointsByEntryType;
    }

    public Integer countVouchersByStatus(String status) {
        return [SELECT COUNT() FROM Voucher__c WHERE Status__c = :status WITH SYSTEM_MODE];
    }

    public AggregateResult sumIssuedVouchers(Datetime fromTime, Datetime toTime) {
        return [
            SELECT COUNT(Id) voucherCount, SUM(Value_CZK__c) totalValue
            FROM Voucher__c
            WHERE Issued_At__c >= :fromTime AND Issued_At__c < :toTime AND Status__c != 'Cancelled'
            WITH SYSTEM_MODE
        ];
    }

    public Decimal sumPartnerBudgets(Integer budgetYear) {
        AggregateResult result = [
            SELECT SUM(Voucher_Budget_CZK__c) budget
            FROM Account
            WHERE Voucher_Budget_Year__c = :budgetYear AND IsPersonAccount = FALSE
            WITH SYSTEM_MODE
        ];
        return (Decimal) result.get('budget');
    }

    public Integer countTransactionsByStatus(String status) {
        return [SELECT COUNT() FROM Loyalty_Transaction__c WHERE Processing_Status__c = :status WITH SYSTEM_MODE];
    }

    public Integer countVoucherEmailErrors() {
        return [SELECT COUNT() FROM Voucher__c WHERE Email_Status__c = 'Error' WITH SYSTEM_MODE];
    }

    public List<AggregateResult> getTopCampaigns(Datetime fromTime, Datetime toTime, Integer maxRows) {
        return [
            SELECT Campaign__c campaignId, Campaign__r.Name campaignName, COUNT(Id) hits, COUNT_DISTINCT(Member__c) members, SUM(Points__c) points
            FROM Point_Ledger__c
            WHERE Entry_Type__c = 'CampaignBonus' AND Occurred_At__c >= :fromTime AND Occurred_At__c < :toTime
            WITH SYSTEM_MODE
            GROUP BY Campaign__c, Campaign__r.Name
            ORDER BY SUM(Points__c) DESC
            LIMIT :maxRows
        ];
    }

    public List<Point_Ledger__c> getRecentAdjustments(Integer maxRows) {
        return [
            SELECT Id, Name, Member__c, Member__r.Name, Points__c, toLabel(Adjustment_Category__c), Reason__c, Occurred_At__c, CreatedBy.Name
            FROM Point_Ledger__c
            WHERE Entry_Type__c = 'Adjustment'
            WITH SYSTEM_MODE
            ORDER BY Occurred_At__c DESC
            LIMIT :maxRows
        ];
    }

    public Map<String, Id> getListViewIds(Set<String> developerNames) {
        Map<String, Id> listViewIdsByName = new Map<String, Id>();
        for (ListView listView : [SELECT Id, DeveloperName FROM ListView WHERE DeveloperName IN :developerNames WITH SYSTEM_MODE]) {
            listViewIdsByName.put(listView.DeveloperName, listView.Id);
        }
        return listViewIdsByName;
    }
}
