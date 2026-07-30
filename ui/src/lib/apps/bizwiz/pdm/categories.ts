export interface VehicleCategory {
	value: string;
	label: string;
}

export const VEHICLE_CATEGORIES: VehicleCategory[] = [
	{ value: 'all', label: 'All' },
	{ value: 'import', label: 'Imports' },
	{ value: 'drift', label: 'Drifts' },
	{ value: 'tuner', label: 'Tuners' },
	{ value: 'coupe', label: 'Coupes' },
	{ value: 'compact', label: 'Compacts' },
	{ value: 'suv', label: 'SUVs' },
	{ value: 'sedans', label: 'Sedan' },
	{ value: 'muscle', label: 'Muscle' },
	{ value: 'sport', label: 'Sports' },
	{ value: 'sportclassic', label: 'Sports Classic' },
	{ value: 'super', label: 'Super' },
	{ value: 'motorcycles', label: 'Motorcycles' },
	{ value: 'offroad', label: 'Off-road' },
	{ value: 'rally', label: 'Rally' },
	{ value: 'van', label: 'Vans' },
	{ value: 'utility', label: 'Utility' },
	{ value: 'misc', label: 'Miscellaneous' },
];

export function categoryLabel(value: string | undefined): string {
	return VEHICLE_CATEGORIES.find((c) => c.value === value)?.label ?? 'Unknown';
}
