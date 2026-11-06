/**
 * Manual "Simulate purchase" entry from the member record (B5, moved from B3).
 * Creates a Loyalty_Transaction__c exactly like an import row, so the B2 points engine trigger calculates it the same way.
 * The insert runs in user mode: the caller needs Create access to transactions and edit access to the purchase input fields.
 */
public inherited sharing class PurchaseSimulationService {
    private static final String POS_ID_PREFIX = 'SIM:';

    private final AccountSelector accountSelector;
    private final LoyaltyTransactionSelector transactionSelector;

    public PurchaseSimulationService() {
        this(new AccountSelector(), new LoyaltyTransactionSelector());
    }

    @TestVisible
    private PurchaseSimulationService(AccountSelector accountSelector, LoyaltyTransactionSelector transactionSelector) {
        this.accountSelector = accountSelector;
        this.transactionSelector = transactionSelector;
    }

    public Account getMember(Id memberId) {
        Account member = accountSelector.getMemberById(memberId);
        if (member == null || String.isBlank(member.Member_Number__c)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Not_Member);
        }
        return member;
    }

    /**
     * Returns the processed transaction with the points breakdown, or with status Error and its reason.
     */
    public Loyalty_Transaction__c simulate(Id memberId, Decimal liters, Decimal fuelAmount, Decimal otherAmount, Datetime purchasedAt) {
        Account member = getMember(memberId);
        if (member.Membership_Status__c != LoyaltyTransactionService.MEMBERSHIP_ACTIVE) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Member_Not_Active);
        }
        Decimal litersValue = liters ?? 0;
        Decimal fuelValue = (fuelAmount ?? 0).setScale(2, RoundingMode.HALF_UP);
        Decimal otherValue = (otherAmount ?? 0).setScale(2, RoundingMode.HALF_UP);
        Datetime purchaseTime = purchasedAt ?? System.now();
        validate(litersValue, fuelValue, otherValue, purchaseTime);

        Loyalty_Transaction__c loyaltyTransaction = new Loyalty_Transaction__c(
            Member__c = member.Id,
            POS_Transaction_Id__c = POS_ID_PREFIX + UUID.randomUUID().toString(),
            Purchased_At__c = purchaseTime,
            Liters__c = litersValue,
            Fuel_Amount__c = fuelValue,
            Other_Amount__c = otherValue,
            Total_Amount__c = fuelValue + otherValue
        );
        Database.insert(loyaltyTransaction, AccessLevel.USER_MODE);
        return transactionSelector.getById(loyaltyTransaction.Id);
    }

    public Decimal getBalance(Id memberId) {
        return accountSelector.getMemberById(memberId)?.Points_Balance__c ?? 0;
    }

    private void validate(Decimal liters, Decimal fuelAmount, Decimal otherAmount, Datetime purchasedAt) {
        if (liters < 0 || fuelAmount < 0 || otherAmount < 0) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Amount_Negative);
        }
        if (fuelAmount + otherAmount <= 0) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Total_Zero);
        }
        if ((fuelAmount > 0) != (liters > 0)) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Fuel_Liters);
        }
        if (purchasedAt > System.now()) {
            throw new LoyaltyActionException(Label.Loyalty_BO_Error_Future_Purchase);
        }
    }
}
