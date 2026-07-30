<script lang="ts">
	import { fly } from 'svelte/transition';
	import Home from './containers/Home.svelte';
	import Footer from './containers/Footer.svelte';
	import Notifications from './containers/Notifications.svelte';
	import Window from './primitives/Window.svelte';
	import Settings from './apps/settings/Settings.svelte';
	import Teams from './apps/teams/Teams.svelte';
	import BizWiz from './apps/bizwiz/BizWiz.svelte';
	import LSU from './apps/lsu/LSU.svelte';
	import Toast from './Toast.svelte';
	import { laptopState } from './store/laptop.svelte';
	import { windowsState } from './store/windows.svelte';
	import { getBucket } from './store/data.svelte';
	import { resolveWallpaper } from './wallpapers';
	import type { LaptopSettings } from './types';

	const settings = $derived(getBucket<{ LaptopSettings: LaptopSettings }>('player')?.LaptopSettings);
	const wallpaper = $derived(resolveWallpaper(settings?.wallpaper));
</script>

{#if laptopState.visible}
	<div class="frame" transition:fly={{ y: 60, duration: 220 }}>
		<img class="wallpaper" src={wallpaper} alt="" />

		<div class="screen">
			<Home />

			<div class="windows">
				{#each windowsState.appStates as win (win.app)}
					{@const entry = laptopState.apps[win.app]}
					{#if entry}
						<Window app={win.app} title={entry.label} color={entry.color}>
							{#if win.app === 'settings'}
								<Settings />
							{:else if win.app === 'teams'}
								<Teams />
							{:else if win.app === 'bizwiz'}
								<BizWiz />
							{:else if win.app === 'lsunderground'}
								<LSU />
							{:else}
								<div class="placeholder">{entry.label} is coming soon.</div>
							{/if}
						</Window>
					{/if}
				{/each}
			</div>

			<Notifications />
			<Toast />
		</div>

		<Footer />
	</div>
{/if}

<style>
	.frame {
		position: absolute;
		inset: 0;
		margin: auto;
		max-width: 1600px;
		max-height: 1000px;
		width: 100%;
		height: 100%;
		overflow: hidden;
		border: 6px solid #0f0f10;
		border-radius: 8px;
		pointer-events: auto;
		font-family: var(--font-body);
		display: flex;
		flex-direction: column;
	}

	.wallpaper {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		object-fit: cover;
		z-index: -1;
		user-select: none;
	}

	.screen {
		position: relative;
		flex: 1;
		overflow: hidden;
	}

	.windows {
		position: absolute;
		inset: 0;
		/* empty (or gapped) space here must stay click-through so Home underneath remains
		   clickable - each Window's own root opts back into pointer-events: auto */
		pointer-events: none;
	}

	.placeholder {
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
