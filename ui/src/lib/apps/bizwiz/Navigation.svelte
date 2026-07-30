<script lang="ts">
	import Icon from '../../Icon.svelte';
	import { getBucket } from '../../store/data.svelte';
	import type { BizWizPage } from '../../types';

	let { current, items, onSelect }: { current: string; items: BizWizPage[]; onSelect: (id: string) => void } = $props();

	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));

	function hasJobPerm(permission: string): boolean {
		if (!onDuty || !jobPerms) return false;
		return !!jobPerms[onDuty]?.[permission];
	}

	const visibleItems = $derived(items.filter((item) => !item.hidden && (!item.permission || hasJobPerm(item.permission))));
</script>

<nav class="nav">
	{#each visibleItems as item (item.id)}
		<button type="button" class="item" class:active={item.id === current} onclick={() => onSelect(item.id)}>
			{#if item.icon}
				<Icon name={item.icon[1]} size="0.95em" />
			{/if}
			<span>{item.label}</span>
		</button>
	{/each}
</nav>

<style>
	.nav {
		display: flex;
		flex-direction: column;
	}

	.item {
		display: flex;
		align-items: center;
		gap: 0.7rem;
		height: 2.6rem;
		padding: 0 0.9rem;
		background: transparent;
		border: none;
		color: var(--color-text-muted);
		text-align: left;
		font-size: 0.82rem;
		cursor: pointer;
		transition:
			color 120ms ease,
			background 120ms ease;
	}

	.item:hover {
		color: var(--color-text);
		background: rgba(255, 255, 255, 0.05);
	}

	.item.active {
		color: var(--color-primary-light);
		background: rgba(139, 92, 246, 0.12);
		border-left: 2px solid var(--color-primary);
	}
</style>
