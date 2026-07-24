import { writable } from "svelte/store";
import { fetchNui } from "../utils/fetchNui";
import type { UIConfig } from "../types";

const DEFAULT_UI_CONFIG: UIConfig = { hudPosition: "top-left", primaryColor: "#72d3f4" };

export const uiConfig = writable<UIConfig>({ ...DEFAULT_UI_CONFIG });

export async function initConfig(): Promise<void> {
  const config = await fetchNui<UIConfig>("getConfig");
  if (config) uiConfig.set({ ...DEFAULT_UI_CONFIG, ...config });
}