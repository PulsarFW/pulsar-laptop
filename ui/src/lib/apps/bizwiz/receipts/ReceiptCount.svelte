<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import ReceiptCountRow from './ReceiptCountRow.svelte';
	import { Nui } from '../../../nui';
	import type { BusinessAuthor, BusinessReceipt, ReceiptCountEntry } from '../../../types';

	const PER_PAGE = 6;

	let loading = $state(false);
	let results = $state<ReceiptCountEntry[]>([]);
	let search = $state('');
	let page = $state(1);

	async function refresh() {
		loading = true;
		const res = await Nui.businessReceiptSearch('');
		results = res ? tally(res) : [];
		page = 1;
		loading = false;
	}

	function tally(receipts: BusinessReceipt[]): ReceiptCountEntry[] {
		const counts = new Map<number, ReceiptCountEntry>();

		function bucket(char: BusinessAuthor): ReceiptCountEntry {
			let entry = counts.get(char.SID);
			if (!entry) {
				entry = { char, created: 0, assisted: 0, latest: 0, types: {} };
				counts.set(char.SID, entry);
			}
			return entry;
		}

		for (const receipt of [...receipts].sort((a, b) => a.time - b.time)) {
			if (receipt.author?.SID) {
				const entry = bucket(receipt.author);
				entry.created++;
				entry.latest = receipt.time;
				entry.types[receipt.type] = (entry.types[receipt.type] ?? 0) + 1;
			}
			for (const worker of receipt.workers ?? []) {
				const entry = bucket(worker);
				entry.assisted++;
				entry.latest = receipt.time;
				entry.types[receipt.type] = (entry.types[receipt.type] ?? 0) + 1;
			}
		}

		return Array.from(counts.values());
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		results.filter((r) => search === '' || `${r.char.First} ${r.char.Last}`.toLowerCase().includes(search.toLowerCase())),
	);
	const pages = $derived(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
	const pageItems = $derived(filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE));
</script>

<div class="counts">
	<div class="toolbar">
		<div class="search-input">
			<input type="text" placeholder="Search By Employee" bind:value={search} />
			{#if search}
				<button type="button" onclick={() => (search = '')} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
		<button type="button" class="refresh" onclick={refresh}>Refresh</button>
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if pageItems.length > 0}
			{#each pageItems as entry (entry.char.SID)}
				<ReceiptCountRow {entry} />
			{/each}
			<Pagination bind:page {pages} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<style>
	.counts {
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

	.refresh {
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0 1rem;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.results {
		flex: 1;
		overflow-y: auto;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
