import { createElement } from "lwc";
import RewardCatalogue from "c/rewardCatalogue";
import getCatalogue from "@salesforce/apex/RewardsPortalController.getCatalogue";
import redeem from "@salesforce/apex/RewardsPortalController.redeem";
jest.mock(
  "@salesforce/apex/RewardsPortalController.getCatalogue",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return { default: createApexTestWireAdapter(jest.fn()) };
  },
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/RewardsPortalController.redeem",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
const flush = () => Promise.resolve();
describe("c-reward-catalogue", () => {
  beforeEach(() => {
    global.crypto.randomUUID = jest.fn(
      () => "00000000-0000-4000-8000-000000000001"
    );
  });
  afterEach(() => {
    while (document.body.firstChild)
      document.body.removeChild(document.body.firstChild);
    jest.clearAllMocks();
  });
  it("renders available rewards and redeems a selected reward", async () => {
    const element = createElement("c-reward-catalogue", {
      is: RewardCatalogue
    });
    document.body.appendChild(element);
    getCatalogue.emit([
      {
        id: "a01000000000001",
        name: "Reward",
        description: "Terms",
        partnerName: "EneServis",
        pointsCost: 500,
        valueCzk: 200,
        memberBalance: 740,
        missingPoints: 0,
        canRedeem: true
      }
    ]);
    await flush();
    element.shadowRoot.querySelector("lightning-button[data-id]").click();
    await flush();
    redeem.mockResolvedValue({
      voucher: { code: "ENE-ABCD-2345" },
      balance: 240
    });
    element.shadowRoot
      .querySelector('.modal lightning-button[variant="brand"]')
      .click();
    await flush();
    await flush();
    expect(redeem).toHaveBeenCalledWith({
      rewardId: "a01000000000001",
      requestKey: "00000000-0000-4000-8000-000000000001"
    });
  });
  it("shows an error from the catalogue", async () => {
    const element = createElement("c-reward-catalogue", {
      is: RewardCatalogue
    });
    document.body.appendChild(element);
    getCatalogue.error({ body: { message: "Unavailable" } });
    await flush();
    expect(
      element.shadowRoot.querySelector('[role="alert"]').textContent
    ).toContain("Unavailable");
  });
});
