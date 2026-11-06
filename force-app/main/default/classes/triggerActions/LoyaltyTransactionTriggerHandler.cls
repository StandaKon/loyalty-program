/**
 * Routes Loyalty_Transaction__c trigger events to LoyaltyTransactionService.
 * Plain handler instead of trigger-actions-framework, which is not installed in the target org (B2 decision).
 *
 * Runs without sharing on purpose: the points engine is a server-side process that must validate any member
 * and write protected ledger entries regardless of the record access of the user who imports the purchase.
 */
public without sharing class LoyaltyTransactionTriggerHandler {
    @TestVisible
    private LoyaltyTransactionService service;

    public LoyaltyTransactionTriggerHandler() {
        this(new LoyaltyTransactionService());
    }

    @TestVisible
    private LoyaltyTransactionTriggerHandler(LoyaltyTransactionService service) {
        this.service = service;
    }

    public void run(TriggerOperation operation, List<Loyalty_Transaction__c> newTransactions, Map<Id, Loyalty_Transaction__c> oldTransactionsById) {
        switch on operation {
            when BEFORE_INSERT {
                service.processTransactions(newTransactions);
            }
            when BEFORE_UPDATE {
                service.preventChangesToProcessed(newTransactions, oldTransactionsById);
                service.processTransactions(getNotYetProcessed(newTransactions, oldTransactionsById));
            }
            when AFTER_INSERT, AFTER_UPDATE {
                service.createLedgerEntries(newTransactions, oldTransactionsById);
            }
        }
    }

    private List<Loyalty_Transaction__c> getNotYetProcessed(List<Loyalty_Transaction__c> newTransactions, Map<Id, Loyalty_Transaction__c> oldTransactionsById) {
        List<Loyalty_Transaction__c> notYetProcessed = new List<Loyalty_Transaction__c>();
        for (Loyalty_Transaction__c loyaltyTransaction : newTransactions) {
            if (oldTransactionsById.get(loyaltyTransaction.Id).Processing_Status__c != LoyaltyTransactionService.STATUS_PROCESSED) {
                notYetProcessed.add(loyaltyTransaction);
            }
        }
        return notYetProcessed;
    }
}
