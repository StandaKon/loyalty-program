public inherited sharing class VoucherSelector {
    // System mode: field access is decided by the calling controller/service; record sharing follows the caller's class.
    public Voucher__c getById(Id voucherId) {
        List<Voucher__c> vouchers = [
            SELECT Id, Name, Code__c, Status__c, Member__c, Member__r.Name, Reward_Name__c, Points_Spent__c, Issued_At__c
            FROM Voucher__c
            WHERE Id = :voucherId
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        return vouchers.isEmpty() ? null : vouchers[0];
    }

    public Voucher__c getByIdForUpdate(Id voucherId) {
        List<Voucher__c> vouchers = [
            SELECT Id, Name, Code__c, Status__c, Member__c, Points_Spent__c
            FROM Voucher__c
            WHERE Id = :voucherId
            WITH SYSTEM_MODE
            LIMIT 1
            FOR UPDATE
        ];
        return vouchers.isEmpty() ? null : vouchers[0];
    }
}
