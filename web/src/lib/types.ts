export type NuiSurface = "none" | "menu" | "hud";

export type HudPosition =
  | "top-left"
  | "top-right"
  | "center-left"
  | "center-right"
  | "bottom-left"
  | "bottom-right";

export type ModeId =
  | "combat-roll"
  | "combat-roll-v2"
  | "beachball"
  | "beachball-v2"
  | "sprint"
  | "sprint-crouch"
  | "tracking"
  | "tracking-v2";

export interface UIConfig {
  hudPosition: HudPosition;
  primaryColor: string;
}

export interface HudState {
  hits: number;
  headshots: number;
  headshotRate: number;
  accuracy: number;
  progress: number | null;
}

export interface SessionResult {
  mode: ModeId;
  hits: number;
  headshots: number;
  headshotRate: number;
  bestStreak: number;
  durationMs: number;
}

export interface LifetimeSummary {
  totalSessions: number;
  totalHits: number;
  totalHeadshots: number;
  headshotRate: number;
}

export interface ModeDefinition {
  id: ModeId;
  base: string;
  qualifier: string;
  description: string;
  gridArea: string;
  hero?: boolean;
  image: string;
}

export interface StatRow {
  label: string;
  value: string;
  key?: boolean;
}

export interface NuiMessage {
  action: string;
  data?: unknown;
}