export interface GameCategory {
	value: string;
	label: string;
}

export const GAME_CATEGORIES: GameCategory[] = [
	{ value: 'all', label: 'All' },
	{ value: 'blackjack', label: 'Blackjack' },
];
