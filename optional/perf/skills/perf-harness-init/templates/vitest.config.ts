import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

// Vitest is the single test runner (grilled decision 2). jsdom for component
// tests + render-count gates (React Profiler); e2e/* belongs to Playwright.
export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    include: ["**/*.{test,spec}.{ts,tsx}"],
    exclude: ["e2e/**", "node_modules/**", ".next/**", "tools/**"],
    setupFiles: ["./vitest.setup.ts"],
  },
});
