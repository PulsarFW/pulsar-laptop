<script lang="ts">
	import { toast } from '../../../store/toast.svelte';
	import { Nui } from '../../../nui';

	let { onNav }: { onNav: (id: string) => void } = $props();

	let tweet = $state('');
	let usingImg = $state(false);
	let imgLink = $state('');

	async function onCreate() {
		const res = await Nui.sendBusinessTweet(tweet, { using: usingImg, link: imgLink });
		if (res) {
			tweet = '';
			usingImg = false;
			imgLink = '';
			toast.success('Spam Created');
			onNav('Dashboard');
		} else {
			toast.error('Unable to Create Spam');
		}
	}
</script>

<div class="tweet">
	<div class="notice">Please use for business purposes only. Abuse of this will have your business permanently banned from using Spammer.</div>

	<div class="row">
		<label class="field">
			<span>Spam ({tweet.length} / 180 Characters)</span>
			<textarea bind:value={tweet} maxlength="180"></textarea>
		</label>
		<button type="button" class="submit" onclick={onCreate}>Post Spam</button>
	</div>

	<label class="checkbox">
		<input type="checkbox" bind:checked={usingImg} />
		Include An Image?
	</label>

	{#if usingImg}
		<label class="field">
			<span>Image (Imgur Links Only!)</span>
			<input type="text" bind:value={imgLink} />
		</label>
		{#if imgLink !== ''}
			<img src={imgLink} alt="Tweet preview" class="preview" />
		{/if}
	{/if}
</div>

<style>
	.tweet {
		height: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.8rem;
		padding: 1rem 0.6rem 1rem 1rem;
		overflow-y: auto;
	}

	.notice {
		background: rgba(56, 189, 248, 0.1);
		border: 1px solid rgba(56, 189, 248, 0.3);
		border-radius: var(--radius);
		color: #7dd3fc;
		padding: 0.6rem 0.8rem;
		font-size: 0.78rem;
	}

	.row {
		display: flex;
		gap: 0.6rem;
		align-items: flex-end;
	}

	.field {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.field span {
		font-size: 0.72rem;
		color: var(--color-text-muted);
	}

	.field input,
	.field textarea {
		background: var(--color-bg-panel-alt);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.5rem;
		font-size: 0.8rem;
		font-family: inherit;
	}

	.field textarea {
		min-height: 5rem;
		resize: vertical;
	}

	.submit {
		background: rgba(255, 255, 255, 0.08);
		border: var(--border-subtle);
		border-radius: var(--radius);
		color: var(--color-text);
		padding: 0.55rem 1rem;
		font-size: 0.78rem;
		cursor: pointer;
	}

	.checkbox {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		font-size: 0.78rem;
		color: var(--color-text-muted);
	}

	.preview {
		width: 12rem;
		margin: 0 auto;
		display: block;
		border-radius: var(--radius);
	}
</style>
