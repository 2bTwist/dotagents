import { test, expect } from "@playwright/test";

// Hard invariant (grilled decision 7): functional correctness must stay green.
// Perf optimization cannot break the page rendering or core content.
//
// Replace __PROJECT_TITLE__ with a regex fragment matching this project's real
// <title>. Left unfilled it fails on the first run, which is the point: a smoke
// test matching any title stays green while the page renders nothing.
const TITLE = /__PROJECT_TITLE__/;

test("homepage renders with title and visible content", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveTitle(TITLE);
  await expect(page.locator("body")).toBeVisible();
});
