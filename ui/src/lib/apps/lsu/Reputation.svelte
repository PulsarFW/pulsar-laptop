<script lang="ts">
	import type { ReputationEntry } from '../../types';

	let { rep }: { rep: ReputationEntry } = $props();

	function normalise(value: number): number {
		const min = rep.current?.value ?? 0;
		const max = rep.next?.value ?? 1000;
		if (max === min) return 100;
		return Math.min(100, Math.max(0, ((value - min) * 100) / (max - min)));
	}

	const percent = $derived(normalise(rep.value));
</script>

<div class="rep">
	<div class="title">{rep.label}</div>
	<div class="row">
		<span class="tier">{rep.current?.label ?? 'No Rank'}</span>
		<div class="bar">
			<div class="fill" style:width="{percent}%"></div>
		</div>
		<span class="tier">{rep.next?.label ?? 'Unknown'}</span>
	</div>
</div>

<style>
	.rep {
		padding: 0.7rem 0.8rem;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		margin-bottom: 0.6rem;
	}

	.title {
		text-align: center;
		font-family: var(--font-heading);
		font-size: 0.9rem;
		color: #e95200;
		margin-bottom: 0.5rem;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.6rem;
	}

	.tier {
		font-size: 0.7rem;
		color: var(--color-text-muted);
		flex-shrink: 0;
		width: 4rem;
		text-align: center;
	}

	.bar {
		flex: 1;
		height: 0.5rem;
		background: rgba(255, 255, 255, 0.08);
		border-radius: 999px;
		overflow: hidden;
	}

	.fill {
		height: 100%;
		background: #e95200;
		border-radius: 999px;
		transition: width 0.2s ease;
	}
</style>
