<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import { CURRENCY } from '../../../../config';
	import { Nui } from '../../../nui';
	import type { CreditResult } from '../../../types';

	let search = $state('');
	let loading = $state(false);
	let result = $state<CreditResult | false | null>(null);

	async function run() {
		if (!search) return;
		loading = true;
		result = await Nui.dyn8RunCredit(search);
		loading = false;
	}

	function clear() {
		search = '';
		result = null;
	}
</script>

<div class="credit">
	<form class="toolbar" onsubmit={(e) => (e.preventDefault(), run())}>
		<div class="search-input">
			<input type="text" placeholder="State ID" bind:value={search} />
			{#if search}
				<button type="button" onclick={clear} aria-label="Clear">
					<Icon name="xmark" size="0.75em" />
				</button>
			{/if}
		</div>
		<button type="submit" class="search-btn" disabled={loading} aria-label="Search">
			<Icon name="magnifying-glass" size="0.85em" />
		</button>
	</form>

	<div class="results">
		{#if loading}
			<div class="empty">Loading…</div>
		{:else if result}
			<div class="row">
				<span class="col">
					<span class="label">State ID</span>
					<span class="value">{result.SID}</span>
				</span>
				<span class="col wide">
					<span class="label">Name</span>
					<span class="value">{result.name}</span>
				</span>
				<span class="col">
					<span class="label">Eligible Loan</span>
					<span class="value">{result.price ? CURRENCY.format(result.price) : 'Currently Not Eligible'}</span>
				</span>
				<span class="col">
					<span class="label">Credit Score</span>
					<span class="value">{result.score}</span>
				</span>
			</div>
		{:else}
			<div class="empty">No Results Found</div>
		{/if}
	</div>
</div>

<style>
	.credit {
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

	.search-btn {
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

	.row {
		display: flex;
		gap: 1rem;
		padding: 0.8rem;
		border: var(--border-subtle);
		border-radius: var(--radius);
		background: var(--color-bg-panel-alt);
	}

	.col {
		display: flex;
		flex-direction: column;
		flex: 1;
	}

	.col.wide {
		flex: 2;
	}

	.label {
		font-size: 0.65rem;
		color: var(--color-text-muted);
	}

	.value {
		font-size: 0.85rem;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}
</style>
