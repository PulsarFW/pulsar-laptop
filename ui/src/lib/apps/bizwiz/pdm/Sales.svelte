<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import VehicleRow from './VehicleRow.svelte';
	import SaleFormModal from './SaleFormModal.svelte';
	import TestDriveModal from './TestDriveModal.svelte';
	import { VEHICLE_CATEGORIES } from './categories';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { PDMStockResponse, VehicleStock } from '../../../types';

	const PER_PAGE = 6;

	let loading = $state(false);
	let stock = $state<PDMStockResponse | null>(null);
	let search = $state('');
	let category = $state('all');
	let page = $state(1);

	let sellVehicle = $state<VehicleStock | null>(null);
	let testDriveVehicle = $state<VehicleStock | null>(null);

	async function refresh() {
		loading = true;
		const res = await Nui.pdmGetStock();
		stock = res || null;
		page = 1;
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		(stock?.stock ?? [])
			.filter((s) => category === 'all' || category === s.data.category)
			.filter((s) => `${s.data.make} ${s.data.model}`.toLowerCase().includes(search.toLowerCase()))
			.sort((a, b) => a.data.price - b.data.price),
	);
	const pages = $derived(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
	const pageItems = $derived(filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE));

	async function completeSale(data: { type: string; SID: string; downpayment: number; weeks: number }) {
		if (!sellVehicle) return;
		const vehicle = sellVehicle;
		sellVehicle = null;
		loading = true;
		const res = await Nui.pdmStartSale({ ...data, vehicle: vehicle.vehicle });
		if (res?.success) {
			toast.success(res.message ?? 'Success');
			refresh();
		} else {
			toast.error(res?.message ?? 'Error Initiating Sale');
			loading = false;
		}
	}

	async function startTestDrive() {
		if (!testDriveVehicle) return;
		const vehicle = testDriveVehicle;
		testDriveVehicle = null;
		const res = await Nui.dealershipStartTestDrive(vehicle.vehicle, vehicle.modelType);
		if (res?.success) toast.success(res.message ?? 'Vehicle has been delivered for test drive.');
		else toast.error(res?.message ?? 'Error Initiating Test Drive');
	}
</script>

<div class="sales">
	<div class="toolbar">
		<select bind:value={category}>
			{#each VEHICLE_CATEGORIES as c (c.value)}
				<option value={c.value}>{c.label}</option>
			{/each}
		</select>
		<div class="search-input">
			<input type="text" placeholder="Search make/model…" bind:value={search} />
			{#if search}
				<button type="button" onclick={() => (search = '')} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
		<button type="button" class="refresh" onclick={refresh}>
			<Icon name="arrows-rotate" size="0.8em" /> Refresh
		</button>
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if pageItems.length > 0}
			{#each pageItems as vehicle (vehicle._id)}
				<VehicleRow
					{vehicle}
					dealerData={stock?.dealerData}
					onClick={() => (sellVehicle = vehicle)}
					onTestDrive={() => (testDriveVehicle = vehicle)}
				/>
			{/each}
			<Pagination bind:page {pages} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<SaleFormModal
	open={!!sellVehicle}
	vehicle={sellVehicle}
	dealerData={stock?.dealerData}
	interest={stock?.interest}
	onClose={() => (sellVehicle = null)}
	onSubmit={completeSale}
/>
<TestDriveModal open={!!testDriveVehicle} vehicle={testDriveVehicle} onClose={() => (testDriveVehicle = null)} onSubmit={startTestDrive} />

<style>
	.sales {
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

	.refresh {
		display: flex;
		align-items: center;
		gap: 0.4rem;
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
