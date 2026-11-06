public inherited sharing class LoyaltySettingsSelector {
    private static final String DEFAULT_SETTINGS_NAME = 'Default';

    public Loyalty_Settings__mdt getDefault() {
        return Loyalty_Settings__mdt.getInstance(DEFAULT_SETTINGS_NAME);
    }
}
