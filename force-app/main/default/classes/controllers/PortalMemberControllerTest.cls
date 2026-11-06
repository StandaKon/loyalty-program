@IsTest
private class PortalMemberControllerTest {
    private static final List<Integer> MEMBER_A_POINTS = new List<Integer>{ 109, 54, 50, 20, 15, 7 };
    private static final List<Integer> MEMBER_B_POINTS = new List<Integer>{ 300, 200 };

    @TestSetup
    static void setup() {
        User owner = PortalTestDataFactory.createAccountOwner();
        System.runAs(owner) {
            Account memberA = PortalTestDataFactory.buildMember('Alena');
            Account memberB = PortalTestDataFactory.buildMember('Bohdan');
            insert new List<Account>{ memberA, memberB };

            List<Point_Ledger__c> entries = PortalTestDataFactory.buildLedgerEntries(memberA.Id, MEMBER_A_POINTS);
            entries.addAll(PortalTestDataFactory.buildLedgerEntries(memberB.Id, MEMBER_B_POINTS));
            insert entries;

            PortalTestDataFactory.createPortalUser(memberA);
            PortalTestDataFactory.createPortalUser(memberB);
        }
    }

    private static User getPortalUser(String firstName) {
        return [SELECT Id, AccountId FROM User WHERE Contact.FirstName = :firstName AND IsActive = TRUE LIMIT 1];
    }

    @IsTest
    static void shouldShowOnlyOwnData_WhenMemberIsLoggedIn() {
        User memberA = getPortalUser('Alena');
        Id memberBAccountId = getPortalUser('Bohdan').AccountId;
        Integer expectedBalance = 0;
        for (Integer points : MEMBER_A_POINTS) {
            expectedBalance += points;
        }

        PortalMemberDto.Overview overview;
        PortalMemberDto.HistoryPage history;
        List<PortalMemberDto.Campaign> campaigns;
        List<Point_Ledger__c> foreignLedger;
        System.runAs(memberA) {
            Test.startTest();
            overview = PortalMemberController.getOverview();
            history = PortalMemberController.getPointHistory(50, 1);
            campaigns = PortalMemberController.getActiveCampaigns();
            foreignLedger = [SELECT Id FROM Point_Ledger__c WHERE Member__c = :memberBAccountId WITH USER_MODE];
            Test.stopTest();
        }

        Assert.areEqual('Alena', overview.firstName, 'Overview should belong to the logged-in member');
        Assert.areEqual(expectedBalance, overview.balance, 'Balance should equal the roll-up of own ledger');
        Assert.areEqual(PortalMemberService.RECENT_MOVEMENTS_LIMIT, overview.recentMovements.size(), 'Overview shows the last 5 movements');
        Assert.areEqual(MEMBER_A_POINTS.size(), history.totalCount, 'History counts only own movements');
        Assert.isNotNull(campaigns, 'Campaign list should be returned');
        Assert.isTrue(foreignLedger.isEmpty(), 'Member A must not see member B ledger');
    }

    @IsTest
    static void shouldShowRoadTierWithoutExpiry_WhenMemberHasOnlyRecentAdjustments() {
        // Given: adjustments neither qualify for a tier nor are old enough to expire
        Integer threshold = Loyalty_Settings__mdt.getInstance('Default').Tier_Highway_Threshold__c.intValue();
        PortalMemberDto.LoyaltyStatus status;

        // When
        System.runAs(getPortalUser('Alena')) {
            Test.startTest();
            status = PortalMemberController.getLoyaltyStatus();
            Test.stopTest();
        }

        // Then
        Assert.isFalse(status.isHighway, 'New member starts on Road');
        Assert.areEqual(0, status.qualifyingPoints, 'Adjustments do not qualify');
        Assert.areEqual(threshold, status.pointsToHighway, 'Whole threshold is missing');
        Assert.areEqual(0, status.expiringPoints, 'Recent points do not expire within the warning window');
    }

    @IsTest
    static void shouldShowActiveRewardsWithAffordability_WhenMemberOpensCatalog() {
        // Given
        Integer balance = 0;
        for (Integer points : MEMBER_A_POINTS) {
            balance += points;
        }
        Account partner = new Account(Name = 'EneServis Test', Type = 'Partner');
        insert partner;
        Reward__c affordable = buildReward(partner.Id, 'Affordable reward', balance - 1, true, 1);
        Reward__c expensive = buildReward(partner.Id, 'Expensive reward', balance + 100, true, 2);
        Reward__c inactive = buildReward(partner.Id, 'Inactive reward', 1, false, null);
        insert new List<Reward__c>{ affordable, expensive, inactive };

        // When
        PortalMemberDto.RewardCatalog catalog;
        System.runAs(getPortalUser('Alena')) {
            Test.startTest();
            catalog = PortalMemberController.getRewardCatalog();
            Test.stopTest();
        }

        // Then
        Assert.areEqual(balance, catalog.balance, 'Catalog shows the member balance');
        Assert.areEqual(2, catalog.rewards.size(), 'Only active rewards are listed');
        Assert.areEqual(affordable.Id, catalog.rewards[0].id, 'Rewards follow Sort_Order__c');
        Assert.isTrue(catalog.rewards[0].isAffordable, 'Reward within balance is affordable');
        Assert.areEqual(0, catalog.rewards[0].pointsMissing, 'Nothing missing for affordable reward');
        Assert.isFalse(catalog.rewards[1].isAffordable, 'Reward above balance is not affordable');
        Assert.areEqual(100, catalog.rewards[1].pointsMissing, 'Missing points = cost - balance');
    }

    private static Reward__c buildReward(Id partnerId, String name, Integer pointsCost, Boolean isActive, Integer sortOrder) {
        return new Reward__c(
            Name = name,
            Partner__c = partnerId,
            Points_Cost__c = pointsCost,
            Value_CZK__c = 200,
            Is_Active__c = isActive,
            Sort_Order__c = sortOrder,
            Description__c = name + ' terms'
        );
    }

    @IsTest
    static void shouldReturnNotMemberCode_WhenUserIsNotMember() {
        // Given
        User internalUser = PortalTestDataFactory.createAccountOwner();

        // When/Then
        System.runAs(internalUser) {
            Test.startTest();
            try {
                PortalMemberController.getOverview();
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException ex) {
                Assert.areEqual(PortalMemberController.ERROR_CODE_NOT_MEMBER, ex.getMessage(), 'Non-member must get the stable not-member code');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldReturnFriendlyError_WhenRequestFails() {
        System.runAs(getPortalUser('Alena')) {
            Test.startTest();
            try {
                PortalMemberController.getPointHistory(0, 1);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException ex) {
                Assert.areEqual(System.Label.Portal_Error_Generic, ex.getMessage(), 'Internal details must not reach the UI');
            }
            Test.stopTest();
        }
    }
}
