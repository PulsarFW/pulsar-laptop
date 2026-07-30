<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import type { ChopListItem } from '../../../types';

	let { chop }: { chop: ChopListItem } = $props();
</script>

<div class="item">
	{#if chop.hv}
		<Icon name="circle-exclamation" size="0.85em" />
	{/if}
	{chop.name}
</div>

<style>
	.item {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		padding: 0.6rem 0.8rem;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		margin-bottom: 0.4rem;
		font-family: var(--font-heading);
		font-size: 0.85rem;
		color: #e95200;
	}

	.item :global(svg) {
		color: gold;
	}
</style>
