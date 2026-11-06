@IsTest
private class PosTransactionRestResourceTest {
    private static final String MEMBER_NUMBER = 'TEST-MEMBER-0';
    private static final String POS_TRANSACTION_ID = 'POS-API-109';

    @TestSetup
    static void setup() {
        LoyaltyTestDataFactory.createMember(LoyaltyTransactionService.MEMBERSHIP_ACTIVE);
        insert LoyaltyTestDataFactory.buildReferenceCampaigns();
    }

    @IsTest
    static void shouldCreateTransactionAndReturn109_WhenRequestIsValid() {
        setRequest(buildRequest(POS_TRANSACTION_ID));

        Test.startTest();
        PosTransactionRestResource.createTransaction();
        Test.stopTest();

        Map<String, Object> responseBody = getResponseBody();
        Assert.areEqual(201, RestContext.response.statusCode, 'A new purchase returns HTTP 201.');
        Assert.areEqual('Processed', responseBody.get('status'), 'The points engine processes the purchase synchronously.');
        Assert.areEqual(Decimal.valueOf(109), responseBody.get('awardedPoints'), 'The acceptance purchase awards 109 points.');
        Assert.areEqual(Decimal.valueOf(109), responseBody.get('memberBalance'), 'The member balance includes the award.');
        Assert.areEqual(false, responseBody.get('isReplay'), 'The first request is not a replay.');
        Assert.areEqual(1, [SELECT COUNT() FROM Loyalty_Transaction__c], 'Exactly one transaction is created.');
    }

    @IsTest
    static void shouldReturnExistingResultWithoutDuplicatePoints_WhenRequestIsReplayed() {
        setRequest(buildRequest(POS_TRANSACTION_ID));
        PosTransactionRestResource.createTransaction();
        setRequest(buildRequest(POS_TRANSACTION_ID));

        Test.startTest();
        PosTransactionRestResource.createTransaction();
        Test.stopTest();

        Map<String, Object> responseBody = getResponseBody();
        Assert.areEqual(200, RestContext.response.statusCode, 'A replay returns the existing result.');
        Assert.areEqual(true, responseBody.get('isReplay'), 'The response identifies the replay.');
        Assert.areEqual(1, [SELECT COUNT() FROM Loyalty_Transaction__c], 'A replay does not create a second transaction.');
        Assert.areEqual(109, [SELECT Points_Balance__c FROM Account WHERE Member_Number__c = :MEMBER_NUMBER].Points_Balance__c, 'Points are awarded once.');
    }

    @IsTest
    static void shouldReturnNotFound_WhenMemberNumberIsUnknown() {
        PosTransactionService.TransactionRequest requestBody = buildRequest('POS-API-UNKNOWN');
        requestBody.memberNumber = 'UNKNOWN-MEMBER';
        setRequest(requestBody);

        Test.startTest();
        PosTransactionRestResource.createTransaction();
        Test.stopTest();

        Assert.areEqual(404, RestContext.response.statusCode, 'An unknown member returns HTTP 404.');
        Assert.areEqual('MEMBER_NOT_FOUND', getResponseBody().get('errorCode'), 'The response has a stable error code.');
        Assert.areEqual(0, [SELECT COUNT() FROM Loyalty_Transaction__c], 'No transaction is created.');
    }

    @IsTest
    static void shouldReturnBadRequest_WhenMemberNumberIsMissing() {
        PosTransactionService.TransactionRequest requestBody = buildRequest('POS-API-MISSING');
        requestBody.memberNumber = null;
        setRequest(requestBody);

        Test.startTest();
        PosTransactionRestResource.createTransaction();
        Test.stopTest();

        Assert.areEqual(400, RestContext.response.statusCode, 'A missing member number returns HTTP 400.');
        Assert.areEqual('INVALID_REQUEST', getResponseBody().get('errorCode'), 'The response has a stable validation code.');
    }

    @IsTest
    static void shouldReturnProcessingErrorWithoutPoints_WhenMemberIsBlocked() {
        Account member = [SELECT Id, Membership_Status__c FROM Account WHERE Member_Number__c = :MEMBER_NUMBER];
        member.Membership_Status__c = 'Blocked';
        update member;
        setRequest(buildRequest('POS-API-BLOCKED'));

        Test.startTest();
        PosTransactionRestResource.createTransaction();
        Test.stopTest();

        Assert.areEqual(422, RestContext.response.statusCode, 'A blocked member returns HTTP 422.');
        Assert.areEqual('TRANSACTION_PROCESSING_ERROR', getResponseBody().get('errorCode'), 'The response identifies a processing failure.');
        Assert.areEqual(0, [SELECT COUNT() FROM Point_Ledger__c], 'No points are awarded.');
    }

    @IsTest
    static void shouldReturnBadRequest_WhenJsonIsInvalid() {
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/loyalty/v1/transactions';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf('{invalid');
        RestContext.response = new RestResponse();

        Test.startTest();
        PosTransactionRestResource.createTransaction();
        Test.stopTest();

        Assert.areEqual(400, RestContext.response.statusCode, 'Invalid JSON returns HTTP 400.');
        Assert.areEqual('INVALID_JSON', getResponseBody().get('errorCode'), 'The response identifies invalid JSON.');
    }

    private static PosTransactionService.TransactionRequest buildRequest(String posTransactionId) {
        PosTransactionService.TransactionRequest requestBody = new PosTransactionService.TransactionRequest();
        requestBody.memberNumber = MEMBER_NUMBER;
        requestBody.posTransactionId = posTransactionId;
        requestBody.purchasedAt = Datetime.now().addMinutes(-1);
        requestBody.liters = 45;
        requestBody.fuelAmount = 1710;
        requestBody.otherAmount = 180;
        requestBody.totalAmount = 1890;
        return requestBody;
    }

    private static void setRequest(PosTransactionService.TransactionRequest requestBody) {
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/loyalty/v1/transactions';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
    }

    private static Map<String, Object> getResponseBody() {
        return (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    }
}
