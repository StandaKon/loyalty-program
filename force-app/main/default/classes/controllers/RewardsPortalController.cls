public with sharing class RewardsPortalController {
    @TestVisible
    private static UserSelector userSelector = new UserSelector();
    @TestVisible
    private static AccountSelector accountSelector = new AccountSelector();
    @TestVisible
    private static RewardSelector rewardSelector = new RewardSelector();
    @TestVisible
    private static VoucherSelector voucherSelector = new VoucherSelector();
    @TestVisible
    private static RewardRedemptionService redemptionService = new RewardRedemptionService();

    public class RewardView {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String partnerName;
        @AuraEnabled public Decimal pointsCost;
        @AuraEnabled public Decimal valueCzk;
        @AuraEnabled public Decimal memberBalance;
        @AuraEnabled public Decimal missingPoints;
        @AuraEnabled public Boolean canRedeem;
    }

    public class VoucherView {
        @AuraEnabled public Id id;
        @AuraEnabled public String code;
        @AuraEnabled public String status;
        @AuraEnabled public String statusLabel;
        @AuraEnabled public String rewardName;
        @AuraEnabled public String description;
        @AuraEnabled public String partnerName;
        @AuraEnabled public Decimal pointsSpent;
        @AuraEnabled public Decimal valueCzk;
        @AuraEnabled public Datetime issuedAt;
        @AuraEnabled public Datetime redeemedAt;
        @AuraEnabled public String serviceLocation;
        @AuraEnabled public Datetime cancelledAt;
    }

    public class RedemptionResult {
        @AuraEnabled public VoucherView voucher;
        @AuraEnabled public Decimal balance;
    }

    @AuraEnabled(cacheable=true)
    public static List<RewardView> getCatalogue() {
        try {
            Account member = getCurrentMember();
            List<RewardView> views = new List<RewardView>();
            for (Reward__c reward : rewardSelector.getAvailable(Date.today())) {
                views.add(toRewardView(reward, member.Points_Balance__c ?? 0));
            }
            return views;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<VoucherView> getMyVouchers() {
        try {
            Id memberId = getCurrentMember().Id;
            List<VoucherView> views = new List<VoucherView>();
            for (Voucher__c voucher : voucherSelector.getByMemberId(memberId)) {
                views.add(toVoucherView(voucher));
            }
            return views;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    @AuraEnabled
    public static RedemptionResult redeem(Id rewardId, String requestKey) {
        try {
            Account member = getCurrentMember();
            Voucher__c voucher = redemptionService.redeem(member.Id, rewardId, requestKey);
            RedemptionResult result = new RedemptionResult();
            result.voucher = toVoucherView(voucher);
            result.balance = accountSelector.getMemberById(member.Id).Points_Balance__c ?? 0;
            return result;
        } catch (Exception caughtException) {
            throw LoyaltyControllerErrors.toAuraException(caughtException);
        }
    }

    private static Account getCurrentMember() {
        Id memberId = userSelector.getCurrentMemberAccountId();
        Account member = memberId == null ? null : accountSelector.getMemberById(memberId);
        if (member == null || String.isBlank(member.Member_Number__c)) {
            throw new LoyaltyActionException(Label.Loyalty_Reward_Error_Not_Member);
        }
        return member;
    }

    private static RewardView toRewardView(Reward__c reward, Decimal balance) {
        RewardView view = new RewardView();
        view.id = reward.Id;
        view.name = reward.Name;
        view.description = reward.Description__c;
        view.partnerName = reward.Partner__r?.Name;
        view.pointsCost = reward.Points_Cost__c;
        view.valueCzk = reward.Value_CZK__c;
        view.memberBalance = balance;
        view.missingPoints = Math.max(0, reward.Points_Cost__c - balance);
        view.canRedeem = view.missingPoints == 0;
        return view;
    }

    private static VoucherView toVoucherView(Voucher__c voucher) {
        VoucherView view = new VoucherView();
        view.id = voucher.Id;
        view.code = voucher.Code__c;
        view.status = voucher.Status__c;
        view.statusLabel = PicklistOptions.getLabel(Voucher__c.Status__c, voucher.Status__c);
        view.rewardName = voucher.Reward_Name__c;
        view.description = voucher.Reward_Description__c;
        view.partnerName = voucher.Partner__r?.Name;
        view.pointsSpent = voucher.Points_Spent__c;
        view.valueCzk = voucher.Value_CZK__c;
        view.issuedAt = voucher.Issued_At__c;
        view.redeemedAt = voucher.Redeemed_At__c;
        view.serviceLocation = voucher.Service_Location__c;
        view.cancelledAt = voucher.Cancelled_At__c;
        return view;
    }
}
