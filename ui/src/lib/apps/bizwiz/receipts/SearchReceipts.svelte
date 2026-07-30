<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Modal from '../../../primitives/Modal.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import ReceiptRow from './ReceiptRow.svelte';
	import { getBucket } from '../../../store/data.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { BusinessReceipt } from '../../../types';

	let { onNav }: { onNav: (id: string, data?: Record<string, unknown>) => void } = $props();

	const PER_PAGE = 6;

	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));
	const canCreate = $derived(!!(onDuty && jobPerms?.[onDuty]?.TABLET_CREATE_RECEIPT));
	const canClear = $derived(!!(onDuty && jobPerms?.[onDuty]?.TABLET_CLEAR_RECEIPT));

	let loading = $state(false);
	let receipts = $state<BusinessReceipt[]>([]);
	let search = $state('');
	let page = $state(1);
	let clearing = $state(false);

	async function refresh() {
		loading = true;
		const res = await Nui.businessReceiptSearch('');
		receipts = res || [];
		page = 1;
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		receipts
			.filter(
				(r) =>
					search === '' ||
					r.customerName.toLowerCase().includes(search.toLowerCase()) ||
					r.type.toLowerCase().includes(search.toLowerCase()),
			)
			.sort((a, b) => b.time - a.time),
	);
	const pages = $derived(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
	const pageItems = $derived(filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE));

	async function confirmClearAll() {
		clearing = false;
		loading = true;
		const res = await Nui.businessReceiptDeleteAll();
		if (res) toast.success('Cleared Receipts');
		else toast.error('Unable to Clear Receipts');
		refresh();
	}
</script>

<div class="receipts">
	<div class="toolbar">
		<div class="search-input">
			<input type="text" placeholder="Search…" bind:value={search} />
			{#if search}
				<button type="button" onclick={() => (search = '')} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
		<button type="button" class="create" onclick={() => onNav('Create/Receipt')} disabled={!canCreate}>Create</button>
		{#if canClear}
			<button type="button" class="clear" onclick={() => (clearing = true)}>Clear All</button>
		{/if}
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if pageItems.length > 0}
			{#each pageItems as receipt (receipt._id)}
				<ReceiptRow {receipt} onClick={() => onNav('View/Receipt', { id: receipt._id })} />
			{/each}
			<Pagination bind:page {pages} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<Modal
	open={clearing}
	title="Clear Receipts"
	submitLabel="Clear All"
	submitVariant="danger"
	onClose={() => (clearing = false)}
	onSubmit={confirmClearAll}
>
	<p>Are you sure you want to clear <strong>ALL</strong> receipts? This is not reversible!</p>
</Modal>

<style>
	.receipts {
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

	.create,
	.clear {
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0 1rem;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.create:disabled {
		opacity: 0.4;
		cursor: default;
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
