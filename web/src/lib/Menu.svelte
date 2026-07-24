<script lang="ts">
  import { onMount } from "svelte";
  import { fade, fly } from "svelte/transition";
  import ModeName from "./ModeName.svelte";
  import { fetchNui, inGame } from "./utils/fetchNui";
  import { sessionResult } from "./stores/session";
  import type { ModeDefinition, ModeId, LifetimeSummary, SessionResult, StatRow } from "./types";

  const MODES: ModeDefinition[] = [
    {
      id: "combat-roll-v2",
      base: "Combat Roll",
      qualifier: "V2",
      description: "Spawns come faster and the window to land your shot shrinks. Hesitate once and you're already behind.",
      gridArea: "hero",
      hero: true,
      image: "images/modes/combatroll.png",
    },
    {
      id: "beachball",
      base: "Beachball",
      qualifier: "",
      description: "Beachballs spawn, then hold. Read the spread and pick your shot.",
      gridArea: "beach",
      image: "images/modes/combatroll.png",
    },
    {
      id: "beachball-v2",
      base: "Beachball",
      qualifier: "V2",
      description: "Same targets, now drifting up and down while they wait.",
      gridArea: "beachv2",
      image: "images/modes/combatroll.png",
    },
    {
      id: "combat-roll",
      base: "Combat Roll",
      qualifier: "",
      description: "Static peds roll at fixed intervals.",
      gridArea: "croll",
      image: "images/modes/combatroll.png",
    },
    {
      id: "sprint",
      base: "Sprint",
      qualifier: "",
      description: "Peds run the lane left to right. Stay on them.",
      gridArea: "sprint",
      image: "images/modes/sprint.png",
    },
    {
      id: "sprint-crouch",
      base: "Sprint",
      qualifier: "(Crouch)",
      description: "Horizontal tracking, except a target can drop into a crouch mid-run and break your line.",
      gridArea: "sprintc",
      image: "images/modes/sprint.png",
    },
    {
      id: "tracking",
      base: "Tracking",
      qualifier: "",
      description: "A target sweeps steadily side to side. Keep your crosshair on it — the meter fills while you stay locked.",
      gridArea: "track",
      image: "images/modes/combatroll.png",
    },
    {
      id: "tracking-v2",
      base: "Tracking",
      qualifier: "V2",
      description: "The target drifts in every direction, not just across. Same idea, much harder to stay on.",
      gridArea: "track2",
      image: "images/modes/combatroll.png",
    },
  ];

  const MODE_IMAGES: Record<string, string> = Object.fromEntries(
    MODES.map((mode): [string, string] => [mode.id, mode.image]),
  );

  const formatNumber = (value: number): string => value.toLocaleString("en-US");
  const formatPercent = (rate: number): string => `${(Math.max(0, rate) * 100).toFixed(1)}%`;
  const formatDuration = (milliseconds: number): string => {
    const totalSeconds = Math.max(0, Math.round(milliseconds / 1000));
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
  };

  let selected: ModeId = "combat-roll-v2";
  let view: "menu" | "results" = "menu";

  let lifetime: LifetimeSummary = {
    totalSessions: 312,
    totalHits: 48209,
    totalHeadshots: 32493,
    headshotRate: 0.674,
  };

  let HEADER_STATS: StatRow[];
  $: HEADER_STATS = [
    { label: "Headshot Rate", value: formatPercent(lifetime.headshotRate), key: true },
    { label: "Sessions", value: formatNumber(lifetime.totalSessions) },
    { label: "Total Hits", value: formatNumber(lifetime.totalHits) },
  ];

  let result: SessionResult;
  $: result = $sessionResult ?? {
    mode: selected, hits: 184, headshots: 131, headshotRate: 0.712, bestStreak: 23, durationMs: 120000,
  };

  let RESULT_STATS: StatRow[];
  $: RESULT_STATS = [
    { label: "Headshot Rate", value: formatPercent(result.headshotRate), key: true },
    { label: "Total Hits", value: formatNumber(result.hits) },
    { label: "Time", value: formatDuration(result.durationMs) },
    { label: "Best Streak", value: formatNumber(result.bestStreak) },
  ];

  $: if ($sessionResult) {
    if ($sessionResult.mode) selected = $sessionResult.mode;
    view = "results";
  }

  async function refreshLifetime(): Promise<void> {
    const stats = await fetchNui<LifetimeSummary>("getStats");
    if (stats) lifetime = stats;
  }

  onMount(refreshLifetime);

  $: selectedMode = MODES.find((mode) => mode.id === selected) ?? MODES[0];

  function startSession(): void {
    if (inGame) {
      fetchNui("startSession", { mode: selected });
    } else {
      view = "results";
    }
  }

  function backToMenu(): void {
    sessionResult.set(null);
    view = "menu";
    refreshLifetime();
  }

  function modeTileStyle(modeId: string, isSelected: boolean): string {
    const image = MODE_IMAGES[modeId];
    const tint = isSelected
      ? "linear-gradient(rgba(114,211,244,0.07), rgba(114,211,244,0.07)), "
      : "";
    const darken = isSelected
      ? "linear-gradient(160deg, rgba(10,13,18,0.90) 0%, rgba(18,23,31,0.965) 70%)"
      : "linear-gradient(160deg, rgba(10,13,18,0.93) 0%, rgba(18,23,31,0.97) 75%)";
    return `background-color: var(--surface); background-image: ${tint}${darken}, url(${image}); background-size: cover; background-position: center;`;
  }

  function mapBackgroundStyle(modeId: string): string {
    const image = MODE_IMAGES[modeId];
    return `background-color: var(--surface); background-image: linear-gradient(180deg, rgba(10,13,18,0.42) 0%, rgba(10,13,18,0.78) 64%, rgba(10,13,18,0.94) 100%), url(${image}); background-size: cover; background-position: center;`;
  }
