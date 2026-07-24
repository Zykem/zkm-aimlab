<script lang="ts">
  import { onMount } from "svelte";
  import { get } from "svelte/store";
  import Menu from "./lib/Menu.svelte";
  import Hud from "./lib/Hud.svelte";
  import { surface, initVisibility, closeUi, toggleSurface } from "./lib/stores/visibility";
  import { initSession } from "./lib/stores/session";
  import { initHud, hud } from "./lib/stores/hud";
  import { initConfig, uiConfig } from "./lib/stores/config";
  import { fetchNui, inGame } from "./lib/utils/fetchNui";

  function shade(hex: string, percent: number): string {
    const match = /^#?([\da-f]{6})$/i.exec(hex || "");
    if (!match) return hex;

    const value = parseInt(match[1], 16);
    const target = percent < 0 ? 0 : 255;
    const ratio = Math.abs(percent) / 100;
    const mixChannel = (channel: number) => Math.round((target - channel) * ratio) + channel;

    const red = mixChannel((value >> 16) & 255);
    const green = mixChannel((value >> 8) & 255);
    const blue = mixChannel(value & 255);
    return `#${((1 << 24) + (red << 16) + (green << 8) + blue).toString(16).slice(1)}`;
  }

  $: accentVars = `--accent: ${$uiConfig.primaryColor}; --accent-hover: ${shade($uiConfig.primaryColor, -14)};`;

  onMount(() => {
    initVisibility();
    initSession();
    initHud();
    initConfig();
    fetchNui("uiReady");

    if (!inGame) {
      hud.set({ hits: 128, headshots: 72, headshotRate: 0.5625, accuracy: 0.81, progress: null });
    }

    function handleKeydown(event: KeyboardEvent) {
      if (!inGame && event.key === "F2") {
        toggleSurface("menu");
        return;
      }
      if (!inGame && event.key === "F3") {
        toggleSurface("hud");
        return;
      }
      if (event.key !== "Escape") return;
      if (get(surface) !== "menu") return;
      closeUi();
    }

    window.addEventListener("keydown", handleKeydown);
    return () => window.removeEventListener("keydown", handleKeydown);
  });
</script>

<main class="app" style={accentVars}>
  {#if $surface === "menu"}
    <Menu />
  {:else if $surface === "hud"}
    <Hud position={$uiConfig.hudPosition} />
  {/if}
</main>

<style>
  .app {
    width: 100vw;
    height: 100vh;
    overflow: hidden;
  }
</style>