<script setup lang="ts">
import { onMounted } from 'vue';
import { keydownEvent, messageEvent } from './utils/events';
import { useDefaultData } from './store/index';

const defaultData = useDefaultData();

onMounted(() => {
    keydownEvent();
    messageEvent();
});
</script>

<template>
    <div v-if="defaultData.visible" class="w-screen h-screen items-center justify-center overflow-hidden flex relative">
        <div class="w-96 rounded-2xl border border-white/10 bg-neutral-900/90 p-6 text-white shadow-2xl backdrop-blur-md">
            <h1 class="text-xl font-semibold tracking-tight">{{ defaultData.locale('ui.title') }}</h1>
            <p class="mt-2 text-sm leading-relaxed text-neutral-400">
                {{ defaultData.locale('ui.description', 'web/src/App.vue') }}
            </p>
            <button
                class="mt-6 w-full cursor-pointer rounded-lg bg-white/10 py-2 text-sm font-medium transition-colors hover:bg-white/20"
                @click="defaultData.CloseUI()"
            >
                {{ defaultData.locale('ui.close') }}
            </button>
        </div>
    </div>
</template>
