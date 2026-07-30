<script lang="ts">
	import Modal from '../../../primitives/Modal.svelte';
	import type { Property, PropertyUpgradeConfig } from '../../../types';

	let {
		open,
		property,
		upgrades,
		onClose,
	}: { open: boolean; property: Property | null; upgrades?: PropertyUpgradeConfig; onClose: () => void } = $props();

	const propertyUpgrades = $derived(property ? upgrades?.[property.type] : undefined);
	const interiorLevel = $derived(propertyUpgrades?.interior?.levels?.find((l) => l.id === property?.upgrades?.interior));
	const otherUpgrades = $derived(
		propertyUpgrades
			? Object.entries(propertyUpgrades)
					.filter(([key]) => key !== 'interior')
					.map(([key, category]) => {
						const level = category.levels[(property?.upgrades?.[key] ?? 1) - 1];
						return { key, level };
					})
					.filter((u) => u.level)
			: [],
	);

	function describeInfo(info: string | { description?: string } | undefined): string {
		if (!info) return '';
		return typeof info === 'string' ? info : (info.description ?? '');
	}
</script>

<Modal {open} title={property?.label ?? ''} submitLabel="Close" {onClose} onSubmit={onClose}>
	{#if propertyUpgrades && interiorLevel}
		<p>Property: {property?.label}</p>
		<p>Property Owner: {property?.owner ? `${property.owner.First} ${property.owner.Last} (${property.owner.SID})` : 'Not Owned'}</p>
		<p>Property Interior: {interiorLevel.name} - {describeInfo(interiorLevel.info)}</p>
		{#each otherUpgrades as u (u.key)}
			<p>Property Upgrade: {u.level.name} - {describeInfo(u.level.info)}</p>
		{/each}
	{:else}
		<p>No upgrade data available.</p>
	{/if}
</Modal>
