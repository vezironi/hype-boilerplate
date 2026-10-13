export function getImage(path: string): string {
    return `https://cfx-nui-${(window as any).GetParentResourceName?.() ?? 'hype-boilerplate'}/web/build/${path}`;
};

interface NuiResponse<T = unknown> {
    success: boolean;
    error?: string;
    data?: T;
};

export async function FetchNUI<T = unknown>(event: string, data?: unknown): Promise<NuiResponse<T>> {
    if (!(window as any).invokeNative) {
        return { success: true };
    }

    const response = await fetch(`https://${(window as any).GetParentResourceName?.() ?? 'hype-boilerplate'}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data ?? {}),
    });

    return response.json();
};