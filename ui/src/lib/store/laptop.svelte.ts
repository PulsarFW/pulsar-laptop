// top-level laptop shell state: visibility, server-driven app catalog, clock, permissions

import type { AppCatalog, LaptopPermissions, LaptopTime } from '../types';

export const laptopState = $state({
	visible: false,
	limited: false,
	clear: false,
	apps: {} as AppCatalog,
	permissions: null as LaptopPermissions | null,
	time: { hour: 4, minute: 20 } as LaptopTime,
});

export function handleLaptopMessage(type: string, data: unknown): boolean {
	switch (type) {
		case 'LAPTOP_VISIBLE':
			laptopState.visible = true;
			return true;
		case 'LAPTOP_NOT_VISIBLE':
			laptopState.visible = false;
			laptopState.limited = false;
			return true;
		case 'LAPTOP_NOT_VISIBLE_FORCED':
			laptopState.visible = false;
			laptopState.limited = false;
			return true;
		case 'SET_APPS':
			laptopState.apps = data as AppCatalog;
			return true;
		case 'LOAD_PERMS':
			laptopState.permissions = data as LaptopPermissions;
			return true;
		case 'SET_TIME':
			laptopState.time = data as LaptopTime;
			return true;
		case 'CLEAR_HISTORY':
			laptopState.clear = true;
			return true;
		default:
			return false;
	}
}
