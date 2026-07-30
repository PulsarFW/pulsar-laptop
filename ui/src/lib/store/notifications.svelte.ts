import type { NotificationItem } from '../types';

export const notificationsState = $state({
	notifications: [] as NotificationItem[],
});

let nextLocalId = 1;

export function handleNotificationMessage(type: string, data: unknown): boolean {
	switch (type) {
		case 'NOTIF_ADD': {
			const incoming = (data as { notification: NotificationItem }).notification;
			const existing = incoming._id != null && notificationsState.notifications.find((n) => n._id === incoming._id);
			if (existing) {
				notificationsState.notifications = notificationsState.notifications.map((n) =>
					n._id === incoming._id ? { ...incoming, collapsed: false } : n,
				);
			} else {
				notificationsState.notifications = [
					{ ...incoming, _id: incoming._id ?? nextLocalId++, collapsed: false },
					...notificationsState.notifications,
				];
			}
			return true;
		}
		case 'NOTIF_UPDATE': {
			const payload = data as { id: number | string; title: string; description: string };
			notificationsState.notifications = notificationsState.notifications.map((n) =>
				n._id === payload.id ? { ...n, title: payload.title, description: payload.description, collapsed: false } : n,
			);
			return true;
		}
		case 'NOTIF_HIDE': {
			const payload = data as { id: number | string };
			notificationsState.notifications = notificationsState.notifications.map((n) =>
				n._id === payload.id ? { ...n, show: false } : n,
			);
			return true;
		}
		case 'NOTIF_DISMISS_ALL':
			notificationsState.notifications = [];
			return true;
		case 'ALERTS_RESET':
			notificationsState.notifications = [];
			return true;
		default:
			return false;
	}
}

export function dismissNotification(id: number | string) {
	notificationsState.notifications = notificationsState.notifications.filter((n) => n._id !== id);
}
