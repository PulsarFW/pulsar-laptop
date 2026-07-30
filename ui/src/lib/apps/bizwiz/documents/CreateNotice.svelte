<script lang="ts">
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';

	let { onNav }: { onNav: (id: string) => void } = $props();

	let title = $state('');
	let description = $state('');

	async function onSubmit() {
		const res = await Nui.createBusinessNotice({ title, description });
		if (res) {
			toast.success('Notice Created');
			onNav('Dashboard');
		} else {
			toast.error('Unable to Create Notice');
		}
	}
</script>

<div class="create">
	<label class="field">
		<span>Notice Title</span>
		<input type="text" bind:value={title} maxlength="64" required />
	</label>
	<label class="field notes-field">
		<span>Notice</span>
		<textarea placeholder="Enter Notice" bind:value={description}></textarea>
	</label>

	<div class="actions">
		<button type="button" onclick={() => onNav('Dashboard')}>Go Back</button>
		<button type="button" class="submit" onclick={onSubmit}>Create Notice</button>
	</div>
</div>

<style>
	.create {
		height: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.8rem;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.field span {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}

	.field input,
	.field textarea {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
		font-family: inherit;
	}

	.notes-field {
		flex: 1;
	}

	.notes-field textarea {
		flex: 1;
		min-height: 12rem;
		resize: vertical;
	}

	.actions {
		display: flex;
		gap: 0.5rem;
	}

	.actions button {
		flex: 1;
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem 0;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.actions .submit {
		background: rgba(34, 197, 94, 0.15);
		border: 1px solid rgba(34, 197, 94, 0.4);
		color: #4ade80;
	}
</style>
