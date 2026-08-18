import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // Any request starting with /api will be forwarded to localhost:5000
      '/api': {
        target: 'http://localhost:5173',
        changeOrigin: true,
        secure: false,
      }
  },
  },
});
