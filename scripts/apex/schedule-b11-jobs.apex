// B11: schedule the daily points expiry and the monthly tier evaluation.
// WARNING: the expiry batch writes immutable Expiration ledger entries for points older than
// Loyalty_Settings__mdt.Points_Validity_Months__c (respecting Expiry_Effective_Date__c). Check the setting first.
System.schedule('Loyalty points expiry (daily 01:30)', '0 30 1 * * ?', new PointExpiryBatch());
System.schedule('Loyalty tier evaluation (1st of month 02:00)', '0 0 2 1 * ?', new LoyaltyTierEvaluationBatch());
