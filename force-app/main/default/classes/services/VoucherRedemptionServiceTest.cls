@IsTest
private class VoucherRedemptionServiceTest {
  @IsTest
  static void shouldNormalizeSupportedVoucherCodeVariants() {
    Test.startTest();
    String fullCode = VoucherRedemptionService.normalize('ene-abcd-2345');
    String compactCode = VoucherRedemptionService.normalize(' abcd 2345 ');
    String invalidCode = VoucherRedemptionService.normalize('ENE-O000-1111');
    Test.stopTest();

    Assert.areEqual(
      'ENE-ABCD-2345',
      fullCode,
      'Lowercase full codes should be normalized.'
    );
    Assert.areEqual(
      'ENE-ABCD-2345',
      compactCode,
      'Prefix, spaces and hyphens should be optional.'
    );
    Assert.isNull(invalidCode, 'Ambiguous characters should be rejected.');
  }
}
