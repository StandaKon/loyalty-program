public inherited sharing class VoucherSelector {
  // System mode: field access is decided by the calling controller/service; record sharing follows the caller's class.
  public Voucher__c getById(Id voucherId) {
    List<Voucher__c> vouchers = [
      SELECT
        Id,
        Name,
        Code__c,
        Status__c,
        Member__c,
        Member__r.Name,
        Reward_Name__c,
        Points_Spent__c,
        Issued_At__c
      FROM Voucher__c
      WHERE Id = :voucherId
      WITH SYSTEM_MODE
      LIMIT 1
    ];
    return vouchers.isEmpty() ? null : vouchers[0];
  }

  public Voucher__c getByIdForUpdate(Id voucherId) {
    List<Voucher__c> vouchers = [
      SELECT Id, Name, Code__c, Status__c, Member__c, Points_Spent__c
      FROM Voucher__c
      WHERE Id = :voucherId
      WITH SYSTEM_MODE
      LIMIT 1
      FOR UPDATE
    ];
    return vouchers.isEmpty() ? null : vouchers[0];
  }

  public Voucher__c getByRequestKey(String requestKey) {
    List<Voucher__c> vouchers = [
      SELECT
        Id,
        Code__c,
        Status__c,
        Member__c,
        Reward__c,
        Reward_Name__c,
        Reward_Description__c,
        Partner__c,
        Points_Spent__c,
        Value_CZK__c,
        Issued_At__c,
        Email_Status__c
      FROM Voucher__c
      WHERE Request_Key__c = :requestKey
      WITH SYSTEM_MODE
      LIMIT 1
    ];
    return vouchers.isEmpty() ? null : vouchers[0];
  }

  public Voucher__c getByCode(String code) {
    List<Voucher__c> vouchers = [
      SELECT
        Id,
        Code__c,
        Status__c,
        Member__c,
        Reward_Name__c,
        Points_Spent__c,
        Value_CZK__c,
        Issued_At__c,
        Redeemed_At__c,
        Service_Location__c,
        Service_Order_Number__c,
        Cancelled_At__c
      FROM Voucher__c
      WHERE Code__c = :code
      WITH SYSTEM_MODE
      LIMIT 1
    ];
    return vouchers.isEmpty() ? null : vouchers[0];
  }

  public Voucher__c getByCodeForUpdate(String code) {
    List<Voucher__c> vouchers = [
      SELECT Id, Code__c, Status__c, Reward_Name__c, Issued_At__c
      FROM Voucher__c
      WHERE Code__c = :code
      WITH SYSTEM_MODE
      LIMIT 1
      FOR UPDATE
    ];
    return vouchers.isEmpty() ? null : vouchers[0];
  }

  public List<Voucher__c> getByMemberId(Id memberId) {
    return [
      SELECT
        Id,
        Code__c,
        Status__c,
        Reward_Name__c,
        Reward_Description__c,
        Partner__r.Name,
        Points_Spent__c,
        Value_CZK__c,
        Issued_At__c,
        Redeemed_At__c,
        Service_Location__c,
        Cancelled_At__c
      FROM Voucher__c
      WHERE Member__c = :memberId
      WITH SYSTEM_MODE
      ORDER BY Issued_At__c DESC
    ];
  }

  public Voucher__c getForEmail(Id voucherId) {
    List<Voucher__c> vouchers = [
      SELECT
        Id,
        Code__c,
        Status__c,
        Reward_Name__c,
        Points_Spent__c,
        Member__c,
        Member__r.PersonEmail,
        Member__r.Name,
        Member__r.Points_Balance__c
      FROM Voucher__c
      WHERE Id = :voucherId
      WITH SYSTEM_MODE
      LIMIT 1
    ];
    return vouchers.isEmpty() ? null : vouchers[0];
  }
}
