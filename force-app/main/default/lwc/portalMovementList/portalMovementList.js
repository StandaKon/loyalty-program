import { LightningElement, api } from 'lwc';
import { formatDate, formatSignedPoints, movementTypeLabel } from 'c/portalUtils';

export default class PortalMovementList extends LightningElement {
    @api movements = [];

    get rows() {
        return (this.movements ?? []).map((movement, index) => ({
            id: movement.id ?? `movement-${index}`,
            typeLabel: movementTypeLabel(movement.type),
            description: movement.description,
            dateLabel: formatDate(movement.movementDate),
            pointsLabel: formatSignedPoints(movement.points),
            pointsClass: movement.points < 0 ? 'movement__points movement__points_minus' : 'movement__points movement__points_plus'
        }));
    }
}
