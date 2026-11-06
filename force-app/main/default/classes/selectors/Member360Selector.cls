/**
 * Data of one member for the back-office member 360 view (B5).
 * Inherits sharing from the caller: the member must be visible to the viewing user; ledger entries follow the member
 * (Controlled by Parent). Consents are read in user mode because only some back-office permission sets may read them.
 */
public inherited sharing class Member360Selector {
    public Account getMember(Id memberId) {
        List<Account> members = [
            SELECT
                Id,
                Name,
                Member_Number__c,
                Points_Balance__c,
                Vehicle_Make__c,
                Vehicle_Model__c,
                toLabel(Vehicle_Fuel_Type__c),
                Vehicle_Year__c,
                Vehicle_Registration__c,
                Profile_Complete__c,
                Marketing_Consent__c
            FROM Account
            WHERE Id = :memberId
            WITH USER_MODE
            LIMIT 1
        ];
        return members.isEmpty() ? null : members[0];
    }

    public Map<String, Decimal> sumPointsByEntryType(Id memberId) {
        Map<String, Decimal> pointsByEntryType = new Map<String, Decimal>();
        for (AggregateResult result : [
            SELECT Entry_Type__c entryType, SUM(Points__c) points
            FROM Point_Ledger__c
            WHERE Member__c = :memberId
            WITH SYSTEM_MODE
            GROUP BY Entry_Type__c
        ]) {
            pointsByEntryType.put((String) result.get('entryType'), (Decimal) result.get('points'));
        }
        return pointsByEntryType;
    }

    public AggregateResult summarizePurchases(Id memberId) {
        return [
            SELECT COUNT(Id) purchaseCount, SUM(Total_Amount__c) totalSpend, MAX(Purchased_At__c) lastPurchase
            FROM Loyalty_Transaction__c
            WHERE Member__c = :memberId AND Processing_Status__c = 'Processed'
            WITH SYSTEM_MODE
        ];
    }

    public Integer countActiveVouchers(Id memberId) {
        return [SELECT COUNT() FROM Voucher__c WHERE Member__c = :memberId AND Status__c = 'Issued' WITH SYSTEM_MODE];
    }

    public List<Point_Ledger__c> getEntriesSince(Id memberId, Datetime fromTime) {
        return [
            SELECT Entry_Type__c, Points__c, Occurred_At__c
            FROM Point_Ledger__c
            WHERE Member__c = :memberId AND Occurred_At__c >= :fromTime
            WITH SYSTEM_MODE
        ];
    }

    public List<Point_Ledger__c> getRecentEntries(Id memberId, Integer maxRows) {
        return [
            SELECT
                Id,
                Entry_Type__c,
                Points__c,
                Occurred_At__c,
                Reason__c,
                Transaction__c,
                Transaction__r.Name,
                Campaign__r.Name,
                Voucher__c,
                Voucher__r.Name,
                Voucher__r.Reward_Name__c
            FROM Point_Ledger__c
            WHERE Member__c = :memberId
            WITH SYSTEM_MODE
            ORDER BY Occurred_At__c DESC, CreatedDate DESC
            LIMIT :maxRows
        ];
    }

    public List<AuthorizationFormConsent> getConsents(Id memberId) {
        return [
            SELECT
                Id,
                toLabel(Consent_Action__c),
                Status,
                ConsentCapturedDateTime,
                AuthorizationFormText.AuthorizationForm.Name,
                AuthorizationFormText.AuthorizationForm.RevisionNumber,
                AuthorizationFormText.AuthorizationForm.Consent_Type__c
            FROM AuthorizationFormConsent
            WHERE ConsentGiverId = :memberId
            WITH USER_MODE
            ORDER BY ConsentCapturedDateTime DESC
            LIMIT 50
        ];
    }
}
