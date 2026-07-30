import type { AppId } from '../config';

export interface AppRestriction {
	state?: string | string[];
	job?: string;
	jobPermission?: string;
	laptopPermission?: { app: AppId; permission: string };
	reputation?: { reputation: string; reputationAmount?: number };
}

// server-driven catalog entry, sent whole via SET_APPS - label/icon/color/restrictions live here,
// not in this UI, so a server owner can add/re-theme an app without touching the bundle
export interface AppEntry {
	name: AppId;
	storeLabel: string;
	label: string;
	icon: string;
	color: string;
	hidden?: boolean;
	canUninstall?: boolean;
	store?: boolean;
	unread: number;
	fake?: boolean;
	restricted?: AppRestriction;
}

export type AppCatalog = Partial<Record<AppId, AppEntry>>;

export interface LaptopApps {
	home: AppId[];
	installed: AppId[];
}

export interface LaptopSettings {
	wallpaper: string;
	texttone: string;
	colors: { accent: string };
	zoom: number;
	volume: number;
	notifications: boolean;
	appNotifications: Partial<Record<AppId, boolean>>;
}

export type LaptopPermissions = Partial<Record<AppId, Record<string, boolean>>>;

export interface LaptopTime {
	hour: number;
	minute: number;
}

export interface NotificationAction {
	accept?: string;
	cancel?: string;
	view?: string;
	[key: string]: unknown;
}

export interface NotificationItem {
	_id: number | string;
	title: string;
	description: string;
	time: number;
	duration?: number;
	app: AppId | Record<string, unknown>;
	action?: NotificationAction;
	data?: unknown;
	show: boolean;
	collapsed?: boolean;
}

// one open app window - `app` doubles as the window key, `state` is arbitrary per-app
// route/tab data the app itself reads back out (e.g. which PDM tab is active)
export interface WindowState {
	app: AppId;
	minimized?: boolean;
	maximized?: boolean;
	state?: Record<string, unknown>;
}

// generic keyed blob store payload shapes, mirrors old's dataReducer.js semantics exactly:
// SET replaces the whole bucket, ADD pushes/merges, UPDATE patches by _id (array) or key (object), REMOVE deletes by _id/key
export interface SetDataMessage {
	type: string;
	data: unknown;
}

export interface AddDataMessage {
	type: string;
	data: unknown;
	key?: string | number;
	first?: boolean;
}

export interface UpdateDataMessage {
	type: string;
	id: string | number;
	data: unknown;
	key?: string;
}

export interface RemoveDataMessage {
	type: string;
	id: string | number;
	key?: string;
}

export interface PopupPayload {
	event: string;
	data?: { server?: boolean; [key: string]: unknown };
}

export interface TeamMember {
	Leader: boolean;
	Source: number;
	SID: number;
	First: string;
	Last: string;
}

export interface Team {
	ID: number;
	Name: string;
	State: number;
	StateName: string;
	Members: TeamMember[];
}

export interface CreateTeamResult {
	success?: boolean;
	message?: string;
	team?: Team;
}

export interface TeamRequest {
	id: number;
	time: number;
	expires: number;
	owner: number;
	team: boolean;
	event: string;
	label: string;
	description: string;
	data: Record<string, unknown>;
}

export interface JobEntry {
	Id: string;
	Name: string;
	Workplace?: { Id: string; Name: string };
	Grade: { Id: string; Name: string };
}

export interface BizWizPage {
	id: string;
	icon?: [string, string];
	label?: string;
	hidden?: boolean;
	permission?: string;
}

export interface BusinessNotice {
	_id: number;
	title: string;
	description: string;
	time: number;
	job: string;
	author: { SID: number; First: string; Last: string };
}

export interface EmployeeSearchResult {
	SID: number;
	First: string;
	Last: string;
}

export interface VehicleStockData {
	category: string;
	model: string;
	price: number;
	make: string;
	class: string;
}

export interface VehicleStock {
	_id: string;
	dealership: string;
	data: VehicleStockData;
	quantity: number;
	default?: boolean;
	vehicle: string;
	modelType?: string;
	lastStocked?: number;
	lastPurchase?: number;
}

export interface DealerData {
	profitPercentage: number;
	commission: number;
}

