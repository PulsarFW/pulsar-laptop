import w1 from '../assets/wallpapers/1.webp';
import w2 from '../assets/wallpapers/2.webp';
import w3 from '../assets/wallpapers/3.webp';
import w4 from '../assets/wallpapers/4.webp';
import w5 from '../assets/wallpapers/5.webp';
import w6 from '../assets/wallpapers/6.webp';
import w7 from '../assets/wallpapers/7.webp';
import w8 from '../assets/wallpapers/8.webp';
import w9 from '../assets/wallpapers/9.webp';
import w10 from '../assets/wallpapers/10.webp';

export interface WallpaperEntry {
	id: string;
	file: string;
	label: string;
}

export const WALLPAPERS: WallpaperEntry[] = [
	{ id: 'wallpaper', file: w1, label: 'Wallpaper 1' },
	{ id: 'wallpaper2', file: w2, label: 'Wallpaper 2' },
	{ id: 'wallpaper3', file: w3, label: 'Wallpaper 3' },
	{ id: 'wallpaper4', file: w4, label: 'Wallpaper 4' },
	{ id: 'wallpaper5', file: w5, label: 'Wallpaper 5' },
	{ id: 'wallpaper6', file: w6, label: 'Wallpaper 6' },
	{ id: 'wallpaper7', file: w7, label: 'Wallpaper 7' },
	{ id: 'wallpaper8', file: w8, label: 'Wallpaper 8' },
	{ id: 'wallpaper9', file: w9, label: 'Wallpaper 9' },
	{ id: 'wallpaper10', file: w10, label: 'Wallpaper 10' },
];

// old resolved settings.wallpaper through a lookup table, falling back to treating the
// value as a raw custom URL if it wasn't one of the 10 built-ins
export function resolveWallpaper(id: string | undefined): string {
	const found = WALLPAPERS.find((w) => w.id === id);
	return found ? found.file : (id ?? WALLPAPERS[0].file);
}
