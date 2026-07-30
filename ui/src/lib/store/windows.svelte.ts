// windowed multi-app desktop: several apps can be open at once, each tracked by WindowState.
// Client-local only - nothing here is pushed from Lua, it's pure UI state (mirrors old's AppHandler reducer).

import type { AppId } from '../../config';
import type { WindowState } from '../types';

export const windowsState = $state({
	focused: null as AppId | null,
	appStates: [] as WindowState[],
});

export function openApp(app: AppId) {
	const existing = windowsState.appStates.find((a) => a.app === app);
	if (existing) {
		windowsState.appStates = windowsState.appStates.map((a) => (a.app === app ? { ...a, minimized: false } : a));
	} else {
		windowsState.appStates = [...windowsState.appStates, { app }];
	}
	windowsState.focused = app;
}

export function closeApp(app: AppId) {
	const remaining = windowsState.appStates.filter((a) => a.app !== app);
	windowsState.appStates = remaining;
	windowsState.focused = remaining[0] && !remaining[0].minimized ? remaining[0].app : null;
}

export function focusApp(app: AppId) {
	windowsState.focused = app;
}

export function minimizeApp(app: AppId) {
	windowsState.appStates = windowsState.appStates.map((a) => (a.app === app ? { ...a, minimized: true } : a));
	if (windowsState.focused === app) windowsState.focused = null;
}

export function restoreApp(app: AppId) {
	windowsState.appStates = windowsState.appStates.map((a) => (a.app === app ? { ...a, minimized: false } : a));
	windowsState.focused = app;
}

export function toggleMinimize(app: AppId) {
	if (windowsState.focused === app) minimizeApp(app);
	else restoreApp(app);
}

export function updateAppState(app: AppId, patch: Record<string, unknown>) {
	windowsState.appStates = windowsState.appStates.map((a) => (a.app === app ? { ...a, state: { ...a.state, ...patch } } : a));
}

export function closeAllApps() {
	windowsState.appStates = [];
	windowsState.focused = null;
}
