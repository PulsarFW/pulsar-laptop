<script lang="ts">
	import Icon from '../../Icon.svelte';
	import Modal from '../../primitives/Modal.svelte';
	import { getBucket } from '../../store/data.svelte';
	import { toast } from '../../store/toast.svelte';
	import { Nui } from '../../nui';
	import type { Team, TeamMember } from '../../types';

	interface PlayerLike {
		SID: number;
	}

	const myData = $derived(getBucket<PlayerLike>('player'));
	const myGroup = $derived(getBucket<Team>('myGroup'));
	const myGroupLeader = $derived(myGroup?.Members?.find((m) => m.Leader));
	const isLeader = $derived(myGroupLeader?.SID === myData?.SID);

	let creatingName = $state<string | null>(null);
	let invitingSid = $state<string | null>(null);
	let removingMember = $state<TeamMember | null>(null);
	let deleting = $state(false);

	async function onCreateTeam() {
		if (!creatingName) return;
		const res = await Nui.createTeam(creatingName);
		if (res && res.success) {
			toast.success('Team Created');
		} else if (res && res.message) {
			toast.error('Team Name Already Taken');
		} else {
			toast.error('Failed to Create Team');
		}
		creatingName = null;
	}

	async function onInviteMember() {
		const sid = parseInt(invitingSid ?? '', 10);
		const res = await Nui.inviteTeamMember(Number.isNaN(sid) ? 0 : sid);
		if (res && res.success) toast.success('Member Invited');
		else toast.error('Member Invite Failed');
		invitingSid = null;
	}

	async function onRemoveMember() {
		if (!removingMember) return;
		const res = await Nui.removeTeamMember(removingMember.SID, removingMember.Source);
		if (res) toast.success('Member Removed');
		else toast.error('Member Removal Failed');
		removingMember = null;
	}

	async function onDeleteTeam() {
		const res = await Nui.deleteTeam();
		if (res) toast.success('Team Deleted');
		else toast.error('Failed to Delete Team');
		deleting = false;
	}
</script>

<div class="column">
	<h3>My Team</h3>

	{#if !myGroup || !myGroupLeader}
		<button type="button" class="create-btn" onclick={() => (creatingName = '')}>
			<Icon name="people-group" size="0.85em" /> Create Team
		</button>
	{:else}
		<div class="row">
			<span class="label">Name</span>
			<span class="value">{myGroup.Name}</span>
			{#if isLeader}
				<button type="button" class="icon-btn danger" disabled={myGroup.State !== 0} onclick={() => (deleting = true)} aria-label="Delete team">
					<Icon name="xmark" size="0.8em" />
				</button>
			{/if}
		</div>
		<div class="row">
			<span class="label">State</span>
			<span class="value">{myGroup.StateName}</span>
		</div>
		<div class="row">
			<span class="label">Leader</span>
			<span class="value">{myGroupLeader.First} {myGroupLeader.Last} ({myGroupLeader.SID})</span>
		</div>
		<div class="row">
			<span class="label">Members ({myGroup.Members.length})</span>
			{#if isLeader && myGroup.Members.length < 5}
				<button type="button" class="icon-btn" disabled={myGroup.State !== 0} onclick={() => (invitingSid = '')} aria-label="Invite member">
					<Icon name="check" size="0.8em" />
				</button>
			{/if}
		</div>
		<div class="members">
			{#each myGroup.Members.filter((m) => !m.Leader) as member (member.SID)}
				<div class="member-row" class:me={member.SID === myData?.SID}>
					<span>{member.First} {member.Last} ({member.SID})</span>
					{#if isLeader || member.SID === myData?.SID}
						<button
							type="button"
							class="icon-btn danger"
							disabled={myGroup.State !== 0}
							onclick={() => (removingMember = member)}
							aria-label="Remove member"
						>
							<Icon name="minus" size="0.75em" />
						</button>
					{/if}
				</div>
			{:else}
				<div class="empty">No Other Members In Team</div>
			{/each}
		</div>
	{/if}
</div>

<Modal open={creatingName !== null} title="Create Team" submitLabel="Create Team" onClose={() => (creatingName = null)} onSubmit={onCreateTeam}>
	<input
		type="text"
		placeholder="Team Name"
		value={creatingName ?? ''}
		oninput={(e) => (creatingName = (e.target as HTMLInputElement).value.replace(/[^a-zA-Z0-9_. -]+/g, '').replace(/\s\s+/g, ' '))}
	/>
</Modal>

<Modal open={invitingSid !== null} title="Invite Member" submitLabel="Invite" onClose={() => (invitingSid = null)} onSubmit={onInviteMember}>
	<input
		type="text"
		inputmode="numeric"
		placeholder="State ID"
		value={invitingSid ?? ''}
		oninput={(e) => (invitingSid = (e.target as HTMLInputElement).value.replace(/[^0-9]/g, ''))}
	/>
</Modal>

<Modal open={removingMember !== null} title="Remove Member" submitLabel="Remove" submitVariant="danger" onClose={() => (removingMember = null)} onSubmit={onRemoveMember}>
	{#if removingMember?.SID !== myData?.SID}
		<p>Are you sure you want to remove {removingMember?.First} {removingMember?.Last}?</p>
	{:else}
		<p>Are you sure you want to leave the group?</p>
	{/if}
</Modal>

<Modal open={deleting} title="Delete Team" submitLabel="Delete" submitVariant="danger" onClose={() => (deleting = false)} onSubmit={onDeleteTeam}>
	<p>Are you sure you want to delete your team?</p>
</Modal>

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

	.create-btn {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		background: transparent;
		border: 1px solid var(--color-success);
		color: var(--color-success);
		border-radius: var(--radius);
		padding: 0.5rem 0.9rem;
		cursor: pointer;
		font-size: 0.8rem;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.5rem 0;
		border-bottom: var(--border-subtle);
		font-size: 0.8rem;
	}

	.label {
		color: var(--color-text-muted);
		width: 6rem;
		flex-shrink: 0;
	}

	.value {
		flex: 1;
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

	.icon-btn.danger {
		color: var(--color-error);
	}

	.icon-btn:disabled {
		opacity: 0.4;
		cursor: default;
	}

	.members {
		margin-top: 0.3rem;
	}

	.member-row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 0.45rem 0;
		border-bottom: var(--border-subtle);
		font-size: 0.78rem;
	}

	.member-row.me span {
		font-weight: 700;
	}

	.empty {
		padding: 0.6rem 0;
		font-size: 0.78rem;
		color: var(--color-text-muted);
	}

	input {
		width: 100%;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
	}
</style>
