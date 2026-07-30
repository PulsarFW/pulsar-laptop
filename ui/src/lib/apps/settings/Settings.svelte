<script lang="ts">
	import Icon from '../../Icon.svelte';
	import { getBucket } from '../../store/data.svelte';
	import { updateSetting } from './update';
	import Wallpaper from './pages/Wallpaper.svelte';
	import Colors from './pages/Colors.svelte';
	import Version from './components/Version.svelte';
	import type { LaptopSettings } from '../../types';

	let page = $state<'wallpaper' | 'colors' | null>(null);

	const settings = $derived(getBucket<{ LaptopSettings: LaptopSettings }>('player')?.LaptopSettings);

	function toggleNotifications() {
		updateSetting('notifications', !(settings?.notifications ?? true));
	}

	function volumeStep(delta: number) {
		const current = settings?.volume ?? 100;
		const next = Math.min(100, Math.max(0, current + delta));
		updateSetting('volume', next);
	}

	function toggleMute() {
		updateSetting('volume', (settings?.volume ?? 100) === 0 ? 100 : 0);
	}
</script>

{#if page}
	<div class="page">
		<div class="page-header">
			<button type="button" class="back" onclick={() => (page = null)}>
				<Icon name="chevron-left" size="0.85em" /> Back
			</button>
		</div>
		{#if page === 'wallpaper'}
			<Wallpaper />
		{:else if page === 'colors'}
			<Colors />
		{/if}
	</div>
{:else}
	<div class="settings">
		<div class="header">Settings</div>

		<div class="section-label">Notifications</div>
		<button type="button" class="row" onclick={toggleNotifications}>
			<span class="row-icon" style:background="#2e9e4f"><Icon name="bell" /></span>
			<span class="row-label">Notifications</span>
			<span class="switch" class:on={settings?.notifications}></span>
		</button>

		<div class="section-label">Personalization</div>
		<button type="button" class="row" onclick={() => (page = 'wallpaper')}>
			<span class="row-icon" style:background="#d8891e"><Icon name="image" /></span>
			<span class="row-label">Wallpaper</span>
			<Icon name="chevron-right" />
		</button>
		<button type="button" class="row" onclick={() => (page = 'colors')}>
			<span class="row-icon" style:background="#6a2ed8"><Icon name="swatchbook" /></span>
			<span class="row-label">Colors</span>
			<Icon name="chevron-right" />
		</button>

		<div class="section-label">Sound</div>
		<div class="row static">
			<span class="row-icon" style:background="#1e8fd8"><Icon name={(settings?.volume ?? 100) === 0 ? 'volume-xmark' : 'volume-high'} /></span>
			<span class="row-label">Volume</span>
			<div class="volume-controls">
				<button type="button" class="vol-btn" onclick={toggleMute} aria-label="Mute">
					<Icon name={(settings?.volume ?? 100) === 0 ? 'volume-xmark' : 'volume-high'} size="0.8em" />
				</button>
				<button type="button" class="vol-btn" onclick={() => volumeStep(-5)} aria-label="Decrease">
					<Icon name="minus" size="0.75em" />
				</button>
				<span class="vol-value">{settings?.volume ?? 100}%</span>
				<button type="button" class="vol-btn" onclick={() => volumeStep(5)} aria-label="Increase">+</button>
			</div>
		</div>

		<Version />
	</div>
{/if}

<style>
	.settings,
	.page {
		height: 100%;
		overflow-y: auto;
	}

	.header {
		padding: 1rem 0.9rem 0.4rem;
		font-family: var(--font-heading);
		font-size: 1.1rem;
	}

	.section-label {
		padding: 0.6rem 0.9rem 0.3rem;
		font-size: 0.72rem;
		text-transform: uppercase;
		letter-spacing: 0.04em;
		color: var(--color-text-muted);
	}

	.row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.7rem;
		padding: 0.7rem 0.9rem;
		background: transparent;
		border: none;
		color: var(--color-text);
		text-align: left;
		cursor: pointer;
		font-size: 0.85rem;
	}

	.row:not(.static):hover {
		background: var(--color-bg-panel-alt);
	}

	.row-icon {
		width: 1.9rem;
		height: 1.9rem;
		border-radius: 0.5rem;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #fff;
		flex-shrink: 0;
	}

	.row-label {
		flex: 1;
	}

	.switch {
		width: 2.2rem;
		height: 1.2rem;
		border-radius: 999px;
		background: rgba(255, 255, 255, 0.15);
		position: relative;
		transition: background 150ms ease;
	}

	.switch::after {
		content: '';
		position: absolute;
		top: 0.15rem;
		left: 0.15rem;
		width: 0.9rem;
		height: 0.9rem;
		border-radius: 50%;
		background: #fff;
		transition: transform 150ms ease;
	}

	.switch.on {
		background: var(--color-primary);
	}

	.switch.on::after {
		transform: translateX(1rem);
	}

	.volume-controls {
		display: flex;
		align-items: center;
		gap: 0.4rem;
	}

	.vol-btn {
		width: 1.6rem;
		height: 1.6rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(255, 255, 255, 0.08);
		color: var(--color-text);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.vol-value {
		font-size: 0.75rem;
		width: 2.4rem;
		text-align: center;
		color: var(--color-text-muted);
	}

	.page-header {
		padding: 0.6rem;
	}

	.back {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		background: transparent;
		border: none;
		color: var(--color-text);
		font-size: 0.8rem;
		cursor: pointer;
	}
</style>
