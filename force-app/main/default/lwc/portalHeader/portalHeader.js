import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import isGuest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import { PAGES } from 'c/portalUtils';
import LABEL_OVERVIEW from '@salesforce/label/c.Portal_Nav_Overview';
import LABEL_HISTORY from '@salesforce/label/c.Portal_Nav_History';
import LABEL_CAMPAIGNS from '@salesforce/label/c.Portal_Nav_Campaigns';
import LABEL_EARN_POINTS from '@salesforce/label/c.Portal_Nav_EarnPoints';
import LABEL_REWARDS from '@salesforce/label/c.Portal_Nav_Rewards';
import LABEL_VOUCHERS from '@salesforce/label/c.Portal_Nav_Vouchers';
import LABEL_PROFILE from '@salesforce/label/c.Portal_Nav_Profile';
import LABEL_LOGIN from '@salesforce/label/c.Portal_Nav_Login';
import LABEL_REGISTER from '@salesforce/label/c.Portal_Nav_Register';
import LABEL_LOGOUT from '@salesforce/label/c.Portal_Nav_Logout';
import LABEL_MENU from '@salesforce/label/c.Portal_Nav_Menu';
import LABEL_HOME from '@salesforce/label/c.Portal_Nav_Home';
import LABEL_LOGO_ALT from '@salesforce/label/c.Portal_Header_LogoAlt';

const MEMBER_ITEMS = [
    { key: 'overview', label: LABEL_OVERVIEW },
    { key: 'history', label: LABEL_HISTORY },
    { key: 'campaigns', label: LABEL_CAMPAIGNS },
    { key: 'earnPoints', label: LABEL_EARN_POINTS },
    { key: 'rewards', label: LABEL_REWARDS },
    { key: 'vouchers', label: LABEL_VOUCHERS },
    { key: 'profile', label: LABEL_PROFILE }
];

const CMS_MEDIA_PATH = '/cms/delivery/media/';
const SITE_RESOURCE_PREFIX = '/sfsites/c';

const GUEST_ITEMS = [
    { key: 'login', label: LABEL_LOGIN },
    { key: 'register', label: LABEL_REGISTER }
];

export default class PortalHeader extends NavigationMixin(LightningElement) {
    @api logoUrl;

    isMember = !isGuest;
    isMenuOpen = false;
    currentPageName;
    homeUrl = `${basePath}/`;
    logoutUrl = `${basePath}/secur/logout.jsp`;

    labels = { logout: LABEL_LOGOUT, menu: LABEL_MENU, home: LABEL_HOME, logoAlt: LABEL_LOGO_ALT };

    @wire(CurrentPageReference)
    handlePageReference(pageReference) {
        this.currentPageName = pageReference?.attributes?.name;
        this.isMenuOpen = false;
    }

    get logoSrc() {
        if (!this.logoUrl) {
            return undefined;
        }
        // CMS media keys from Builder are relative to the site's resource path, not to the domain root.
        return this.logoUrl.startsWith(CMS_MEDIA_PATH) ? `${basePath}${SITE_RESOURCE_PREFIX}${this.logoUrl}` : this.logoUrl;
    }

    get navItems() {
        return (this.isMember ? MEMBER_ITEMS : GUEST_ITEMS).map((item) => {
            const isActive = PAGES[item.key] === this.currentPageName;
            return {
                ...item,
                cssClass: isActive ? 'nav__link nav__link_active' : 'nav__link',
                ariaCurrent: isActive ? 'page' : undefined
            };
        });
    }

    get navClass() {
        return this.isMenuOpen ? 'nav nav_open' : 'nav';
    }

    get menuExpanded() {
        return String(this.isMenuOpen);
    }

    handleToggleMenu() {
        this.isMenuOpen = !this.isMenuOpen;
    }

    handleNavigate(event) {
        const pageName = PAGES[event.currentTarget.dataset.page];
        if (!pageName) {
            return;
        }
        event.preventDefault();
        this.isMenuOpen = false;
        this[NavigationMixin.Navigate]({ type: 'comm__namedPage', attributes: { name: pageName } });
    }
}
