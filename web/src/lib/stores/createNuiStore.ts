import type { NuiMessage } from "../types";

export function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

export function isString(value: unknown): value is string {
  return typeof value === "string";
}

export function isNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

export type NuiHandler = (message: NuiMessage) => void;

export interface NuiStoreOptions {
  handlers: Record<string, NuiHandler>;
  refresh?: () => unknown;
}

export function createNuiStore(options: NuiStoreOptions): () => void {
  let initialized = false;

  function onMessage(event: MessageEvent) {
    const payload: unknown = event.data;
    if (!isObject(payload)) return;
    if (!isString(payload.action)) return;

    const handler = options.handlers[payload.action];
    if (!handler) return;
    handler({ action: payload.action, data: payload.data });
  }

  return function init() {
    if (initialized) return;
    initialized = true;
    window.addEventListener("message", onMessage);
    if (options.refresh) {
      void options.refresh();
    }
  };
}