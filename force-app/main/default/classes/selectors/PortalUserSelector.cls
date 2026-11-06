/**
 * Encapsulates all SOQL for User records used by the member portal.
 */
public inherited sharing class PortalUserSelector {
    public List<User> selectByIds(Set<Id> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return new List<User>();
        }
        return [
            SELECT Id, AccountId, ContactId, FirstName
            FROM User
            WHERE Id IN :userIds
            WITH USER_MODE
        ];
    }

    /**
     * SYSTEM_MODE because the duplicate check runs as the site guest user,
     * who cannot see any User records. Only Id and Username leave this method.
     */
    public List<User> selectByUsernames(Set<String> usernames) {
        if (usernames == null || usernames.isEmpty()) {
            return new List<User>();
        }
        return [
            SELECT Id, Username
            FROM User
            WHERE Username IN :usernames
            WITH SYSTEM_MODE
        ];
    }
}
