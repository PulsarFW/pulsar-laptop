<script lang="ts">
	import { getBucket } from '../../../store/data.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { BusinessDocument } from '../../../types';

	let { onNav, data }: { onNav: (id: string, data?: Record<string, unknown>) => void; data?: Record<string, unknown> } = $props();

	const onDuty = $derived(getBucket<string>('onDuty'));
	const jobPerms = $derived(getBucket<Record<string, Record<string, boolean>>>('JobPermissions'));
	const canPin = $derived(!!(onDuty && jobPerms?.[onDuty]?.TABLET_PIN_DOCUMENT));

	let loading = $state(false);
	let existing = $state<BusinessDocument | null>(null);
	let title = $state('');
	let notes = $state('');
	let pinned = $state(false);

	async function load() {
		const id = data?.id as string | undefined;
		if (!id) return;
		loading = true;
		const res = await Nui.businessDocumentView(id);
		if (res) {
			existing = res;
			title = res.title;
			notes = res.notes;
			pinned = res.pinned;
		} else {
			toast.error('Unable to Load Document');
		}
		loading = false;
	}

	$effect(() => {
		load();
	});

	async function onSubmit() {
		if (title === '') {
			toast.error('Must Add Title');
			return;
		}
		if (notes === '') {
			toast.error('Must Add Content');
			return;
		}

		if (existing) {
			const res = await Nui.businessDocumentUpdate(existing._id, {
				title,
				pinned,
				notes,
				time: existing.time,
				author: existing.author,
			});
			if (res) onNav('View/Document', { id: existing._id });
			else toast.error('Unable to Update Document');
		} else {
			const res = await Nui.businessDocumentCreate({ title, pinned, notes, time: Math.floor(Date.now() / 1000) });
			if (res) onNav('View/Document', { id: res._id });
			else toast.error('Unable to Create Document');
		}
	}
</script>

<div class="create">
	<div class="actions">
		<label class="pinned">
			<input type="checkbox" bind:checked={pinned} disabled={!canPin} />
			Pinned
		</label>
		<span class="title">{existing ? existing.title : 'New Document'}</span>
		<button type="button" class="submit" onclick={onSubmit}>{existing ? 'Edit' : 'Create'} Document</button>
	</div>

	<label class="field">
		<span>Document Title</span>
		<input type="text" placeholder="Document Title" bind:value={title} />
	</label>

	{#if !loading}
		<label class="field notes-field">
			<span>Document Notes</span>
			<textarea placeholder="Enter Document Content" bind:value={notes}></textarea>
		</label>
	{/if}
</div>

<style>
	.create {
		height: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.8rem;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.actions {
		display: flex;
		align-items: center;
		gap: 0.8rem;
		padding-bottom: 0.7rem;
		border-bottom: var(--border-subtle);
	}

	.pinned {
		display: flex;
		align-items: center;
		gap: 0.35rem;
		font-size: 0.75rem;
		color: var(--color-text-muted);
	}

	.title {
		flex: 1;
		text-align: center;
		font-family: var(--font-heading);
		font-size: 0.9rem;
	}

	.submit {
		background: rgba(34, 197, 94, 0.15);
		border: 1px solid rgba(34, 197, 94, 0.4);
		border-radius: var(--radius);
		color: #4ade80;
		padding: 0.5rem 1rem;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.field span {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}

	.field input,
	.field textarea {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
		font-family: inherit;
	}

	.notes-field {
		flex: 1;
	}

	.notes-field textarea {
		flex: 1;
		min-height: 12rem;
		resize: vertical;
	}
</style>
