<!-- app launcher grid - shows apps installed on this character's LaptopApps.home list, filtered by
	 state-based restrictions client-side (server is still the real gate once an app actually opens) -->
<script lang="ts">
	import type { AppId } from '../../config';
	import type { AppEntry } from '../types';
	import Icon from '../Icon.svelte';
	import { laptopState } from '../store/laptop.svelte';
	import { getBucket } from '../store/data.svelte';
	import { openApp } from '../store/windows.svelte';

	interface PlayerLike {
		States?: string[];
		LaptopApps?: { home?: AppId[]; installed?: AppId[] };
	}

	const player = $derived(getBucket<PlayerLike>('player'));

	function isUsable(entry: AppEntry): boolean {
		if (!entry.restricted?.state) return true;
		const required = Array.isArray(entry.restricted.state) ? entry.restricted.state : [entry.restricted.state];
		const states = player?.States ?? [];
		return required.every((s) => states.includes(s));
	}

	const homeApps = $derived(
		(player?.LaptopApps?.home ?? [])
			.map((id) => laptopState.apps[id])
			.filter((entry): entry is AppEntry => !!entry && isUsable(entry)),
	);

	function onClick(entry: AppEntry) {
		if (entry.fake) return;
		openApp(entry.name);
	}
</script>

<div class="home">
	<div class="grid">
		{#each homeApps as entry (entry.name)}
			<button type="button" class="app-btn" class:fake={entry.fake} title={entry.label} onclick={() => onClick(entry)}>
				<span class="app-icon" style:background={entry.color}>
					<Icon name={entry.icon} size="1.6rem" />
					{#if entry.unread > 0}
						<span class="badge">{entry.unread}</span>
					{/if}
				</span>
				<span class="app-label">{entry.label}</span>
			</button>
		{/each}
	</div>
</div>

<style>
	.home {
		height: 87%;
		padding: 0.6rem;
		overflow-y: auto;
		overflow-x: hidden;
	}

	.grid {
		display: flex;
		flex-wrap: wrap;
		align-content: flex-start;
		gap: 0.2rem;
	}

	.app-btn {
		width: 5.3rem;
		padding: 0.6rem;
		background: transparent;
		border: none;
		border-radius: var(--radius);
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.5rem;
		cursor: pointer;
		transition: background 150ms ease;
	}

	.app-btn:not(.fake):hover {
		background: rgba(139, 92, 246, 0.15);
	}

	.app-btn.fake {
		cursor: default;
	}

	.app-icon {
		position: relative;
		width: 3.2rem;
		height: 3.2rem;
		border-radius: 0.6rem;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #fff;
	}

	.badge {
		position: absolute;
		bottom: -0.3rem;
		right: -0.3rem;
		min-width: 1.2rem;
		height: 1.2rem;
		padding: 0 0.25rem;
		border-radius: 999px;
		background: var(--color-error);
		color: #fff;
		font-size: 0.65rem;
		line-height: 1.2rem;
		text-align: center;
	}

	.app-label {
		font-size: 0.7rem;
		text-align: center;
		text-shadow: 0 0 5px #000;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		max-width: 100%;
	}
</style>
