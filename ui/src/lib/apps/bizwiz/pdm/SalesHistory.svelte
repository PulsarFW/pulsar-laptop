<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Modal from '../../../primitives/Modal.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import { CURRENCY } from '../../../../config';
	import { VEHICLE_CATEGORIES, categoryLabel } from './categories';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { OwnerInfo, SalesHistoryEntry } from '../../../types';

	let search = $state('');
	let category = $state('all');
	let page = $state(1);
	let pages = $state(1);
	let loading = $state(false);
	let results = $state<SalesHistoryEntry[]>([]);
	let viewing = $state<SalesHistoryEntry | null>(null);
	let owner = $state<OwnerInfo | null>(null);

	async function fetchPage(p: number) {
		loading = true;
		page = p;
		const res = await Nui.pdmGetHistory(search, category, p);
		if (res) {
			results = res.data;
			pages = res.more ? p + 1 : p;
		} else {
			results = [];
		}
		loading = false;
	}

	$effect(() => {
		void search;
		void category;
		fetchPage(1);
	});

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 3600) return `${Math.max(1, Math.floor(diff / 60))}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}

	async function lookupOwner(vin: string) {
		const res = await Nui.pdmGetOwner(vin);
		if (res) owner = res;
		else toast.error('Error');
	}
</script>

<div class="history">
	<div class="toolbar">
		<select bind:value={category}>
			{#each VEHICLE_CATEGORIES as c (c.value)}
				<option value={c.value}>{c.label}</option>
			{/each}
		</select>
		<div class="search-input">
			<input type="text" placeholder="Search…" bind:value={search} />
			{#if search}
				<button type="button" onclick={() => (search = '')} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if results.length > 0}
			{#each [...results].sort((a, b) => b.time - a.time) as entry (entry._id)}
				<div class="row" role="button" tabindex="0" onclick={() => (viewing = entry)} onkeydown={(e) => e.key === 'Enter' && (viewing = entry)}>
					<span class="col">
						<span class="label">Type</span>
						<span class="value">{entry.type === 'loan' ? 'Loan' : 'Cash'}</span>
					</span>
					<span class="col wide">
						<span class="label">Vehicle</span>
						<span class="value">{entry.vehicle.data.make} {entry.vehicle.data.model} ({entry.vehicle.data.class})</span>
					</span>
					<span class="col">
						<span class="label">Category</span>
						<span class="value">{categoryLabel(entry.vehicle.data.category)}</span>
					</span>
					<span class="col">
						<span class="label">Sale Price</span>
						<span class="value">{CURRENCY.format(entry.salePrice)} <small>({CURRENCY.format(entry.commission)})</small></span>
					</span>
					<span class="col">
						<span class="label">Seller</span>
						<span class="value">{entry.seller.First} {entry.seller.Last} ({entry.seller.SID})</span>
					</span>
					<span class="col">
						<span class="label">Buyer</span>
						<span class="value">{entry.buyer.First} {entry.buyer.Last} ({entry.buyer.SID})</span>
					</span>
					<span class="col">
						<span class="label">Time</span>
						<span class="value">{timeAgo(entry.time)}</span>
					</span>
					<button
						type="button"
						class="lookup"
						onclick={(e) => {
							e.stopPropagation();
							lookupOwner(entry.vehicle.VIN);
						}}
						aria-label="Look up current owner"
					>
						<Icon name="magnifying-glass" size="0.8em" />
					</button>
				</div>
			{/each}
			<Pagination {page} {pages} onChange={fetchPage} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<Modal
	open={!!viewing}
	title={viewing ? `${viewing.vehicle.data.make} ${viewing.vehicle.data.model}` : ''}
	submitLabel="Close"
	onClose={() => (viewing = null)}
	onSubmit={() => (viewing = null)}
>
	{#if viewing}
		<p>Sold for {CURRENCY.format(viewing.salePrice)} ({viewing.type === 'loan' ? 'Loan' : 'Cash'})</p>
		<p>Seller: {viewing.seller.First} {viewing.seller.Last} ({viewing.seller.SID})</p>
		<p>Buyer: {viewing.buyer.First} {viewing.buyer.Last} ({viewing.buyer.SID})</p>
		<p>VIN: {viewing.vehicle.VIN}</p>
	{/if}
</Modal>

<Modal open={!!owner} title="Current Ownership" submitLabel="Okay" onClose={() => (owner = null)} onSubmit={() => (owner = null)}>
	{#if owner}
		<p>Vehicle: {owner.Make} {owner.Model}</p>
		<p>Vehicle VIN: {owner.VIN}</p>
		<p>Current Owner: {owner.OwnerName}</p>
	{/if}
</Modal>

<style>
	.history {
		height: 100%;
		display: flex;
		flex-direction: column;
		padding: 1rem 0.6rem 1rem 1rem;
	}

	.toolbar {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 0.7rem;
		flex-shrink: 0;
	}

	select {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem;
		font-size: 0.78rem;
		flex: 0 0 8rem;
	}

	.search-input {
		flex: 1;
		position: relative;
	}

	.search-input input {
		width: 100%;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem 1.8rem 0.4rem 0.5rem;
		font-size: 0.78rem;
	}

	.search-input button {
		position: absolute;
		right: 0.4rem;
		top: 50%;
		transform: translateY(-50%);
		background: transparent;
		border: none;
		color: var(--color-text-muted);
		cursor: pointer;
	}

	.results {
		flex: 1;
		overflow-y: auto;
	}

	.row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.6rem;
		padding: 0.7rem;
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

	.col {
		display: flex;
		flex-direction: column;
		min-width: 0;
		flex: 1;
	}

	.col.wide {
		flex: 1.6;
	}

	.label {
		font-size: 0.65rem;
		color: var(--color-text-muted);
	}

	.value {
		font-size: 0.76rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.value small {
		color: var(--color-text-muted);
	}

	.lookup {
		width: 1.8rem;
		height: 1.8rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(139, 92, 246, 0.15);
		color: var(--color-primary-light);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
