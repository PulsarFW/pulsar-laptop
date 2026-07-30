<script lang="ts">
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';
	import type { Property } from '../../../types';

	let { open, property, onClose }: { open: boolean; property: Property | null; onClose: () => void } = $props();

	const EDITABLES = [
		{ value: 'garage', label: 'Garage' },
		{ value: 'backdoor', label: 'Backdoor' },
	];

	let type = $state(EDITABLES[0].value);
	let loading = $state(false);

	$effect(() => {
		if (open) {
			type = EDITABLES[0].value;
			loading = false;
		}
	});

	async function showLocation() {
		if (!property) return;
		const res = await Nui.dyn8ShowPropertyLocations(property._id);
		if (res) toast.success('Started Showing Locations');
		else toast.error('Error Showing Locations');
	}

	async function changeLocation() {
		if (!property) return;
		loading = true;
		const res = await Nui.dyn8ChangePropertyLocations(property._id, type);
		if (res) toast.success('Successfully Updated Location');
		else toast.error('Error Updating Location');
		loading = false;
	}
</script>

{#if open}
	<div class="backdrop" role="presentation" onclick={onClose}>
		<!-- svelte-ignore a11y_click_events_have_key_events -->
		<div class="modal" role="dialog" aria-label="Edit property" tabindex="-1" onclick={(e) => e.stopPropagation()}>
			<h3>Edit {property?.label}</h3>
			<p>Property: {property?.label}</p>
			<p>Property ID: {property?._id}</p>

			<button type="button" class="btn outline" onclick={showLocation}>Show Current Locations</button>

			<label class="field">
				<span>Type</span>
				<select bind:value={type} disabled={loading}>
					{#each EDITABLES as opt (opt.value)}
						<option value={opt.value}>{opt.label}</option>
					{/each}
				</select>
			</label>

			<button type="button" class="btn outline" onclick={changeLocation} disabled={loading}>
				{loading ? 'Updating…' : 'Update Location (To Standing Position)'}
			</button>

			<button type="button" class="btn close" onclick={onClose}>Close</button>
		</div>
	</div>
{/if}

<style>
	.backdrop {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.55);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 100;
	}

	.modal {
		width: 22rem;
		background: var(--color-bg-panel);
		border: var(--border-primary);
		border-radius: var(--radius);
		padding: 1rem;
	}

	h3 {
		margin: 0 0 0.6rem;
		font-family: var(--font-heading);
		font-size: 0.95rem;
	}

	p {
		font-size: 0.8rem;
		color: var(--color-text-muted);
	}

	.field {
		display: block;
		margin: 0.8rem 0;
	}

	.field span {
		display: block;
		font-size: 0.72rem;
		color: var(--color-text-muted);
		margin-bottom: 0.25rem;
	}

	select {
		width: 100%;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem;
		font-size: 0.78rem;
	}

	.btn {
		width: 100%;
		padding: 0.5rem 0;
		border-radius: var(--radius);
		font-size: 0.78rem;
		cursor: pointer;
		margin-top: 0.5rem;
	}

	.btn.outline {
		background: transparent;
		border: var(--border-primary);
		color: var(--color-primary-light);
	}

	.btn.outline:disabled {
		opacity: 0.5;
		cursor: default;
	}

	.btn.close {
		background: rgba(255, 255, 255, 0.08);
		border: none;
		color: var(--color-text);
	}
</style>
