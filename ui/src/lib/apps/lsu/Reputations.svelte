<script lang="ts">
	import Reputation from './Reputation.svelte';
	import type { ReputationEntry } from '../../types';

	let { reputations }: { reputations: ReputationEntry[] | null } = $props();

	const LSU_REPS = ['Chopping', 'Racing'];
	const theseReputations = $derived(reputations?.filter((r) => LSU_REPS.includes(r.id)) ?? []);
</script>

<div class="reputations">
	{#if !reputations}
		<div class="empty">Loading…</div>
	{:else if theseReputations.length > 0}
		{#each theseReputations as rep (rep.id)}
			<Reputation {rep} />
		{/each}
	{:else}
		<div class="empty">No Reputation Built</div>
	{/if}
</div>

<style>
	.reputations {
		height: 100%;
		padding: 0.8rem;
		overflow-y: auto;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
