import { createElement } from "lwc";
import MyVouchers from "c/myVouchers";
import getMyVouchers from "@salesforce/apex/RewardsPortalController.getMyVouchers";
jest.mock(
  "@salesforce/apex/RewardsPortalController.getMyVouchers",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return { default: createApexTestWireAdapter(jest.fn()) };
  },
  { virtual: true }
);
const flush = () => Promise.resolve();
describe("c-my-vouchers", () => {
  afterEach(() => {
    while (document.body.firstChild)
      document.body.removeChild(document.body.firstChild);
    jest.clearAllMocks();
  });
  it("renders vouchers and copies an active code", async () => {
    navigator.clipboard = { writeText: jest.fn().mockResolvedValue() };
    const element = createElement("c-my-vouchers", { is: MyVouchers });
    document.body.appendChild(element);
    getMyVouchers.emit([
      {
        id: "a",
        code: "ENE-ABCD-2345",
        status: "Issued",
        statusLabel: "Active",
        rewardName: "Reward",
        description: "Terms",
        partnerName: "EneServis",
        issuedAt: "2026-11-06T10:00:00Z"
      }
    ]);
    await flush();
    element.shadowRoot.querySelector("lightning-button-icon").click();
    await flush();
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith("ENE-ABCD-2345");
  });
  it("renders empty state", async () => {
    const element = createElement("c-my-vouchers", { is: MyVouchers });
    document.body.appendChild(element);
    getMyVouchers.emit([]);
    await flush();
    expect(element.shadowRoot.querySelector(".empty")).not.toBeNull();
  });
});
