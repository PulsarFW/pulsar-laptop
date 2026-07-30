<script lang="ts">
	import { getBucket } from '../../store/data.svelte';
	import type { JobEntry } from '../../types';

	const logo = $derived(getBucket<string>('businessLogo'));
	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobs = $derived(getBucket<{ Jobs?: JobEntry[] }>('player')?.Jobs);
	const jobData = $derived(jobs?.find((j) => j.Id === onDuty));
</script>

<div class="titlebar">
	{#if logo}
		<img src={logo} alt="" class="logo" />
	{/if}
	<div class="branding">
		<span class="name">{jobData?.Name ?? ''}</span>
		<small class="grade">{jobData?.Grade?.Name ?? ''}</small>
	</div>
</div>

<style>
	.titlebar {
		display: flex;
		align-items: center;
		gap: 0.7rem;
		padding: 0.9rem;
		border-bottom: var(--border-subtle);
	}

	.logo {
		width: 2.6rem;
		height: 2.6rem;
		object-fit: contain;
		border-radius: var(--radius);
		flex-shrink: 0;
	}

	.branding {
		display: flex;
		flex-direction: column;
		min-width: 0;
	}

	.name {
		font-family: var(--font-heading);
		font-size: 0.85rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.grade {
		font-size: 0.7rem;
		color: var(--color-text-muted);
	}
</style>
