// local action feedback ("Team Created", "Invite Failed") - old's useAlert() hook equivalent

export interface Toast {
	id: number;
	kind: 'success' | 'error';
	message: string;
}

export const toastState = $state({ toasts: [] as Toast[] });

let nextId = 1;

export const toast = {
	success(message: string) {
		push('success', message);
	},
	error(message: string) {
		push('error', message);
	},
};

function push(kind: 'success' | 'error', message: string) {
	const id = nextId++;
	toastState.toasts = [...toastState.toasts, { id, kind, message }];
	setTimeout(() => dismissToast(id), 4000);
}

export function dismissToast(id: number) {
	toastState.toasts = toastState.toasts.filter((t) => t.id !== id);
}
