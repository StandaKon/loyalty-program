/**
 * Active values of a picklist field with labels in the running user's language, for back-office actions.
 */
public inherited sharing class PicklistOptions {
    public class Option {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public static List<Option> getOptions(Schema.SObjectField field) {
        List<Option> options = new List<Option>();
        for (Schema.PicklistEntry entry : field.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                options.add(new Option(entry.getLabel(), entry.getValue()));
            }
        }
        return options;
    }

    public static String getLabel(Schema.SObjectField field, String value) {
        for (Option option : getOptions(field)) {
            if (option.value == value) {
                return option.label;
            }
        }
        return null;
    }

    public static Boolean isValid(Schema.SObjectField field, String value) {
        return String.isNotBlank(value) && getLabel(field, value) != null;
    }
}
