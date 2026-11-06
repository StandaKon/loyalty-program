@IsTest
public class LoyaltyTestDataFactory {
    public static final Datetime DEFAULT_PURCHASED_AT = Datetime.newInstanceGmt(2026, 6, 15, 10, 0, 0);
    public static final Date CAMPAIGN_START = Date.newInstance(2026, 1, 1);
    public static final Date CAMPAIGN_END = Date.newInstance(2026, 12, 31);
    public static final Decimal FUEL_PRICE_PER_LITER = 38;

    public static Account createMember(String membershipStatus) {
        return createMembers(1, membershipStatus)[0];
    }

    public static List<Account> createMembers(Integer count, String membershipStatus) {
        Id personAccountRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = TRUE AND IsActive = TRUE LIMIT 1].Id;
        List<Account> members = new List<Account>();
        for (Integer index = 0; index < count; index++) {
            members.add(
                new Account(
                    RecordTypeId = personAccountRecordTypeId,
                    FirstName = 'Test',
                    LastName = 'Member ' + index,
                    PersonEmail = 'member' + index + '@example.com',
                    Member_Number__c = 'TEST-MEMBER-' + index,
                    Membership_Status__c = membershipStatus,
                    Joined_At__c = Datetime.now()
                )
            );
        }
        insert members;
        return members;
    }

    public static Loyalty_Campaign__c buildCampaign(String name, String conditionField, Decimal threshold, String rewardType, Decimal rewardValue) {
        return new Loyalty_Campaign__c(
            Name = name,
            Is_Enabled__c = true,
            Start_Date__c = CAMPAIGN_START,
            End_Date__c = CAMPAIGN_END,
            Condition_Field__c = conditionField,
            Threshold__c = threshold,
            Reward_Type__c = rewardType,
            Reward_Value__c = rewardValue
        );
    }

    public static List<Loyalty_Campaign__c> buildReferenceCampaigns() {
        return new List<Loyalty_Campaign__c>{
            buildCampaign('Natankuj plnou', PointsCalculator.CONDITION_LITERS, 40, PointsCalculator.REWARD_FIXED_BONUS, 50),
            buildCampaign('Zastávka na cestě', PointsCalculator.CONDITION_OTHER_AMOUNT, 150, PointsCalculator.REWARD_BASE_MULTIPLIER, 1.1)
        };
    }

    public static Loyalty_Transaction__c buildTransaction(Id memberId, String posTransactionId, Decimal liters, Decimal otherAmount) {
        Decimal fuelAmount = liters * FUEL_PRICE_PER_LITER;
        return new Loyalty_Transaction__c(
            Member__c = memberId,
            POS_Transaction_Id__c = posTransactionId,
            Purchased_At__c = DEFAULT_PURCHASED_AT,
            Liters__c = liters,
            Fuel_Amount__c = fuelAmount,
            Other_Amount__c = otherAmount,
            Total_Amount__c = fuelAmount + otherAmount
        );
    }
}
