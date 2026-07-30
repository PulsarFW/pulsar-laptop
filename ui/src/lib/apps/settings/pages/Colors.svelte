<script lang="ts">
	import { getBucket } from '../../../store/data.svelte';
	import { updateSetting } from '../update';
	import type { LaptopSettings } from '../../../types';

	const settings = $derived(getBucket<{ LaptopSettings: LaptopSettings }>('player')?.LaptopSettings);
	const accent = $derived(settings?.colors?.accent ?? '#1a7cc1');

	function onChange(e: Event) {
		const hex = (e.target as HTMLInputElement).value;
		updateSetting('colors', { ...settings?.colors, accent: hex });
	}
</script>

<div class="colors-page">
	<div class="row">
		<div class="swatch" style:background={accent}></div>
		<div class="info">
			<span class="label">Accent Color</span>
			<span class="value">{accent}</span>
		</div>
		<input type="color" value={accent} onchange={onChange} aria-label="Accent color" />
	</div>
</div>

<style>
	.colors-page {
		padding: 0.8rem;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.8rem;
		background: var(--color-bg-panel-alt);
		border-radius: var(--radius);
		padding: 0.9rem;
	}

	.swatch {
		width: 2.6rem;
		height: 2.6rem;
		border-radius: 50%;
		flex-shrink: 0;
		border: var(--border-subtle);
	}

	.info {
		flex: 1;
		display: flex;
		flex-direction: column;
	}

	.label {
		font-family: var(--font-heading);
		font-size: 0.9rem;
	}

	.value {
		font-size: 0.75rem;
		color: var(--color-text-muted);
	}

	input[type='color'] {
		width: 2.6rem;
		height: 2.6rem;
		border: none;
		background: transparent;
		cursor: pointer;
	}
</style>
