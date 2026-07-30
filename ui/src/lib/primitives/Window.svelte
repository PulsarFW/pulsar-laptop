<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { AppId } from '../../config';
	import Icon from '../Icon.svelte';
	import { windowsState, closeApp, minimizeApp, focusApp } from '../store/windows.svelte';

	let {
		app,
		title,
		color,
		width = '100%',
		height = '100%',
		children,
	}: {
		app: AppId;
		title: string;
		color?: string;
		width?: string;
		height?: string;
		children: Snippet;
	} = $props();

	const draggable = $derived(width !== '100%' || height !== '100%');
	const focused = $derived(windowsState.focused === app);
	const win = $derived(windowsState.appStates.find((a) => a.app === app));

	let pos = $state({ x: 0, y: 0 });
	let dragging = false;
	let dragStart = { x: 0, y: 0, px: 0, py: 0 };

	function onTitlebarDown(e: PointerEvent) {
		if (!focused) focusApp(app);
		if (!draggable) return;
		dragging = true;
		dragStart = { x: pos.x, y: pos.y, px: e.clientX, py: e.clientY };
		(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
	}

	function onTitlebarMove(e: PointerEvent) {
		if (!dragging) return;
		pos = { x: dragStart.x + (e.clientX - dragStart.px), y: dragStart.y + (e.clientY - dragStart.py) };
	}

	function onTitlebarUp() {
		dragging = false;
	}
</script>

<div
	class="window"
	class:focused
	class:hidden={win?.minimized}
	style:max-width={width}
	style:max-height={height}
	style:transform={draggable ? `translate(${pos.x}px, ${pos.y}px)` : undefined}
	style:z-index={focused ? 200 : 100}
	style:--window-border={focused ? color : undefined}
	role="dialog"
	aria-label={title}
	tabindex="-1"
	onpointerdown={() => !focused && focusApp(app)}
>
	<div
		class="titlebar"
		role="presentation"
		style:background={focused ? color : undefined}
		onpointerdown={onTitlebarDown}
		onpointermove={onTitlebarMove}
		onpointerup={onTitlebarUp}
	>
		<span class="title">{title}</span>
		<div class="actions">
			<button type="button" class="action" onclick={() => minimizeApp(app)} aria-label="Minimize">
				<Icon name="minus" size="0.85em" />
			</button>
			<button type="button" class="action" onclick={() => closeApp(app)} aria-label="Close">
				<Icon name="xmark" size="0.9em" />
			</button>
		</div>
	</div>
	<div class="content">
		{@render children()}
	</div>
</div>

<style>
	.window {
		position: absolute;
		/* floats over the desktop with a margin on every side instead of blanking it out
		   edge-to-edge - wallpaper/Home stay visible around the window */
		inset: 1.1rem;
		width: auto;
		height: auto;
		display: flex;
		flex-direction: column;
		background: var(--color-bg-panel);
		border: var(--window-border, rgba(232, 232, 236, 0.14)) 2px solid;
		border-radius: 10px;
		box-shadow: 0 12px 32px rgba(0, 0, 0, 0.45);
		overflow: hidden;
		pointer-events: auto;
	}

	.window.hidden {
		visibility: hidden;
		pointer-events: none;
	}

	.titlebar {
		height: 2.8rem;
		flex-shrink: 0;
		display: flex;
		align-items: center;
		background: var(--color-bg-panel-alt);
		user-select: none;
		cursor: default;
	}

	.window.focused .titlebar {
		background: var(--color-primary-dark);
	}

	.title {
		flex: 1;
		padding-left: 0.9rem;
		font-family: var(--font-heading);
		font-size: 0.85rem;
	}

	.actions {
		display: flex;
	}

	.action {
		height: 2.8rem;
		width: 3rem;
		background: transparent;
		border: none;
		color: var(--color-text);
		cursor: pointer;
		transition: background 120ms ease;
	}

	.action:hover {
		background: rgba(255, 255, 255, 0.1);
	}

	.content {
		flex: 1;
		overflow: auto;
		background: var(--color-bg);
	}
</style>
