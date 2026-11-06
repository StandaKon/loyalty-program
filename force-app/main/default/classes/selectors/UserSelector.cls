public inherited sharing class UserSelector {
  public Id getCurrentMemberAccountId() {
    List<User> users = [
      SELECT AccountId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      WITH SYSTEM_MODE
      LIMIT 1
    ];
    return users.isEmpty() ? null : users[0].AccountId;
  }
}
