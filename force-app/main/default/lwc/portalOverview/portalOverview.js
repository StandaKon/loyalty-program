import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOverview from '@salesforce/apex/PortalMemberController.getOverview';
import { PAGES, formatLabel, formatPoints, isNotMemberError } from 'c/portalUtils';
import LABEL_NOT_MEMBER from '@salesforce/label/c.Portal_State_NotMember';
import LABEL_GREETING from '@salesforce/label/c.Portal_Overview_Greeting';
import LABEL_GREETING_NO_NAME from '@salesforce/label/c.Portal_Overview_GreetingNoName';
import LABEL_BALANCE_TITLE from '@salesforce/label/c.Portal_Overview_BalanceTitle';
import LABEL_MEMBER_NUMBER from '@salesforce/label/c.Portal_Overview_MemberNumber';
import LABEL_POINTS_TO_REWARD from '@salesforce/label/c.Portal_Overview_PointsToReward';
import LABEL_ALL_REWARDS_REACHED from '@salesforce/label/c.Portal_Overview_AllRewardsReached';
import LABEL_RECENT_MOVEMENTS from '@salesforce/label/c.Portal_Overview_RecentMovements';
import LABEL_SHOW_ALL_HISTORY from '@salesforce/label/c.Portal_Overview_ShowAllHistory';
import LABEL_ACTIVE_CAMPAIGNS from '@salesforce/label/c.Portal_Overview_ActiveCampaigns';
import LABEL_SHOW_ALL_CAMPAIGNS from '@salesforce/label/c.Portal_Overview_ShowAllCampaigns';
import LABEL_HISTORY_EMPTY from '@salesforce/label/c.Portal_History_Empty';
import LABEL_CAMPAIGNS_EMPTY from '@salesforce/label/c.Portal_Campaigns_Empty';

export default class PortalOverview extends NavigationMixin(LightningElement) {
    overview;
    isLoading = true;
    hasError = false;
    isNotMember = false;

    labels = {
        notMember: LABEL_NOT_MEMBER,
        balanceTitle: LABEL_BALANCE_TITLE,
        allRewardsReached: LABEL_ALL_REWARDS_REACHED,
        recentMovements: LABEL_RECENT_MOVEMENTS,
        showAllHistory: LABEL_SHOW_ALL_HISTORY,
        activeCampaigns: LABEL_ACTIVE_CAMPAIGNS,
        showAllCampaigns: LABEL_SHOW_ALL_CAMPAIGNS,
        historyEmpty: LABEL_HISTORY_EMPTY,
        campaignsEmpty: LABEL_CAMPAIGNS_EMPTY
    };

    connectedCallback() {
        this.loadOverview();
    }

    async loadOverview() {
        this.isLoading = true;
        this.hasError = false;
        this.isNotMember = false;
        try {
            this.overview = await getOverview();
        } catch (error) {
            this.overview = undefined;
            this.isNotMember = isNotMemberError(error);
            this.hasError = !this.isNotMember;
        } finally {
            this.isLoading = false;
        }
    }

    get greeting() {
        return this.overview?.firstName ? formatLabel(LABEL_GREETING, this.overview.firstName) : LABEL_GREETING_NO_NAME;
    }

    get balanceLabel() {
        return formatPoints(this.overview?.balance);
    }

    get memberNumberLabel() {
        return this.overview?.memberNumber ? formatLabel(LABEL_MEMBER_NUMBER, this.overview.memberNumber) : undefined;
    }

    get hasNextReward() {
        return Boolean(this.overview?.nextReward);
    }

    get hasReachedAllRewards() {
        return this.overview?.hasReachedAllRewards === true;
    }

    get progressPercent() {
        return this.overview?.nextReward?.progressPercent ?? 0;
    }

    get progressStyle() {
        return `width: ${this.progressPercent}%`;
    }

    get nextRewardText() {
        const nextReward = this.overview?.nextReward;
        return nextReward ? formatLabel(LABEL_POINTS_TO_REWARD, formatPoints(nextReward.pointsMissing), nextReward.name) : '';
    }

    get hasMovements() {
        return this.overview?.recentMovements?.length > 0;
    }

    get hasCampaigns() {
        return this.overview?.activeCampaigns?.length > 0;
    }

    handleNavigate(event) {
        const pageName = PAGES[event.currentTarget.dataset.page];
        if (!pageName) {
            return;
        }
        this[NavigationMixin.Navigate]({ type: 'comm__namedPage', attributes: { name: pageName } });
    }
}
