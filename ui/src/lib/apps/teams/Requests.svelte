<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import Icon from '../../Icon.svelte';
	import { getBucket } from '../../store/data.svelte';
	import { notificationsState } from '../../store/notifications.svelte';
	import { Nui } from '../../nui';
	import type { Team, TeamRequest } from '../../types';

	interface PlayerLike {
		SID: number;
	}

	const myData = $derived(getBucket<PlayerLike>('player'));
	const myGroup = $derived(getBucket<Team>('myGroup'));
	const isLeader = $derived(myGroup?.Members?.find((m) => m.Leader)?.SID === myData?.SID);

	let loading = $state(false);
	let requests = $state<TeamRequest[]>([]);
	let now = $state(Date.now());
	let interval: ReturnType<typeof setInterval>;
	let lastNotifCount = 0;

	async function refresh() {
		loading = true;
		requests = await Nui.getTeamRequests();
		loading = false;
	}

	onMount(() => {
		refresh();
		interval = setInterval(() => (now = Date.now()), 30000);
	});

	onDestroy(() => clearInterval(interval));

	$effect(() => {
		const withRequest = notificationsState.notifications.filter((n) => (n.data as { request?: unknown } | undefined)?.request).length;
		if (withRequest > 0 && withRequest !== lastNotifCount) {
			lastNotifCount = withRequest;
			refresh();
		}
	});

	const availableRequests = $derived(requests.filter((r) => r.expires > now / 1000));

	async function respond(request: TeamRequest, action: 'accept' | 'deny') {
		loading = true;
		await Nui.teamRequest(request, action);
		await refresh();
	}
</script>

<div class="column">
	<h3>Incoming Requests</h3>

	{#if loading}
		<div class="loading">Loading…</div>
	{:else if availableRequests.length > 0}
		{#each availableRequests as request (request.id)}
			<div class="row">
				<div class="text">
					<span class="value">{request.label}</span>
					<span class="desc">{request.description}</span>
				</div>
				{#if isLeader || !request.team}
					<button type="button" class="icon-btn success" onclick={() => respond(request, 'accept')} aria-label="Accept">
						<Icon name="check" size="0.8em" />
					</button>
					<button type="button" class="icon-btn danger" onclick={() => respond(request, 'deny')} aria-label="Deny">
						<Icon name="xmark" size="0.8em" />
					</button>
				{/if}
			</div>
		{/each}
	{:else}
		<div class="empty">No Pending Requests</div>
	{/if}
</div>

<style>
	.column {
		flex: 1;
		min-width: 0;
		padding: 0.9rem;
	}

	h3 {
		margin: 0 0 0.7rem;
		padding-bottom: 0.6rem;
		border-bottom: var(--border-subtle);
		font-family: var(--font-heading);
		font-size: 0.95rem;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		padding: 0.5rem 0;
		border-bottom: var(--border-subtle);
		font-size: 0.8rem;
	}

	.text {
		flex: 1;
		display: flex;
		flex-direction: column;
		min-width: 0;
	}

	.desc {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}

	.icon-btn {
		width: 1.6rem;
		height: 1.6rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(255, 255, 255, 0.08);
		color: var(--color-text);
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
	}

	.icon-btn.success {
		color: var(--color-success);
	}

	.icon-btn.danger {
		color: var(--color-error);
	}

	.loading,
	.empty {
		padding: 0.6rem 0;
		font-size: 0.78rem;
		color: var(--color-text-muted);
	}
</style>
