<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import Icon from '../../Icon.svelte';
	import { getBucket } from '../../store/data.svelte';
	import { toast } from '../../store/toast.svelte';
	import { Nui } from '../../nui';
	import type { Team } from '../../types';

	const myGroup = $derived(getBucket<Team>('myGroup'));

	let loading = $state(false);
	let teams = $state<Team[]>([]);
	let cooldown = $state(false);
	let interval: ReturnType<typeof setInterval>;
	let cooldownTimer: ReturnType<typeof setTimeout>;

	async function refresh() {
		loading = true;
		teams = await Nui.getTeams();
		loading = false;
	}

	onMount(() => {
		refresh();
		interval = setInterval(refresh, 120000);
	});

	onDestroy(() => {
		clearInterval(interval);
		clearTimeout(cooldownTimer);
	});

	async function requestInvite(teamId: number) {
		loading = true;
		cooldown = true;
		const res = await Nui.requestTeamInvite(teamId);
		if (res) toast.success('Invite Requested');
		else toast.error('Invite Request Failed');
		cooldownTimer = setTimeout(() => (cooldown = false), 20000);
		loading = false;
	}
</script>

<div class="column">
	<h3>Active Teams</h3>

	{#if loading}
		<div class="loading">Loading…</div>
	{:else if teams.length > 0}
		{#each teams as team (team.ID)}
			<div class="row">
				<span class="value" class:me={myGroup?.ID === team.ID}>{team.Name}</span>
				{#if !myGroup}
					<button
						type="button"
						class="icon-btn"
						disabled={cooldown || team.Members.length >= 5}
						onclick={() => requestInvite(team.ID)}
						aria-label="Request to join"
					>
						<Icon name="check" size="0.8em" />
					</button>
				{/if}
			</div>
		{/each}
	{:else}
		<div class="empty">No Available Teams</div>
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
		gap: 0.5rem;
		padding: 0.5rem 0;
		border-bottom: var(--border-subtle);
		font-size: 0.8rem;
	}

	.value {
		flex: 1;
	}

	.value.me {
		font-weight: 700;
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

	.icon-btn:disabled {
		opacity: 0.4;
		cursor: default;
	}

	.loading,
	.empty {
		padding: 0.6rem 0;
		font-size: 0.78rem;
		color: var(--color-text-muted);
	}
</style>
