<script lang="ts">
  import { items } from "../lib/store";
  import type { Item } from "../lib/types";

  let { activeMods = $bindable<string[]>([]), showEnchanted = $bindable(false), showRenamed = $bindable(false), showDamaged = $bindable(false), sortBy = $bindable("count") }: {
    activeMods: string[];
    showEnchanted: boolean;
    showRenamed: boolean;
    showDamaged: boolean;
    sortBy: string;
  } = $props();

  const allMods = $derived(
    [...new Set($items.map((i: Item) => i.mod))].sort()
  );

  function toggleMod(mod: string) {
    if (activeMods.includes(mod)) {
      activeMods = activeMods.filter((m) => m !== mod);
    } else {
      activeMods = [...activeMods, mod];
    }
  }
</script>

<div class="filters">
  <div class="chips">
    {#each allMods as mod}
      <button
        class="chip"
        class:active={activeMods.includes(mod)}
        onclick={() => toggleMod(mod)}
      >
        {mod}
      </button>
    {/each}
  </div>

  <div class="chips">
    <button class="chip" class:active={showEnchanted} onclick={() => showEnchanted = !showEnchanted}>Enchanted</button>
    <button class="chip" class:active={showRenamed} onclick={() => showRenamed = !showRenamed}>Renamed</button>
    <button class="chip" class:active={showDamaged} onclick={() => showDamaged = !showDamaged}>Damaged</button>
  </div>

  <select bind:value={sortBy}>
    <option value="count">Count (high→low)</option>
    <option value="name">Name (A→Z)</option>
  </select>
</div>

<style>
  .filters {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  .chips {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
  }
  .chip {
    padding: 0.25rem 0.5rem;
    background: #24283b;
    border: 1px solid #3b4261;
    border-radius: 4px;
    color: #565f89;
    font-size: 0.75rem;
    cursor: pointer;
  }
  .chip:hover {
    border-color: #7aa2f7;
    color: #c0caf5;
  }
  .chip.active {
    background: #7aa2f733;
    border-color: #7aa2f7;
    color: #7aa2f7;
  }
  select {
    padding: 0.4rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
    font-size: 0.8rem;
  }
</style>
