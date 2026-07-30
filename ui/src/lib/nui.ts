import type {
	BoostingContract,
	BusinessDocument,
	BusinessReceipt,
	CasinoWin,
	CreateTeamResult,
	CreditResult,
	DealerData,
	EmployeeSearchResult,
	FleetVehicle,
	LSUBanEntry,
	LSUDetails,
	OwnerInfo,
	PDMStockResponse,
	PropertiesSearchResponse,
	SaleResult,
	SalesHistoryResponse,
	Team,
	TeamRequest,
} from './types';
import {
	MOCK_TEAMS,
	MOCK_TEAM_REQUESTS,
	MOCK_EMPLOYEES,
	MOCK_PDM_STOCK,
	MOCK_DEALER_DATA,
	MOCK_FLEET,
	MOCK_PROPERTIES,
	MOCK_CASINO_WINS,
	MOCK_DOCUMENTS,
	MOCK_RECEIPTS,
	MOCK_REPUTATIONS,
	MOCK_MARKET_ITEMS,
	MOCK_CHOP_LIST,
} from './mockData';

const RESOURCE_NAME = 'pulsar_laptop';

async function send(event: string, data: unknown = {}): Promise<void> {
	if (import.meta.env.DEV) {
		window.dispatchEvent(new CustomEvent('nui:send', { detail: { event, data } }));
		return;
	}
	try {
		await fetch(`https://${RESOURCE_NAME}/${event}`, {
			method: 'post',
			headers: { 'Content-Type': 'application/json; charset=UTF-8' },
			body: JSON.stringify(data),
		});
	} catch {
		// Expected to fail outside the actual NUI browser
	}
}

// request/response callbacks - these RegisterNUICallback handlers pass their `cb` straight through
// as the server callback's completion handler, so the fetch response body carries real data back
async function sendJson<T>(event: string, data: unknown, devValue: T): Promise<T> {
	if (import.meta.env.DEV) {
		window.dispatchEvent(new CustomEvent('nui:send', { detail: { event, data } }));
		return devValue;
	}
	try {
		const res = await fetch(`https://${RESOURCE_NAME}/${event}`, {
			method: 'post',
			headers: { 'Content-Type': 'application/json; charset=UTF-8' },
			body: JSON.stringify(data),
		});
		return (await res.json()) as T;
	} catch {
		return devValue;
	}
}

