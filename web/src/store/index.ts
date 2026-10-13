import { defineStore } from 'pinia';
import { FetchNUI } from '../utils';

export const useDefaultData = defineStore('DefaultData', {
    state: () => ({
        visible: !(window as any).invokeNative,
        /** Flattened ox_lib locales, sent by the client with 'nui/open'. */
        locales: {} as Record<string, string>,
    }),
    getters: {
        /** locale('ui.close') | locale('ui.description', 'web/src/App.vue') */
        locale: (state) => (key: string, ...args: (string | number)[]): string => {
            const text = state.locales[key] ?? key;
            if (!args.length) return text;

            let index = 0;
            return text.replace(/%[sd]/g, () => String(args[index++] ?? ''));
        },
    },
    actions: {
        CloseUI() {
            this.visible = false;
            FetchNUI('nui/close', {});
        },
    },
});