</script>

<div class="page">
  <div class="frame">
    <header in:fly={{ y: -6, duration: 300 }}>
      <div class="brand">
        <svg class="reticle-mark" viewBox="0 0 40 40" fill="none">
          <circle cx="20" cy="20" r="13" stroke="var(--text-faint)" stroke-width="1.4" />
          <circle cx="20" cy="20" r="2.2" fill="var(--text-faint)" />
          <line x1="20" y1="0" x2="20" y2="9" stroke="var(--text-faint)" stroke-width="1.4" />
          <line x1="20" y1="31" x2="20" y2="40" stroke="var(--text-faint)" stroke-width="1.4" />
          <line x1="0" y1="20" x2="9" y2="20" stroke="var(--text-faint)" stroke-width="1.4" />
          <line x1="31" y1="20" x2="40" y2="20" stroke="var(--text-faint)" stroke-width="1.4" />
        </svg>
        <span class="wordmark">Aimlab</span>
      </div>

      <div class="stats">
        {#each HEADER_STATS as stat, index}
          <div class="stat" class:divided={index !== 0}>
            <span class="stat-label">{stat.label}</span>
            <span class="stat-value" class:key={stat.key}>{stat.value}</span>
          </div>
        {/each}
      </div>
    </header>

    {#if view === "menu"}
      <div class="body" in:fade={{ duration: 200 }}>
        <div class="grid">
          {#each MODES as mode, index}
            <div
              class="tile"
              class:selected={selected === mode.id}
              style={modeTileStyle(mode.id, selected === mode.id) + ` grid-area: ${mode.gridArea};`}
              on:click={() => (selected = mode.id)}
              on:keydown={(event) => (event.key === "Enter" || event.key === " ") && (selected = mode.id)}
              role="button"
              tabindex="0"
              in:fly={{ y: 8, duration: 320, delay: index * 40 }}
            >
              <div class="tile-hover"></div>
              <div class="tile-top">
                <ModeName base={mode.base} qualifier={mode.qualifier} big={mode.hero} />
                <p class="desc" class:hero={mode.hero}>{mode.description}</p>
              </div>
            </div>
          {/each}

          <div class="map-tile" in:fly={{ y: 8, duration: 320, delay: 50 }}>
            {#key selected}
              <div class="map-bg" style={mapBackgroundStyle(selected)} in:fade={{ duration: 250 }}></div>
            {/key}

            <div class="map-reticle">
              <svg viewBox="0 0 120 120" fill="none">
                <circle cx="60" cy="60" r="34" stroke="var(--border-strong)" stroke-width="1" />
                <line x1="60" y1="8" x2="60" y2="40" stroke="var(--border-strong)" stroke-width="1" />
                <line x1="60" y1="80" x2="60" y2="112" stroke="var(--border-strong)" stroke-width="1" />
                <line x1="8" y1="60" x2="40" y2="60" stroke="var(--border-strong)" stroke-width="1" />
                <line x1="80" y1="60" x2="112" y2="60" stroke="var(--border-strong)" stroke-width="1" />
              </svg>
            </div>

            <div class="map-content">
              <span class="tiny-label">Map Preview</span>
              <div>
                <span class="tiny-label block">Map</span>
                <ModeName base={selectedMode.base} qualifier={selectedMode.qualifier} />
              </div>
            </div>
          </div>
        </div>

        <footer in:fly={{ y: 6, duration: 300, delay: 80 }}>
          <div class="selected-info">
            <span class="tiny-label">Selected</span>
            <ModeName base={selectedMode.base} qualifier={selectedMode.qualifier} />
          </div>
          <button class="btn-primary" on:click={startSession}>
            Start Session
          </button>
        </footer>
      </div>
    {:else}
      <div class="body results-wrap" in:fade={{ duration: 200 }}>
        <div class="results-panel" in:fly={{ y: 10, duration: 340 }}>
          <span class="tiny-label wide">Session Complete</span>
          <div class="results-title">
            <ModeName base={selectedMode.base} qualifier={selectedMode.qualifier} big />
          </div>

          <div class="results-grid">
            {#each RESULT_STATS as stat}
              <div class="result-stat">
                <span class="stat-label">{stat.label}</span>
                <span class="result-value" class:key={stat.key}>{stat.value}</span>
              </div>
            {/each}
          </div>

          <div class="results-actions">
            <button class="btn-primary grow" on:click={startSession}>Retry</button>
            <button class="btn-ghost grow" on:click={backToMenu}>Back to Menu</button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</div>

<style>
  .page {
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .frame {
    border-radius: 1.1111vh;
    height: 80vh;
    max-width: 100vw;
    aspect-ratio: 16 / 9;
    background: var(--bg);
    border: 1px solid var(--border);
    padding: 2.844vh;
    display: flex;
    flex-direction: column;
    gap: 2.311vh;
    overflow: hidden;
  }

  header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 2.311vh;
    border-bottom: 1px solid var(--border);
  }
  .brand {
    display: flex;
    align-items: center;
    gap: 1.6vh;
  }
  .reticle-mark {
    width: 2.963vh;
    height: 2.963vh;
  }
  .wordmark {
    color: var(--text);
    font-weight: 800;
    font-size: 2.7778vh;
    letter-spacing: 0.3704vh;
    text-transform: uppercase;
  }
  .stats {
    display: flex;
    align-items: stretch;
    gap: 4.267vh;
  }
  .stat {
    display: flex;
    flex-direction: column;
    gap: 0.622vh;
  }
  .stat.divided {
    padding-left: 4.267vh;
    border-left: 1px solid var(--border);
  }
  .stat-label {
    color: var(--text-faint);
    font-weight: 600;
    font-size: 1.0804vh;
    letter-spacing: 0.2778vh;
    text-transform: uppercase;
  }
  .stat-value {
    color: var(--text);
    font-weight: 700;
    font-size: 2.3002vh;
    line-height: 1;
    font-variant-numeric: tabular-nums;
  }
  .stat-value.key {
    color: var(--accent);
  }

  .body {
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: column;
    gap: 2.311vh;
  }

  .grid {
    flex: 1;
    min-height: 0;
    display: grid;
    gap: 1.511vh;
    grid-template-columns: repeat(5, minmax(0, 1fr));
    grid-template-rows: repeat(3, minmax(0, 1fr));
    grid-template-areas:
      "hero hero beach map map"
      "hero hero beachv2 map map"
      "croll sprint sprintc track track2";
  }

  .tile {
    border-radius: 8px;
    position: relative;
    overflow: hidden;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 2.044vh;
    border: 1px solid var(--border);
    transition: border-color 0.18s ease;
    outline: none;
  }
  .tile[style*="grid-area: hero"] {
    padding: 2.667vh;
  }
  .tile.selected {
    border-color: var(--accent);
  }
  .tile-hover {
    position: absolute;
    inset: 0;
    background: rgba(231, 234, 238, 0.025);
    opacity: 0;
    transition: opacity 0.18s ease;
    pointer-events: none;
  }
  .tile:hover .tile-hover,
  .tile:focus-visible .tile-hover {
    opacity: 1;
  }
  .tile-top {
    position: relative;
    z-index: 1;
  }
  .desc {
    color: var(--text-dim);
    font-weight: 400;
    font-size: 1.2963vh;
    line-height: 1.5;
    margin: 0.978vh 0 0 0;
  }
  .desc.hero {
    font-size: 1.4815vh;
    margin-top: 1.6vh;
    max-width: 48vh;
  }

  .map-tile {
    grid-area: map;
    border-radius: 8px;
    position: relative;
    overflow: hidden;
    border: 1px solid var(--border);
    background-color: var(--surface);
  }
  .map-bg {
    position: absolute;
    inset: 0;
  }
  .map-reticle {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    pointer-events: none;
  }
  .map-reticle svg {
    width: 34%;
    opacity: 0.28;
  }
  .map-content {
    position: absolute;
    inset: 0;
    padding: 2.133vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .tiny-label {
    color: var(--text-faint);
    font-weight: 600;
    font-size: 1.138vh;
    letter-spacing: 0.1852vh;
    text-transform: uppercase;
  }
  .tiny-label.block {
    display: block;
    margin-bottom: 0.622vh;
  }
  .tiny-label.wide {
    font-size: 1.244vh;
    letter-spacing: 0.26em;
  }

  /* FOOTER */
  footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-top: 2.133vh;
    border-top: 1px solid var(--border);
  }
  .selected-info {
    display: flex;
    align-items: baseline;
    gap: 1.778vh;
  }

  /* BUTTONS */
  .btn-primary {
    background-color: var(--accent);
    color: var(--bg);
    border: none;
    border-radius: 6px;
    padding: 1.867vh 4.622vh;
    font-family: "Montserrat", sans-serif;
    font-size: 1.689vh;
    font-weight: 700;
    letter-spacing: 0.2778vh;
    text-transform: uppercase;
    cursor: pointer;
    transition: background-color 0.15s ease, transform 0.1s ease;
  }
  .btn-primary:hover {
    background-color: var(--accent-hover);
    transform: translateY(-0.2778vh);
  }
  .btn-primary:active {
    transform: scale(0.985);
  }
  .btn-ghost {
    background-color: transparent;
    color: var(--text-dim);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 1.867vh 0;
    font-family: "Montserrat", sans-serif;
    font-size: 1.689vh;
    font-weight: 600;
    letter-spacing: 0.2778vh;
    text-transform: uppercase;
    cursor: pointer;
    transition: background-color 0.15s ease, border-color 0.15s ease, transform 0.1s ease;
  }
  .btn-ghost:hover {
    background-color: var(--surface-2);
    border-color: var(--border-strong);
  }
  .btn-ghost:active {
    transform: scale(0.985);
  }
  .grow {
    flex: 1;
  }

  /* RESULTS */
  .results-wrap {
    align-items: center;
    justify-content: center;
  }
  .results-panel {
    width: 110.222vh;
    background-color: var(--surface);
    border: 1px solid var(--border-strong);
    border-radius: 8px;
    padding: 4.622vh;
  }
  .results-title {
    margin-top: 1.067vh;
  }
  .results-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 1.778vh;
    margin: 4.267vh 0;
  }
  .result-stat {
    background-color: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 2.133vh;
    display: flex;
    flex-direction: column;
    gap: 1.244vh;
  }
  .result-value {
    color: var(--text);
    font-weight: 700;
    font-size: 3.556vh;
    line-height: 1;
    font-variant-numeric: tabular-nums;
  }
  .result-value.key {
    color: var(--accent);
  }
  .results-actions {
    display: flex;
    gap: 1.6vh;
  }
</style>