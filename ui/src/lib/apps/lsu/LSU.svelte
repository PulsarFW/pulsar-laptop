<script lang="ts">
	import Icon from '../../Icon.svelte';
	import Boosting from './boosting/Boosting.svelte';
	import BoostingMarket from './boosting/BoostingMarket.svelte';
	import ChopList from './chopping/ChopList.svelte';
	import Market from './Market.svelte';
	import Reputations from './Reputations.svelte';
	import { laptopState } from '../../store/laptop.svelte';
	import { Nui } from '../../nui';
	import type { LSUDetails } from '../../types';

	let loading = $state(false);
	let details = $state<LSUDetails | null>(null);
	let tab = $state(0);

	const TABS = [
		{ icon: 'screwdriver-wrench', label: 'Boosting' },
		{ icon: 'file-contract', label: 'Boosting Market', disabled: false },
		{ icon: 'car', label: 'Chop List' },
		{ icon: 'cart-shopping', label: 'Market' },
		{ icon: 'clock-rotate-left', label: 'Reputations' },
	];

	async function refresh() {
		if (loading) return;
		loading = true;
		const res = await Nui.getLSUDetails();
		details = res || null;
		loading = false;
	}

	$effect(() => {
		refresh();
	});

	$effect(() => {
		if (laptopState.visible) refresh();
	});
</script>

<div class="lsu">
	<div class="content">
		{#if tab === 0}
			<Boosting canBoost={details?.canBoost ?? false} banned={details?.banned ?? null} reputations={details?.reputations ?? null} />
		{:else if tab === 1}
			<BoostingMarket banned={details?.banned ?? null} />
		{:else if tab === 2}
			<ChopList chopList={details?.chopList ?? null} />
		{:else if tab === 3}
			<Market banned={details?.banned ?? null} items={details?.items ?? []} />
		{:else if tab === 4}
			<Reputations reputations={details?.reputations ?? null} />
		{/if}
	</div>

	<div class="tabs">
		{#each TABS as t, i (i)}
			<button
				type="button"
				class="tab"
				class:active={tab === i}
				disabled={i === 2 && !details?.chopList}
				onclick={() => (tab = i)}
				aria-label={t.label}
			>
				<Icon name={t.icon} size="1.1em" />
			</button>
		{/each}
	</div>
</div>

<style>
	.lsu {
		height: 100%;
		display: flex;
		flex-direction: column;
		background: var(--color-bg-panel);
	}

	.content {
		flex: 1;
		min-height: 0;
	}

	.tabs {
		display: flex;
		border-top: 1px solid #e95200;
		flex-shrink: 0;
	}

	.tab {
		flex: 1;
		padding: 0.7rem 0;
		background: transparent;
		border: none;
		color: var(--color-text-muted);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.tab:hover {
		color: #e95200;
	}

	.tab.active {
		color: #e95200;
	}

	.tab:disabled {
		color: #333;
		cursor: default;
	}
</style>
