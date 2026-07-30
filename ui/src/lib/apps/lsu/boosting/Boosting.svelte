<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import Modal from '../../../primitives/Modal.svelte';
	import MyContract from './MyContract.svelte';
	import Reputation from '../Reputation.svelte';
	import { getBucket } from '../../../store/data.svelte';
	import { laptopState } from '../../../store/laptop.svelte';
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { BoostingContract, LSUBanEntry, ReputationEntry, Team } from '../../../types';

	let { canBoost, banned, reputations }: { canBoost: boolean; banned: string[] | null; reputations: ReputationEntry[] | null } = $props();

	const VEHICLE_CLASSES = ['D', 'C', 'B', 'A', 'A+', 'S+'];

	const myGroup = $derived(getBucket<Team>('myGroup'));
	const queue = $derived(getBucket<{ joined: number } | null>('boostingQueue'));
	const alias = $derived(getBucket<{ Profiles?: Record<string, { name: string }> }>('player')?.Profiles?.redline?.name);
	const myContracts = $derived(getBucket<{ BoostingContracts?: BoostingContract[] }>('player')?.BoostingContracts ?? []);
	const activeContracts = $derived(myContracts.filter((c) => c.expires * 1000 > Date.now()));
	const isAdmin = $derived(!!laptopState.permissions?.lsunderground?.admin);

	const boostRep = $derived(
		reputations?.find((r) => r.id === 'Boosting') ?? {
			id: 'Boosting',
			label: 'Boosting',
			value: 0,
			current: { value: 0, label: 'D' },
			next: { value: 50000, label: 'C' },
		},
	);

	let queueModal = $state(false);

	async function onQueueExit() {
		const res = await Nui.boostingExitQueue();
		if (res) toast.success('Left Queue');
		else toast.error('Failed to Leave Queue');
		queueModal = false;
	}

	async function onQueueEnter() {
		if (alias && myGroup && (myGroup.Members.length >= 2 || isAdmin)) {
			const res = await Nui.boostingEnterQueue();
			if (res && res.success) toast.success('Entered Queue');
			else toast.error((res && res.message) || 'Failed to Enter Queue');
		} else {
			queueModal = true;
		}
	}

	function queuedFor(): string {
		if (!queue) return '';
		const diff = Date.now() / 1000 - queue.joined;
		if (diff < 60) return `${Math.floor(diff)}s`;
		if (diff < 3600) return `${Math.floor(diff / 60)}m`;
		return `${Math.floor(diff / 3600)}h`;
	}

	let adminSub = $state(false);
	let creatingContract = $state(false);
	let contractVehicle = $state('');
	let contractMake = $state('');
	let contractModel = $state('');
	let contractClass = $state('D');
	let contractTrackers = $state(0);
	let contractPrice = $state(20);
	let contractSkipRep = $state(false);
	let contractPayoutOverride = $state(0);

	function startCreatingContract() {
		contractVehicle = '';
		contractMake = '';
		contractModel = '';
		contractClass = 'D';
		contractTrackers = 0;
		contractPrice = 20;
		contractSkipRep = false;
		contractPayoutOverride = 0;
		creatingContract = true;
	}

	async function onCreateContract() {
		creatingContract = false;
		const res = await Nui.boostingAdminCreateContract({
			vehicle: contractVehicle,
			make: contractMake,
			model: contractModel,
			class: contractClass,
			trackers: contractTrackers,
			price: contractPrice,
			skipRep: contractSkipRep,
			payoutOverride: contractPayoutOverride,
		});
		const ok = res === true || (typeof res === 'object' && res.success);
		if (ok) toast.success('Contract Created Successfully');
		else toast.error((typeof res === 'object' && res.message) || 'Failed to Create Contract');
	}

	let banning = $state(false);
	let banLoading = $state(false);
	let banList = $state<LSUBanEntry[]>([]);
	let banSid = $state('');

	async function onStartBanning() {
		banLoading = true;
		banning = true;
		banSid = '';
		const res = await Nui.boostingAdminGetBans();
		banList = res || [];
		banLoading = false;
	}

	async function onBan() {
		if (!banSid) return;
		banLoading = true;
		const res = await Nui.boostingAdminBan(parseInt(banSid, 10));
		if (res) {
			toast.success('Ban Successful');
			await onStartBanning();
		} else {
			toast.error('Failed to Ban');
		}
		banLoading = false;
	}

	async function onUnban(sid: number) {
		banLoading = true;
		const res = await Nui.boostingAdminUnban(sid);
		if (res) {
			toast.success('Unban Successful');
			await onStartBanning();
		} else {
			toast.error('Failed to Unban');
		}
		banLoading = false;
	}
