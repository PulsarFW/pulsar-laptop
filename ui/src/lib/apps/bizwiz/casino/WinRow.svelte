<script lang="ts">
	import { CURRENCY } from '../../../../config';
	import type { CasinoWin } from '../../../types';

	let { win }: { win: CasinoWin } = $props();

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 3600) return `${Math.max(1, Math.floor(diff / 60))}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}
</script>

<div class="row">
	<span class="col">
		<span class="label">Game</span>
		<span class="value">{win.Type.toUpperCase()}</span>
	</span>
	<span class="col wide">
		<span class="label">Winner</span>
		<span class="value">{win.Winner.First} {win.Winner.Last} ({win.Winner.SID})</span>
	</span>
	<span class="col">
		<span class="label">Prize</span>
		<span class="value">{typeof win.Prize === 'number' ? CURRENCY.format(win.Prize) : win.Prize}</span>
	</span>
	<span class="col">
		<span class="label">Time</span>
		<span class="value">{timeAgo(win.Time)}</span>
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
