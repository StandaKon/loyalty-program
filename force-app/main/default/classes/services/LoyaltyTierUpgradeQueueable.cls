/**
 * Upgrades members to the Highway tier right after a purchase brought them over the threshold (B11, BR-60).
 */
public inherited sharing class LoyaltyTierUpgradeQueueable implements Queueable {
    private final Set<Id> memberIds;

    public LoyaltyTierUpgradeQueueable(Set<Id> memberIds) {
        this.memberIds = memberIds;
    }

    public void execute(QueueableContext context) {
        new LoyaltyTierService().upgradeQualified(memberIds);
    }
}
