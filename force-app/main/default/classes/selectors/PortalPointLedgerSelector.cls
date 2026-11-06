/**
 * Encapsulates all SOQL for Point_Ledger__c records.
 */
public inherited sharing class PortalPointLedgerSelector {
    public List<Point_Ledger__c> selectByMemberId(Id memberId, Integer limitSize, Integer offsetSize) {
        if (memberId == null || limitSize == null || limitSize <= 0) {
            return new List<Point_Ledger__c>();
        }
        Integer safeOffset = offsetSize == null || offsetSize < 0 ? 0 : offsetSize;
        return [
            SELECT Id, Occurred_At__c, Entry_Type__c, Points__c, Campaign__r.Name
            FROM Point_Ledger__c
            WHERE Member__c = :memberId
            WITH USER_MODE
            ORDER BY Occurred_At__c DESC, CreatedDate DESC, Id DESC
            LIMIT :limitSize
            OFFSET :safeOffset
        ];
    }

    public Integer countByMemberId(Id memberId) {
        if (memberId == null) {
            return 0;
        }
        return [
            SELECT COUNT()
            FROM Point_Ledger__c
            WHERE Member__c = :memberId
            WITH USER_MODE
        ];
    }
}
