<!-- taskbar: open-app icons (click to focus/minimize) + system tray (team/race/wifi/clock) -->
<script lang="ts">
	import Icon from '../Icon.svelte';
	import { laptopState } from '../store/laptop.svelte';
	import { getBucket } from '../store/data.svelte';
	import { windowsState, toggleMinimize } from '../store/windows.svelte';

	const player = $derived(getBucket<{ States?: string[] }>('player'));
	const myGroup = $derived(getBucket('myGroup'));
	const hasState = (state: string) => !!player?.States?.includes(state);
</script>

<div class="footer">
	<div class="apps">
		{#each windowsState.appStates as win (win.app)}
			{@const entry = laptopState.apps[win.app]}
			{#if entry}
				<button
					type="button"
					class="app-tab"
					class:focused={windowsState.focused === win.app}
					onclick={() => toggleMinimize(win.app)}
				>
					<span class="tab-icon" style:background={entry.color}>
						<Icon name={entry.icon} size="1rem" />
					</span>
				</button>
			{/if}
		{/each}
	</div>
	<div class="tray">
		{#if myGroup}
			<span class="tray-icon team"><Icon name="people-group" /></span>
		{/if}
		{#if hasState('RACE_DONGLE')}
			<span class="tray-icon race"><Icon name="flag-checkered" /></span>
		{/if}
		<span class="tray-icon" class:vpn={hasState('PHONE_VPN')}><Icon name="wifi" /></span>
		<span class="tray-icon"><Icon name="signal" /></span>
		<div class="clock">
			<span>{laptopState.time.hour.toString().padStart(2, '0')}:{laptopState.time.minute.toString().padStart(2, '0')}</span>
		</div>
	</div>
</div>

<style>
	.footer {
		height: 3rem;
		flex-shrink: 0;
		display: flex;
		background: var(--color-bg-panel);
		border-top: var(--border-subtle);
	}

	.apps {
		flex: 1;
		display: flex;
	}

	.app-tab {
		width: 4rem;
		background: transparent;
		border: none;
		border-bottom: 2px solid transparent;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: background 150ms ease;
	}

	.app-tab:hover {
		background: rgba(255, 255, 255, 0.06);
	}

	.app-tab.focused {
		border-bottom-color: var(--color-primary);
		background: var(--color-bg-panel-alt);
	}

	.tab-icon {
		width: 1.8rem;
		height: 1.8rem;
		border-radius: 0.4rem;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #fff;
	}

	.tray {
		display: flex;
		align-items: center;
		gap: 0.7rem;
		padding: 0 1rem;
		font-size: 0.85rem;
	}

	.tray-icon {
		color: var(--color-text-muted);
	}

	.tray-icon.vpn {
		color: var(--color-error);
	}

	.tray-icon.race {
		color: var(--color-info);
	}

	.tray-icon.team {
		color: var(--color-success);
	}

	.clock {
		font-size: 0.75rem;
		color: var(--color-text-muted);
	}
</style>
