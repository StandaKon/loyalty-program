/**
 * Points engine for Loyalty_Transaction__c (block B2).
 * Before save: validates the purchase and stores the points breakdown and processing status on the record.
 * After save: creates the immutable Point_Ledger__c entries for newly processed purchases.
 * Idempotency relies on unique POS_Transaction_Id__c and unique Point_Ledger__c.Unique_Key__c values.
 * Data validity (amounts, future date, registered member) and the lock of processed purchases are enforced by the
 * B1 validation rules, which reject such rows at import. The engine only stores business errors as status Error.
 */
public inherited sharing class LoyaltyTransactionService {
    public static final String STATUS_PROCESSED = 'Processed';
    public static final String STATUS_ERROR = 'Error';
    public static final String MEMBERSHIP_ACTIVE = 'Active';
    public static final String ENTRY_TYPE_PURCHASE_BASE = 'PurchaseBase';
    public static final String ENTRY_TYPE_CAMPAIGN_BONUS = 'CampaignBonus';

    private final AccountSelector accountSelector;
    private final LoyaltyCampaignSelector campaignSelector;
    private final LoyaltySettingsSelector settingsSelector;

    public LoyaltyTransactionService() {
        this(new AccountSelector(), new LoyaltyCampaignSelector(), new LoyaltySettingsSelector());
    }

    @TestVisible
    private LoyaltyTransactionService(AccountSelector accountSelector, LoyaltyCampaignSelector campaignSelector, LoyaltySettingsSelector settingsSelector) {
        this.accountSelector = accountSelector;
        this.campaignSelector = campaignSelector;
        this.settingsSelector = settingsSelector;
    }

    public void processTransactions(List<Loyalty_Transaction__c> allTransactions) {
        List<Loyalty_Transaction__c> transactions = getCalculable(allTransactions);
        if (transactions.isEmpty()) {
            return;
        }
        Loyalty_Settings__mdt settings = settingsSelector.getDefault();
        Boolean hasValidSettings = isValid(settings);
        Map<Id, Account> membersById = accountSelector.getMembersByIds(collectMemberIds(transactions));

        List<Loyalty_Transaction__c> validTransactions = new List<Loyalty_Transaction__c>();
        for (Loyalty_Transaction__c loyaltyTransaction : transactions) {
            String validationError = hasValidSettings ? validate(membersById.get(loyaltyTransaction.Member__c)) : Label.Loyalty_Tx_Error_Invalid_Settings;
            if (validationError == null) {
                validTransactions.add(loyaltyTransaction);
            } else {
                markAsError(loyaltyTransaction, validationError);
            }
        }
        if (validTransactions.isEmpty()) {
            return;
        }

        PointsCalculator calculator = new PointsCalculator(settings);
        List<Loyalty_Campaign__c> campaigns = getCampaigns(validTransactions);
        for (Loyalty_Transaction__c loyaltyTransaction : validTransactions) {
            markAsProcessed(loyaltyTransaction, calculator.calculate(loyaltyTransaction, campaigns));
        }
    }

    public void createLedgerEntries(List<Loyalty_Transaction__c> transactions, Map<Id, Loyalty_Transaction__c> oldTransactionsById) {
        Map<Id, Loyalty_Transaction__c> newlyProcessedById = getNewlyProcessed(transactions, oldTransactionsById);
        if (newlyProcessedById.isEmpty()) {
            return;
        }

        PointsCalculator calculator = new PointsCalculator(settingsSelector.getDefault());
        List<Loyalty_Campaign__c> campaigns = getCampaigns(newlyProcessedById.values());
        List<Point_Ledger__c> ledgerEntries = new List<Point_Ledger__c>();
        for (Loyalty_Transaction__c loyaltyTransaction : newlyProcessedById.values()) {
            PointsCalculator.PointsResult result = calculator.calculate(loyaltyTransaction, campaigns);
            ledgerEntries.add(buildBaseEntry(loyaltyTransaction, result));
            for (PointsCalculator.CampaignBonus campaignBonus : result.campaignBonuses) {
                ledgerEntries.add(buildCampaignEntry(loyaltyTransaction, campaignBonus));
            }
        }

        // Partial success on purpose: a failed entry rejects only its own purchase via addError. The platform then
        // rolls back that purchase together with all its entries, so no partial award is ever kept.
        List<Database.SaveResult> saveResults = Database.insert(ledgerEntries, false, AccessLevel.SYSTEM_MODE);
        for (Integer index = 0; index < saveResults.size(); index++) {
            if (!saveResults[index].isSuccess()) {
                newlyProcessedById.get(ledgerEntries[index].Transaction__c)
                    .addError(String.format(Label.Loyalty_Tx_Error_Ledger_Failed, new List<Object>{ saveResults[index].getErrors()[0].getMessage() }));
            }
        }
    }

    private String validate(Account member) {
        if (member?.Membership_Status__c != MEMBERSHIP_ACTIVE) {
            return Label.Loyalty_Tx_Error_Member_Inactive;
        }
        return null;
    }

    // Rows without the inputs needed for calculation are left untouched; the B1 validation rules reject them.
    private List<Loyalty_Transaction__c> getCalculable(List<Loyalty_Transaction__c> transactions) {
        List<Loyalty_Transaction__c> calculable = new List<Loyalty_Transaction__c>();
        for (Loyalty_Transaction__c loyaltyTransaction : transactions) {
            if (loyaltyTransaction.Member__c != null && loyaltyTransaction.Purchased_At__c != null && loyaltyTransaction.Liters__c != null && loyaltyTransaction.Other_Amount__c != null) {
                calculable.add(loyaltyTransaction);
            }
        }
        return calculable;
    }

    private Boolean isValid(Loyalty_Settings__mdt settings) {
        return settings != null && (settings.Fuel_Points_Per_Liter__c ?? 0) > 0 && (settings.Other_CZK_Per_Point__c ?? 0) > 0;
    }

    private void markAsError(Loyalty_Transaction__c loyaltyTransaction, String errorMessage) {
        loyaltyTransaction.Processing_Status__c = STATUS_ERROR;
        loyaltyTransaction.Processing_Error__c = errorMessage;
        loyaltyTransaction.Processed_At__c = null;
        loyaltyTransaction.Base_Fuel_Points__c = null;
        loyaltyTransaction.Base_Other_Points__c = null;
        loyaltyTransaction.Campaign_Points__c = null;
    }

    private void markAsProcessed(Loyalty_Transaction__c loyaltyTransaction, PointsCalculator.PointsResult result) {
        loyaltyTransaction.Processing_Status__c = STATUS_PROCESSED;
        loyaltyTransaction.Processing_Error__c = null;
        loyaltyTransaction.Processed_At__c = Datetime.now();
        loyaltyTransaction.Base_Fuel_Points__c = result.fuelPoints;
        loyaltyTransaction.Base_Other_Points__c = result.otherPoints;
        loyaltyTransaction.Campaign_Points__c = result.getCampaignPoints();
    }

    private Map<Id, Loyalty_Transaction__c> getNewlyProcessed(List<Loyalty_Transaction__c> transactions, Map<Id, Loyalty_Transaction__c> oldTransactionsById) {
        Map<Id, Loyalty_Transaction__c> newlyProcessedById = new Map<Id, Loyalty_Transaction__c>();
        for (Loyalty_Transaction__c loyaltyTransaction : transactions) {
            Loyalty_Transaction__c oldTransaction = oldTransactionsById?.get(loyaltyTransaction.Id);
            if (loyaltyTransaction.Processing_Status__c == STATUS_PROCESSED && oldTransaction?.Processing_Status__c != STATUS_PROCESSED) {
                newlyProcessedById.put(loyaltyTransaction.Id, loyaltyTransaction);
            }
        }
        return newlyProcessedById;
    }

    private List<Loyalty_Campaign__c> getCampaigns(List<Loyalty_Transaction__c> transactions) {
        Date fromDate;
        Date toDate;
        for (Loyalty_Transaction__c loyaltyTransaction : transactions) {
            Date purchaseDate = PointsCalculator.toProgramDate(loyaltyTransaction.Purchased_At__c);
            fromDate = (fromDate == null || purchaseDate < fromDate) ? purchaseDate : fromDate;
            toDate = (toDate == null || purchaseDate > toDate) ? purchaseDate : toDate;
        }
        return campaignSelector.getEnabledOverlapping(fromDate, toDate);
    }

    private Set<Id> collectMemberIds(List<Loyalty_Transaction__c> transactions) {
        Set<Id> memberIds = new Set<Id>();
        for (Loyalty_Transaction__c loyaltyTransaction : transactions) {
            memberIds.add(loyaltyTransaction.Member__c);
        }
        return memberIds;
    }

    private Point_Ledger__c buildBaseEntry(Loyalty_Transaction__c loyaltyTransaction, PointsCalculator.PointsResult result) {
        return new Point_Ledger__c(
            Member__c = loyaltyTransaction.Member__c,
            Transaction__c = loyaltyTransaction.Id,
            Entry_Type__c = ENTRY_TYPE_PURCHASE_BASE,
            Points__c = result.getBasePoints(),
            Occurred_At__c = loyaltyTransaction.Purchased_At__c,
            Unique_Key__c = 'TX:' + loyaltyTransaction.Id + ':BASE'
        );
    }

    private Point_Ledger__c buildCampaignEntry(Loyalty_Transaction__c loyaltyTransaction, PointsCalculator.CampaignBonus campaignBonus) {
        Loyalty_Campaign__c campaign = campaignBonus.campaign;
        return new Point_Ledger__c(
            Member__c = loyaltyTransaction.Member__c,
            Transaction__c = loyaltyTransaction.Id,
            Campaign__c = campaign.Id,
            Entry_Type__c = ENTRY_TYPE_CAMPAIGN_BONUS,
            Points__c = campaignBonus.points,
            Occurred_At__c = loyaltyTransaction.Purchased_At__c,
            Unique_Key__c = 'TX:' + loyaltyTransaction.Id + ':CAM:' + campaign.Id,
            Applied_Condition_Field__c = campaign.Condition_Field__c,
            Applied_Threshold__c = campaign.Threshold__c,
            Applied_Reward_Type__c = campaign.Reward_Type__c,
            Applied_Reward_Value__c = campaign.Reward_Value__c
        );
    }
}
