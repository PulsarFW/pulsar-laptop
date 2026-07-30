<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { FleetVehicle } from '../../../types';

	let search = $state('');
	let loading = $state(false);
	let results = $state<FleetVehicle[]>([]);

	async function refresh() {
		loading = true;
		const res = await Nui.viewVehicleFleet();
		results = res || [];
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		results
			.filter((r) => {
				const term = search.toLowerCase();
				return (
					r.VIN.toLowerCase().includes(term) || r.RegisteredPlate.toLowerCase().includes(term) || `${r.Make} ${r.Model}`.toLowerCase().includes(term)
				);
			})
			.sort((a, b) => (a.RegistrationDate ?? 0) - (b.RegistrationDate ?? 0)),
	);

	async function markGps(vin: string) {
		const res = await Nui.trackFleetVehicle(vin);
		if (res) toast.success('Marked Successfully on GPS');
		else toast.error('Error Marking GPS');
	}

	function formatDate(ts?: number): string {
		if (!ts) return 'Unknown';
		return new Date(ts * 1000).toLocaleDateString();
	}
</script>

<div class="fleet">
	<div class="search-input">
		<input type="text" placeholder="Search By Plate, VIN or Make/Model" bind:value={search} />
		{#if search}
			<button type="button" onclick={() => (search = '')} aria-label="Clear">
				<Icon name="xmark" size="0.75em" />
			</button>
		{/if}
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if results.length === 0}
			<div class="empty">This Business Has No Fleet Vehicles</div>
		{:else}
			{#each filtered as vehicle (vehicle.VIN)}
				<div class="row">
					<span class="col">
						<span class="label">Reg. Date</span>
						<span class="value">{formatDate(vehicle.RegistrationDate)}</span>
					</span>
					<span class="col">
						<span class="label">VIN</span>
						<span class="value">{vehicle.VIN}</span>
					</span>
					<span class="col">
						<span class="label">Plate</span>
						<span class="value">{vehicle.RegisteredPlate}</span>
					</span>
					<span class="col wide">
						<span class="label">Make / Model</span>
						<span class="value">{vehicle.Make} {vehicle.Model}</span>
					</span>
					<span class="col wide">
						<span class="label">Storage</span>
						<span class="value">{vehicle.Storage?.Name ?? 'Unknown'}</span>
					</span>
					<button type="button" class="gps" onclick={() => markGps(vehicle.VIN)} aria-label="Mark on GPS">
						<Icon name="location-crosshairs" size="0.85em" />
					</button>
				</div>
			{/each}
		{/if}
	</div>
</div>

<style>
	.fleet {
		height: 100%;
		display: flex;
		flex-direction: column;
		padding: 1rem 0.6rem 1rem 1rem;
	}

	.search-input {
		position: relative;
		margin-bottom: 0.7rem;
		flex-shrink: 0;
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
		display: flex;
		align-items: center;
		gap: 0.6rem;
		padding: 0.7rem;
		border-bottom: var(--border-subtle);
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
		font-size: 0.78rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.gps {
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