</script>

{#if banned}
	<div class="empty">Denied...</div>
{:else if !canBoost}
	<div class="empty">Insufficient Reputation to Begin Boosting</div>
{:else if !alias}
	<div class="empty">A Racing Alias is Required to Use This</div>
{:else}
	<div class="boosting">
		<div class="top">
			{#if isAdmin}
				<div class="admin-col">
					{#if adminSub}
						<button type="button" class="admin-btn success" onclick={startCreatingContract} aria-label="Create contract">
							<Icon name="plus" size="1em" />
						</button>
						<button type="button" class="admin-btn danger" onclick={onStartBanning} aria-label="Manage bans">
							<Icon name="xmark" size="1em" />
						</button>
					{:else}
						<button type="button" class="admin-btn success" onclick={() => (adminSub = true)} aria-label="Admin tools">
							<Icon name="gear" size="1em" />
						</button>
					{/if}
				</div>
			{/if}
			<div class="rep-col">
				<Reputation rep={boostRep} />
			</div>
			<button
				type="button"
				class="queue-btn"
				class:active={!!queue}
				disabled={!myGroup || myGroup.StateName?.toLowerCase() === 'boosting'}
				onclick={() => (queue ? (queueModal = true) : onQueueEnter())}
			>
				{queue ? 'Exit Queue' : 'Enter Queue'}
			</button>
		</div>

		<div class="contracts">
			{#if activeContracts.length > 0}
				<div class="grid">
					{#each activeContracts as contract (contract.id)}
						<MyContract {contract} repLevel={boostRep.value} />
					{/each}
				</div>
			{:else}
				<div class="empty">You Have No Available Contracts</div>
			{/if}
		</div>
	</div>
{/if}

<Modal
	open={queueModal}
	title={queue ? 'Exit Queue' : 'Entry Requirements!'}
	submitLabel={queue ? 'Exit' : undefined}
	submitVariant="danger"
	onClose={() => (queueModal = false)}
	onSubmit={queue ? onQueueExit : undefined}
>
	{#if queue}
		<p>You have been in the queue for {queuedFor()}, are you sure you want to leave?</p>
	{:else}
		<p>In order to join the queue, you must have a racing alias and you must be part of a group with at least 2 members.</p>
	{/if}
</Modal>

<Modal open={creatingContract} title="Custom Contract Creation" submitLabel="Create" onClose={() => (creatingContract = false)} onSubmit={onCreateContract}>
	<label class="field">
		<span>Vehicle Class</span>
		<select bind:value={contractClass}>
			{#each VEHICLE_CLASSES as c (c)}
				<option value={c}>{c}</option>
			{/each}
		</select>
	</label>
	<label class="field">
		<span>Vehicle (model, the spawn code)</span>
		<input type="text" bind:value={contractVehicle} />
	</label>
	<label class="field">
		<span>Vehicle Make (e.g. Aston Martin)</span>
		<input type="text" bind:value={contractMake} />
	</label>
	<label class="field">
		<span>Vehicle Model (e.g. DBS)</span>
		<input type="text" bind:value={contractModel} />
	</label>
	<label class="field">
		<span>Number of Trackers (0 to skip stage)</span>
		<input type="number" bind:value={contractTrackers} />
	</label>
	<label class="field">
		<span>Price in $VRM</span>
		<input type="number" bind:value={contractPrice} />
	</label>
	<label class="field">
		<span>Skip Reputation Reward</span>
		<select bind:value={contractSkipRep}>
			<option value={false}>No</option>
			<option value={true}>Yes</option>
		</select>
	</label>
	<label class="field">
		<span>Payout Reward (0 for default)</span>
		<input type="number" bind:value={contractPayoutOverride} />
	</label>
</Modal>

<Modal open={banning} title="LSUNDG Banning System" submitLabel="Ban" submitVariant="danger" disabled={banLoading} onClose={() => (banning = false)} onSubmit={onBan}>
	{#if banLoading}
		<p>Loading…</p>
	{:else}
		<label class="field">
			<span>Target State ID</span>
			<input type="text" bind:value={banSid} placeholder="State ID of who you want to ban" />
		</label>
		<h4>Ban List</h4>
		<div class="ban-list">
			{#each banList as b (b.SID)}
				<div class="ban-row">
					<span>{b.RacingAlias} - {b.First} {b.Last} (SID #{b.SID}) - Banned From: {b.LSUNDGBan.join(', ')}</span>
					<button type="button" onclick={() => onUnban(b.SID)} aria-label="Unban">
						<Icon name="check" size="0.8em" />
					</button>
				</div>
			{/each}
		</div>
	{/if}
</Modal>

<style>
	.empty {
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-text-muted);
		font-size: 0.95rem;
		font-weight: bold;
	}

	.boosting {
		height: 100%;
		display: flex;
		flex-direction: column;
		padding: 0.6rem;
	}

	.top {
		display: flex;
		align-items: stretch;
		gap: 0.5rem;
		margin-bottom: 0.6rem;
	}

	.admin-col {
		display: flex;
		flex-direction: column;
		gap: 0.4rem;
		width: 3rem;
	}

	.admin-btn {
		flex: 1;
		border-radius: var(--radius);
		border: none;
		cursor: pointer;
		color: #fff;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.admin-btn.success {
		background: #16a34a;
	}

	.admin-btn.danger {
		background: #dc2626;
	}

	.rep-col {
		flex: 1;
	}

	.rep-col :global(.rep) {
		margin-bottom: 0;
		height: 100%;
	}

	.queue-btn {
		width: 6rem;
		border-radius: var(--radius);
		border: none;
		background: #16a34a;
		color: #fff;
		font-size: 0.8rem;
		cursor: pointer;
	}

	.queue-btn.active {
		background: #dc2626;
	}

	.queue-btn:disabled {
		opacity: 0.4;
		cursor: default;
	}

	.contracts {
		flex: 1;
		overflow-y: auto;
	}

	.grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(9rem, 1fr));
		gap: 0.6rem;
	}

	.field {
		display: block;
		margin-bottom: 0.7rem;
	}

	.field span {
		display: block;
		font-size: 0.72rem;
		color: var(--color-text-muted);
		margin-bottom: 0.25rem;
	}

	.field input,
	.field select {
		width: 100%;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.45rem;
		font-size: 0.78rem;
	}

	h4 {
		margin: 0.6rem 0 0.4rem;
		font-size: 0.8rem;
	}

	.ban-list {
		display: flex;
		flex-direction: column;
		gap: 0.3rem;
		max-height: 10rem;
		overflow-y: auto;
	}

	.ban-row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 0.5rem;
		padding: 0.4rem 0.5rem;
		background: var(--color-bg-panel-alt);
		border-radius: var(--radius);
		font-size: 0.72rem;
	}

	.ban-row button {
		flex-shrink: 0;
		width: 1.7rem;
		height: 1.7rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(34, 197, 94, 0.15);
		color: #4ade80;
		cursor: pointer;
	}
</style>
