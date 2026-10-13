import { useDefaultData } from "../store/index";

export function keydownEvent() {
    window.addEventListener("keydown", ({ code }) => {
        if (code === "Escape") {
            const defaultData = useDefaultData();
            if (defaultData.visible) defaultData.CloseUI();
        }
    });
};

interface NuiMessage {
    action: string;
    payload: any;
}

export function messageEvent() {
    const handlers: Record<string, (payload: any) => void> = {
        'nui/open': (payload) => {
            const defaultData = useDefaultData();

            defaultData.locales = payload?.locales ?? {};
            defaultData.visible = true;
        },
        'nui/check': () => {
        },
    };

    window.addEventListener('message', async ({ data }: MessageEvent<NuiMessage>) => {
        const handler = handlers[data.action];

        if (handler) {
            handler(data.payload);
        } else {
            console.warn(`Unknown action received: ${data.action}`);
        }
    });
};