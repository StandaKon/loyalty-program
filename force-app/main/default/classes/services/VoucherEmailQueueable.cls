public inherited sharing class VoucherEmailQueueable implements Queueable {
  private static final String STATUS_SENT = 'Sent';
  private static final String STATUS_ERROR = 'Error';
  private static final Integer MAX_ERROR_LENGTH = 255;
  private final Id voucherId;

  public VoucherEmailQueueable(Id voucherId) {
    this.voucherId = voucherId;
  }

  public void execute(QueueableContext context) {
    Voucher__c voucher = new VoucherSelector().getForEmail(voucherId);
    if (voucher == null || String.isBlank(voucher.Member__r?.PersonEmail)) {
      markError(Label.Loyalty_Voucher_Email_Missing_Address);
      return;
    }

    try {
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setToAddresses(new List<String>{ voucher.Member__r.PersonEmail });
      message.setSubject(
        String.format(
          Label.Loyalty_Voucher_Email_Subject,
          new List<Object>{ voucher.Reward_Name__c }
        )
      );
      message.setHtmlBody(buildHtml(voucher));
      message.setSaveAsActivity(false);
      Messaging.SendEmailResult result = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ message }
      )[0];
      if (!result.isSuccess()) {
        markError(result.getErrors()[0].getMessage());
        return;
      }
      Database.update(
        new Voucher__c(
          Id = voucher.Id,
          Email_Status__c = STATUS_SENT,
          Email_Sent_At__c = System.now(),
          Email_Error__c = null
        ),
        AccessLevel.SYSTEM_MODE
      );
    } catch (Exception caughtException) {
      Log.error(caughtException);
      Log.save();
      markError(caughtException.getMessage());
    }
  }

  private String buildHtml(Voucher__c voucher) {
    return '<div style="font-family:Arial,sans-serif;color:#17352d">' +
      '<h1>' +
      Label.Loyalty_Voucher_Email_Heading.escapeHtml4() +
      '</h1>' +
      '<p>' +
      String.format(
        Label.Loyalty_Voucher_Email_Intro,
        new List<Object>{ voucher.Reward_Name__c.escapeHtml4() }
      ) +
      '</p>' +
      '<p style="font-family:monospace;font-size:24px;font-weight:700;background:#eef7f2;padding:16px">' +
      voucher.Code__c.escapeHtml4() +
      '</p>' +
      '<p>' +
      Label.Loyalty_Voucher_Email_Instructions.escapeHtml4() +
      '</p>' +
      '<p>' +
      String.format(
        Label.Loyalty_Voucher_Email_Points,
        new List<Object>{
          voucher.Points_Spent__c,
          voucher.Member__r.Points_Balance__c
        }
      ) +
      '</p>' +
      '<p>' +
      Label.Loyalty_Voucher_Email_Terms.escapeHtml4() +
      '</p></div>';
  }

  private void markError(String errorMessage) {
    String safeError = String.isBlank(errorMessage)
      ? Label.Loyalty_Voucher_Email_Unknown_Error
      : errorMessage.left(MAX_ERROR_LENGTH);
    Database.update(
      new Voucher__c(
        Id = voucherId,
        Email_Status__c = STATUS_ERROR,
        Email_Error__c = safeError
      ),
      AccessLevel.SYSTEM_MODE
    );
  }
}
