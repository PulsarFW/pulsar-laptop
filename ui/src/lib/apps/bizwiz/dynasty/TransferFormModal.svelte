<script lang="ts">
	import Modal from '../../../primitives/Modal.svelte';
	import type { Property } from '../../../types';

	let {
		open,
		property,
		onClose,
		onSubmit,
	}: { open: boolean; property: Property | null; onClose: () => void; onSubmit: (sid: string) => void } = $props();

	let sid = $state('');

	$effect(() => {
		if (open) sid = '';
	});

	function submit() {
		onSubmit(sid);
	}
</script>

<Modal {open} title={`Transfer ${property?.label ?? ''}`} submitLabel="Transfer Property" {onClose} onSubmit={submit}>
	<p>Property: {property?.label}</p>
	<p><i>Please make sure personal belongings and vehicles are removed from the property before transfer.</i></p>
	<label class="field">
		<span>State ID of New Owner</span>
		<input type="text" inputmode="numeric" bind:value={sid} />
	</label>
</Modal>

<style>
	.field {
		display: block;
		margin-top: 0.8rem;
	}

	.field span {
		display: block;
		font-size: 0.72rem;
		color: var(--color-text-muted);
		margin-bottom: 0.25rem;
	}

	input {
		width: 100%;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.4rem;
		font-size: 0.78rem;
	}
</style>
