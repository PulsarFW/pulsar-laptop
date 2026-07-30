<!-- toast stack, top-right. Accept/Cancel relay back through the generic popup dispatch so any
	 app's action.accept/action.cancel event names work without this component knowing about them -->
<script lang="ts">
	import Icon from '../Icon.svelte';
	import { notificationsState, dismissNotification } from '../store/notifications.svelte';
	import { Nui } from '../nui';

	// routing between TriggerServerEvent/TriggerEvent happens Lua-side off the `server` flag in extra
	function respond(id: number | string, event: string | undefined, extra?: Record<string, unknown>) {
		dismissNotification(id);
		if (!event) return;
		Nui.acceptPopup(event, extra);
	}
</script>

<div class="stack">
	{#each notificationsState.notifications.filter((n) => n.show) as notif (notif._id)}
		<div class="toast">
			<div class="title">{notif.title}</div>
			<div class="desc">{notif.description}</div>
			<div class="row">
				{#if notif.action?.accept}
					<button type="button" class="btn accept" onclick={() => respond(notif._id, notif.action?.accept)}>
						<Icon name="check" size="0.8em" /> Accept
					</button>
				{/if}
				{#if notif.action?.cancel}
					<button type="button" class="btn cancel" onclick={() => respond(notif._id, notif.action?.cancel)}>
						<Icon name="xmark" size="0.8em" /> Dismiss
					</button>
				{/if}
				{#if !notif.action?.accept && !notif.action?.cancel}
					<button type="button" class="btn cancel" onclick={() => dismissNotification(notif._id)}>
						<Icon name="xmark" size="0.8em" />
					</button>
				{/if}
			</div>
		</div>
	{/each}
</div>

<style>
	.stack {
		position: absolute;
		top: 3.5rem;
		right: 0.8rem;
		width: 17rem;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		pointer-events: none;
		z-index: 500;
	}

	.toast {
		pointer-events: auto;
		background: var(--color-bg-panel);
		border: var(--border-subtle);
		border-left: 3px solid var(--color-primary);
		border-radius: var(--radius);
		padding: 0.7rem 0.8rem;
	}

	.title {
		font-family: var(--font-heading);
		font-size: 0.85rem;
		margin-bottom: 0.2rem;
	}

	.desc {
		font-size: 0.78rem;
		color: var(--color-text-muted);
		line-height: 1.35;
	}

	.row {
		display: flex;
		gap: 0.4rem;
		margin-top: 0.5rem;
	}

	.btn {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.35rem;
		padding: 0.3rem 0;
		border-radius: var(--radius);
		border: none;
		font-size: 0.72rem;
		cursor: pointer;
	}

	.btn.accept {
		background: var(--color-primary);
		color: #fff;
	}

	.btn.cancel {
		background: rgba(255, 255, 255, 0.08);
		color: var(--color-text);
	}
</style>
