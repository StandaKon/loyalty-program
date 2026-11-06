@IsTest
private class RewardRedemptionServiceTest {
  private static final String REQUEST_KEY = '00000000-0000-4000-8000-000000000001';

  @TestSetup
  static void setupData() {
    Account member = TestDataFactory.member('b8-member');
    Account poorMember = TestDataFactory.member('b8-poor');
    Account partner = new Account(Name = 'B8 EneServis', Type = 'Partner');
    Database.insert(
      new List<Account>{ member, poorMember, partner },
      true,
      AccessLevel.SYSTEM_MODE
    );
    Reward__c reward = TestDataFactory.reward(partner.Id);
    reward.Name = 'B8 tyre discount';
    Database.insert(reward, AccessLevel.SYSTEM_MODE);
    Database.insert(
      TestDataFactory.adjustment(member.Id, 740, 'B8-FUNDING'),
      AccessLevel.SYSTEM_MODE
    );
  }

  @IsTest
  static void shouldCreateOneVoucherAndLedgerEntry_WhenBalanceIsSufficient() {
    Account member = getMember('TEST-b8-member');
    Reward__c reward = getReward();

    Test.startTest();
    Voucher__c voucher = new RewardRedemptionService()
      .redeem(member.Id, reward.Id, REQUEST_KEY);
    Test.stopTest();

    List<Point_Ledger__c> entries = [
      SELECT Points__c, Entry_Type__c, Voucher__c
      FROM Point_Ledger__c
      WHERE Voucher__c = :voucher.Id
      WITH SYSTEM_MODE
    ];
    Voucher__c stored = [
      SELECT
        Code__c,
        Points_Spent__c,
        Value_CZK__c,
        Reward_Name__c,
        Email_Status__c
      FROM Voucher__c
      WHERE Id = :voucher.Id
      WITH SYSTEM_MODE
    ];
    Assert.areEqual(
      1,
      entries.size(),
      'One redemption ledger entry should be created.'
    );
    Assert.areEqual(
      -500,
      entries[0].Points__c,
      'The reward price should be deducted once.'
    );
    Assert.areEqual(
      'Redemption',
      entries[0].Entry_Type__c,
      'The ledger entry should be a redemption.'
    );
    Assert.isTrue(
      Pattern.matches(
        'ENE-[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{4}-[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{4}',
        stored.Code__c
      ),
      'The code should use the approved format.'
    );
    Assert.areEqual(
      reward.Value_CZK__c,
      stored.Value_CZK__c,
      'The voucher should retain the issue-time CZK value.'
    );
    Assert.areEqual(
      240,
      getMember('TEST-b8-member').Points_Balance__c,
      'The balance should be reduced immediately.'
    );
  }

  @IsTest
  static void shouldReturnExistingVoucher_WhenRequestIsRepeated() {
    Account member = getMember('TEST-b8-member');
    Reward__c reward = getReward();

    Test.startTest();
    Voucher__c first = new RewardRedemptionService()
      .redeem(member.Id, reward.Id, REQUEST_KEY);
    Voucher__c repeated = new RewardRedemptionService()
      .redeem(member.Id, reward.Id, REQUEST_KEY);
    Test.stopTest();

    Assert.areEqual(
      first.Id,
      repeated.Id,
      'A repeated request key should return the original voucher.'
    );
    Assert.areEqual(
      1,
      [
        SELECT COUNT()
        FROM Voucher__c
        WHERE Request_Key__c = :REQUEST_KEY
        WITH SYSTEM_MODE
      ],
      'Only one voucher should exist for the request.'
    );
    Assert.areEqual(
      240,
      getMember('TEST-b8-member').Points_Balance__c,
      'Points should be deducted only once.'
    );
  }

  @IsTest
  static void shouldRejectRedemption_WhenBalanceIsInsufficient() {
    Account member = getMember('TEST-b8-poor');
    Reward__c reward = getReward();

    Test.startTest();
    try {
      new RewardRedemptionService().redeem(member.Id, reward.Id, REQUEST_KEY);
      Assert.fail('Expected insufficient balance to reject the redemption.');
    } catch (LoyaltyActionException expectedException) {
      Assert.isTrue(
        expectedException.getMessage().contains('500'),
        'The error should include the missing points.'
      );
    }
    Test.stopTest();

    Assert.areEqual(
      0,
      [
        SELECT COUNT()
        FROM Voucher__c
        WHERE Member__c = :member.Id
        WITH SYSTEM_MODE
      ],
      'No voucher should be created.'
    );
    Assert.areEqual(
      0,
      getMember('TEST-b8-poor').Points_Balance__c,
      'The balance should remain unchanged.'
    );
  }

  @IsTest
  static void shouldRejectRedemption_WhenRewardIsInactive() {
    Account member = getMember('TEST-b8-member');
    Reward__c reward = getReward();
    reward.Is_Active__c = false;
    Database.update(reward, AccessLevel.SYSTEM_MODE);

    Test.startTest();
    try {
      new RewardRedemptionService().redeem(member.Id, reward.Id, REQUEST_KEY);
      Assert.fail('Expected an inactive reward to be rejected.');
    } catch (LoyaltyActionException expectedException) {
      Assert.areEqual(
        Label.Loyalty_Reward_Error_Unavailable,
        expectedException.getMessage(),
        'The unavailable reward message should be returned.'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void shouldGenerateAnotherCode_WhenCandidateCollides() {
    Account member = getMember('TEST-b8-member');
    Reward__c reward = getReward();
    Voucher__c existing = TestDataFactory.voucher(member.Id, reward);
    existing.Request_Key__c = 'existing-collision';
    Database.insert(existing, AccessLevel.SYSTEM_MODE);

    Test.startTest();
    RewardRedemptionService service = new RewardRedemptionService(
      new AccountSelector(),
      new RewardSelector(),
      new VoucherSelector(),
      new CollidingCodeGenerator()
    );
    Voucher__c created = service.redeem(member.Id, reward.Id, REQUEST_KEY);
    Test.stopTest();

    Assert.areEqual(
      'ENE-WXYZ-6789',
      created.Code__c,
      'The next unique code should be used after a collision.'
    );
  }

  private static Account getMember(String memberNumber) {
    return [
      SELECT Id, Points_Balance__c
      FROM Account
      WHERE Member_Number__c = :memberNumber
      WITH SYSTEM_MODE
      LIMIT 1
    ];
  }

  private static Reward__c getReward() {
    return [
      SELECT
        Id,
        Name,
        Partner__c,
        Points_Cost__c,
        Value_CZK__c,
        Description__c,
        Is_Active__c
      FROM Reward__c
      WHERE Name = 'B8 tyre discount'
      WITH SYSTEM_MODE
      LIMIT 1
    ];
  }

  private class CollidingCodeGenerator extends VoucherCodeGenerator {
    public override String generate(Integer attempt) {
      return attempt == 0 ? 'ENE-ABCD-2345' : 'ENE-WXYZ-6789';
    }
  }
}
