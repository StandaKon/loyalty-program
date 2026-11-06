// B11: read-only preview — members whose points would expire today. Writes nothing.
// Run as a user with Loyalty_Manager (needs FLS on Member_Number__c).
Set<Id> memberIds = new Map<Id, Account>((List<Account>) Database.query('SELECT Id FROM Account WHERE Member_Number__c != NULL LIMIT 2000')).keySet();
Map<Id, Integer> dueByMemberId = new PointExpiryService().getDuePoints(memberIds, PointsCalculator.toProgramDate(System.now()));
Integer total = 0;
System.debug('B11 EXPIRY MEMBERS ' + memberIds.size());
for (Id memberId : dueByMemberId.keySet()) {
    if (dueByMemberId.get(memberId) > 0) {
        total += dueByMemberId.get(memberId);
        System.debug('B11 EXPIRY ' + memberId + ' ' + dueByMemberId.get(memberId));
    }
}
System.debug('B11 EXPIRY TOTAL ' + total);
