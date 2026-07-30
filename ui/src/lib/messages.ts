import { handleDataMessage } from './store/data.svelte';
import { handleLaptopMessage, laptopState } from './store/laptop.svelte';
import { handleNotificationMessage } from './store/notifications.svelte';
import { closeAllApps } from './store/windows.svelte';

export function handleMessage(type: string, data: unknown) {
	if (handleLaptopMessage(type, data)) return;
	if (handleDataMessage(type, data)) return;
	if (handleNotificationMessage(type, data)) return;

	switch (type) {
		case 'UI_RESET':
			laptopState.visible = false;
			closeAllApps();
			return;
		case 'CLOSE_ALL_APPS':
			closeAllApps();
			return;
	}
}

export function startMessageListener() {
	window.addEventListener('message', (event: MessageEvent) => {
		const { type, data } = event.data ?? {};
		if (typeof type !== 'string') return;
		handleMessage(type, data);
	});
}
