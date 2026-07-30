<script lang="ts">
	import Icon from '../../Icon.svelte';
	import Modal from '../../primitives/Modal.svelte';
	import { getBucket } from '../../store/data.svelte';
	import { toast } from '../../store/toast.svelte';
	import { Nui } from '../../nui';
	import type { BusinessNotice } from '../../types';

	let { notice }: { notice: BusinessNotice } = $props();

	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));
	const canDelete = $derived(!!(onDuty && jobPerms?.[onDuty]?.TABLET_DELETE_NOTICE));

	let open = $state(false);

	async function onDismiss() {
		if (!canDelete) return;
		const res = await Nui.deleteBusinessNotice(notice._id);
		if (res) toast.success('Notice Dismissed');
		else toast.error('Unable to Dismiss Notice');
		open = false;
	}

	function timeAgo(ts: number): string {
		const diff = Date.now() / 1000 - ts;
		if (diff < 60) return 'just now';
		if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
		if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
		return `${Math.floor(diff / 86400)}d ago`;
	}
</script>

<button type="button" class="notice-row" onclick={() => (open = true)}>
	<span class="avatar"><Icon name="circle-info" size="0.9em" /></span>
	<span class="text">
		<span class="title">{notice.title}</span>
		<span class="desc">{notice.description}</span>
	</span>
	<span class="time">{timeAgo(notice.time)}</span>
</button>

<Modal open={open && !canDelete} title={notice.title} submitLabel="Close" onClose={() => (open = false)} onSubmit={() => (open = false)}>
	<p>{notice.description}</p>
	<p class="meta">By {notice.author?.First} {notice.author?.Last}</p>
</Modal>

{#if canDelete}
	<Modal {open} title={notice.title} submitLabel="Delete" submitVariant="danger" onClose={() => (open = false)} onSubmit={onDismiss}>
		<p>{notice.description}</p>
		<p class="meta">By {notice.author?.First} {notice.author?.Last}</p>
	</Modal>
{/if}

<style>
	.notice-row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.6rem;
		padding: 0.5rem;
		background: transparent;
		border: none;
		border-bottom: var(--border-subtle);
		text-align: left;
		cursor: pointer;
		color: var(--color-text);
	}

	.notice-row:hover {
		background: var(--color-bg-panel-alt);
	}

	.avatar {
		width: 1.8rem;
		height: 1.8rem;
		border-radius: 50%;
		background: rgba(139, 92, 246, 0.2);
		color: var(--color-primary-light);
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
	}

	.text {
		flex: 1;
		display: flex;
		flex-direction: column;
		min-width: 0;
	}

	.title {
		font-size: 0.8rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.desc {
		font-size: 0.72rem;
		color: var(--color-text-muted);
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.time {
		font-size: 0.68rem;
		color: var(--color-text-muted);
		flex-shrink: 0;
	}

	.meta {
		margin-top: 0.6rem;
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}
</style>
