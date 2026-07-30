<script lang="ts">
	import Icon from '../../../Icon.svelte';
	import { getBucket } from '../../../store/data.svelte';
	import { updateSetting } from '../update';
	import { WALLPAPERS } from '../../../wallpapers';
	import type { LaptopSettings } from '../../../types';

	const settings = $derived(getBucket<{ LaptopSettings: LaptopSettings }>('player')?.LaptopSettings);
	const isBuiltIn = $derived(!!settings && WALLPAPERS.some((w) => w.id === settings.wallpaper));

	let customUrl = $state('');
	let customOpen = $state(false);

	function pick(id: string) {
		updateSetting('wallpaper', id);
	}

	function openCustom() {
		customUrl = !isBuiltIn ? (settings?.wallpaper ?? '') : '';
		customOpen = true;
	}

	function saveCustom() {
		if (customUrl.trim() !== '') updateSetting('wallpaper', customUrl.trim());
		customOpen = false;
	}
</script>

<div class="wallpaper-page">
	<div class="grid">
		<button type="button" class="tile custom" class:active={!isBuiltIn} onclick={openCustom}>
			{#if !isBuiltIn && settings?.wallpaper}
				<img src={settings.wallpaper} alt="Custom wallpaper" />
			{:else}
				<div class="add"><Icon name="circle-info" size="1.6rem" /></div>
			{/if}
			<span class="label">Custom</span>
		</button>
		{#each WALLPAPERS as wp (wp.id)}
			<button type="button" class="tile" class:active={settings?.wallpaper === wp.id} onclick={() => pick(wp.id)}>
				<img src={wp.file} alt={wp.label} />
				<span class="label">{wp.label}</span>
			</button>
		{/each}
	</div>

	{#if customOpen}
		<div
			class="modal-backdrop"
			role="button"
			tabindex="0"
			onclick={() => (customOpen = false)}
			onkeydown={(e) => e.key === 'Escape' && (customOpen = false)}
		>
			<!-- svelte-ignore a11y_click_events_have_key_events -->
			<div class="modal" role="dialog" tabindex="-1" onclick={(e) => e.stopPropagation()}>
				<h3>Custom Wallpaper</h3>
				{#if customUrl}
					<img class="preview" src={customUrl} alt="Preview" />
				{/if}
				<input type="text" placeholder="Image URL" bind:value={customUrl} />
				<div class="row">
					<button type="button" class="btn cancel" onclick={() => (customOpen = false)}>Cancel</button>
					<button type="button" class="btn save" onclick={saveCustom}>Save</button>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.wallpaper-page {
		height: 100%;
		overflow-y: auto;
		padding: 0.8rem;
	}

	.grid {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		gap: 0.7rem;
	}

	.tile {
		background: var(--color-bg-panel-alt);
		border: 2px solid transparent;
		border-radius: var(--radius);
		padding: 0.4rem;
		cursor: pointer;
		text-align: left;
	}

	.tile:hover {
		border-color: rgba(139, 92, 246, 0.35);
	}

	.tile.active {
		border-color: var(--color-primary);
	}

	.tile img {
		width: 100%;
		height: 6rem;
		object-fit: cover;
		border-radius: 2px;
		display: block;
	}

	.tile .add {
		width: 100%;
		height: 6rem;
		display: flex;
		align-items: center;
		justify-content: center;
		background: var(--color-bg);
		color: var(--color-text-muted);
		border-radius: 2px;
	}

	.label {
		display: block;
		font-size: 0.72rem;
		margin-top: 0.4rem;
		color: var(--color-text-muted);
	}

	.modal-backdrop {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.55);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 50;
	}

	.modal {
		width: 22rem;
		background: var(--color-bg-panel);
		border: var(--border-primary);
		border-radius: var(--radius);
		padding: 1rem;
	}

	.modal h3 {
		margin: 0 0 0.7rem;
		font-family: var(--font-heading);
		font-size: 0.95rem;
	}

	.preview {
		width: 100%;
		height: 8rem;
		object-fit: cover;
		border-radius: 2px;
		margin-bottom: 0.6rem;
	}

	.modal input {
		width: 100%;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
	}

	.row {
		display: flex;
		gap: 0.5rem;
		margin-top: 0.8rem;
	}

	.btn {
		flex: 1;
		padding: 0.4rem 0;
		border-radius: var(--radius);
		border: none;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.btn.save {
		background: var(--color-primary);
		color: #fff;
	}

	.btn.cancel {
		background: rgba(255, 255, 255, 0.08);
		color: var(--color-text);
	}
</style>
