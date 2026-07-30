<script lang="ts">
	import type { ReceiptCountEntry } from '../../../types';

	let { entry }: { entry: ReceiptCountEntry } = $props();

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 3600) return `${Math.max(1, Math.floor(diff / 60))}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}
</script>

<div class="row">
	<span class="col">
		<span class="label">Employee</span>
		<span class="value">{entry.char?.First} {entry.char?.Last} ({entry.char?.SID})</span>
	</span>
	<span class="col">
		<span class="label">Receipts Created</span>
		<span class="value">{entry.created}</span>
	</span>
	<span class="col">
		<span class="label">Receipts Assisted</span>
		<span class="value">{entry.assisted}</span>
	</span>
	<span class="col wide">
		<span class="label">Receipt Types</span>
		<span class="value">{Object.entries(entry.types).map(([type, count]) => `${type}: ${count}`).join(';  ')}</span>
	</span>
	<span class="col">
		<span class="label">Latest Receipt</span>
		<span class="value">{timeAgo(entry.latest)}</span>
	</span>
</div>

<style>
	.row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.6rem;
		padding: 0.7rem;
		border-bottom: var(--border-subtle);
		color: var(--color-text);
	}

	.col {
		display: flex;
		flex-direction: column;
		min-width: 0;
		flex: 1;
	}

	.col.wide {
		flex: 2;
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
