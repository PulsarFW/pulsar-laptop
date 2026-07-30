import type {
	BoostingContract,
	BusinessDocument,
	BusinessReceipt,
	CasinoWin,
	ChopListData,
	DealerData,
	EmployeeSearchResult,
	FleetVehicle,
	MarketItem,
	Property,
	ReputationEntry,
	Team,
	TeamRequest,
	VehicleStock,
} from './types';

export const MOCK_TEAMS: Team[] = [
	{
		ID: 2,
		Name: 'Nightshift',
		State: 0,
		StateName: 'Available',
		Members: [
			{ Leader: true, Source: 2, SID: 2, First: 'Vinny', Last: 'Cross' },
			{ Leader: false, Source: 3, SID: 3, First: 'Reggie', Last: 'Stone' },
		],
	},
	{
		ID: 4,
		Name: 'Blacktop',
		State: 1,
		StateName: 'Busy',
		Members: [{ Leader: true, Source: 4, SID: 4, First: 'Dana', Last: 'Foles' }],
	},
];

export const MOCK_TEAM_REQUESTS: TeamRequest[] = [
	{
		id: 1,
		time: Math.floor(Date.now() / 1000) - 30,
		expires: Math.floor(Date.now() / 1000) + 90,
		owner: 1,
		team: false,
		event: 'Laptop:Server:Teams:Invite',
		label: 'New Team Invite',
		description: 'To Join Nightshift',
		data: { invite: true, team: 2 },
	},
];

export const MOCK_EMPLOYEES: EmployeeSearchResult[] = [
	{ SID: 1, First: 'Testy', Last: 'McTest' },
	{ SID: 5, First: 'Marco', Last: 'Reyes' },
	{ SID: 6, First: 'Ida', Last: 'Whitlock' },
];

export const MOCK_DEALER_DATA: DealerData = { profitPercentage: 15, commission: 15 };

export const MOCK_PDM_STOCK: VehicleStock[] = [
	{
		_id: '1',
		dealership: 'pdm',
		data: { category: 'sedans', model: 'Tailgater S', price: 82500, make: 'Obey', class: 'A' },
		quantity: 4,
		vehicle: 'tailgater2',
		lastStocked: Math.floor(Date.now() / 1000) - 86400,
	},
	{
		_id: '2',
		dealership: 'pdm',
		data: { category: 'muscle', model: 'Sabre Turbo', price: 110000, make: 'Declasse', class: 'A' },
		quantity: 1,
		vehicle: 'sabregt',
		lastStocked: Math.floor(Date.now() / 1000) - 172800,
		lastPurchase: Math.floor(Date.now() / 1000) - 3600,
	},
	{
		_id: '3',
		dealership: 'pdm',
		data: { category: 'suv', model: 'Seminole', price: 23750, make: 'Canis', class: 'C' },
		quantity: 10,
		vehicle: 'seminole',
		lastStocked: Math.floor(Date.now() / 1000) - 43200,
	},
];

export const MOCK_FLEET: FleetVehicle[] = [
	{
		RegistrationDate: Math.floor(Date.now() / 1000) - 604800,
		VIN: 'VIN-001',
		RegisteredPlate: 'PDM001',
		Make: 'Vapid',
		Model: 'Speedo',
		Storage: { Name: 'PDM Lot' },
	},
];

export const MOCK_PROPERTIES: Property[] = [
	{
		_id: '1',
		label: 'Vinewood Hills Manor',
		sold: false,
		type: 'house',
		location: { front: { x: -689.22, y: 315.94, z: 81.9, h: 175.7 } },
		interior: 2,
		price: 450000,
	},
	{
		_id: '2',
		label: 'Downtown Office',
		sold: true,
		type: 'office',
		location: { front: { x: 394.36, y: -816.54, z: 28.08, h: 102.0 } },
		interior: 40,
		price: 250000,
		owner: { First: 'Testy', Last: 'McTest', SID: 1 },
	},
];

export const MOCK_CASINO_WINS: CasinoWin[] = [
	{ _id: '1', Type: 'blackjack', Prize: 12500, Winner: { First: 'Testy', Last: 'McTest', SID: 1 }, Time: Math.floor(Date.now() / 1000) - 1800 },
	{ _id: '2', Type: 'blackjack', Prize: 4800, Winner: { First: 'Marco', Last: 'Reyes', SID: 5 }, Time: Math.floor(Date.now() / 1000) - 7200 },
];

export const MOCK_DOCUMENTS: BusinessDocument[] = [
	{
		_id: '1',
		title: 'Shift Handover Notes',
		notes: 'Front counter restocked. Cash drawer counted and locked. Next shift should follow up on the Sabre Turbo repaint order.',
		pinned: true,
		time: Math.floor(Date.now() / 1000) - 3600,
		author: { First: 'Testy', Last: 'McTest', SID: 1 },
	},
	{
		_id: '2',
		title: 'Vendor Contact List',
		notes: 'Parts supplier: 555-0142. Tow contractor: 555-0198.',
		pinned: false,
		time: Math.floor(Date.now() / 1000) - 172800,
		author: { First: 'Marco', Last: 'Reyes', SID: 5 },
	},
];

export const MOCK_REPUTATIONS: ReputationEntry[] = [
	{ id: 'Chopping', label: 'Chopping', value: 1200, current: { value: 0, label: 'Novice' }, next: { value: 2500, label: 'Skilled' } },
	{ id: 'Racing', label: 'Racing', value: 400, current: { value: 0, label: 'Rookie' }, next: { value: 1000, label: 'Amateur' } },
	{ id: 'Salvaging', label: 'Salvaging', value: 3000, current: { value: 2500, label: 'Veteran' }, next: { value: 5000, label: 'Master' } },
];

export const MOCK_MARKET_ITEMS: MarketItem[] = [
	{ id: 1, item: 'racing_dongle', itemData: { name: 'racing_dongle', label: 'Racing Dongle' }, coin: 'VRM', price: 15, qty: 4 },
	{ id: 2, item: 'chop_torch', itemData: { name: 'chop_torch', label: 'Cutting Torch' }, coin: 'VRM', price: 30, qty: -1 },
];

export const MOCK_CHOP_LIST: ChopListData = {
	Public: { public: true, list: [{ name: 'Vapid Speedo' }, { name: 'Obey Tailgater', hv: true }] },
	Personal: { id: 1, list: [{ name: 'Declasse Sabre Turbo' }] },
};

export const MOCK_BOOSTING_CONTRACTS: BoostingContract[] = [
	{
		id: 1,
		owner: { SID: 1, Alias: 'MeFast' },
		vehicle: { model: 'drafter', label: 'Drafter', class: 'A+', classLevel: 4000 },
		prices: { standard: { price: 25, coin: 'VRM' }, scratch: { price: 50, coin: 'VRM' } },
		expires: Math.floor(Date.now() / 1000) + 3600,
	},
];

export const MOCK_RECEIPTS: BusinessReceipt[] = [
	{
		_id: '1',
		type: 'Full Repair',
		customerName: 'Bob Johnson',
		customerNumber: '555-0110',
		paymentAmount: '450',
		paymentPaid: '450',
		workers: [{ SID: 5, First: 'Marco', Last: 'Reyes' }],
		notes: 'Engine + suspension rebuild.',
		time: Math.floor(Date.now() / 1000) - 5400,
		author: { First: 'Testy', Last: 'McTest', SID: 1 },
	},
];
