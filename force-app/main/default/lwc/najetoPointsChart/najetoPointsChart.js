import { LightningElement, api } from 'lwc';
import { formatNumber } from 'c/loyaltyActionUtils';
import TITLE from '@salesforce/label/c.Loyalty_Dash_Chart_Title';
import AWARDED from '@salesforce/label/c.Loyalty_Dash_Chart_Awarded';
import REDEEMED from '@salesforce/label/c.Loyalty_Dash_Chart_Redeemed';
import MONTH from '@salesforce/label/c.Loyalty_Dash_Chart_Month';
import SHOW_TABLE from '@salesforce/label/c.Loyalty_Dash_Show_Table';
import SHOW_CHART from '@salesforce/label/c.Loyalty_Dash_Show_Chart';

const WIDTH = 600;
const HEIGHT = 240;
const PLOT = { top: 16, right: 12, bottom: 28, left: 56 };
const BAR_GAP = 2;
const RADIUS = 4;
const GRID_LINES = 4;

const niceMax = (value) => {
    if (value <= 0) {
        return GRID_LINES;
    }
    const magnitude = 10 ** Math.floor(Math.log10(value));
    const step = [1, 2, 2.5, 5, 10].map((factor) => factor * magnitude).find((candidate) => candidate * GRID_LINES >= value);
    return step * GRID_LINES;
};

// Bar with rounded data end and square baseline end.
const barPath = (x, y, width, height) => {
    if (height <= 0) {
        return '';
    }
    const radius = Math.min(RADIUS, width / 2, height);
    const baseline = y + height;
    return `M${x},${baseline} V${y + radius} Q${x},${y} ${x + radius},${y} H${x + width - radius} Q${x + width},${y} ${x + width},${y + radius} V${baseline} Z`;
};

export default class NajetoPointsChart extends LightningElement {
    @api trend = [];

    labels = { TITLE, AWARDED, REDEEMED, MONTH };
    viewBox = `0 0 ${WIDTH} ${HEIGHT}`;
    isTableView = false;
    activeIndex;

    get toggleLabel() {
        return this.isTableView ? SHOW_CHART : SHOW_TABLE;
    }

    get monthFormatter() {
        return new Intl.DateTimeFormat('cs-CZ', { month: 'short', year: '2-digit', timeZone: 'UTC' });
    }

    get rows() {
        return (this.trend ?? []).map((point, index) => ({
            key: point.monthStart,
            index,
            month: this.monthFormatter.format(new Date(point.monthStart)),
            awarded: Number(point.awarded ?? 0),
            redeemed: Number(point.redeemed ?? 0),
            awardedText: formatNumber(point.awarded),
            redeemedText: formatNumber(point.redeemed)
        }));
    }

    get scaleMax() {
        return niceMax(Math.max(0, ...this.rows.flatMap((row) => [row.awarded, row.redeemed])));
    }

    get plotHeight() {
        return HEIGHT - PLOT.top - PLOT.bottom;
    }

    get gridLines() {
        return Array.from({ length: GRID_LINES + 1 }, (_, step) => {
            const value = (this.scaleMax / GRID_LINES) * step;
            const y = PLOT.top + this.plotHeight - (value / this.scaleMax) * this.plotHeight;
            return { key: `grid-${step}`, y, labelY: y + 4, label: formatNumber(value), x1: PLOT.left, x2: WIDTH - PLOT.right, labelX: PLOT.left - 8 };
        });
    }

    get groups() {
        const rows = this.rows;
        const slot = (WIDTH - PLOT.left - PLOT.right) / Math.max(rows.length, 1);
        const barWidth = Math.min(28, (slot * 0.6 - BAR_GAP) / 2);
        const scale = (value) => (value / this.scaleMax) * this.plotHeight;
        const baseline = PLOT.top + this.plotHeight;
        return rows.map((row) => {
            const center = PLOT.left + slot * row.index + slot / 2;
            const awardedHeight = scale(row.awarded);
            const redeemedHeight = scale(row.redeemed);
            const awardedX = center - barWidth - BAR_GAP / 2;
            const redeemedX = center + BAR_GAP / 2;
            return {
                ...row,
                hitX: PLOT.left + slot * row.index,
                hitWidth: slot,
                hitY: PLOT.top,
                hitHeight: this.plotHeight,
                awardedPath: barPath(awardedX, baseline - awardedHeight, barWidth, awardedHeight),
                redeemedPath: barPath(redeemedX, baseline - redeemedHeight, barWidth, redeemedHeight),
                labelX: center,
                labelY: HEIGHT - 8,
                isActive: row.index === this.activeIndex,
                hitClass: row.index === this.activeIndex ? 'hit hit_active' : 'hit',
                ariaLabel: `${row.month}: ${AWARDED} ${row.awardedText}, ${REDEEMED} ${row.redeemedText}`
            };
        });
    }

    get activeRow() {
        return this.groups.find((group) => group.isActive);
    }

    get tooltipStyle() {
        const group = this.activeRow;
        if (!group) {
            return 'display:none';
        }
        const leftPercent = ((group.hitX + group.hitWidth / 2) / WIDTH) * 100;
        const alignRight = leftPercent > 70;
        return `left:${leftPercent}%;transform:translateX(${alignRight ? '-100%' : '-50%'})`;
    }

    handleEnter(event) {
        this.activeIndex = Number(event.currentTarget.dataset.index);
    }

    handleLeave() {
        this.activeIndex = undefined;
    }

    handleToggle() {
        this.isTableView = !this.isTableView;
    }
}
