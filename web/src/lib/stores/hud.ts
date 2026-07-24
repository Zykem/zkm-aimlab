import { writable } from "svelte/store";
import { createNuiStore, isObject, isNumber } from "./createNuiStore";
import type { HudState, NuiMessage } from "../types";

const EMPTY_HUD: HudState = { hits: 0, headshots: 0, headshotRate: 0, accuracy: 0, progress: null };

export const hud = writable<HudState>({ ...EMPTY_HUD });

const toNumber = (value: unknown): number => (isNumber(value) ? value : 0);

export const initHud = createNuiStore({
  handlers: {
    sessionStart() {
      hud.set({ ...EMPTY_HUD });
    },
    setHud(message: NuiMessage) {
      if (!isObject(message.data)) return;
      const data = message.data;
      hud.set({
        hits: toNumber(data.hits),
        headshots: toNumber(data.headshots),
        headshotRate: toNumber(data.headshotRate),
        accuracy: toNumber(data.accuracy),
        progress: isNumber(data.progress) ? data.progress : null,
      });
    },
  },
});