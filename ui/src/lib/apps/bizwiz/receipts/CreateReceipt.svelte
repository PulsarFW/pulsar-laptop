<script lang="ts">
	import BusinessSearch from '../BusinessSearch.svelte';
	import { getBucket } from '../../../store/data.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { BusinessReceipt, EmployeeSearchResult } from '../../../types';

	let { onNav, data }: { onNav: (id: string, data?: Record<string, unknown>) => void; data?: Record<string, unknown> } = $props();

	const RECEIPT_TYPES = [
		{ value: 'General', jobs: false as false | string[] },
		{ value: 'Regular Repair', jobs: ['redline', 'hayes', 'autoexotics', 'ottos', 'bennys', 'paleto_tuners', 'dreamworks'] },
		{ value: 'Full Repair', jobs: ['redline', 'hayes', 'autoexotics', 'ottos', 'bennys', 'paleto_tuners', 'dreamworks'] },
		{ value: 'Lockpick', jobs: ['redline', 'hayes', 'autoexotics', 'ottos', 'bennys', 'paleto_tuners', 'dreamworks'] },
		{ value: 'Performance Upgrades', jobs: ['redline', 'hayes', 'autoexotics', 'ottos', 'bennys', 'paleto_tuners', 'dreamworks'] },
		{ value: 'Discounted Repair', jobs: ['redline', 'hayes', 'autoexotics', 'ottos', 'bennys', 'paleto_tuners', 'dreamworks'] },
		{ value: 'Repair Kits', jobs: ['redline', 'hayes', 'autoexotics', 'ottos', 'bennys', 'paleto_tuners', 'dreamworks'] },
	];

	const onDuty = $derived(getBucket<string>('onDuty'));
	const availableTypes = $derived(RECEIPT_TYPES.filter((r) => !r.jobs || (onDuty && r.jobs.includes(onDuty))));

	let loading = $state(false);
	let existing = $state<BusinessReceipt | null>(null);
	let type = $state('General');
	let customerName = $state('');
	let customerNumber = $state('');
	let paymentAmount = $state('');
	let paymentPaid = $state('');
	let notes = $state('');
	let workers = $state<EmployeeSearchResult[]>([]);

	$effect(() => {
		if (availableTypes.length > 0 && !existing) type = availableTypes[0].value;
	});

	async function load() {
		const id = data?.id as string | undefined;
		if (!id) return;
		loading = true;
		const res = await Nui.businessReceiptView(id);
		if (res) {
			existing = res;
			type = res.type;
			customerName = res.customerName;
			customerNumber = res.customerNumber;
			paymentAmount = res.paymentAmount;
			paymentPaid = res.paymentPaid;
			notes = res.notes;
			workers = res.workers ?? [];
		} else {
			toast.error('Unable to Load Receipt');
		}
		loading = false;
	}

	$effect(() => {
		load();
	});

	async function onSubmit() {
		if (customerName === '') {
			toast.error('Must Add Customer Name');
			return;
		}

		if (existing) {
			const res = await Nui.businessReceiptUpdate(existing._id, {
				type,
				customerName,
				customerNumber,
				paymentAmount,
				paymentPaid,
				workers,
				notes,
				time: existing.time,
				author: existing.author,
			});
			if (res) onNav('View/Receipt', { id: existing._id });
			else toast.error('Unable to Update');
		} else {
			const res = await Nui.businessReceiptCreate({
				type,
				customerName,
				customerNumber,
				paymentAmount,
				paymentPaid,
				workers,
				notes,
				time: Math.floor(Date.now() / 1000),
			});
			if (res) onNav('View/Receipt', { id: res._id });
			else toast.error('Unable to Create');
		}
	}
</script>

<div class="create">
	<div class="actions">
		<span class="title">{existing ? 'Edit Receipt' : 'New Receipt'}</span>
		<button type="button" class="submit" onclick={onSubmit}>{existing ? 'Edit' : 'Create'} Receipt</button>
	</div>

	<div class="grid">
		<div class="col">
			<label class="field">
				<span>Receipt Type</span>
				<select bind:value={type} disabled={!!existing}>
					{#each availableTypes as opt (opt.value)}
						<option value={opt.value}>{opt.value}</option>
					{/each}
				</select>
			</label>
			<label class="field">
				<span>Customer Name</span>
				<input type="text" placeholder="Customer Name" bind:value={customerName} />
			</label>
			<label class="field">
				<span>Customer Phone Number</span>
				<input type="text" placeholder="Customer Phone Number" bind:value={customerNumber} />
			</label>
			<label class="field">
				<span>Payment Charged</span>
				<input type="text" placeholder="Payment Charged" bind:value={paymentAmount} />
			</label>
			<label class="field">
				<span>Payment Paid</span>
				<input type="text" placeholder="Payment Paid" bind:value={paymentPaid} />
			</label>
		</div>
		<div class="col">
			<BusinessSearch label="Additional Employees" placeholder="Bob, Tim, Dave" bind:value={workers} job={onDuty ?? ''} disableSelf />
			{#if !loading}
				<label class="field notes-field">
					<span>Additional Notes</span>
					<textarea placeholder="Enter Content" bind:value={notes}></textarea>
				</label>
			{/if}
		</div>
	</div>
</div>

<style>
	.create {
		height: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.8rem;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.actions {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 0.8rem;
		padding-bottom: 0.7rem;
		border-bottom: var(--border-subtle);
	}

	.title {
		font-family: var(--font-heading);
		font-size: 0.9rem;
	}

	.submit {
		background: rgba(34, 197, 94, 0.15);
		border: 1px solid rgba(34, 197, 94, 0.4);
		border-radius: var(--radius);
		color: #4ade80;
		padding: 0.5rem 1rem;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.grid {
		display: flex;
		gap: 1.5rem;
		flex: 1;
	}

	.col {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.6rem;
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

	.field input,
	.field select,
	.field textarea {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
		font-family: inherit;
	}

	.notes-field {
		flex: 1;
	}

	.notes-field textarea {
		flex: 1;
		min-height: 8rem;
		resize: vertical;
	}
</style>