export interface PDMStockResponse {
	stock: VehicleStock[];
	dealerData: DealerData;
	interest: number;
}

export interface SaleResult {
	success: boolean;
	message?: string;
}

export interface CreditResult {
	SID: number;
	name: string;
	price?: number;
	score: number;
}

export interface SalesHistoryEntry {
	_id: string;
	type: 'loan' | 'full';
	vehicle: { data: VehicleStockData; VIN: string };
	salePrice: number;
	commission: number;
	seller: { First: string; Last: string; SID: number };
	buyer: { First: string; Last: string; SID: number };
	time: number;
}

export interface SalesHistoryResponse {
	data: SalesHistoryEntry[];
	more: boolean;
}

export interface OwnerInfo {
	Make: string;
	Model: string;
	VIN: string;
	OwnerName: string;
}

export interface PropertyOwner {
	First: string;
	Last: string;
	SID: number;
}

export interface PropertyLocation {
	x: number;
	y: number;
	z: number;
	h: number;
}

export interface Property {
	_id: string;
	label: string;
	sold: boolean;
	type: string;
	location: Record<string, PropertyLocation>;
	interior: number;
	price: number;
	owner?: PropertyOwner;
	upgrades?: Record<string, number>;
}

export interface PropertyUpgradeLevel {
	id: number;
	name: string;
	// interior levels carry { description }, other upgrade categories carry a plain string - old's own inconsistency
	info?: string | { description?: string };
}

export interface PropertyUpgradeCategory {
	levels: PropertyUpgradeLevel[];
}

export type PropertyUpgradeConfig = Record<string, Record<string, PropertyUpgradeCategory>>;

export interface PropertiesSearchResponse {
	properties: Property[];
	upgrades: PropertyUpgradeConfig;
}

export interface FleetVehicle {
	RegistrationDate?: number;
	VIN: string;
	RegisteredPlate: string;
	Make: string;
	Model: string;
	Storage?: { Name: string };
}

export interface CasinoWin {
	_id: string;
	Type: string;
	Prize: number | string;
	Winner: { First: string; Last: string; SID: number };
	Time: number;
}

export interface BusinessAuthor {
	First: string;
	Last: string;
	SID: number;
}

export interface BusinessLastUpdated extends BusinessAuthor {
	Time: number;
}

export interface BusinessDocument {
	_id: string;
	title: string;
	notes: string;
	pinned: boolean;
	time: number;
	author: BusinessAuthor;
	lastUpdated?: BusinessLastUpdated;
}

export interface BusinessReceipt {
	_id: string;
	type: string;
	customerName: string;
	customerNumber: string;
	paymentAmount: string;
	paymentPaid: string;
	workers: EmployeeSearchResult[];
	notes: string;
	time: number;
	author: BusinessAuthor;
	lastUpdated?: BusinessLastUpdated;
}

export interface ReceiptCountEntry {
	char: BusinessAuthor;
	created: number;
	assisted: number;
	latest: number;
	types: Record<string, number>;
}

export interface ReputationLevel {
	value: number;
	label: string;
}

export interface ReputationEntry {
	id: string;
	label: string;
	value: number;
	current?: ReputationLevel;
	next?: ReputationLevel;
}

export interface MarketItem {
	id: number | string;
	item: string;
	itemData: { name: string; label: string };
	coin: string;
	price: number;
	qty: number;
	delayed?: boolean;
}

export interface ChopListItem {
	name: string;
	hv?: boolean;
}

export interface ChopListGroup {
	id?: number | string;
	public?: boolean;
	list: ChopListItem[];
}

export type ChopListData = Record<string, ChopListGroup>;

export interface ContractPrice {
	price: number;
	coin: string;
}

export interface BoostingContract {
	id: number | string;
	owner: { SID: number; Alias: string };
	vehicle: { model: string; label: string; class: string; classLevel?: number; rewarded?: boolean };
	prices: { standard: ContractPrice; scratch?: ContractPrice };
	expires: number;
}

export interface LSUDetails {
	chopList: ChopListData | null;
	reputations: ReputationEntry[];
	items: MarketItem[];
	banned: string[] | null;
	canBoost: boolean;
}

export interface LSUBanEntry {
	SID: number;
	First: string;
	Last: string;
	RacingAlias: string;
	LSUNDGBan: string[];
}
