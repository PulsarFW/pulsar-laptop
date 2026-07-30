<script lang="ts">
	import { onMount } from 'svelte';
	import Shell from './lib/Shell.svelte';
	import { startMessageListener } from './lib/messages';
	import { laptopState } from './lib/store/laptop.svelte';
	import { Nui } from './lib/nui';

	onMount(() => {
		startMessageListener();

		function onKeyDown(e: KeyboardEvent) {
			// F3 matches old's keyCode 114 - kept for parity
			if (!laptopState.visible || (e.key !== 'Escape' && e.key !== 'F3')) return;
			laptopState.visible = false;
			Nui.closeLaptop();
		}

		window.addEventListener('keydown', onKeyDown);
		return () => window.removeEventListener('keydown', onKeyDown);
	});
</script>

<Shell />
