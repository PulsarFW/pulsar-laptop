<!-- generic confirm/form dialog - covers old's Modal usage across Teams (create/invite/remove/delete) -->
<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		open,
		title,
		submitLabel = 'Save',
		submitVariant = 'primary',
		disabled = false,
		onClose,
		onSubmit,
		children,
	}: {
		open: boolean;
		title: string;
		submitLabel?: string;
		submitVariant?: 'primary' | 'danger';
		disabled?: boolean;
		onClose: () => void;
		onSubmit?: () => void;
		children: Snippet;
	} = $props();

	function handleSubmit(e: Event) {
		e.preventDefault();
		onSubmit?.();
	}
</script>

{#if open}
	<div class="backdrop" role="presentation" onclick={onClose}>
		<!-- svelte-ignore a11y_click_events_have_key_events -->
		<div class="modal" role="dialog" aria-label={title} tabindex="-1" onclick={(e) => e.stopPropagation()}>
			<h3>{title}</h3>
			<form onsubmit={handleSubmit}>
				<div class="body">
					{@render children()}
				</div>
				<div class="actions">
					<button type="button" class="btn cancel" onclick={onClose}>Cancel</button>
					<button type="submit" class="btn" class:primary={submitVariant === 'primary'} class:danger={submitVariant === 'danger'} {disabled}>
						{submitLabel}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	.backdrop {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.55);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 100;
	}

	.modal {
		width: 22rem;
		background: var(--color-bg-panel);
		border: var(--border-primary);
		border-radius: var(--radius);
		padding: 1rem;
	}

	h3 {
		margin: 0 0 0.8rem;
		font-family: var(--font-heading);
		font-size: 0.95rem;
	}

	.body {
		font-size: 0.82rem;
		color: var(--color-text-muted);
		line-height: 1.4;
	}

	.actions {
		display: flex;
		gap: 0.5rem;
		margin-top: 1rem;
	}

	.btn {
		flex: 1;
		padding: 0.45rem 0;
		border-radius: var(--radius);
		border: none;
		font-size: 0.78rem;
		cursor: pointer;
		background: rgba(255, 255, 255, 0.08);
		color: var(--color-text);
	}

	.btn.primary {
		background: var(--color-primary);
		color: #fff;
	}

	.btn.danger {
		background: var(--color-error);
		color: #fff;
	}

	.btn:disabled {
		opacity: 0.5;
		cursor: default;
	}
</style>
