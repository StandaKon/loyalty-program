import { LightningElement } from 'lwc';
import LABEL_FUEL_TITLE from '@salesforce/label/c.Portal_Promo_Fuel_Title';
import LABEL_FUEL_TEXT from '@salesforce/label/c.Portal_Promo_Fuel_Text';
import LABEL_FUEL_BADGE from '@salesforce/label/c.Portal_Promo_Fuel_Badge';
import LABEL_FUEL_NOTE from '@salesforce/label/c.Portal_Promo_Fuel_Note';
import LABEL_SHOP_TITLE from '@salesforce/label/c.Portal_Promo_Shop_Title';
import LABEL_SHOP_TEXT from '@salesforce/label/c.Portal_Promo_Shop_Text';
import LABEL_SHOP_BADGE from '@salesforce/label/c.Portal_Promo_Shop_Badge';
import LABEL_APP_TITLE from '@salesforce/label/c.Portal_Promo_App_Title';
import LABEL_APP_TEXT from '@salesforce/label/c.Portal_Promo_App_Text';

/**
 * Static promo banners for the "Akce" portal page (visual mockup, no data binding).
 */
export default class PortalPromoBanners extends LightningElement {
    labels = {
        fuelTitle: LABEL_FUEL_TITLE,
        fuelText: LABEL_FUEL_TEXT,
        fuelBadge: LABEL_FUEL_BADGE,
        fuelNote: LABEL_FUEL_NOTE,
        shopTitle: LABEL_SHOP_TITLE,
        shopText: LABEL_SHOP_TEXT,
        shopBadge: LABEL_SHOP_BADGE,
        appTitle: LABEL_APP_TITLE,
        appText: LABEL_APP_TEXT
    };
}
