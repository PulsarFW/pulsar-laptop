// dev-only simulated Lua message stream, mirrors server/data.lua's real app catalog + a plausible
// character blob so `bun run dev` shows a live desktop in a regular browser
import { handleMessage } from './messages';
import type { AppCatalog, BizWizPage, BusinessNotice, LaptopSettings } from './types';
import { MOCK_BOOSTING_CONTRACTS } from './mockData';

const MOCK_APPS: AppCatalog = {
	lsunderground: {
		name: 'lsunderground',
		storeLabel: 'LS UNDG',
		label: 'LS UNDG',
		icon: 'user-secret',
		color: '#E95200',
		unread: 2,
		restricted: { state: ['ACCESS_LSUNDERGROUND', 'PHONE_VPN', 'RACE_DONGLE'] },
	},
	teams: {
		name: 'teams',
		storeLabel: 'Teams',
		label: 'Teams',
		icon: 'people-group',
		color: '#8b5cf6',
		unread: 0,
	},
	bizwiz: {
		name: 'bizwiz',
		storeLabel: 'BizWiz',
		label: 'BizWiz',
		icon: 'business-time',
		color: '#135dd8',
		unread: 1,
	},
	settings: {
		name: 'settings',
		storeLabel: 'Settings',
		label: 'Settings',
		icon: 'gear',
		color: '#18191e',
		canUninstall: false,
		unread: 0,
	},
	internet: {
		name: 'internet',
		storeLabel: 'Interwebz',
		label: 'Interwebz',
		icon: 'spider-web',
		color: '#1db5e7',
		canUninstall: false,
		unread: 0,
		fake: true,
	},
	files: {
		name: 'files',
		storeLabel: 'Files',
		label: 'Files',
		icon: 'folder-open',
		color: '#D8A71E',
		canUninstall: false,
		unread: 0,
		fake: true,
	},
};

const MOCK_SETTINGS: LaptopSettings = {
	wallpaper: 'wallpaper',
	texttone: 'notification.ogg',
	colors: { accent: '#1a7cc1' },
	zoom: 75,
	volume: 100,
	notifications: true,
	appNotifications: {},
};

const MOCK_BIZWIZ_PAGES: BizWizPage[] = [
	{ id: 'Dashboard', icon: ['fas', 'house'], label: 'Dashboard' },
	{ id: 'Search/Document', icon: ['fas', 'file-lines'], label: 'Documents', permission: 'TABLET_VIEW_DOCUMENT' },
	{ id: 'View/Document', hidden: true },
	{ id: 'View/Receipt', hidden: true },
	{ id: 'Create/Document', hidden: true },
	{ id: 'Create/Notice', hidden: true },
	{ id: 'Create/Receipt', hidden: true },
	{ id: 'Search/Receipt', icon: ['fas', 'money-check-dollar'], label: 'Receipts' },
	{ id: 'Search/ReceiptCount', icon: ['fas', 'money-check-dollar'], label: 'Receipts Count' },
	{ id: 'PDM/Sales', icon: ['fas', 'car'], label: 'Sell Vehicles' },
	{ id: 'PDM/Credit', icon: ['fas', 'money-check-dollar'], label: 'Run Credit' },
	{ id: 'PDM/Manage', icon: ['fas', 'gear'], label: 'Manage Dealership' },
	{ id: 'PDM/SalesHistory', icon: ['fas', 'file-lines'], label: 'Sales History' },
	{ id: 'Dynasty/Properties', icon: ['fas', 'house'], label: 'Sell Properties' },
	{ id: 'Dynasty/Credit', icon: ['fas', 'money-check-dollar'], label: 'Run Credit' },
	{ id: 'Tweet', icon: ['fas', 'face-awesome'], label: 'Business Spammer', permission: 'TABLET_TWEET' },
	{ id: 'TweetSettings', icon: ['fas', 'face-awesome'], label: 'Spammer Profile', permission: 'JOB_MANAGEMENT' },
	{ id: 'FleetManagement', icon: ['fas', 'cars'], label: 'Fleet Management', permission: 'FLEET_MANAGEMENT' },
	{ id: 'Casino/BigWins', icon: ['fas', 'money-check-dollar'], label: 'Casino Big Wins' },
];

