<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Pagination from '../../../primitives/Pagination.svelte';
	import WinRow from './WinRow.svelte';
	import { GAME_CATEGORIES } from './categories';
	import { Nui } from '../../../nui';
	import type { CasinoWin } from '../../../types';

	const PER_PAGE = 6;

	let loading = $state(false);
	let wins = $state<CasinoWin[]>([]);
	let search = $state('');
	let category = $state('all');
	let page = $state(1);

	async function refresh() {
		loading = true;
		const res = await Nui.casinoGetBigWins();
		wins = res || [];
		page = 1;
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	const filtered = $derived(
		wins
			.filter((w) => {
				const term = search.toLowerCase();
				return (
					search === '' ||
					`${w.Winner.First} ${w.Winner.Last}`.toLowerCase().includes(term) ||
					String(w.Prize).toLowerCase().includes(term)
				);
			})
			.filter((w) => category === 'all' || w.Type === category)
			.sort((a, b) => b.Time - a.Time),
	);
	const pages = $derived(Math.max(1, Math.ceil(filtered.length / PER_PAGE)));
	const pageItems = $derived(filtered.slice((page - 1) * PER_PAGE, page * PER_PAGE));
</script>

<div class="bigwins">
	<div class="toolbar">
		<select bind:value={category}>
			{#each GAME_CATEGORIES as c (c.value)}
				<option value={c.value}>{c.label}</option>
			{/each}
		</select>
		<div class="search-input">
			<input type="text" placeholder="Search…" bind:value={search} />
			{#if search}
				<button type="button" onclick={() => (search = '')} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
		<button type="button" class="refresh" onclick={refresh} aria-label="Refresh">
			<Icon name="arrows-rotate" size="0.85em" />
		</button>
	</div>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if pageItems.length > 0}
			{#each pageItems as win (win._id)}
				<WinRow {win} />
			{/each}
			<Pagination bind:page {pages} />
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<style>
	.bigwins {
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

	select {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem;
		font-size: 0.78rem;
		flex: 0 0 8rem;
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

	.refresh {
		width: 2.4rem;
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
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