export const Nui = {
	closeLaptop: () => send('CloseLaptop'),
	cdExpired: () => send('CDExpired'),
	// generic popup dispatch - `event.data.server` decides whether the accepted/cancelled
	// event fires server-side (TriggerServerEvent) or client-side (TriggerEvent), same as old
	acceptPopup: (event: string, data?: Record<string, unknown>) => send('AcceptPopup', { event, data }),
	cancelPopup: (event: string, data?: Record<string, unknown>) => send('CancelPopup', { event, data }),
	updateSetting: (type: string, val: unknown) => send('UpdateSetting', { type, val }),
	testSound: (type: string, val: unknown) => send('TestSound', { type, val }),

	// Teams
	getTeams: () => sendJson<Team[]>('GetTeams', {}, MOCK_TEAMS),
	getTeamRequests: () => sendJson<TeamRequest[]>('GetTeamRequests', {}, MOCK_TEAM_REQUESTS),
	createTeam: (name: string) => sendJson<CreateTeamResult | false>('CreateTeam', { Name: name }, { success: true, team: MOCK_TEAMS[0] }),
	deleteTeam: () => sendJson<boolean>('DeleteTeam', {}, true),
	inviteTeamMember: (sid: number) => sendJson<{ success: boolean } | false>('InviteTeamMember', { SID: sid }, { success: true }),
	removeTeamMember: (sid: number, source: number) => sendJson<boolean>('RemoveTeamMember', { SID: sid, Source: source }, true),
	requestTeamInvite: (teamId: number) => sendJson<boolean>('RequestTeamInvite', teamId, true),
	teamRequest: (request: TeamRequest, action: 'accept' | 'deny') => sendJson<void>('TeamRequest', { ...request, action }, undefined),

	// BizWiz
	bizWizEmployeeSearch: (job: string) => sendJson<EmployeeSearchResult[] | false>('BizWizEmployeeSearch', { job }, MOCK_EMPLOYEES),
	createBusinessNotice: (doc: { title: string; description: string }) =>
		sendJson<number | false>('CreateBusinessNotice', { doc: { ...doc, time: Math.floor(Date.now() / 1000) } }, 99),
	deleteBusinessNotice: (id: number) => sendJson<boolean>('DeleteBusinessNotice', { id }, true),
	getBusinessTwitter: () => sendJson<{ success: boolean; pfp?: string } | false>('GetBusinessTwitter', {}, { success: true }),
	setBusinessTwitter: (profile: string) => sendJson<string | false>('SetBusinessTwitter', { profile }, profile),
	sendBusinessTweet: (content: string, image?: { using: boolean; link: string }) =>
		sendJson<boolean>('SendBusinessTweet', { time: Date.now(), content, image: image ?? { using: false, link: '' }, likes: [] }, true),
	viewVehicleFleet: () => sendJson<FleetVehicle[] | false>('ViewVehicleFleet', {}, MOCK_FLEET),
	trackFleetVehicle: (vin: string) => sendJson<boolean>('TrackFleetVehicle', { vehicle: vin }, true),

	// PDM (dealership) - thin proxy to pulsar_dealerships, see client/apps/bizwiz/dealers.lua
	pdmGetStock: () => sendJson<PDMStockResponse | false>('PDMGetStock', {}, { stock: MOCK_PDM_STOCK, dealerData: MOCK_DEALER_DATA, interest: 15 }),
	pdmStartSale: (payload: { type: string; SID?: string; downpayment?: number; weeks?: number; vehicle: string }) =>
		sendJson<SaleResult>('PDMStartSale', payload, { success: true }),
	dealershipStartTestDrive: (vehicle: string, modelType?: string) =>
		sendJson<SaleResult>('DealershipStartTestDrive', { vehicle, modelType }, { success: true, message: 'Vehicle has been delivered for test drive.' }),
	pdmRunCredit: (term: string) => sendJson<CreditResult | false>('PDMRunCredit', { term }, { SID: 2, name: 'John Doe', price: 10000, score: 680 }),
	pdmGetDealerData: () => sendJson<DealerData | false>('PDMGetDealerData', {}, MOCK_DEALER_DATA),
	pdmSaveDealerData: (data: DealerData) => sendJson<DealerData | false>('PDMSaveDealerData', { data }, data),
	pdmGetHistory: (value: string, category: string, page: number) =>
		sendJson<SalesHistoryResponse | false>('PDMGetHistory', { value, category, page }, { data: [], more: false }),
	pdmGetOwner: (vin: string) => sendJson<OwnerInfo | false>('PDMGetOwner', { VIN: vin }, { Make: 'Vapid', Model: 'Speedo', VIN: vin, OwnerName: 'Testy McTest' }),

	// Dynasty (real estate) - thin proxy to pulsar_properties, see client/apps/bizwiz/realestate.lua
	dyn8SearchProperties: () =>
		sendJson<PropertiesSearchResponse | false>('Dyn8SearchProperties', {}, { properties: MOCK_PROPERTIES, upgrades: {} }),
	dyn8MarkProperty: (propertyId: string) => sendJson<boolean>('Dyn8MarkProperty', propertyId, true),
	dyn8StartSale: (payload: { type: string; SID?: string; downpayment?: number; weeks?: number; property: string }) =>
		sendJson<SaleResult>('Dyn8StartSale', payload, { success: true }),
	dyn8StartTransfer: (property: string, sid: string) => sendJson<SaleResult>('Dyn8StartTransfer', { property, SID: sid }, { success: true }),
	dyn8RunCredit: (term: string) => sendJson<CreditResult | false>('Dyn8RunCredit', { term }, { SID: 2, name: 'John Doe', price: 250000, score: 680 }),
	dyn8ChangePropertyLocations: (property: string, location: string) =>
		sendJson<boolean>('Dyn8ChangePropertyLocations', { property, location }, true),
	dyn8ShowPropertyLocations: (property: string) => sendJson<boolean>('Dyn8ShowPropertyLocations', { property }, true),
	dyn8CopyID: (propertyId: string) => sendJson<boolean>('Dyn8CopyID', propertyId, true),
	dyn8ToggleBlips: () => sendJson<string>('Dyn8ToggleBlips', {}, 'ok'),

	// Casino
	casinoGetBigWins: () => sendJson<CasinoWin[] | false>('CasinoGetBigWins', {}, MOCK_CASINO_WINS),

	// BizWiz Documents
	businessDocumentSearch: (term: string) => sendJson<BusinessDocument[] | false>('BusinessDocumentSearch', { term }, MOCK_DOCUMENTS),
	businessDocumentCreate: (doc: { title: string; notes: string; pinned: boolean; time: number }) =>
		sendJson<BusinessDocument | false>('BusinessDocumentCreate', { doc }, { ...MOCK_DOCUMENTS[0], ...doc, _id: '99' }),
	businessDocumentUpdate: (id: string, report: Omit<BusinessDocument, '_id' | 'lastUpdated'>) =>
		sendJson<boolean>('BusinessDocumentUpdate', { id, Report: report }, true),
	businessDocumentView: (id: string) => sendJson<BusinessDocument | false>('BusinessDocumentView', { id }, MOCK_DOCUMENTS[0]),
	businessDocumentDelete: (id: string) => sendJson<boolean>('BusinessDocumentDelete', { id }, true),

	// BizWiz Receipts
	businessReceiptSearch: (term: string) => sendJson<BusinessReceipt[] | false>('BusinessReceiptSearch', { term }, MOCK_RECEIPTS),
	businessReceiptCreate: (doc: Omit<BusinessReceipt, '_id' | 'author' | 'lastUpdated'>) =>
		sendJson<BusinessReceipt | false>('BusinessReceiptCreate', { doc }, { ...MOCK_RECEIPTS[0], ...doc, _id: '99' }),
	businessReceiptUpdate: (id: string, report: Omit<BusinessReceipt, '_id' | 'lastUpdated'>) =>
		sendJson<boolean>('BusinessReceiptUpdate', { id, Report: report }, true),
	businessReceiptView: (id: string) => sendJson<BusinessReceipt | false>('BusinessReceiptView', { id }, MOCK_RECEIPTS[0]),
	businessReceiptDelete: (id: string) => sendJson<boolean>('BusinessReceiptDelete', { id }, true),
	businessReceiptDeleteAll: () => sendJson<boolean>('BusinessReceiptDeleteAll', {}, true),

	// LSU
	getLSUDetails: () =>
		sendJson<LSUDetails | false>(
			'GetLSUDetails',
			{},
			{ chopList: MOCK_CHOP_LIST, reputations: MOCK_REPUTATIONS, items: MOCK_MARKET_ITEMS, banned: null, canBoost: true },
		),
	lsuMarketCheckout: (cart: { id: number | string; quantity: number }[]) => sendJson<boolean>('LSUNDG:Market:Checkout', cart, true),
	boostingEnterQueue: () => sendJson<{ success: boolean; message?: string } | false>('Boosting:EnterQueue', {}, { success: true }),
	boostingExitQueue: () => sendJson<boolean>('Boosting:ExitQueue', {}, true),
	boostingAcceptContract: (contract: BoostingContract, scratch: boolean) =>
		sendJson<{ success: boolean; message?: string } | false>('Boosting:AcceptContract', { ...contract, scratch }, { success: true }),
	boostingTransferContract: (id: number | string, alias: string) =>
		sendJson<boolean>('Boosting:TransferContract', { id, alias }, true),
	boostingDeclineContract: (contract: BoostingContract) => sendJson<boolean>('Boosting:DeclineContract', contract, true),
	boostingAdminCreateContract: (data: {
		vehicle: string;
		make: string;
		model: string;
		class: string;
		trackers: number;
		price: number;
		skipRep: boolean;
		payoutOverride: number;
	}) => sendJson<{ success: boolean; message?: string } | boolean>('Boosting:Admin:CreateContract', data, true),
	boostingAdminGetBans: () => sendJson<LSUBanEntry[] | false>('Boosting:Admin:GetBans', {}, []),
	boostingAdminBan: (sid: number) => sendJson<boolean>('Boosting:Admin:Ban', { SID: sid }, true),
	boostingAdminUnban: (sid: number) => sendJson<boolean>('Boosting:Admin:Unban', { SID: sid }, true),
};
