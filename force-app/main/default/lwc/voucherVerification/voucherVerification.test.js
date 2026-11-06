import { createElement } from "lwc";
import VoucherVerification from "c/voucherVerification";
import findVoucher from "@salesforce/apex/VoucherVerificationController.findVoucher";
import redeemVoucher from "@salesforce/apex/VoucherVerificationController.redeemVoucher";
jest.mock(
  "@salesforce/apex/VoucherVerificationController.findVoucher",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/VoucherVerificationController.redeemVoucher",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
const flush = () => Promise.resolve();
describe("c-voucher-verification", () => {
  afterEach(() => {
    while (document.body.firstChild)
      document.body.removeChild(document.body.firstChild);
    jest.clearAllMocks();
  });
  it("finds and redeems an active voucher", async () => {
    const element = createElement("c-voucher-verification", {
      is: VoucherVerification
    });
    document.body.appendChild(element);
    findVoucher.mockResolvedValue({
      code: "ENE-ABCD-2345",
      statusLabel: "Active",
      rewardName: "Reward",
      canRedeem: true
    });
    const input = element.shadowRoot.querySelector("lightning-input");
    input.value = "ENE-ABCD-2345";
    input.dispatchEvent(new CustomEvent("change"));
    element.shadowRoot.querySelector("lightning-button").click();
    await flush();
    await flush();
    expect(findVoucher).toHaveBeenCalledWith({ code: "ENE-ABCD-2345" });
    redeemVoucher.mockResolvedValue({
      code: "ENE-ABCD-2345",
      statusLabel: "Redeemed",
      rewardName: "Reward",
      canRedeem: false
    });
    const details = element.shadowRoot.querySelectorAll("[data-validate]");
    details[0].reportValidity = jest.fn(() => true);
    details[1].reportValidity = jest.fn(() => true);
    details[0].value = "Prague";
    details[0].dispatchEvent(new CustomEvent("change"));
    details[1].value = "SO-123";
    details[1].dispatchEvent(new CustomEvent("change"));
    element.shadowRoot.querySelectorAll("lightning-button")[1].click();
    await flush();
    await flush();
    expect(redeemVoucher).toHaveBeenCalledWith({
      code: "ENE-ABCD-2345",
      serviceLocation: "Prague",
      serviceOrderNumber: "SO-123"
    });
  });
  it("shows lookup errors", async () => {
    const element = createElement("c-voucher-verification", {
      is: VoucherVerification
    });
    document.body.appendChild(element);
    findVoucher.mockRejectedValue({ body: { message: "Denied" } });
    const input = element.shadowRoot.querySelector("lightning-input");
    input.value = "ENE-ABCD-2345";
    input.dispatchEvent(new CustomEvent("change"));
    element.shadowRoot.querySelector("lightning-button").click();
    await flush();
    await flush();
    expect(
      element.shadowRoot.querySelector('[role="alert"]').textContent
    ).toContain("Denied");
  });
});
