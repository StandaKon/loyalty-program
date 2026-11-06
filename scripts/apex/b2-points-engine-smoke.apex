// B2 smoke test: acceptance example (45 l + 180 CZK = 109 points) against the real org.
// Creates a demo member and the two reference campaigns if missing, imports one purchase, prints the result
// and then ROLLS BACK everything – no data is left in the org.
// Run: sf apex run --file scripts/apex/b2-points-engine-smoke.apex

Savepoint beforeSmokeTest = Database.setSavepoint();
try {
String demoMemberNumber = 'ENE-DEMO-B2';
List<Account> members = [SELECT Id FROM Account WHERE Member_Number__c = :demoMemberNumber LIMIT 1];
Account member;
if (members.isEmpty()) {
    member = new Account(
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
        FirstName = 'Demo',
        LastName = 'B2 Member',
        PersonEmail = 'demo.b2@example.com',
        Member_Number__c = demoMemberNumber,
        Membership_Status__c = 'Active',
        Joined_At__c = Datetime.now()
    );
    insert member;
} else {
    member = members[0];
}

Date yearStart = Date.newInstance(Date.today().year(), 1, 1);
Date yearEnd = Date.newInstance(Date.today().year(), 12, 31);
Set<String> existingCampaigns = new Set<String>();
for (Loyalty_Campaign__c campaign : [SELECT Name FROM Loyalty_Campaign__c WHERE Name IN ('Natankuj plnou', 'Zastávka na cestě')]) {
    existingCampaigns.add(campaign.Name);
}
List<Loyalty_Campaign__c> campaigns = new List<Loyalty_Campaign__c>();
if (!existingCampaigns.contains('Natankuj plnou')) {
    campaigns.add(new Loyalty_Campaign__c(Name = 'Natankuj plnou', Is_Enabled__c = true, Start_Date__c = yearStart, End_Date__c = yearEnd,
        Condition_Field__c = 'Liters', Threshold__c = 40, Reward_Type__c = 'FixedBonus', Reward_Value__c = 50));
}
if (!existingCampaigns.contains('Zastávka na cestě')) {
    campaigns.add(new Loyalty_Campaign__c(Name = 'Zastávka na cestě', Is_Enabled__c = true, Start_Date__c = yearStart, End_Date__c = yearEnd,
        Condition_Field__c = 'OtherAmount', Threshold__c = 150, Reward_Type__c = 'BaseMultiplier', Reward_Value__c = 1.1));
}
insert campaigns;

Loyalty_Transaction__c purchase = new Loyalty_Transaction__c(
    Member__c = member.Id,
    POS_Transaction_Id__c = 'SMOKE-' + Datetime.now().getTime(),
    Purchased_At__c = Datetime.now().addMinutes(-5),
    Liters__c = 45,
    Fuel_Amount__c = 1710,
    Other_Amount__c = 180,
    Total_Amount__c = 1890
);
insert purchase;

purchase = [SELECT Name, Processing_Status__c, Base_Fuel_Points__c, Base_Other_Points__c, Campaign_Points__c, Total_Points__c FROM Loyalty_Transaction__c WHERE Id = :purchase.Id];
System.debug(LoggingLevel.ERROR, 'B2 transaction ' + purchase.Name + ': ' + purchase.Processing_Status__c + ', total points ' + purchase.Total_Points__c + ' (expected 109)');
for (Point_Ledger__c entry : [SELECT Entry_Type__c, Points__c, Campaign__r.Name FROM Point_Ledger__c WHERE Transaction__c = :purchase.Id ORDER BY Points__c DESC]) {
    System.debug(LoggingLevel.ERROR, 'B2 ledger: ' + entry.Entry_Type__c + ' ' + entry.Points__c + ' ' + (entry.Campaign__r?.Name ?? ''));
}
System.debug(LoggingLevel.ERROR, 'B2 member balance: ' + [SELECT Points_Balance__c FROM Account WHERE Id = :member.Id].Points_Balance__c);
} finally {
    Database.rollback(beforeSmokeTest);
    System.debug(LoggingLevel.ERROR, 'B2 smoke test rolled back, no data kept.');
}
