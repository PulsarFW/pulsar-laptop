import { handleDataMessage } from '../../store/data.svelte';
import { Nui } from '../../nui';

export function updateSetting(type: string, val: unknown) {
	Nui.updateSetting(type, val);
	handleDataMessage('UPDATE_DATA', { type: 'player', id: 'LaptopSettings', key: type, data: val });
}
