<script lang="ts">
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { DealerData } from '../../../types';

	let loading = $state(false);
	let data = $state<DealerData | null>(null);

	async function refresh() {
		loading = true;
		const res = await Nui.pdmGetDealerData();
		data = res || { profitPercentage: 15, commission: 15 };
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	async function save() {
		if (!data) return;
		loading = true;
		const res = await Nui.pdmSaveDealerData(data);
		if (res) {
			data = res;
			toast.success('Changes Saved');
		} else {
			toast.error('Failed to Save');
		}
		loading = false;
	}
</script>

<div class="manage">
	<button type="button" class="save" onclick={save} disabled={loading}>Save Changes</button>

	{#if loading}
		<div class="empty">Loading…</div>
	{:else if data}
		<div class="row">
			<span class="label">Dealership Profit %</span>
			<input type="range" min="5" max="15" step="5" bind:value={data.profitPercentage} />
			<span class="value">{data.profitPercentage}%</span>
		</div>
		<div class="row">
			<span class="label">Employee Earned Commission %</span>
			<input type="range" min="5" max="15" step="5" bind:value={data.commission} />
			<span class="value">{data.commission}%</span>
		</div>
	{:else}
		<div class="empty">No Results Found</div>
	{/if}
</div>

<style>
	.manage {
		height: 100%;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.save {
		width: 100%;
		padding: 0.6rem 0;
		border-radius: var(--radius);
		border: var(--border-primary);
		background: transparent;
		color: var(--color-primary-light);
		cursor: pointer;
		font-size: 0.82rem;
		margin-bottom: 0.8rem;
	}

	.save:disabled {
		opacity: 0.5;
		cursor: default;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.8rem;
		padding: 0.7rem;
		border-bottom: var(--border-subtle);
	}

	.label {
		flex: 0 0 12rem;
		font-size: 0.8rem;
	}

	.row input[type='range'] {
		flex: 1;
	}

	.value {
		flex: 0 0 3rem;
		text-align: right;
		font-size: 0.78rem;
		color: var(--color-text-muted);
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
