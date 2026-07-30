<!-- multi-select employee picker, reused across Documents/Receipts/Notices forms for signers/co-authors -->
<script lang="ts">
	import Icon from '../../Icon.svelte';
	import { getBucket } from '../../store/data.svelte';
	import { Nui } from '../../nui';
	import type { EmployeeSearchResult } from '../../types';

	let {
		label,
		placeholder = 'Search employees…',
		value = $bindable([]),
		job = 'pdm',
		disableSelf = true,
	}: {
		label: string;
		placeholder?: string;
		value: EmployeeSearchResult[];
		job?: string;
		disableSelf?: boolean;
	} = $props();

	const me = $derived(getBucket<{ SID: number }>('player'));

	let query = $state('');
	let options = $state<EmployeeSearchResult[]>([]);
	let open = $state(false);

	$effect(() => {
		void job;
		Nui.bizWizEmployeeSearch(job).then((res) => {
			options = res || [];
		});
	});

	const filteredOptions = $derived(
		options.filter((o) => !value.some((v) => v.SID === o.SID) && `${o.First} ${o.Last} ${o.SID}`.toLowerCase().includes(query.toLowerCase())),
	);

	function select(option: EmployeeSearchResult) {
		if (disableSelf && option.SID === me?.SID) return;
		value = [...value, option];
		query = '';
		open = false;
	}

	function remove(sid: number) {
		value = value.filter((v) => v.SID !== sid);
	}
</script>

<div class="search">
	<span class="label">{label}</span>
	<div class="chips">
		{#each value as v (v.SID)}
			<span class="chip" class:self={disableSelf && v.SID === me?.SID}>
				{v.First} {v.Last} ({v.SID})
				{#if !(disableSelf && v.SID === me?.SID)}
					<button type="button" onclick={() => remove(v.SID)} aria-label="Remove">
						<Icon name="xmark" size="0.65em" />
					</button>
				{/if}
			</span>
		{/each}
	</div>
	<div class="input-wrap">
		<input type="text" {placeholder} bind:value={query} onfocus={() => (open = true)} onblur={() => setTimeout(() => (open = false), 150)} />
		{#if open && filteredOptions.length > 0}
			<div class="dropdown">
				{#each filteredOptions as option (option.SID)}
					<button type="button" class="option" onmousedown={() => select(option)}>
						<span>{option.First} {option.Last}</span>
						<span class="sid">SID: {option.SID}</span>
					</button>
				{/each}
			</div>
		{/if}
	</div>
</div>

<style>
	.search {
		margin-bottom: 0.8rem;
	}

	.label {
		display: block;
		font-size: 0.72rem;
		color: var(--color-text-muted);
		margin-bottom: 0.35rem;
	}

	.chips {
		display: flex;
		flex-wrap: wrap;
		gap: 0.35rem;
		margin-bottom: 0.35rem;
	}

	.chip {
		display: flex;
		align-items: center;
		gap: 0.3rem;
		background: rgba(139, 92, 246, 0.15);
		color: var(--color-primary-light);
		border-radius: 999px;
		padding: 0.2rem 0.6rem;
		font-size: 0.72rem;
	}

	.chip.self {
		background: rgba(255, 255, 255, 0.08);
		color: var(--color-text-muted);
	}

	.chip button {
		background: transparent;
		border: none;
		color: inherit;
		cursor: pointer;
		display: flex;
		padding: 0;
	}

	.input-wrap {
		position: relative;
	}

	input {
		width: 100%;
		background: var(--color-bg);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
	}

	.dropdown {
		position: absolute;
		top: calc(100% + 0.2rem);
		left: 0;
		right: 0;
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		max-height: 10rem;
		overflow-y: auto;
		z-index: 20;
	}

	.option {
		width: 100%;
		display: flex;
		justify-content: space-between;
		gap: 0.5rem;
		padding: 0.4rem 0.6rem;
		background: transparent;
		border: none;
		color: var(--color-text);
		text-align: left;
		font-size: 0.75rem;
		cursor: pointer;
	}

	.option:hover {
		background: rgba(139, 92, 246, 0.12);
	}

	.sid {
		color: var(--color-text-muted);
	}
</style>
