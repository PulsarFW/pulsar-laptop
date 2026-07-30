<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import type { BusinessDocument } from '../../../types';

	let { document, onClick }: { document: BusinessDocument; onClick: () => void } = $props();

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 3600) return `${Math.max(1, Math.floor(diff / 60))}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}
</script>

<div class="row" role="button" tabindex="0" onclick={onClick} onkeydown={(e) => e.key === 'Enter' && onClick()}>
	<span class="col wide">
		<span class="label">Title</span>
		<span class="value">{document.title}</span>
	</span>
	<span class="col">
		<span class="label">Author</span>
		<span class="value">{document.author?.First} {document.author?.Last} ({document.author?.SID})</span>
	</span>
	<span class="col">
		<span class="label">Created</span>
		<span class="value">{timeAgo(document.time)}</span>
	</span>
	{#if document.pinned}
		<Icon name="thumbtack" size="0.85em" />
	{/if}
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
