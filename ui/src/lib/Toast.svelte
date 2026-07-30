<script lang="ts">
	import Icon from './Icon.svelte';
	import { toastState, dismissToast } from './store/toast.svelte';
</script>

<div class="stack">
	{#each toastState.toasts as t (t.id)}
		<div class="toast" class:error={t.kind === 'error'}>
			<Icon name={t.kind === 'success' ? 'circle-check' : 'circle-exclamation'} size="1rem" />
			<span class="message">{t.message}</span>
			<button type="button" class="close" onclick={() => dismissToast(t.id)} aria-label="Dismiss">
				<Icon name="xmark" size="0.75rem" />
			</button>
		</div>
	{/each}
</div>

<style>
	.stack {
		position: absolute;
		bottom: 3.6rem;
		right: 0.8rem;
		display: flex;
		flex-direction: column-reverse;
		gap: 0.4rem;
		pointer-events: none;
		z-index: 600;
	}

	.toast {
		display: flex;
		align-items: center;
		gap: 0.6rem;
		background: rgba(6, 6, 8, 0.97);
		border: var(--border-subtle);
		border-left: 3px solid var(--color-success);
		border-radius: var(--radius);
		padding: 0.6rem 0.7rem;
		min-width: 14rem;
		max-width: 20rem;
		pointer-events: auto;
		color: var(--color-success);
	}

	.toast.error {
		border-left-color: var(--color-error);
		color: var(--color-error);
	}

	.message {
		flex: 1;
		font-size: 0.78rem;
		color: var(--color-text);
	}

	.close {
		background: transparent;
		border: none;
		color: var(--color-text-muted);
		cursor: pointer;
		display: flex;
		padding: 0;
		flex-shrink: 0;
	}
</style>
