<script lang="ts">
	import MyTeam from './MyTeam.svelte';
	import Available from './Available.svelte';
	import Requests from './Requests.svelte';
</script>

<div class="teams">
	<MyTeam />
	<Available />
	<Requests />
</div>

<style>
	.teams {
		height: 100%;
		display: flex;
		overflow-y: auto;
	}

	.teams > :global(.column:not(:last-child)) {
		border-right: var(--border-subtle);
	}
</style>
