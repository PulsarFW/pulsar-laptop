<script lang="ts">
	import { getBucket } from '../../../store/data.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { BusinessReceipt } from '../../../types';

	let { onNav, data }: { onNav: (id: string, data?: Record<string, unknown>) => void; data?: Record<string, unknown> } = $props();

	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));
	const canManage = $derived(!!(onDuty && jobPerms?.[onDuty]?.TABLET_MANAGE_RECEIPT));

	let loading = $state(false);
	let err = $state(false);
	let report = $state<BusinessReceipt | null>(null);

	async function fetch() {
		const id = data?.id as string | undefined;
		if (!id) return;
		loading = true;
		const res = await Nui.businessReceiptView(id);
		if (res) report = res;
		else {
			err = true;
			toast.error('Unable to Load Receipt');
		}
		loading = false;
	}

	$effect(() => {
		fetch();
	});

	function onEdit() {
		if (!report) return;
		onNav('Create/Receipt', { id: report._id });
	}

	async function onDelete() {
		if (!report || !canManage) return;
		const res = await Nui.businessReceiptDelete(report._id);
		if (res) {
			toast.success('Document Deleted');
			onNav('Search/Receipt');
		} else {
			toast.error('Unable to Delete Receipt');
		}
	}
</script>

<div class="view">
	{#if loading || (!report && !err)}
		<div class="empty">Loading…</div>
	{:else if err || !report}
		<div class="error">Invalid Document ID</div>
	{:else}
		<div class="actions">
			<button type="button" onclick={fetch} disabled={loading}>Refresh</button>
			<button type="button" onclick={onEdit} disabled={!canManage}>Edit Document</button>
			{#if canManage}
				<button type="button" onclick={onDelete}>Delete Document</button>
			{/if}
		</div>

		<div class="meta">
			<div class="col">
				<span class="label">Created</span>
				<span class="value">By {report.author.First} {report.author.Last} ({report.author.SID})</span>
			</div>
			{#if report.lastUpdated}
				<div class="col">
					<span class="label">Last Updated</span>
					<span class="value">By {report.lastUpdated.First} {report.lastUpdated.Last} ({report.lastUpdated.SID})</span>
				</div>
			{/if}
		</div>

		<div class="grid">
			<div class="section">
				<div class="field">
					<span class="label">Receipt Type</span>
					<span class="value">{report.type}</span>
				</div>
				<div class="field">
					<span class="label">Customer Name</span>
					<span class="value">{report.customerName}</span>
				</div>
				<div class="field">
					<span class="label">Customer Number</span>
					<span class="value">{report.customerNumber}</span>
				</div>
				<div class="field">
					<span class="label">Payment Charge</span>
					<span class="value">{report.paymentAmount}</span>
				</div>
				<div class="field">
					<span class="label">Payment Paid</span>
					<span class="value">{report.paymentPaid}</span>
				</div>
			</div>
			<div class="section">
				<div class="field">
					<span class="label">Additional Employees</span>
					{#if report.workers && report.workers.length > 0}
						{#each report.workers as worker (worker.SID)}
							<span class="value">{worker.First} {worker.Last} ({worker.SID})</span>
						{/each}
					{:else}
						<span class="value">No Additional Employees</span>
					{/if}
				</div>
				<div class="field">
					<span class="label">Additional Notes</span>
					<span class="value notes">{report.notes}</span>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.view {
		height: 100%;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.empty,
	.error {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}

	.actions {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 1rem;
	}

	.actions button {
		flex: 1;
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem 0;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.actions button:disabled {
		opacity: 0.4;
		cursor: default;
	}

	.meta {
		display: flex;
		gap: 1.5rem;
		padding-bottom: 0.8rem;
		margin-bottom: 0.8rem;
		border-bottom: var(--border-subtle);
	}

	.col {
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
	}

	.grid {
		display: flex;
		gap: 1.5rem;
	}

	.section {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.6rem;
	}

	.field {
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
	}

	.label {
		font-size: 0.65rem;
		color: var(--color-text-muted);
	}

	.value {
		font-size: 0.8rem;
	}

	.value.notes {
		white-space: pre-line;
		line-height: 1.5;
	}
</style>
