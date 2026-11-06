@IsTest
public with sharing class TestDataFactory {
    public static Account member(String suffix) {
        Id personType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
            AND IsPersonType = true WITH SYSTEM_MODE LIMIT 1].Id;
        return new Account(RecordTypeId = personType, LastName = 'B1 ' + suffix,
            PersonEmail = 'b1-' + suffix + '@example.com',
            Member_Number__c = 'TEST-' + suffix, Membership_Status__c = 'Active',
            Joined_At__c = System.now());
    }

    public static Loyalty_Transaction__c purchase(Id memberId, String key) {
        return new Loyalty_Transaction__c(Member__c = memberId,
            POS_Transaction_Id__c = key, Purchased_At__c = System.now().addMinutes(-1),
            Total_Amount__c = 1890, Fuel_Amount__c = 1710, Other_Amount__c = 180,
            Liters__c = 45, Processing_Status__c = 'Pending');
    }

    public static Point_Ledger__c adjustment(Id memberId, Decimal points, String key) {
        return new Point_Ledger__c(Member__c = memberId, Points__c = points,
            Entry_Type__c = 'Adjustment', Unique_Key__c = key,
            Occurred_At__c = System.now(), Reason__c = 'B1 metadata verification');
    }

    public static Loyalty_Campaign__c campaign(String name) {
        return new Loyalty_Campaign__c(Name = name, Is_Enabled__c = true,
            Start_Date__c = Date.today().addDays(-1), End_Date__c = Date.today().addDays(1),
            Condition_Field__c = 'Liters', Threshold__c = 40,
            Reward_Type__c = 'FixedBonus', Reward_Value__c = 50);
    }

    public static Reward__c reward(Id partnerId) {
        return new Reward__c(Name = 'Tyre change discount', Partner__c = partnerId,
            Points_Cost__c = 500, Value_CZK__c = 200, Is_Active__c = true,
            Description__c = 'Discount issued by the test partner.');
    }

    public static Voucher__c voucher(Id memberId, Reward__c reward) {
        return new Voucher__c(Member__c = memberId, Reward__c = reward.Id,
            Partner__c = reward.Partner__c, Code__c = 'ENE-ABCD-2345',
            Request_Key__c = memberId + ':test-request', Points_Spent__c = reward.Points_Cost__c,
            Value_CZK__c = reward.Value_CZK__c, Reward_Name__c = reward.Name,
            Reward_Description__c = reward.Description__c, Issued_At__c = System.now());
    }
}
