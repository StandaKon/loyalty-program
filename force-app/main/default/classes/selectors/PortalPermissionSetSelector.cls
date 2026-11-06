/**
 * Encapsulates all SOQL for PermissionSet records.
 */
public inherited sharing class PortalPermissionSetSelector {
    /**
     * SYSTEM_MODE because permission sets are assigned in a guest-initiated async context.
     */
    public List<PermissionSet> selectByNames(Set<String> names) {
        if (names == null || names.isEmpty()) {
            return new List<PermissionSet>();
        }
        return [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :names
            WITH SYSTEM_MODE
        ];
    }
}
