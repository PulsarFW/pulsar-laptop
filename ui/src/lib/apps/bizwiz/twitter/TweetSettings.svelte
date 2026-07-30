<script lang="ts">
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';

	let loading = $state(false);
	let pfp = $state('');

	async function load() {
		loading = true;
		const res = await Nui.getBusinessTwitter();
		if (res && res.success) pfp = res.pfp ?? '';
		loading = false;
	}

	$effect(() => {
		load();
	});

	async function onUpdate() {
		loading = true;
		const res = await Nui.setBusinessTwitter(pfp);
		if (res) {
			pfp = res;
			toast.success('Business Spammer Profile Updated');
		} else {
			pfp = '';
			toast.error('Failed to Update Business Spammer Profile');
		}
		loading = false;
	}
</script>

<div class="settings">
	<div class="notice">Please use for business purposes only. Abuse of this will have your business permanently banned from using Spammer.</div>

	{#if loading}
		<div class="empty">Loading…</div>
	{:else}
		<div class="row">
			<img class="avatar" src={pfp || undefined} alt="Business profile" />
			<label class="field">
				<span>Business Profile Picture</span>
				<input type="text" bind:value={pfp} />
			</label>
		</div>
		<button type="button" class="update" onclick={onUpdate}>Update Profile</button>
	{/if}
</div>

<style>
	.settings {
		height: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.8rem;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.notice {
		background: rgba(56, 189, 248, 0.1);
		border: 1px solid rgba(56, 189, 248, 0.3);
		border-radius: var(--radius);
		color: #7dd3fc;
		padding: 0.6rem 0.8rem;
		font-size: 0.78rem;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.8rem;
	}

	.avatar {
		width: 3rem;
		height: 3rem;
		border-radius: 50%;
		object-fit: cover;
		background: var(--color-bg-panel-alt);
		flex-shrink: 0;
	}

	.field {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.field span {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}

	.field input {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
	}

	.update {
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.55rem 0;
		font-size: 0.78rem;
		cursor: pointer;
	}
</style>
