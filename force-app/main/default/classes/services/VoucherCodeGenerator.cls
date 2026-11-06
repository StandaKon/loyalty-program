public inherited sharing virtual class VoucherCodeGenerator {
  private static final String ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  private static final String HEX = '0123456789ABCDEF';

  public virtual String generate(Integer attempt) {
    String source =
      UUID.randomUUID().toString() +
      ':' +
      String.valueOf(attempt);
    String digest = EncodingUtil.convertToHex(
        Crypto.generateDigest('SHA-256', Blob.valueOf(source))
      )
      .toUpperCase();
    String characters = '';
    for (Integer index = 0; index < 8; index++) {
      Integer digestValue =
        HEX.indexOf(digest.substring(index * 2, index * 2 + 1)) * 16 +
        HEX.indexOf(digest.substring(index * 2 + 1, index * 2 + 2));
      characters += ALPHABET.substring(
        Math.mod(digestValue, ALPHABET.length()),
        Math.mod(digestValue, ALPHABET.length()) + 1
      );
    }
    return 'ENE-' + characters.substring(0, 4) + '-' + characters.substring(4);
  }
}
