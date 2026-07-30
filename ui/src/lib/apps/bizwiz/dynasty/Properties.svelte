<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import PropertyRow from './PropertyRow.svelte';
	import SaleFormModal from './SaleFormModal.svelte';
	import TransferFormModal from './TransferFormModal.svelte';
	import InfoModal from './InfoModal.svelte';
	import ConstructionModal from './ConstructionModal.svelte';
	import { PROPERTY_CATEGORIES } from './categories';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { Property, PropertyUpgradeConfig } from '../../../types';

	const PER_PAGE = 6;

	let loading = $state(false);
	let properties = $state<Property[]>([]);
	let upgrades = $state<PropertyUpgradeConfig>({});
	let search = $state('');
	let category = $state('all');
	let page = $state(1);

	let sellProperty = $state<Property | null>(null);
	let transferProperty = $state<Property | null>(null);
	let infoProperty = $state<Property | null>(null);
	let constructionProperty = $state<Property | null>(null);

	async function refresh() {
		loading = true;
		const res = await Nui.dyn8SearchProperties();
		if (res) {
			properties = res.properties;
			upgrades = res.upgrades;
			category = 'all';
		}
		page = 1;
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		properties
			.filter((p) => {
				const term = search.toLowerCase();
				return (
					search === '' ||
					p.label.toLowerCase().includes(term) ||
					(p.owner && `${p.owner.First} ${p.owner.Last}`.toLowerCase().includes(term)) ||
					(p.owner && p.owner.SID === parseInt(search))
				);
			})
			.filter((p) => category === 'all' || p.type === category)
			.sort((a, b) => a.price - b.price)
			.sort((a, b) => Number(a.sold) - Number(b.sold)),
	);
	const pages = $derived(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
	const pageItems = $derived(filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE));

	async function completeSale(data: { type: string; SID: string; downpayment: number; weeks: number }) {
		if (!sellProperty) return;
		const property = sellProperty;
		sellProperty = null;
		loading = true;
		const res = await Nui.dyn8StartSale({ ...data, property: property._id });
		if (res?.success) {
			toast.success(res.message ?? 'Success');
			refresh();
		} else {
			toast.error(res?.message ?? 'Error Initiating Sale');
			loading = false;
		}
	}

	async function completeTransfer(sid: string) {
		if (!transferProperty) return;
		const property = transferProperty;
		transferProperty = null;
		loading = true;
		const res = await Nui.dyn8StartTransfer(property._id, sid);
		if (res?.success) {
			toast.success(res.message ?? 'Success');
			refresh();
		} else {
			toast.error(res?.message ?? 'Error Initiating Transfer');
			loading = false;
		}
	}

	async function toggleBlips() {
		await Nui.dyn8ToggleBlips();
	}
</script>

<div class="properties">
	<div class="toolbar">
		<select bind:value={category}>
			{#each PROPERTY_CATEGORIES as c (c.value)}
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
		<button type="button" class="toggle-blips" onclick={toggleBlips}>Toggle Blips</button>
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if pageItems.length > 0}
			{#each pageItems as property (property._id)}
				<PropertyRow
					{property}
					{upgrades}
					onSell={() => (sellProperty = property)}
					onTransfer={() => (transferProperty = property)}
					onViewInfo={() => (infoProperty = property)}
					onConstruction={() => (constructionProperty = property)}
				/>
			{/each}
			<Pagination bind:page {pages} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<SaleFormModal open={!!sellProperty} property={sellProperty} onClose={() => (sellProperty = null)} onSubmit={completeSale} />
<TransferFormModal open={!!transferProperty} property={transferProperty} onClose={() => (transferProperty = null)} onSubmit={completeTransfer} />
<InfoModal open={!!infoProperty} property={infoProperty} {upgrades} onClose={() => (infoProperty = null)} />
<ConstructionModal open={!!constructionProperty} property={constructionProperty} onClose={() => (constructionProperty = null)} />

<style>
	.properties {
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

	.toggle-blips {
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0 0.8rem;
		font-size: 0.75rem;
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
