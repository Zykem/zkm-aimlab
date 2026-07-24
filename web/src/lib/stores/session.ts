import { writable } from "svelte/store";
import { createNuiStore, isObject } from "./createNuiStore";
import type { SessionResult, NuiMessage } from "../types";

export const sessionResult = writable<SessionResult | null>(null);

export const initSession = createNuiStore({
  handlers: {
    sessionStart() {
      sessionResult.set(null);
    },
    sessionEnd(message: NuiMessage) {
      if (!isObject(message.data)) return;
      sessionResult.set(message.data as SessionResult);
    },
  },
});