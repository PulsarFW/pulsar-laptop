<script lang="ts">
	import Icon from '../../Icon.svelte';
	import TitleBar from './TitleBar.svelte';
	import Navigation from './Navigation.svelte';
	import Dashboard from './pages/Dashboard.svelte';
	import Sales from './pdm/Sales.svelte';
	import PDMCredit from './pdm/Credit.svelte';
	import Manage from './pdm/Manage.svelte';
	import SalesHistory from './pdm/SalesHistory.svelte';
	import FleetManagement from './pdm/FleetManagement.svelte';
	import Properties from './dynasty/Properties.svelte';
	import DynastyCredit from './dynasty/Credit.svelte';
	import BigWins from './casino/BigWins.svelte';
	import SearchDocuments from './documents/SearchDocuments.svelte';
	import ViewDocument from './documents/ViewDocument.svelte';
	import CreateDocument from './documents/CreateDocument.svelte';
	import CreateNotice from './documents/CreateNotice.svelte';
	import SearchReceipts from './receipts/SearchReceipts.svelte';
	import ReceiptCount from './receipts/ReceiptCount.svelte';
	import ViewReceipt from './receipts/ViewReceipt.svelte';
	import CreateReceipt from './receipts/CreateReceipt.svelte';
	import Tweet from './twitter/Tweet.svelte';
	import TweetSettings from './twitter/TweetSettings.svelte';
	import { getBucket } from '../../store/data.svelte';
	import type { BizWizPage } from '../../types';

	const pages = $derived(getBucket<BizWizPage[]>('businessPages'));
	const hasAccess = $derived(!!getBucket<string>('businessLogo'));

	let currentPage = $state('Dashboard');
	let currentData = $state<Record<string, unknown> | undefined>(undefined);

	function onNav(id: string, data?: Record<string, unknown>) {
		if (pages?.some((p) => p.id === id)) {
			currentPage = id;
			currentData = data;
		} else {
			currentPage = 'Dashboard';
			currentData = undefined;
		}
	}
</script>

{#if !hasAccess || !pages}
	<div class="empty">
		<Icon name="business-time" size="3.5rem" />
		<p>Must Be Clocked In at a Participating Business</p>
	</div>
{:else}
	<div class="bizwiz">
		<div class="sidebar">
			<TitleBar />
			<Navigation current={currentPage} items={pages} onSelect={onNav} />
		</div>
		<div class="content">
			{#if currentPage === 'Dashboard'}
				<Dashboard {onNav} />
			{:else if currentPage === 'PDM/Sales'}
				<Sales />
			{:else if currentPage === 'PDM/Credit'}
				<PDMCredit />
			{:else if currentPage === 'PDM/Manage'}
				<Manage />
			{:else if currentPage === 'PDM/SalesHistory'}
				<SalesHistory />
			{:else if currentPage === 'Dynasty/Properties'}
				<Properties />
			{:else if currentPage === 'Dynasty/Credit'}
				<DynastyCredit />
			{:else if currentPage === 'FleetManagement'}
				<FleetManagement />
			{:else if currentPage === 'Casino/BigWins'}
				<BigWins />
			{:else if currentPage === 'Search/Document'}
				<SearchDocuments {onNav} />
			{:else if currentPage === 'View/Document'}
				<ViewDocument {onNav} data={currentData} />
			{:else if currentPage === 'Create/Document'}
				<CreateDocument {onNav} data={currentData} />
			{:else if currentPage === 'Create/Notice'}
				<CreateNotice {onNav} />
			{:else if currentPage === 'Search/Receipt'}
				<SearchReceipts {onNav} />
			{:else if currentPage === 'Search/ReceiptCount'}
				<ReceiptCount />
			{:else if currentPage === 'View/Receipt'}
				<ViewReceipt {onNav} data={currentData} />
			{:else if currentPage === 'Create/Receipt'}
				<CreateReceipt {onNav} data={currentData} />
			{:else if currentPage === 'Tweet'}
				<Tweet {onNav} />
			{:else if currentPage === 'TweetSettings'}
				<TweetSettings />
			{:else}
				<div class="placeholder">This page isn't built yet.</div>
			{/if}
		</div>
	</div>
{/if}

<style>
	.empty {
		height: 100%;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 1rem;
		color: var(--color-text-muted);
		text-align: center;
		padding: 2rem;
	}

	.bizwiz {
		height: 100%;
		display: flex;
	}

	.sidebar {
		width: 15rem;
		flex-shrink: 0;
		border-right: var(--border-subtle);
		overflow-y: auto;
	}

	.content {
		flex: 1;
		min-width: 0;
		overflow-y: auto;
	}

	.placeholder {
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-text-muted);
		font-size: 0.85rem;
	}
</style>
