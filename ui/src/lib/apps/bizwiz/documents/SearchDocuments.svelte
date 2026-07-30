<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import DocumentRow from './DocumentRow.svelte';
	import { Nui } from '../../../nui';
	import type { BusinessDocument } from '../../../types';

	let { onNav }: { onNav: (id: string, data?: Record<string, unknown>) => void } = $props();

	const PER_PAGE = 6;

	let loading = $state(false);
	let documents = $state<BusinessDocument[]>([]);
	let search = $state('');
	let page = $state(1);

	async function refresh() {
		loading = true;
		const res = await Nui.businessDocumentSearch('');
		documents = res || [];
		page = 1;
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		documents
			.filter((d) => search === '' || d.title.toLowerCase().includes(search.toLowerCase()))
			.sort((a, b) => b.time - a.time)
			.sort((a, b) => Number(b.pinned) - Number(a.pinned)),
	);
	const pages = $derived(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
	const pageItems = $derived(filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE));
</script>

<div class="documents">
	<div class="toolbar">
		<div class="search-input">
			<input type="text" placeholder="Search…" bind:value={search} />
			{#if search}
				<button type="button" onclick={() => (search = '')} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
		<button type="button" class="create" onclick={() => onNav('Create/Document')}>Create</button>
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if pageItems.length > 0}
			{#each pageItems as document (document._id)}
				<DocumentRow {document} onClick={() => onNav('View/Document', { id: document._id })} />
			{/each}
			<Pagination bind:page {pages} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<style>
	.documents {
		height: 100%;
		display: flex;
		flex-direction: column;
		padding: 1rem 0.6rem 1rem 1rem;
	}

	.toolbar {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 0.7rem;
		flex-shrink: 0;
	}

	.search-input {
		flex: 1;
		position: relative;
	}

	.search-input input {
		width: 100%;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem 1.8rem 0.4rem 0.5rem;
		font-size: 0.78rem;
	}

	.search-input button {
		position: absolute;
		right: 0.4rem;
		top: 50%;
		transform: translateY(-50%);
		background: transparent;
		border: none;
		color: var(--color-text-muted);
		cursor: pointer;
	}

	.create {
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0 1rem;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.results {
		flex: 1;
		overflow-y: auto;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
