<script lang="ts">
	import Icon from '../../Icon.svelte';
	import Modal from '../../primitives/Modal.svelte';
	import { Nui } from '../../nui';
	import type { MarketItem } from '../../types';

	let { banned, items }: { banned: string[] | null; items: MarketItem[] } = $props();

	let cart = $state<(MarketItem & { quantity: number })[]>([]);
	let checkout = $state(false);
	let submitting = $state(false);

	function cartQty(item: MarketItem): number {
		return cart.find((i) => i.id === item.id)?.quantity ?? 0;
	}

	function onAdd(item: MarketItem) {
		const existing = cart.find((i) => i.id === item.id);
		if (existing) {
			if (existing.quantity >= 5) return;
			if (item.qty !== -1 && existing.quantity >= item.qty) return;
			cart = cart.map((i) => (i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i));
		} else {
			cart = [...cart, { ...item, quantity: 1 }];
		}
	}

	function onRemove(item: MarketItem) {
		const existing = cart.find((i) => i.id === item.id);
		if (!existing) return;
		if (existing.quantity > 1) {
			cart = cart.map((i) => (i.id === item.id ? { ...i, quantity: i.quantity - 1 } : i));
		} else {
			cart = cart.filter((i) => i.id !== item.id);
		}
	}

	async function onCheckout() {
		if (submitting) return;
		submitting = true;
		await Nui.lsuMarketCheckout(cart.map((i) => ({ id: i.id, quantity: i.quantity })));
		submitting = false;
		checkout = false;
		cart = [];
	}
</script>

{#if banned}
	<div class="empty">Denied...</div>
{:else}
	<div class="market">
		<div class="list">
			{#each items as item (item.id)}
				<div class="row">
					<span class="col">
						<span class="value">{item.itemData.label}</span>
						<span class="sub">
							{#if item.delayed}
								Not For Sale Yet
							{:else}
								{item.price} ${item.coin}{item.qty > -1 ? ` | ${item.qty} In Stock` : ''}
							{/if}
						</span>
					</span>
					<span class="actions">
						{#if cartQty(item) > 0}
							<span class="qty">{cartQty(item)}</span>
							<button type="button" class="icon-btn danger" disabled={submitting} onclick={() => onRemove(item)} aria-label="Remove one">
								<Icon name="minus" size="0.75em" />
							</button>
						{/if}
						<button
							type="button"
							class="icon-btn"
							disabled={submitting || (item.qty <= 0 && item.qty !== -1)}
							onclick={() => onAdd(item)}
							aria-label="Add one"
						>
							<Icon name="plus" size="0.75em" />
						</button>
					</span>
				</div>
			{/each}
		</div>

		{#if cart.length > 0}
			<button type="button" class="fab" disabled={submitting} onclick={() => (checkout = true)} aria-label="Checkout">
				<Icon name="money-check-dollar" size="1.1em" />
			</button>
		{/if}
	</div>
{/if}

<Modal open={checkout} title="Purchase Items" submitLabel="Checkout" disabled={submitting} onClose={() => (checkout = false)} onSubmit={onCheckout}>
	{#if submitting}
		<p>Submitting Order…</p>
	{/if}
	<div class="checkout-list">
		{#each cart as item (item.id)}
			<div class="checkout-row">
				<span>{item.itemData.label}</span>
				<span>${item.price * item.quantity} ({item.quantity} at {item.price} ${item.coin}/each)</span>
			</div>
		{/each}
	</div>
</Modal>

<style>
	.market {
		position: relative;
		height: 100%;
		overflow-y: auto;
		padding: 0.8rem;
	}

	.empty {
		padding: 3rem 0;
		text-align: center;
		color: var(--color-text-muted);
		font-size: 0.9rem;
	}

	.list {
		display: flex;
		flex-direction: column;
	}

	.row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 0.6rem;
		padding: 0.7rem 0;
		border-bottom: var(--border-subtle);
	}

	.col {
		display: flex;
		flex-direction: column;
		gap: 0.1rem;
	}

	.value {
		font-size: 0.85rem;
	}

	.sub {
		font-size: 0.7rem;
		color: var(--color-text-muted);
	}

	.actions {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		flex-shrink: 0;
	}

	.qty {
		font-size: 0.8rem;
		min-width: 1.2rem;
		text-align: center;
	}

	.icon-btn {
		width: 1.9rem;
		height: 1.9rem;
		border-radius: var(--radius);
		border: none;
		background: rgba(34, 197, 94, 0.15);
		color: #4ade80;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.icon-btn.danger {
		background: rgba(239, 68, 68, 0.15);
		color: #f87171;
	}

	.icon-btn:disabled {
		opacity: 0.4;
		cursor: default;
	}

	.fab {
		position: fixed;
		bottom: 1.5rem;
		right: 1.5rem;
		width: 3rem;
		height: 3rem;
		border-radius: 50%;
		border: none;
		background: var(--color-primary);
		color: #fff;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
	}

	.checkout-list {
		display: flex;
		flex-direction: column;
		gap: 0.4rem;
	}

	.checkout-row {
		display: flex;
		justify-content: space-between;
		font-size: 0.8rem;
	}
</style>
