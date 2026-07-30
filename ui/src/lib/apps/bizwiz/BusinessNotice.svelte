<script lang="ts">
	import Icon from '../../Icon.svelte';
	import Pagination from '../../primitives/Pagination.svelte';
	import NoticeItem from './NoticeItem.svelte';
	import { getBucket } from '../../store/data.svelte';
	import type { BusinessNotice, JobEntry } from '../../types';

	let { onNav }: { onNav: (id: string) => void } = $props();

	const PER_PAGE = 6;

	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));
	const canCreate = $derived(!!(onDuty && jobPerms?.[onDuty]?.TABLET_CREATE_NOTICE));
	const jobs = $derived(getBucket<{ Jobs?: JobEntry[] }>('player')?.Jobs);
	const jobData = $derived(jobs?.find((j) => j.Id === onDuty));

	const notices = $derived(getBucket<BusinessNotice[]>('businessNotices') ?? []);
	const sorted = $derived([...notices].sort((a, b) => b.time - a.time));
	const pages = $derived(Math.ceil(sorted.length / PER_PAGE) || 1);

	let page = $state(1);
	$effect(() => {
		void notices;
		page = 1;
	});

	const pageItems = $derived(sorted.slice((page - 1) * PER_PAGE, page * PER_PAGE));
</script>

<div class="block">
	<div class="header">
		<span>{jobData?.Name || 'Notice Board'}</span>
		{#if canCreate}
			<button type="button" class="create" onclick={() => onNav('Create/Notice')} aria-label="Create notice">
				<Icon name="plus" size="0.8em" />
			</button>
		{/if}
	</div>
	<div class="list">
		{#if pageItems.length > 0}
			{#each pageItems as notice (notice._id)}
				<NoticeItem {notice} />
			{/each}
		{:else}
			<div class="empty">No Notices</div>
		{/if}
	</div>
	<Pagination bind:page {pages} />
</div>

<style>
	.block {
		background: var(--color-bg-panel);
		border: var(--border-subtle);
		border-radius: var(--radius);
		padding: 0.8rem;
	}

	.header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding-bottom: 0.6rem;
		margin-bottom: 0.4rem;
		border-bottom: var(--border-subtle);
		color: var(--color-primary-light);
		font-family: var(--font-heading);
		font-size: 0.9rem;
	}

	.create {
		width: 1.8rem;
		height: 1.8rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(139, 92, 246, 0.15);
		color: var(--color-primary-light);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.empty {
		padding: 1rem 0;
		text-align: center;
		font-size: 0.8rem;
		color: var(--color-text-muted);
	}
</style>
