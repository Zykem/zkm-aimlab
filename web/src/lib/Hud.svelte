<script lang="ts">
  import { fade } from "svelte/transition";
  import { hud } from "./stores/hud";
  import type { HudPosition, StatRow } from "./types";

  export let position: HudPosition = "top-left";

  const VALID_POSITIONS: HudPosition[] = [
    "top-left", "top-right", "center-left",
    "center-right", "bottom-left", "bottom-right",
  ];
  $: resolvedPosition = VALID_POSITIONS.includes(position) ? position : "top-left";

  const formatNumber = (value: number | null | undefined): string =>
    (value ?? 0).toLocaleString("en-US");
  const formatPercent = (rate: number | null | undefined): string =>
    `${(Math.max(0, rate ?? 0) * 100).toFixed(1)}%`;

  let statRows: StatRow[];
  $: statRows = [
    { label: "Hits", value: formatNumber($hud.hits) },
    { label: "Headshots", value: formatNumber($hud.headshots) },
    { label: "HS Rate", value: formatPercent($hud.headshotRate), key: true },
    { label: "Accuracy", value: formatPercent($hud.accuracy) },
  ];
</script>

<aside class="hud pos-{resolvedPosition}" in:fade={{ duration: 180 }}>
  <span class="hud-title">Session</span>
  {#if $hud.progress != null}
    <div class="hud-progress">
      <div class="hud-progress-head">
        <span class="hud-label">Track</span>
        <span class="hud-value sm key">{formatPercent($hud.progress)}</span>
      </div>
      <div class="hud-bar">
        <div
          class="hud-bar-fill"
          style="width: {Math.min(100, Math.max(0, $hud.progress * 100))}%"
        ></div>
      </div>
    </div>
  {/if}
  <div class="hud-rows">
    {#each statRows as row}
      <div class="hud-row">
        <span class="hud-label">{row.label}</span>
        <span class="hud-value" class:key={row.key}>{row.value}</span>
      </div>
    {/each}
  </div>
  <div class="hud-exit">
    <kbd class="key-cap">X</kbd>
    <span class="hud-exit-label">Exit</span>
  </div>
</aside>

<style>
  .hud {
    position: fixed;
    min-width: 21vh;
    background-color: var(--surface);
    border: 1px solid var(--border-strong);
    border-radius: 8px;
    padding: 1.778vh 2.044vh;
    display: flex;
    flex-direction: column;
    gap: 1.244vh;
    pointer-events: none;
    font-family: "Montserrat", sans-serif;
  }
  .pos-top-left {
    top: 2.844vh;
    left: 2.844vh;
  }
  .pos-top-right {
    top: 2.844vh;
    right: 2.844vh;
  }
  .pos-center-left {
    top: 50%;
    left: 2.844vh;
    transform: translateY(-50%);
  }
  .pos-center-right {
    top: 50%;
    right: 2.844vh;
    transform: translateY(-50%);
  }
  .pos-bottom-left {
    bottom: 2.844vh;
    left: 2.844vh;
  }
  .pos-bottom-right {
    bottom: 2.844vh;
    right: 2.844vh;
  }
  .hud-title {
    color: var(--text-faint);
    font-weight: 600;
    font-size: 1.138vh;
    letter-spacing: 0.24em;
    text-transform: uppercase;
  }
  .hud-rows {
    display: flex;
    flex-direction: column;
    gap: 0.978vh;
  }
  .hud-row {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 2.4vh;
  }
  .hud-label {
    color: var(--text-faint);
    font-weight: 600;
    font-size: 1.173vh;
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }
  .hud-value {
    color: var(--text);
    font-weight: 700;
    font-size: 2.044vh;
    line-height: 1;
    font-variant-numeric: tabular-nums;
  }
  .hud-value.key {
    color: var(--accent);
  }
  .hud-value.sm {
    font-size: 1.6vh;
  }
  .hud-progress {
    display: flex;
    flex-direction: column;
    gap: 0.711vh;
  }
  .hud-progress-head {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 2.4vh;
  }
  .hud-bar {
    height: 0.711vh;
    border-radius: 999px;
    background-color: var(--surface-2);
    overflow: hidden;
  }
  .hud-bar-fill {
    height: 100%;
    background-color: var(--accent);
    border-radius: 999px;
    transition: width 0.1s linear;
  }
  .hud-exit {
    display: flex;
    align-items: center;
    gap: 0.889vh;
    padding-top: 1.244vh;
    border-top: 1px solid var(--border);
  }
  .key-cap {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 1.956vh;
    height: 1.956vh;
    padding: 0 0.533vh;
    border: 1px solid var(--border-strong);
    border-radius: 4px;
    background-color: var(--surface-2);
    color: var(--text);
    font-family: "Montserrat", sans-serif;
    font-size: 1.138vh;
    font-weight: 700;
    line-height: 1;
  }
  .hud-exit-label {
    color: var(--text-faint);
    font-weight: 600;
    font-size: 1.138vh;
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }
</style>