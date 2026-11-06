import { LightningElement } from 'lwc';
import getPointHistory from '@salesforce/apex/PortalMemberController.getPointHistory';
import LABEL_TITLE from '@salesforce/label/c.Portal_History_Title';
import LABEL_EMPTY from '@salesforce/label/c.Portal_History_Empty';
import LABEL_LOAD_MORE from '@salesforce/label/c.Portal_History_LoadMore';
import LABEL_NOT_MEMBER from '@salesforce/label/c.Portal_State_NotMember';
import { isNotMemberError } from 'c/portalUtils';

const PAGE_SIZE = 20;

export default class PortalPointHistory extends LightningElement {
    movements = [];
    pageNumber = 0;
    hasMore = false;
    isLoading = false;
    hasError = false;
    isNotMember = false;

    labels = { title: LABEL_TITLE, empty: LABEL_EMPTY, loadMore: LABEL_LOAD_MORE, notMember: LABEL_NOT_MEMBER };

    connectedCallback() {
        this.loadNextPage();
    }

    get hasMovements() {
        return this.movements.length > 0;
    }

    get isEmpty() {
        return !this.hasMovements;
    }

    handleLoadMore() {
        this.loadNextPage();
    }

    handleRetry() {
        this.loadNextPage();
    }

    async loadNextPage() {
        if (this.isLoading) {
            return;
        }
        this.isLoading = true;
        this.hasError = false;
        const nextPageNumber = this.pageNumber + 1;
        try {
            const page = await getPointHistory({ pageSize: PAGE_SIZE, pageNumber: nextPageNumber });
            this.movements = [...this.movements, ...(page?.movements ?? [])];
            this.hasMore = page?.hasMore === true;
            this.pageNumber = nextPageNumber;
        } catch (error) {
            this.isNotMember = isNotMemberError(error);
            this.hasError = !this.isNotMember;
        } finally {
            this.isLoading = false;
        }
    }
}
