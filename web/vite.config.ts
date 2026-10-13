import tailwindcss from '@tailwindcss/vite'
import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue(), tailwindcss()],
  // NUI loads the page from web/build/index.html, so assets must be relative.
  base: './',
  build: {
    outDir: 'build',
    emptyOutDir: true,
  },
})
