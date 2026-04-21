<script lang="ts">
  import type { Item } from "../lib/types";
  import ItemIcon from "./ItemIcon.svelte";
  import { selectedItem } from "../lib/store";

  let { items: filteredItems }: { items: Item[] } = $props();

  function formatCount(n: number): string {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "M";
    if (n >= 1_000) return (n / 1_000).toFixed(1) + "k";
    return String(n);
  }

  function select(item: Item) {
    selectedItem.set(item);
  }
</script>

{#if filteredItems.length === 0}
  <div class="empty">No items found</div>
{:else}
  <div class="grid">
    {#each filteredItems as item (item.key)}
      <button class="card" class:enchanted={item.enchantments?.length} class:renamed={!!item.customName} onclick={() => select(item)}>
        <ItemIcon name={item.name} mod={item.mod} />
        <div class="info">
          <span class="name">{item.displayName}</span>
          {#if item.customName}
            <span class="original">{item.name.split(":")[1]?.replace(/_/g, " ")}</span>
          {/if}
          <span class="mod">{item.mod}</span>
        </div>
        <span class="count">{formatCount(item.count)}</span>
      </button>
    {/each}
  </div>
{/if}

<style>
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 0.5rem;
  }
  .card {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem;
    background: #24283b;
    border: 1px solid #3b4261;
    border-radius: 8px;
    cursor: pointer;
    text-align: left;
    color: inherit;
    font: inherit;
    transition: border-color 0.15s;
  }
  .card:hover {
    border-color: #7aa2f7;
  }
  .card.enchanted {
    border-left: 3px solid #bb9af7;
  }
  .info {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
  }
  .name {
    font-size: 0.85rem;
    color: #c0caf5;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .card.renamed .name {
    font-style: italic;
  }
  .original {
    font-size: 0.7rem;
    color: #565f89;
  }
  .mod {
    font-size: 0.65rem;
    color: #565f89;
  }
  .count {
    font-size: 1rem;
    font-weight: 700;
    color: #9ece6a;
    white-space: nowrap;
  }
  .empty {
    text-align: center;
    padding: 2rem;
    color: #565f89;
  }
</style>
