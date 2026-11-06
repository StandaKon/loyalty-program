// B5 smoke test: back-office actions (manual adjustment, purchase simulation, campaign lock, voucher cancellation)
// against the real org: happy paths through the LWC controllers, rejections through the services
// (AuraHandledException cannot be thrown outside an Aura context). Run as a user with permission set Loyalty_Manager.
// Uses an existing active member and creates its own partner, reward, campaign and voucher and then ROLLS BACK everything – no data is left in the org.
// Run: sf apex run --file scripts/apex/b5-back-office-smoke.apex

List<String> results = new List<String>();
Savepoint beforeSmokeTest = Database.setSavepoint();
try {
    // Uses an existing active member: creating Person Accounts needs the record type in the running user's profile.
    Account member = [
        SELECT Id, Points_Balance__c
        FROM Account
        WHERE Member_Number__c != NULL AND Membership_Status__c = 'Active' AND IsPersonAccount = TRUE
        ORDER BY CreatedDate
        LIMIT 1
    ];
    Decimal startBalance = member.Points_Balance__c ?? 0;

    // A) Manual adjustment
    String requestKey = UUID.randomUUID().toString();
    Decimal balance = PointAdjustmentController.adjustPoints(member.Id, 100, 'Goodwill', 'Smoke test add', requestKey);
    results.add((balance == startBalance + 100 ? 'PASS' : 'FAIL') + ' A1 +100 points -> balance ' + balance);
    Decimal replayBalance = PointAdjustmentController.adjustPoints(member.Id, 100, 'Goodwill', 'Smoke test add', requestKey);
    Integer adjustmentCount = [SELECT COUNT() FROM Point_Ledger__c WHERE Unique_Key__c = :('ADJ:' + requestKey)];
    results.add((replayBalance == startBalance + 100 && adjustmentCount == 1 ? 'PASS' : 'FAIL') + ' A2 replay of the same request -> balance ' + replayBalance + ', entries ' + adjustmentCount);
    for (List<Object> invalidCase : new List<List<Object>>{
        new List<Object>{ 'A3 deduct above balance', -(startBalance.intValue() + 101), 'Complaint', 'Too much' },
        new List<Object>{ 'A4 zero points', 0, 'Complaint', 'Zero' },
        new List<Object>{ 'A5 invalid category', 10, 'Unknown', 'Bad category' },
        new List<Object>{ 'A6 missing comment', 10, 'Other', ' ' }
    }) {
        try {
            new PointAdjustmentService().adjust(member.Id, (Integer) invalidCase[1], (String) invalidCase[2], (String) invalidCase[3], UUID.randomUUID().toString());
            results.add('FAIL ' + invalidCase[0] + ' was accepted');
        } catch (LoyaltyActionException expected) {
            results.add('PASS ' + invalidCase[0] + ' rejected: ' + expected.getMessage());
        }
    }
    balance = PointAdjustmentController.adjustPoints(member.Id, -40, 'ImportError', 'Smoke test deduct', UUID.randomUUID().toString());
    results.add((balance == startBalance + 60 ? 'PASS' : 'FAIL') + ' A7 -40 points -> balance ' + balance);

    // B) Purchase simulation + C) campaign lock
    Loyalty_Campaign__c campaign = new Loyalty_Campaign__c(
        Name = 'B5 Smoke Campaign',
        Is_Enabled__c = true,
        Start_Date__c = Date.today().addDays(-1),
        End_Date__c = Date.today().addDays(1),
        Condition_Field__c = 'Liters',
        Threshold__c = 40,
        Reward_Type__c = 'FixedBonus',
        Reward_Value__c = 5
    );
    insert campaign;
    PurchaseSimulationController.SimulationResult simulation = PurchaseSimulationController.simulatePurchase(member.Id, 45, 1710, 180, Datetime.now().addMinutes(-1));
    results.add(
        (simulation.isProcessed && simulation.baseFuelPoints == 45 && simulation.baseOtherPoints == 9 && simulation.campaignPoints >= 5 ? 'PASS' : 'FAIL') +
        ' B1 simulate 45 l / 1710 + 180 CZK -> ' + simulation.transactionName + ' base ' + simulation.baseFuelPoints + '+' + simulation.baseOtherPoints +
        ', campaigns ' + simulation.campaignPoints + ', total ' + simulation.totalPoints + ', balance ' + simulation.newBalance
    );
    try {
        new PurchaseSimulationService().simulate(member.Id, 10, 0, 50, Datetime.now());
        results.add('FAIL B2 litres without fuel amount was accepted');
    } catch (LoyaltyActionException expected) {
        results.add('PASS B2 litres without fuel amount rejected: ' + expected.getMessage());
    }
    try {
        campaign.Threshold__c = 30;
        update campaign;
        results.add('FAIL C1 threshold change of a used campaign was accepted');
    } catch (DmlException expected) {
        results.add('PASS C1 threshold change of a used campaign rejected: ' + expected.getDmlMessage(0));
    }
    update new Loyalty_Campaign__c(Id = campaign.Id, Name = 'B5 Smoke Campaign renamed');
    results.add('PASS C2 rename of a used campaign accepted');

    // D) Voucher cancellation with refund
    Account partner = new Account(Name = 'B5 Smoke Partner', Type = 'Partner');
    insert partner;
    Reward__c reward = new Reward__c(Name = 'B5 Smoke Reward', Partner__c = partner.Id, Points_Cost__c = 50, Value_CZK__c = 200, Is_Active__c = true, Description__c = 'Smoke test reward');
    insert reward;
    Voucher__c voucher = new Voucher__c(
        Member__c = member.Id,
        Reward__c = reward.Id,
        Partner__c = partner.Id,
        Code__c = 'ENE-SMKT-2345',
        Request_Key__c = member.Id + ':' + UUID.randomUUID().toString(),
        Status__c = 'Issued',
        Points_Spent__c = 50,
        Value_CZK__c = 200,
        Reward_Name__c = reward.Name,
        Reward_Description__c = reward.Description__c,
        Issued_At__c = Datetime.now(),
        Email_Status__c = 'Pending'
    );
    insert voucher;
    insert new Point_Ledger__c(Member__c = member.Id, Points__c = -50, Entry_Type__c = 'Redemption', Voucher__c = voucher.Id, Occurred_At__c = Datetime.now(), Unique_Key__c = 'VCH:' + voucher.Id + ':REDEEM');
    Decimal balanceBeforeCancel = [SELECT Points_Balance__c FROM Account WHERE Id = :member.Id].Points_Balance__c;
    Decimal refunded = VoucherCancellationController.cancelVoucher(voucher.Id, 'MemberRequest', null);
    Voucher__c cancelled = [SELECT Status__c, Cancellation_Category__c, Cancellation_Reason__c, Cancelled_At__c FROM Voucher__c WHERE Id = :voucher.Id];
    Decimal balanceAfterCancel = [SELECT Points_Balance__c FROM Account WHERE Id = :member.Id].Points_Balance__c;
    results.add(
        (refunded == 50 && cancelled.Status__c == 'Cancelled' && balanceAfterCancel == balanceBeforeCancel + 50 ? 'PASS' : 'FAIL') +
        ' D1 cancel voucher -> refunded ' + refunded + ', status ' + cancelled.Status__c + ', reason "' + cancelled.Cancellation_Reason__c + '", balance ' + balanceBeforeCancel + ' -> ' + balanceAfterCancel
    );
    try {
        new VoucherCancellationService().cancel(voucher.Id, 'MemberRequest', 'Second attempt');
        results.add('FAIL D2 second cancellation was accepted');
    } catch (LoyaltyActionException expected) {
        results.add('PASS D2 second cancellation rejected: ' + expected.getMessage());
    }

    // E) Inactive member cannot simulate a purchase
    update new Account(Id = member.Id, Membership_Status__c = 'Blocked');
    try {
        new PurchaseSimulationService().simulate(member.Id, 10, 400, 0, Datetime.now());
        results.add('FAIL E1 purchase of a blocked member was accepted');
    } catch (LoyaltyActionException expected) {
        results.add('PASS E1 purchase of a blocked member rejected: ' + expected.getMessage());
    }
} catch (Exception unexpected) {
    results.add('FAIL unexpected ' + unexpected.getTypeName() + ': ' + unexpected.getMessage() + ' ' + unexpected.getStackTraceString());
} finally {
    Database.rollback(beforeSmokeTest);
}
System.debug(LoggingLevel.ERROR, 'B5 SMOKE\n' + String.join(results, '\n'));
