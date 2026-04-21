<script lang="ts">
  import { connected, items, status } from "./lib/store";
  import { send } from "./lib/ws";
  import type { Item } from "./lib/types";
  import SearchBar from "./components/SearchBar.svelte";
  import FilterBar from "./components/FilterBar.svelte";
  import ItemList from "./components/ItemList.svelte";
  import ItemDetail from "./components/ItemDetail.svelte";
  import Settings from "./components/Settings.svelte";

  let search = $state("");
  let activeMods = $state<string[]>([]);
  let showEnchanted = $state(false);
  let showRenamed = $state(false);
  let showDamaged = $state(false);
  let sortBy = $state("count");
  let settingsOpen = $state(false);

  const filtered = $derived.by(() => {
    let result = $items;

    if (search) {
      const q = search.toLowerCase();
      result = result.filter(
        (i: Item) =>
          i.displayName.toLowerCase().includes(q) ||
          i.name.toLowerCase().includes(q)
      );
    }

    if (activeMods.length > 0) {
      result = result.filter((i: Item) => activeMods.includes(i.mod));
    }
    if (showEnchanted) {
      result = result.filter((i: Item) => i.enchantments && i.enchantments.length > 0);
    }
    if (showRenamed) {
      result = result.filter((i: Item) => !!i.customName);
    }
    if (showDamaged) {
      result = result.filter((i: Item) => i.damage != null && i.damage > 0);
    }

    if (sortBy === "name") {
      result = [...result].sort((a: Item, b: Item) => a.displayName.localeCompare(b.displayName));
    }

    return result;
  });

  function refresh() {
    send({ type: "refresh" });
  }
</script>

<div class="app">
  <header>
    <h1>Storage Terminal</h1>
    <div class="header-right">
      <span class="stat">{$status.uniqueTypes} types · {$status.vaults} vaults</span>
      <button class="icon-btn" onclick={refresh} title="Refresh">↻</button>
      <button class="icon-btn" onclick={() => settingsOpen = true} title="Settings">⚙</button>
      <span class="status-dot" class:connected={$connected} title={$connected ? "Connected" : "Disconnected"}></span>
    </div>
  </header>

  <div class="layout">
    <aside class="sidebar">
      <SearchBar bind:value={search} />
      <FilterBar
        bind:activeMods
        bind:showEnchanted
        bind:showRenamed
        bind:showDamaged
        bind:sortBy
      />
    </aside>

    <main>
      <ItemList items={filtered} />
    </main>
  </div>

  <ItemDetail />
  <Settings bind:open={settingsOpen} />
</div>

<style>
  :global(*) {
    box-sizing: border-box;
  }
  :global(body) {
    margin: 0;
    background: #1a1b26;
    color: #c0caf5;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }
  .app {
    display: flex;
    flex-direction: column;
    height: 100vh;
  }
  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.5rem 1rem;
    background: #24283b;
    border-bottom: 1px solid #3b4261;
    flex-shrink: 0;
  }
  h1 {
    margin: 0;
    font-size: 1.1rem;
  }
  .header-right {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }
  .stat {
    font-size: 0.75rem;
    color: #565f89;
  }
  .icon-btn {
    background: none;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #565f89;
    padding: 0.3rem 0.5rem;
    cursor: pointer;
    font-size: 1rem;
  }
  .icon-btn:hover {
    color: #c0caf5;
    border-color: #7aa2f7;
  }
  .status-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #f7768e;
  }
  .status-dot.connected {
    background: #9ece6a;
  }
  .layout {
    display: flex;
    flex: 1;
    overflow: hidden;
  }
  .sidebar {
    width: 240px;
    padding: 0.75rem;
    border-right: 1px solid #3b4261;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    overflow-y: auto;
    flex-shrink: 0;
  }
  main {
    flex: 1;
    padding: 0.75rem;
    overflow-y: auto;
  }
</style>
