<script lang="ts">
  export let base: string;
  export let qualifier = "";
  export let big = false;
</script>

<div class="name" class:big>
  <span class="base">{base}</span>
  {#if qualifier}
    <span class="qualifier">{qualifier}</span>
  {/if}
</div>

<style>
  .name {
    display: flex;
    align-items: baseline;
    gap: 0.711vh;
    line-height: 1;
    flex-wrap: wrap;
  }
  .name.big {
    gap: 0.978vh;
  }
  .base {
    color: var(--text);
    font-weight: 800;
    font-size: 2.1222vh;
    letter-spacing: 0.005em;
    text-transform: uppercase;
  }
  .name.big .base {
    font-size: 3.518vh;
  }
  .qualifier {
    color: var(--text-dim);
    font-weight: 500;
    font-size: 1.778vh;
    letter-spacing: 0.01em;
    text-transform: uppercase;
  }
  .name.big .qualifier {
    font-size: 3.022vh;
  }
</style>