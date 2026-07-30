/*
	Pulsar Laptop content config.
	Server owners: for colors/fonts, edit theme.css instead.
*/

// The real app catalog (label/icon/color/restrictions) is server-driven via SET_APPS
export type AppId = 'lsunderground' | 'teams' | 'bizwiz' | 'settings' | 'internet' | 'files';

export const CURRENCY = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

export const NOTIFICATION_SOUND = 'notification1.ogg';
export const NOTIFICATION_DEFAULT_DURATION_MS = 8000;

export const CLOCK_POLL_INTERVAL_MS = 15000;
