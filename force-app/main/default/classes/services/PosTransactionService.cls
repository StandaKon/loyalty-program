public inherited sharing class PosTransactionService {
    private static final String STATUS_PENDING = 'Pending';

    private final AccountSelector accountSelector;
    private final LoyaltyTransactionSelector transactionSelector;

    public PosTransactionService() {
        this(new AccountSelector(), new LoyaltyTransactionSelector());
    }

    @TestVisible
    private PosTransactionService(AccountSelector accountSelector, LoyaltyTransactionSelector transactionSelector) {
        this.accountSelector = accountSelector;
        this.transactionSelector = transactionSelector;
    }

    public TransactionResult createTransaction(TransactionRequest request) {
        validateRequest(request);
        request.memberNumber = request.memberNumber.trim();
        request.posTransactionId = request.posTransactionId.trim();

        Loyalty_Transaction__c existingTransaction = transactionSelector.getByPosTransactionId(request.posTransactionId);
        if (existingTransaction != null) {
            if (!existingTransaction.Member__r.Member_Number__c.equalsIgnoreCase(request.memberNumber)) {
                throw createError('POS_ID_CONFLICT', 409, 'The POS transaction ID is already used by another member.');
            }
            return buildResultOrThrow(existingTransaction, true);
        }

        Account member = accountSelector.getMemberByNumber(request.memberNumber);
        if (member == null) {
            throw createError('MEMBER_NOT_FOUND', 404, 'No loyalty member was found for the supplied member number.');
        }

        Loyalty_Transaction__c loyaltyTransaction = new Loyalty_Transaction__c(
            Member__c = member.Id,
            POS_Transaction_Id__c = request.posTransactionId,
            Purchased_At__c = request.purchasedAt,
            Liters__c = request.liters,
            Fuel_Amount__c = request.fuelAmount,
            Other_Amount__c = request.otherAmount,
            Total_Amount__c = request.totalAmount,
            Processing_Status__c = STATUS_PENDING
        );

        try {
            Database.insert(new List<Loyalty_Transaction__c>{ loyaltyTransaction }, true, AccessLevel.SYSTEM_MODE);
        } catch (DmlException ex) {
            throw createError('INVALID_TRANSACTION', 422, ex.getDmlMessage(0));
        }

        return buildResultOrThrow(transactionSelector.getById(loyaltyTransaction.Id), false);
    }

    private void validateRequest(TransactionRequest request) {
        if (request == null) {
            throw createError('INVALID_REQUEST', 400, 'A request body is required.');
        }
        if (String.isBlank(request.memberNumber)) {
            throw createError('INVALID_REQUEST', 400, 'Member number is required.');
        }
        if (String.isBlank(request.posTransactionId)) {
            throw createError('INVALID_REQUEST', 400, 'POS transaction ID is required.');
        }
        if (
            request.purchasedAt == null ||
            request.liters == null ||
            request.fuelAmount == null ||
            request.otherAmount == null ||
            request.totalAmount == null
        ) {
            throw createError('INVALID_REQUEST', 400, 'Purchase date and all amount fields are required.');
        }
    }

    private TransactionResult buildResultOrThrow(Loyalty_Transaction__c loyaltyTransaction, Boolean isReplay) {
        if (loyaltyTransaction.Processing_Status__c == LoyaltyTransactionService.STATUS_ERROR) {
            throw createError('TRANSACTION_PROCESSING_ERROR', 422, loyaltyTransaction.Processing_Error__c);
        }
        Account member = accountSelector.getMemberById(loyaltyTransaction.Member__c);
        TransactionResult result = new TransactionResult();
        result.transactionId = loyaltyTransaction.Id;
        result.posTransactionId = loyaltyTransaction.POS_Transaction_Id__c;
        result.memberNumber = member.Member_Number__c;
        result.status = loyaltyTransaction.Processing_Status__c;
        result.processingError = loyaltyTransaction.Processing_Error__c;
        result.baseFuelPoints = loyaltyTransaction.Base_Fuel_Points__c;
        result.baseOtherPoints = loyaltyTransaction.Base_Other_Points__c;
        result.campaignPoints = loyaltyTransaction.Campaign_Points__c;
        result.awardedPoints = loyaltyTransaction.Total_Points__c;
        result.memberBalance = member.Points_Balance__c;
        result.isReplay = isReplay;
        return result;
    }

    private static PosTransactionException createError(String errorCode, Integer httpStatus, String message) {
        PosTransactionException exceptionValue = new PosTransactionException(message);
        exceptionValue.errorCode = errorCode;
        exceptionValue.httpStatus = httpStatus;
        return exceptionValue;
    }

    public class TransactionRequest {
        public String memberNumber;
        public String posTransactionId;
        public Datetime purchasedAt;
        public Decimal liters;
        public Decimal fuelAmount;
        public Decimal otherAmount;
        public Decimal totalAmount;
    }

    public class TransactionResult {
        public Id transactionId;
        public String posTransactionId;
        public String memberNumber;
        public String status;
        public String processingError;
        public Decimal baseFuelPoints;
        public Decimal baseOtherPoints;
        public Decimal campaignPoints;
        public Decimal awardedPoints;
        public Decimal memberBalance;
        public Boolean isReplay;
    }

    public class PosTransactionException extends Exception {
        public String errorCode;
        public Integer httpStatus;
    }
}
