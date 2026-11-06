@IsTest
private with sharing class LoyaltyCzechTranslationsTest {
    @IsTest
    static void shouldUseCzechLabelsAndValidation_WhenUserLanguageIsCzech() {
        String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        User customer = new User(Username = 'b1-czech-' + token + '@example.com',
            Email = 'b1-czech@example.com', Alias = 'b1cs', LastName = 'Czech translation test',
            ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = 'Europe/Prague',
            LocaleSidKey = 'cs_CZ', LanguageLocaleKey = 'cs', EmailEncodingKey = 'UTF-8');
        Database.insert(customer, true, AccessLevel.SYSTEM_MODE);
        System.runAs(customer) {
            Test.startTest();
            Assert.areEqual('cs', UserInfo.getLanguage(), 'The test must run with Czech as the user language.');
            Assert.areEqual('Nákup', Loyalty_Transaction__c.SObjectType.getDescribe().getLabel(),
                'The transaction object label must be translated.');
            Assert.areEqual('Odměny', Reward__c.SObjectType.getDescribe().getLabelPlural(),
                'The reward tab must use the Czech plural object label.');
            Assert.areEqual('Zůstatek bodů', Account.Points_Balance__c.getDescribe().getLabel(),
                'The member balance field must be translated.');
            Assert.areEqual('Projev člena', AuthorizationFormConsent.Consent_Action__c.getDescribe().getLabel(),
                'Custom fields on standard consent objects must be translated.');
            assertPicklistLabel(Loyalty_Campaign__c.Reward_Type__c, 'BaseMultiplier', 'Násobitel základních bodů');
            assertPicklistLabel(Point_Ledger__c.Entry_Type__c, 'Redemption', 'Čerpání za voucher');
            assertPicklistLabel(Voucher__c.Email_Status__c, 'Pending', 'Čeká na odeslání');
            Account invalidMember = TestDataFactory.member('cs-invalid-year');
            invalidMember.Vehicle_Year__c = 1800;
            Database.SaveResult result = Database.insert(invalidMember, false, AccessLevel.SYSTEM_MODE);
            Assert.isFalse(result.isSuccess(), 'An invalid vehicle year must fail validation.');
            Assert.areEqual('Rok výroby musí být od roku 1900 do příštího kalendářního roku.',
                result.getErrors()[0].getMessage(), 'The validation message must be Czech in a Czech user context.');
            Test.stopTest();
        }
    }

    private static void assertPicklistLabel(Schema.SObjectField field, String apiValue, String expectedLabel) {
        for (Schema.PicklistEntry value : field.getDescribe().getPicklistValues()) {
            if (value.getValue() == apiValue) {
                Assert.areEqual(expectedLabel, value.getLabel(), 'The translated label must preserve its API value.');
                return;
            }
        }
        Assert.fail('The expected picklist API value must exist: ' + apiValue);
    }
}
