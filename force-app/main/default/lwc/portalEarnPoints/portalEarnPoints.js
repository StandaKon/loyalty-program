import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getActivities from '@salesforce/apex/PortalActivityController.getActivities';
import { PAGES, formatPoints, isNotMemberError } from 'c/portalUtils';
import LABEL_TITLE from '@salesforce/label/c.Portal_Nav_EarnPoints';
import LABEL_INTRO from '@salesforce/label/c.Portal_EarnPoints_Intro';
import LABEL_NOT_MEMBER from '@salesforce/label/c.Portal_State_NotMember';
import LABEL_PROFILE_TITLE from '@salesforce/label/c.Portal_Activity_Profile_Title';
import LABEL_PROFILE_TEXT from '@salesforce/label/c.Portal_Activity_Profile_Text';
import LABEL_MARKETING_TITLE from '@salesforce/label/c.Portal_Activity_Marketing_Title';
import LABEL_MARKETING_TEXT from '@salesforce/label/c.Portal_Activity_Marketing_Text';
import LABEL_DONE from '@salesforce/label/c.Portal_Activity_Done';
import LABEL_OPEN from '@salesforce/label/c.Portal_Activity_Open';
import LABEL_GO_TO_PROFILE from '@salesforce/label/c.Portal_Activity_GoToProfile';

export default class PortalEarnPoints extends NavigationMixin(LightningElement) {
    activities;
    isLoading = true;
    hasError = false;
    isNotMember = false;

    labels = {
        title: LABEL_TITLE,
        intro: LABEL_INTRO,
        notMember: LABEL_NOT_MEMBER,
        goToProfile: LABEL_GO_TO_PROFILE
    };

    connectedCallback() {
        this.loadActivities();
    }

    async loadActivities() {
        this.isLoading = true;
        this.hasError = false;
        this.isNotMember = false;
        try {
            this.activities = await getActivities();
        } catch (error) {
            this.activities = undefined;
            this.isNotMember = isNotMemberError(error);
            this.hasError = !this.isNotMember;
        } finally {
            this.isLoading = false;
        }
    }

    get activityItems() {
        return [
            this.buildItem('profile', LABEL_PROFILE_TITLE, LABEL_PROFILE_TEXT, this.activities.profileBonusPoints, this.activities.hasProfileBonus),
            this.buildItem('marketing', LABEL_MARKETING_TITLE, LABEL_MARKETING_TEXT, this.activities.marketingBonusPoints, this.activities.hasMarketingBonus)
        ];
    }

    buildItem(key, title, text, points, isDone) {
        return {
            key,
            title,
            text,
            pointsLabel: `+${formatPoints(points)}`,
            isOpen: !isDone,
            statusLabel: isDone ? LABEL_DONE : LABEL_OPEN,
            statusClass: isDone ? 'activity__status activity__status_done' : 'activity__status'
        };
    }

    handleGoToProfile() {
        this[NavigationMixin.Navigate]({ type: 'comm__namedPage', attributes: { name: PAGES.profile } });
    }
}
