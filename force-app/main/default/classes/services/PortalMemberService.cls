/**
 * Builds member-facing portal data for the currently logged-in Customer Community user.
 * The member is always resolved from the running user, never from client input.
 */
public inherited sharing class PortalMemberService {
    public static final Integer RECENT_MOVEMENTS_LIMIT = 5;
    public static final Integer MAX_PAGE_SIZE = 50;
    private static final Integer FULL_PROGRESS_PERCENT = 100;

    private final PortalUserSelector userSelector;
    private final PortalAccountSelector accountSelector;
    private final PortalPointLedgerSelector pointLedgerSelector;
    private final PortalCampaignSelector campaignSelector;
    private final PortalRewardSelector rewardSelector;
    private final LoyaltyMemberSelector loyaltyMemberSelector = new LoyaltyMemberSelector();
    private final LoyaltyTierService tierService = new LoyaltyTierService();
    private final PointExpiryService expiryService = new PointExpiryService();

    public PortalMemberService() {
        this(new PortalUserSelector(), new PortalAccountSelector(), new PortalPointLedgerSelector(), new PortalCampaignSelector(), new PortalRewardSelector());
    }

    @TestVisible
    private PortalMemberService(
        PortalUserSelector userSelector,
        PortalAccountSelector accountSelector,
        PortalPointLedgerSelector pointLedgerSelector,
        PortalCampaignSelector campaignSelector,
        PortalRewardSelector rewardSelector
    ) {
        this.userSelector = userSelector;
        this.accountSelector = accountSelector;
        this.pointLedgerSelector = pointLedgerSelector;
        this.campaignSelector = campaignSelector;
        this.rewardSelector = rewardSelector;
    }

    public PortalMemberDto.Overview getOverview() {
        Account member = getCurrentMember();
        Integer balance = toInteger(member.Points_Balance__c);

        PortalMemberDto.Overview overview = new PortalMemberDto.Overview();
        overview.firstName = member.FirstName;
        overview.memberNumber = member.Member_Number__c;
        overview.balance = balance;
        overview.recentMovements = toMovements(pointLedgerSelector.selectByMemberId(member.Id, RECENT_MOVEMENTS_LIMIT, 0));
        overview.activeCampaigns = getActiveCampaigns();

        List<Reward__c> rewards = rewardSelector.selectActiveOrderedByPointsCost();
        overview.nextReward = buildNextReward(rewards, balance);
        overview.hasReachedAllRewards = !rewards.isEmpty() && overview.nextReward == null;
        return overview;
    }

    public PortalMemberDto.HistoryPage getPointHistory(Integer pageSize, Integer pageNumber) {
        if (pageSize == null || pageSize <= 0 || pageSize > MAX_PAGE_SIZE || pageNumber == null || pageNumber < 1) {
            throw new PortalMemberException('Invalid paging parameters.');
        }
        Id memberId = getCurrentMemberId();
        Integer offsetSize = (pageNumber - 1) * pageSize;

        PortalMemberDto.HistoryPage page = new PortalMemberDto.HistoryPage();
        page.movements = toMovements(pointLedgerSelector.selectByMemberId(memberId, pageSize, offsetSize));
        page.totalCount = pointLedgerSelector.countByMemberId(memberId);
        page.hasMore = offsetSize + page.movements.size() < page.totalCount;
        return page;
    }

    public List<PortalMemberDto.Campaign> getActiveCampaigns() {
        List<PortalMemberDto.Campaign> campaigns = new List<PortalMemberDto.Campaign>();
        for (Loyalty_Campaign__c record : campaignSelector.selectEnabledOn(Date.today())) {
            PortalMemberDto.Campaign campaign = new PortalMemberDto.Campaign();
            campaign.id = record.Id;
            campaign.name = record.Name;
            campaign.memberText = record.Member_Description__c;
            campaign.validTo = record.End_Date__c;
            campaigns.add(campaign);
        }
        return campaigns;
    }

    public PortalMemberDto.RewardCatalog getRewardCatalog() {
        Integer balance = toInteger(getCurrentMember().Points_Balance__c);
        PortalMemberDto.RewardCatalog catalog = new PortalMemberDto.RewardCatalog();
        catalog.balance = balance;
        catalog.rewards = new List<PortalMemberDto.Reward>();
        for (Reward__c record : rewardSelector.selectActiveCatalog()) {
            Integer pointsCost = toInteger(record.Points_Cost__c);
            PortalMemberDto.Reward reward = new PortalMemberDto.Reward();
            reward.id = record.Id;
            reward.name = record.Name;
            reward.description = record.Description__c;
            reward.pointsCost = pointsCost;
            reward.valueCzk = record.Value_CZK__c;
            reward.isAffordable = balance >= pointsCost;
            reward.pointsMissing = Math.max(0, pointsCost - balance);
            reward.progressPercent = Math.max(0, Math.min(FULL_PROGRESS_PERCENT, (balance * FULL_PROGRESS_PERCENT) / pointsCost));
            catalog.rewards.add(reward);
        }
        return catalog;
    }

    // B11: tier card and expiry warning. Tier and ledger reads use the member resolved from UserInfo only.
    public PortalMemberDto.LoyaltyStatus getLoyaltyStatus() {
        Id memberId = getCurrentMemberId();
        List<Account> members = loyaltyMemberSelector.getByIds(new Set<Id>{ memberId });
        if (members.isEmpty()) {
            throw new PortalNotMemberException('Account is not a loyalty member: ' + memberId);
        }
        Date today = PointsCalculator.toProgramDate(System.now());
        Integer qualifyingPoints = tierService.getQualifyingPoints(new Set<Id>{ memberId }).get(memberId);
        Integer threshold = tierService.getThreshold();

        PortalMemberDto.LoyaltyStatus status = new PortalMemberDto.LoyaltyStatus();
        status.isHighway = members[0].Loyalty_Tier__c == LoyaltyTierService.TIER_HIGHWAY;
        status.qualifyingPoints = qualifyingPoints;
        status.threshold = threshold;
        status.qualificationMonths = tierService.getQualificationMonths();
        status.pointsToHighway = Math.max(0, threshold - qualifyingPoints);
        status.progressPercent = Math.min(FULL_PROGRESS_PERCENT, (qualifyingPoints * FULL_PROGRESS_PERCENT) / threshold);
        status.fuelBonusPercent = tierService.getFuelBonusPercent();
        status.nextEvaluationDate = LoyaltyTierService.getNextEvaluationDate(today);
        PointExpiryService.Forecast forecast = expiryService.getForecast(memberId, today);
        status.expiringPoints = forecast?.points ?? 0;
        status.expiryDate = forecast?.expiryDate;
        return status;
    }

    private Account getCurrentMember() {
        Id memberId = getCurrentMemberId();
        List<Account> members = accountSelector.selectMembersByIds(new Set<Id>{ memberId });
        if (members.isEmpty()) {
            throw new PortalMemberException('Member account is not accessible for user ' + UserInfo.getUserId());
        }
        return members[0];
    }

    private Id getCurrentMemberId() {
        List<User> users = userSelector.selectByIds(new Set<Id>{ UserInfo.getUserId() });
        Id memberId = users.isEmpty() ? null : users[0].AccountId;
        if (memberId == null) {
            throw new PortalNotMemberException('Running user is not linked to a member account: ' + UserInfo.getUserId());
        }
        return memberId;
    }

    private PortalMemberDto.NextReward buildNextReward(List<Reward__c> rewards, Integer balance) {
        for (Reward__c reward : rewards) {
            Integer pointsCost = toInteger(reward.Points_Cost__c);
            if (pointsCost > balance) {
                PortalMemberDto.NextReward nextReward = new PortalMemberDto.NextReward();
                nextReward.name = reward.Name;
                nextReward.pointsCost = pointsCost;
                nextReward.pointsMissing = pointsCost - balance;
                nextReward.progressPercent = Math.max(0, Math.min(FULL_PROGRESS_PERCENT, (balance * FULL_PROGRESS_PERCENT) / pointsCost));
                return nextReward;
            }
        }
        return null;
    }

    private List<PortalMemberDto.Movement> toMovements(List<Point_Ledger__c> ledgerEntries) {
        List<PortalMemberDto.Movement> movements = new List<PortalMemberDto.Movement>();
        for (Point_Ledger__c entry : ledgerEntries) {
            PortalMemberDto.Movement movement = new PortalMemberDto.Movement();
            movement.id = entry.Id;
            movement.movementDate = entry.Occurred_At__c?.date();
            movement.type = entry.Entry_Type__c;
            movement.description = entry.Campaign__r?.Name;
            movement.points = toInteger(entry.Points__c);
            movements.add(movement);
        }
        return movements;
    }

    private static Integer toInteger(Decimal value) {
        return value == null ? 0 : value.intValue();
    }

    public class PortalMemberException extends Exception {
    }

    // Expected state (e.g. an admin previewing the site in Experience Builder), not a failure.
    public class PortalNotMemberException extends Exception {
    }
}
