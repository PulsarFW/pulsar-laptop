<script lang="ts">
	let { banned }: { banned: string[] | null } = $props();
</script>

{#if banned}
	<div class="empty">Denied...</div>
{:else}
	<div class="empty">Boosting Market is Not Yet Available</div>
{/if}

<style>
	.empty {
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-text-muted);
		font-size: 0.95rem;
		font-weight: bold;
		text-align: center;
		padding: 2rem;
	}
</style>
