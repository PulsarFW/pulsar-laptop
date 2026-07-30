<script lang="ts">
	import Modal from '../../../primitives/Modal.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { getBucket } from '../../../store/data.svelte';
	import { Nui } from '../../../nui';
	import type { BoostingContract } from '../../../types';

	let { contract, repLevel }: { contract: BoostingContract; repLevel: number } = $props();

	const disabledContracts = $derived(getBucket<(number | string)[]>('disabledBoostingContracts') ?? []);
	const isDisabled = $derived(disabledContracts.includes(contract.id));
	const isDisabledByRep = $derived(repLevel < (contract.vehicle.classLevel ?? 0) && !contract.vehicle.rewarded);

	let accepting = $state(false);
	let loading = $state(false);
	let transferring = $state(false);
	let alias = $state('');

	function expiresIn(ts: number): string {
		const diff = ts - Date.now() / 1000;
		if (diff <= 0) return 'Expired';
		if (diff < 3600) return `${Math.ceil(diff / 60)}m`;
		return `${Math.ceil(diff / 3600)}h`;
	}

	async function accept() {
		loading = true;
		accepting = false;
		const res = await Nui.boostingAcceptContract(contract, false);
		if (res && res.success) toast.success('Request Sent to Team Leader');
		else toast.error((res && res.message) || 'Failed to Accept Contract');
		loading = false;
	}

	async function acceptScratch() {
		loading = true;
		accepting = false;
		const res = await Nui.boostingAcceptContract(contract, true);
		if (res && res.success) toast.success('Request Sent to Team Leader');
		else toast.error((res && res.message) || 'Failed to Accept Contract');
		loading = false;
	}

	async function onTransfer() {
		loading = true;
		const targetAlias = alias;
		transferring = false;
		alias = '';
		const res = await Nui.boostingTransferContract(contract.id, targetAlias);
		if (res) toast.success('Contract Transferred Successfully');
		else toast.error('Failed to Transfer Contract');
		loading = false;
	}

	async function decline() {
		loading = true;
		const res = await Nui.boostingDeclineContract(contract);
		if (res) toast.success('Contract Declined Successfully');
		else toast.error('Failed to Decline Contract');
		loading = false;
	}
</script>

<div class="contract">
	<div class="class-badge">{contract.vehicle.class}</div>
	<div class="label">{contract.vehicle.label}</div>
	<div class="owner">{contract.owner.Alias}</div>
	<div class="price">
		<span>{contract.prices.standard.price} ${contract.prices.standard.coin}</span>
		{#if contract.prices.scratch}
			<small>{contract.prices.scratch.price} ${contract.prices.scratch.coin}</small>
		{/if}
	</div>
	<div class="expiration">Expires: {expiresIn(contract.expires)}</div>

	{#if !accepting}
		<button type="button" class="btn success" disabled={isDisabled || loading || isDisabledByRep} onclick={() => (accepting = true)}>
			Accept Contract
		</button>
		<button type="button" class="btn warning" disabled={isDisabled || loading || transferring} onclick={() => (transferring = true)}>
			Transfer Contract
		</button>
		<button type="button" class="btn danger" disabled={isDisabled || loading} onclick={decline}>Decline Contract</button>
	{:else}
		<button type="button" class="btn info" onclick={accept}>Standard ({contract.prices.standard.price} ${contract.prices.standard.coin})</button>
		{#if contract.prices.scratch}
			<button type="button" class="btn warning" onclick={acceptScratch}>
				VIN Scratch ({contract.prices.scratch.price} ${contract.prices.scratch.coin})
			</button>
		{/if}
		<button type="button" class="btn danger" onclick={() => (accepting = false)}>Cancel</button>
	{/if}
</div>

<Modal open={transferring} title="Transferring Contract" submitLabel="Transfer" onClose={() => (transferring = false)} onSubmit={onTransfer}>
	<label class="field">
		<span>Target</span>
		<input type="text" bind:value={alias} placeholder="Alias" />
		<small>The alias of who you want to transfer the contract to.</small>
	</label>
</Modal>

<style>
	.contract {
		padding: 0.8rem;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		text-align: center;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.class-badge {
		width: 3.5rem;
		height: 3.5rem;
		margin: 0 auto;
		border-radius: 50%;
		background: rgba(233, 82, 0, 0.15);
		color: #e95200;
		display: flex;
		align-items: center;
		justify-content: center;
		font-family: var(--font-heading);
		font-size: 1.2rem;
	}

	.label {
		font-size: 0.95rem;
	}

	.owner {
		font-size: 0.75rem;
		color: var(--color-text-muted);
	}

	.price {
		font-size: 0.78rem;
		color: #4ade80;
	}

	.price small {
		margin-left: 0.3rem;
		color: var(--color-text-muted);
	}

	.expiration {
		font-size: 0.68rem;
		color: var(--color-text-muted);
	}

	.btn {
		border: none;
		border-radius: var(--radius);
		padding: 0.5rem 0;
		font-size: 0.75rem;
		cursor: pointer;
		color: #fff;
	}

	.btn:disabled {
		opacity: 0.4;
		cursor: default;
	}

	.btn.success {
		background: #16a34a;
	}

	.btn.warning {
		background: #d97706;
	}

	.btn.danger {
		background: #dc2626;
	}

	.btn.info {
		background: #0ea5e9;
	}

	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.field span {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}

	.field input {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
	}

	.field small {
		color: var(--color-text-muted);
		font-size: 0.68rem;
	}
</style>
