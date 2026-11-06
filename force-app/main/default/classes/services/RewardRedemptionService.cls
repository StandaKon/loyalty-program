// Issuance must access the internal partner Account referenced by the voucher;
// the with-sharing portal controller binds memberId to the signed-in member.
public without sharing class RewardRedemptionService {
  private static final String MEMBERSHIP_ACTIVE = 'Active';
  private static final String STATUS_ISSUED = 'Issued';
  private static final String EMAIL_PENDING = 'Pending';
  private static final String ENTRY_TYPE_REDEMPTION = 'Redemption';
  private static final Integer CODE_ATTEMPTS = 5;
  private static final Pattern REQUEST_KEY_PATTERN = Pattern.compile(
    '^[0-9a-fA-F-]{36}$'
  );

  private final AccountSelector accountSelector;
  private final RewardSelector rewardSelector;
  private final VoucherSelector voucherSelector;
  private final VoucherCodeGenerator codeGenerator;

  public RewardRedemptionService() {
    this(
      new AccountSelector(),
      new RewardSelector(),
      new VoucherSelector(),
      new VoucherCodeGenerator()
    );
  }

  @TestVisible
  private RewardRedemptionService(
    AccountSelector accountSelector,
    RewardSelector rewardSelector,
    VoucherSelector voucherSelector,
    VoucherCodeGenerator codeGenerator
  ) {
    this.accountSelector = accountSelector;
    this.rewardSelector = rewardSelector;
    this.voucherSelector = voucherSelector;
    this.codeGenerator = codeGenerator;
  }

  public Voucher__c redeem(Id memberId, Id rewardId, String requestKey) {
    validateRequest(memberId, rewardId, requestKey);
    Account member = accountSelector.getMemberByIdForUpdate(memberId);
    if (member == null || member.Membership_Status__c != MEMBERSHIP_ACTIVE) {
      throw new LoyaltyActionException(
        Label.Loyalty_Reward_Error_Member_Inactive
      );
    }

    String normalizedRequestKey = requestKey.toLowerCase();
    Voucher__c existingVoucher = voucherSelector.getByRequestKey(
      normalizedRequestKey
    );
    if (existingVoucher != null) {
      if (
        existingVoucher.Member__c != memberId ||
        existingVoucher.Reward__c != rewardId
      ) {
        throw new LoyaltyActionException(
          Label.Loyalty_Reward_Error_Invalid_Request
        );
      }
      return existingVoucher;
    }

    Reward__c reward = rewardSelector.getById(rewardId);
    if (!isAvailable(reward, Date.today())) {
      throw new LoyaltyActionException(Label.Loyalty_Reward_Error_Unavailable);
    }
    Decimal balance = member.Points_Balance__c ?? 0;
    if (balance < reward.Points_Cost__c) {
      throw new LoyaltyActionException(
        String.format(
          Label.Loyalty_Reward_Error_Insufficient_Balance,
          new List<Object>{ reward.Points_Cost__c - balance }
        )
      );
    }

    Voucher__c voucher = buildVoucher(
      memberId,
      reward,
      normalizedRequestKey,
      generateUniqueCode()
    );
    Savepoint savepoint = Database.setSavepoint();
    try {
      Database.insert(voucher, AccessLevel.SYSTEM_MODE);
      Database.insert(
        new Point_Ledger__c(
          Member__c = memberId,
          Voucher__c = voucher.Id,
          Entry_Type__c = ENTRY_TYPE_REDEMPTION,
          Points__c = -reward.Points_Cost__c,
          Occurred_At__c = voucher.Issued_At__c,
          Unique_Key__c = 'VCH:' + voucher.Id + ':REDEEM'
        ),
        AccessLevel.SYSTEM_MODE
      );
      System.enqueueJob(new VoucherEmailQueueable(voucher.Id));
    } catch (Exception caughtException) {
      Database.rollback(savepoint);
      throw caughtException;
    }
    return voucher;
  }

  private void validateRequest(Id memberId, Id rewardId, String requestKey) {
    if (
      memberId == null ||
      rewardId == null ||
      String.isBlank(requestKey) ||
      !REQUEST_KEY_PATTERN.matcher(requestKey).matches()
    ) {
      throw new LoyaltyActionException(
        Label.Loyalty_Reward_Error_Invalid_Request
      );
    }
  }

  private Boolean isAvailable(Reward__c reward, Date availabilityDate) {
    return reward != null &&
      reward.Is_Active__c &&
      (reward.Available_From__c == null ||
      reward.Available_From__c <= availabilityDate) &&
      (reward.Available_Until__c == null ||
      reward.Available_Until__c >= availabilityDate);
  }

  private String generateUniqueCode() {
    for (Integer attempt = 0; attempt < CODE_ATTEMPTS; attempt++) {
      String code = codeGenerator.generate(attempt);
      if (voucherSelector.getByCode(code) == null) {
        return code;
      }
    }
    throw new LoyaltyActionException(
      Label.Loyalty_Reward_Error_Code_Generation
    );
  }

  private Voucher__c buildVoucher(
    Id memberId,
    Reward__c reward,
    String requestKey,
    String code
  ) {
    return new Voucher__c(
      Member__c = memberId,
      Reward__c = reward.Id,
      Partner__c = reward.Partner__c,
      Code__c = code,
      Request_Key__c = requestKey,
      Status__c = STATUS_ISSUED,
      Points_Spent__c = reward.Points_Cost__c,
      Value_CZK__c = reward.Value_CZK__c,
      Reward_Name__c = reward.Name,
      Reward_Description__c = reward.Description__c,
      Issued_At__c = System.now(),
      Email_Status__c = EMAIL_PENDING
    );
  }
}
