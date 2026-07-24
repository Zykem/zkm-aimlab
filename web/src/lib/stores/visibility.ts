import { writable } from "svelte/store";
import { fetchNui } from "../utils/fetchNui";
import { createNuiStore, isObject, isString } from "./createNuiStore";
import type { NuiSurface, NuiMessage } from "../types";

const VALID_SURFACES: NuiSurface[] = ["menu", "hud", "none"];

export const surface = writable<NuiSurface>("none");

export function toggleSurface(target: NuiSurface): void {
  surface.update((current) => (current === target ? "none" : target));
}

export function closeUi(): void {
  fetchNui("closeUi");
  surface.set("none");
}

export const initVisibility = createNuiStore({
  handlers: {
    setSurface(message: NuiMessage) {
      if (!isObject(message.data)) return;
      const surfaceValue = message.data.surface;
      if (!isString(surfaceValue)) return;
      if (!VALID_SURFACES.includes(surfaceValue as NuiSurface)) return;
      surface.set(surfaceValue as NuiSurface);
    },
  },
});