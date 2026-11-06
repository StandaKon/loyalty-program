// Assigns the Loyalty_Portal_Guest permission set to the EneOil site guest user (B6).
// Run once per org after deploying B6 (SF CLI: apex run with this file against the default org).
Site eneOilSite = [SELECT GuestUserId FROM Site WHERE Name = 'EneOil' LIMIT 1];
PermissionSet guestPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Loyalty_Portal_Guest' LIMIT 1];
List<PermissionSetAssignment> existing = [
    SELECT Id
    FROM PermissionSetAssignment
    WHERE AssigneeId = :eneOilSite.GuestUserId AND PermissionSetId = :guestPermissionSet.Id
];
if (existing.isEmpty()) {
    insert new PermissionSetAssignment(AssigneeId = eneOilSite.GuestUserId, PermissionSetId = guestPermissionSet.Id);
}
System.debug('Loyalty_Portal_Guest assigned to guest user ' + eneOilSite.GuestUserId);
