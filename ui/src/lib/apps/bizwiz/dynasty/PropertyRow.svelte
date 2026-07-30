<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import { CURRENCY } from '../../../../config';
	import { propertyCategoryLabel } from './categories';
	import { getBucket } from '../../../store/data.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { Property, PropertyUpgradeConfig } from '../../../types';

	let {
		property,
		upgrades,
		onSell,
		onConstruction,
		onViewInfo,
		onTransfer,
	}: {
		property: Property;
		upgrades?: PropertyUpgradeConfig;
		onSell: () => void;
		onConstruction: () => void;
		onViewInfo: () => void;
		onTransfer: () => void;
	} = $props();

	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));
	const canSell = $derived(!!jobPerms?.realestate?.JOB_SELL);

	const interiorLevel = $derived(
		property.upgrades?.interior && upgrades?.[property.type]?.interior?.levels
			? upgrades[property.type].interior.levels.find((l) => l.id === property.upgrades?.interior)
			: undefined,
	);

	function rowClick() {
		if (!canSell) return;
		if (property.sold) onTransfer();
		else onSell();
	}

	async function markGps(e: Event) {
		e.stopPropagation();
		const res = await Nui.dyn8MarkProperty(property._id);
		if (res) toast.success('Marked Successfully');
		else toast.error('Error Marking GPS');
	}

	function constructionClick(e: Event) {
		e.stopPropagation();
		if (canSell) onConstruction();
		else toast.error('Invalid Permissions');
	}

	function infoClick(e: Event) {
		e.stopPropagation();
		onViewInfo();
	}

	async function copyId(e: Event) {
		e.stopPropagation();
		const res = await Nui.dyn8CopyID(property._id);
		if (res) toast.success('Copied Successfully');
		else toast.error('Error Copying Property');
	}
</script>

<div class="row" role="button" tabindex="0" onclick={rowClick} onkeydown={(e) => e.key === 'Enter' && rowClick()}>
	<span class="col">
		<span class="label">Type</span>
		<span class="value">{propertyCategoryLabel(property.type)}</span>
	</span>
	<span class="col wide">
		<span class="label">Property</span>
		<span class="value">{property.label}</span>
	</span>
	<span class="col">
		<span class="label">Price</span>
		<span class="value">{CURRENCY.format(Math.ceil(property.price))}</span>
	</span>
	<span class="col">
		<span class="label">Interior</span>
		<span class="value">{interiorLevel ? interiorLevel.name : 'Unknown'}</span>
	</span>
	<span class="col wide">
		<span class="label">Owner</span>
		<span class="value">{property.owner ? `${property.owner.First} ${property.owner.Last} (${property.owner.SID})` : 'Not Owned'}</span>
	</span>
	<div class="actions">
		<button type="button" onclick={markGps} aria-label="Mark on GPS"><Icon name="location-crosshairs" size="0.85em" /></button>
		<button type="button" onclick={constructionClick} aria-label="Edit construction"><Icon name="hammer" size="0.85em" /></button>
		<button type="button" onclick={infoClick} aria-label="View info"><Icon name="circle-info" size="0.85em" /></button>
		<button type="button" onclick={copyId} aria-label="Copy ID"><Icon name="copy" size="0.85em" /></button>
	</div>
</div>

<style>
	.row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.6rem;
		padding: 0.7rem;
		border-bottom: var(--border-subtle);
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

	.actions {
		display: flex;
		gap: 0.3rem;
		flex-shrink: 0;
	}

	.actions button {
		width: 1.7rem;
		height: 1.7rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(139, 92, 246, 0.15);
		color: var(--color-primary-light);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
	}
</style>
