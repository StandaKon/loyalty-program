import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getMyVouchers from "@salesforce/apex/RewardsPortalController.getMyVouchers";
import TITLE from "@salesforce/label/c.Loyalty_Vouchers_Title";
import INTRO from "@salesforce/label/c.Loyalty_Vouchers_Intro";
import EMPTY from "@salesforce/label/c.Loyalty_Vouchers_Empty";
import COPY from "@salesforce/label/c.Loyalty_Vouchers_Copy";
import COPIED from "@salesforce/label/c.Loyalty_Vouchers_Copied";
import { reduceError } from "c/loyaltyActionUtils";

export default class MyVouchers extends LightningElement {
  labels = { title: TITLE, intro: INTRO, empty: EMPTY, copy: COPY };
  vouchers = [];
  errorMessage;
  isLoading = true;
  @wire(getMyVouchers)
  wiredVouchers({ data, error }) {
    if (data) {
      this.vouchers = data;
      this.errorMessage = undefined;
    } else if (error) {
      this.vouchers = [];
      this.errorMessage = reduceError(error);
    }
    this.isLoading = false;
  }
  get displayVouchers() {
    return [...this.vouchers]
      .sort(
        (a, b) => Number(b.status === "Issued") - Number(a.status === "Issued")
      )
      .map((voucher) => ({
        ...voucher,
        isActive: voucher.status === "Issued",
        cssClass:
          voucher.status === "Issued"
            ? "voucher-card active"
            : "voucher-card inactive"
      }));
  }
  get hasVouchers() {
    return this.vouchers.length > 0;
  }
  get isEmpty() {
    return !this.isLoading && !this.errorMessage && !this.hasVouchers;
  }
  async handleCopy(event) {
    try {
      await navigator.clipboard.writeText(event.currentTarget.dataset.code);
      this.dispatchEvent(
        new ShowToastEvent({
          title: TITLE,
          message: COPIED,
          variant: "success"
        })
      );
    } catch (error) {
      this.errorMessage = reduceError(error);
    }
  }
}
