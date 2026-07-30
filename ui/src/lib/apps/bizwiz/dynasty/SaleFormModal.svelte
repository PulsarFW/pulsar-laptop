<script lang="ts">
	import Modal from '../../../primitives/Modal.svelte';
	import { CURRENCY } from '../../../../config';
	import type { Property } from '../../../types';

	let {
		open,
		property,
		interest = 15,
		onClose,
		onSubmit,
	}: {
		open: boolean;
		property: Property | null;
		interest?: number;
		onClose: () => void;
		onSubmit: (data: { type: string; SID: string; downpayment: number; weeks: number }) => void;
	} = $props();

	let type = $state<'full' | 'loan'>('loan');
	let sid = $state('');
	let downpayment = $state(50);
	let weeks = $state(8);

	$effect(() => {
		if (open) {
			type = 'loan';
			sid = '';
			downpayment = 50;
			weeks = 8;
		}
	});

	const salePrice = $derived(property?.price ?? 0);
	const earnedCommission = $derived(salePrice * 0.05);
	const downPaymentAmount = $derived(salePrice * (downpayment / 100));
	const remainingCost = $derived((salePrice - downPaymentAmount) * (1 + interest / 100));
	const perWeek = $derived(weeks > 0 ? remainingCost / weeks : 0);

	function submit() {
		onSubmit({ type, SID: sid, downpayment, weeks });
	}
</script>

<Modal {open} title={`Sell ${property?.label ?? ''}`} submitLabel="Confirm Sale" {onClose} onSubmit={submit}>
	<p>Property: {property?.label}</p>
	{#if type === 'loan'}
		<p>Loan Interest Rate: {interest}%</p>
		<p>Downpayment: {CURRENCY.format(Math.ceil(downPaymentAmount))} ({downpayment}%)</p>
		<p>Remaining Cost (Interest Applied): {CURRENCY.format(Math.ceil(remainingCost))}</p>
		<p>Loan Length in Weeks: {weeks}</p>
		<p>Weekly Payment: {CURRENCY.format(Math.ceil(perWeek))}</p>
		<p>Your Earned Commission: {CURRENCY.format(Math.ceil(earnedCommission))}</p>
	{:else}
		<p>Cost: {CURRENCY.format(Math.ceil(salePrice))}</p>
	{/if}

	<label class="field">
		<span>Type</span>
		<select bind:value={type}>
			<option value="full">Cash</option>
			<option value="loan">Loan</option>
		</select>
	</label>

	{#if type === 'loan'}
		<label class="field">
			<span>Downpayment {downpayment}% ({CURRENCY.format(Math.ceil(downPaymentAmount))})</span>
			<input type="range" min="15" max="80" step="5" bind:value={downpayment} />
		</label>
		<label class="field">
			<span>Loan Length ({weeks} Weeks)</span>
			<input type="range" min="8" max="24" step="1" bind:value={weeks} />
		</label>
	{/if}

	<label class="field">
		<span>Customer State ID</span>
		<input type="text" inputmode="numeric" bind:value={sid} />
	</label>
</Modal>

<style>
	.field {
		display: block;
		margin-top: 0.6rem;
	}

	.field span {
		display: block;
		font-size: 0.72rem;
		color: var(--color-text-muted);
		margin-bottom: 0.25rem;
	}

	select,
	input[type='text'] {
		width: 100%;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem;
		font-size: 0.78rem;
	}

	input[type='range'] {
		width: 100%;
	}
</style>