const MOCK_NOTICES: BusinessNotice[] = [
	{
		_id: 1,
		title: 'New Shipment In',
		description: 'Fresh parts arrived at the warehouse, restock the front counter before end of shift.',
		time: Math.floor(Date.now() / 1000) - 3600,
		job: 'pdm',
		author: { SID: 1, First: 'Testy', Last: 'McTest' },
	},
	{
		_id: 2,
		title: 'Schedule Change',
		description: 'Weekend shifts moved to 10am start starting next week.',
		time: Math.floor(Date.now() / 1000) - 86400,
		job: 'pdm',
		author: { SID: 5, First: 'Marco', Last: 'Reyes' },
	},
];

export function startMock(): void {
	setTimeout(() => {
		handleMessage('SET_APPS', MOCK_APPS);
		handleMessage('SET_DATA', {
			type: 'player',
			data: {
				SID: 1,
				First: 'Testy',
				Last: 'McTest',
				States: ['ACCESS_LSUNDERGROUND'],
				Jobs: [{ Id: 'pdm', Name: 'Premium Deluxe Motorsport', Workplace: { Id: 'pdm', Name: 'PDM' }, Grade: { Id: 'manager', Name: 'Manager' } }],
				LaptopApps: {
					home: ['settings', 'files', 'internet', 'bizwiz', 'teams', 'lsunderground'],
					installed: ['settings', 'files', 'internet', 'bizwiz', 'teams', 'lsunderground'],
				},
				LaptopSettings: MOCK_SETTINGS,
				Profiles: { redline: { name: 'MeFast' } },
				BoostingContracts: MOCK_BOOSTING_CONTRACTS,
			},
		});
		handleMessage('SET_DATA', { type: 'myGroup', data: { ID: 1, Name: 'Nightshift', State: 0, StateName: 'available', Members: [{ Leader: true, Source: 1, SID: 1, First: 'Testy', Last: 'McTest' }, { Leader: false, Source: 2, SID: 2, First: 'Marco', Last: 'Reyes' }] } });
		handleMessage('SET_DATA', { type: 'boostingQueue', data: null });
		handleMessage('SET_DATA', { type: 'disabledBoostingContracts', data: [] });
		handleMessage('SET_DATA', { type: 'onDuty', data: 'pdm' });
		handleMessage('SET_DATA', {
			type: 'JobPermissions',
			data: {
				pdm: {
					TABLET_VIEW_DOCUMENT: true,
					TABLET_CREATE_NOTICE: true,
					TABLET_DELETE_NOTICE: true,
					TABLET_TWEET: true,
					JOB_MANAGEMENT: true,
					FLEET_MANAGEMENT: true,
					TABLET_MANAGE_RECEIPT: true,
					TABLET_PIN_DOCUMENT: true,
					TABLET_DELETE_DOCUMENT: true,
					TABLET_CREATE_RECEIPT: true,
					TABLET_CLEAR_RECEIPT: true,
				},
				realestate: { JOB_SELL: true },
			},
		});
		handleMessage('SET_DATA', { type: 'businessLogo', data: 'https://i.imgur.com/ORHSuSM.png' });
		handleMessage('SET_DATA', { type: 'businessPages', data: MOCK_BIZWIZ_PAGES });
		handleMessage('SET_DATA', { type: 'businessNotices', data: MOCK_NOTICES });
		handleMessage('SET_TIME', { hour: 14, minute: 32 });
		handleMessage('LAPTOP_VISIBLE', {});
	}, 150);

	window.addEventListener('nui:send', (e) => {
		const { event, data } = (e as CustomEvent).detail;
		// eslint-disable-next-line no-console
		console.log('[mock nui:send]', event, data);
	});
}
