export interface PropertyCategory {
	value: string;
	label: string;
}

export const PROPERTY_CATEGORIES: PropertyCategory[] = [
	{ value: 'all', label: 'All' },
	{ value: 'house', label: 'House' },
	{ value: 'office', label: 'Office' },
	{ value: 'warehouse', label: 'Warehouse' },
];

export function propertyCategoryLabel(value: string | undefined): string {
	return PROPERTY_CATEGORIES.find((c) => c.value === value)?.label ?? 'Unknown';
}
