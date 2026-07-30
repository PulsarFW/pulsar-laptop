<script lang="ts">
	import type { BusinessReceipt } from '../../../types';

	let { receipt, onClick }: { receipt: BusinessReceipt; onClick: () => void } = $props();

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 3600) return `${Math.max(1, Math.floor(diff / 60))}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}
</script>

<div class="row" role="button" tabindex="0" onclick={onClick} onkeydown={(e) => e.key === 'Enter' && onClick()}>
	<span class="col">
		<span class="label">Type</span>
		<span class="value">{receipt.type}</span>
	</span>
	<span class="col">
		<span class="label">Submitted By</span>
		<span class="value">{receipt.author?.First} {receipt.author?.Last} ({receipt.author?.SID})</span>
	</span>
	<span class="col">
		<span class="label">Created</span>
		<span class="value">{timeAgo(receipt.time)}</span>
	</span>
	<span class="col wide">
		<span class="label">Customer Info</span>
		<span class="value">{receipt.customerName} - {receipt.customerNumber}</span>
	</span>
	<span class="col">
		<span class="label">Amount Paid</span>
		<span class="value">${Number(receipt.paymentPaid) > 0 ? receipt.paymentPaid : 0}</span>
	</span>
</div>

<style>
	.row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.6rem;
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
		font-size: 0.76rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}
</style>
