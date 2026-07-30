// generic keyed blob store every app reads/writes through - mirrors old's dataReducer.js semantics
// exactly: SET replaces a bucket, ADD pushes (array) or merges (object), UPDATE patches by _id/key,
// REMOVE deletes by _id/key. Buckets are untyped here on purpose - each app narrows via its own getters.

import type { AddDataMessage, RemoveDataMessage, SetDataMessage, UpdateDataMessage } from '../types';

type Bucket = unknown[] | Record<string, unknown> | null;

export const dataState = $state({
	data: {} as Record<string, Bucket>,
});

function isArrayBucket(bucket: Bucket): bucket is unknown[] {
	return Array.isArray(bucket);
}

export function handleDataMessage(type: string, data: unknown): boolean {
	switch (type) {
		case 'SET_DATA': {
			const payload = data as SetDataMessage;
			dataState.data = { ...dataState.data, [payload.type]: payload.data as Bucket };
			return true;
		}
		case 'RESET_DATA':
			dataState.data = {};
			return true;
		case 'ADD_DATA': {
			const payload = data as AddDataMessage;
			const bucket = dataState.data[payload.type];
			let next: Bucket;
			if (bucket == null) {
				next = [payload.data];
			} else if (isArrayBucket(bucket)) {
				next = payload.first ? [payload.data, ...bucket] : [...bucket, payload.data];
			} else if (payload.key != null) {
				next = { ...bucket, [payload.key]: payload.data };
			} else {
				next = { ...bucket, ...(payload.data as Record<string, unknown>) };
			}
			dataState.data = { ...dataState.data, [payload.type]: next };
			return true;
		}
		case 'UPDATE_DATA': {
			const payload = data as UpdateDataMessage;
			const bucket = dataState.data[payload.type];
			let next: Bucket;
			if (isArrayBucket(bucket)) {
				next = bucket.map((item) =>
					(item as Record<string, unknown>)?._id === payload.id ? payload.data : item,
				);
			} else {
				const obj = (bucket ?? {}) as Record<string, unknown>;
				next = payload.key
					? {
							...obj,
							[payload.id]: {
								...(obj[payload.id] as Record<string, unknown>),
								[payload.key]: payload.data,
							},
						}
					: { ...obj, [payload.id]: payload.data };
			}
			dataState.data = { ...dataState.data, [payload.type]: next };
			return true;
		}
		case 'REMOVE_DATA': {
			const payload = data as RemoveDataMessage;
			const bucket = dataState.data[payload.type];
			let next: Bucket;
			if (isArrayBucket(bucket)) {
				next = bucket.filter((item) => {
					if (item != null && typeof item === 'object') {
						const rec = item as Record<string, unknown>;
						return payload.key ? rec[payload.key] !== payload.id : rec._id !== payload.id;
					}
					return item !== payload.id;
				});
			} else if (bucket != null) {
				const obj = { ...bucket } as Record<string, unknown>;
				delete obj[payload.id];
				next = obj;
			} else {
				next = bucket;
			}
			dataState.data = { ...dataState.data, [payload.type]: next };
			return true;
		}
		default:
			return false;
	}
}

export function getBucket<T = unknown>(key: string): T | null {
	return (dataState.data[key] as T) ?? null;
}
