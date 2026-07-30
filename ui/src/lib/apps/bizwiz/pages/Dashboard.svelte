<script lang="ts">
	import BusinessNotice from '../BusinessNotice.svelte';

	let { onNav }: { onNav: (id: string) => void } = $props();
</script>

<div class="dashboard">
	<BusinessNotice {onNav} />
</div>

<style>
	.dashboard {
		padding: 1rem 0.6rem 1rem 1rem;
		height: 100%;
		overflow-y: auto;
	}
</style>
