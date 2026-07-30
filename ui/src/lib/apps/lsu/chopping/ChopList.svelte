<script lang="ts">
	import ChopItem from './ChopItem.svelte';
	import Modal from '../../../primitives/Modal.svelte';
	import type { ChopListData } from '../../../types';

	let { chopList }: { chopList: ChopListData | null } = $props();

	let open = $state<string | null>(null);

	const openGroup = $derived(open ? chopList?.[open] : null);
	const sortedList = $derived([...(openGroup?.list ?? [])].sort((a, b) => Number(b.hv) - Number(a.hv)));
</script>

<div class="choplist">
	{#if !chopList}
		<div class="empty">Loading…</div>
	{:else}
		{#each Object.entries(chopList) as [key, group] (key)}
			<button type="button" class="row" onclick={() => (open = key)}>
				<span class="value">{group.id ? key : `${key} Chop List`}</span>
				{#if group.public}
					<span class="sub">Shared Chop List - {group.list.length} Remaining {group.list.length > 1 ? 'Vehicles' : 'Vehicle'}</span>
				{:else if group.id}
					<span class="sub">Personal Chop List - {group.list.length} Remaining {group.list.length > 1 ? 'Vehicles' : 'Vehicle'}</span>
				{/if}
			</button>
		{/each}
	{/if}
</div>

<Modal open={!!open} title={open ? `${open} Chop List` : ''} onClose={() => (open = null)}>
	{#each sortedList as chop (chop.name)}
		<ChopItem {chop} />
	{/each}
</Modal>

<style>
	.choplist {
		height: 100%;
		overflow-y: auto;
		padding: 0.8rem;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}

	.row {
		width: 100%;
		display: flex;
		flex-direction: column;
		align-items: flex-start;
		gap: 0.2rem;
		padding: 0.7rem 0.5rem;
		background: transparent;
		border: none;
		border-bottom: var(--border-subtle);
		text-align: left;
		cursor: pointer;
		color: var(--color-text);
	}

	.row:hover {
		background: var(--color-bg-panel-alt);
	}

	.value {
		font-size: 0.85rem;
	}

	.sub {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}
</style>
