<script lang="ts">
	import Modal from '../../../primitives/Modal.svelte';
	import type { VehicleStock } from '../../../types';

	let { open, vehicle, onClose, onSubmit }: { open: boolean; vehicle: VehicleStock | null; onClose: () => void; onSubmit: () => void } = $props();
</script>

<Modal {open} title={`Test Drive ${vehicle?.data.make ?? ''} ${vehicle?.data.model ?? ''}`} submitLabel="Confirm Test Drive" {onClose} {onSubmit}>
	<p>Vehicle: {vehicle?.data.make} {vehicle?.data.model}</p>
</Modal>
