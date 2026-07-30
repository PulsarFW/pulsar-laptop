<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import { CURRENCY } from '../../../../config';
	import { categoryLabel } from './categories';
	import type { DealerData, VehicleStock } from '../../../types';

	let {
		vehicle,
		dealerData,
		onClick,
		onTestDrive,
	}: { vehicle: VehicleStock; dealerData?: DealerData; onClick: () => void; onTestDrive: () => void } = $props();

	const priceMult = $derived(1 + (dealerData?.profitPercentage ?? 0) / 100);
	const salePrice = $derived(vehicle.data.price * priceMult);

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 3600) return `${Math.max(1, Math.floor(diff / 60))}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}
</script>

<div class="row" role="button" tabindex="0" onclick={onClick} onkeydown={(e) => e.key === 'Enter' && onClick()}>
	<span class="col wide">
		<span class="label">Make / Model</span>
		<span class="value">{vehicle.data.make} {vehicle.data.model}</span>
	</span>
	<span class="col">
		<span class="label">Class</span>
		<span class="value">{vehicle.data.class}</span>
	</span>
	<span class="col">
		<span class="label">Price</span>
		<span class="value">{CURRENCY.format(Math.ceil(salePrice))} <small>({CURRENCY.format(vehicle.data.price)})</small></span>
	</span>
	<span class="col">
		<span class="label">Quantity</span>
		<span class="value">{vehicle.quantity}</span>
	</span>
	<span class="col">
		<span class="label">Category</span>
		<span class="value">{categoryLabel(vehicle.data.category)}</span>
	</span>
	<span class="col">
		<span class="label">Last Purchase</span>
		<span class="value">{vehicle.lastPurchase ? timeAgo(vehicle.lastPurchase) : 'Never'}</span>
	</span>
	<button
		type="button"
		class="test-drive"
		onclick={(e) => {
			e.stopPropagation();
			onTestDrive();
		}}
		aria-label="Test drive"
	>
		<Icon name="steering-wheel" size="0.9em" />
	</button>
</div>

<style>
	.row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.8rem;
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
		font-size: 0.78rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.value small {
		color: var(--color-text-muted);
	}

	.test-drive {
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
</style>
