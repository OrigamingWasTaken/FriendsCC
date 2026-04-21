<script lang="ts">
  import { selectedItem } from "../lib/store";
  import { send } from "../lib/ws";
  import ItemIcon from "./ItemIcon.svelte";

  let extractAmount = $state("");
  let extracting = $state(false);
  let message = $state("");

  function close() {
    selectedItem.set(null);
    extractAmount = "";
    message = "";
  }

  function formatCount(n: number): string {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "M";
    if (n >= 1_000) return (n / 1_000).toFixed(1) + "k";
    return String(n);
  }

  function extract(amount: number) {
    if (!$selectedItem || amount <= 0) return;
    extracting = true;
    message = "";
    send({ type: "extract", itemKey: $selectedItem.key, count: amount });
    setTimeout(() => {
      extracting = false;
      message = `Requested ${amount} items`;
    }, 500);
  }

  function extractCustom() {
    const n = parseInt(extractAmount);
    if (n > 0) extract(n);
  }

  function extractAll() {
    if ($selectedItem) extract($selectedItem.count);
  }
</script>

{#if $selectedItem}
  <div class="overlay" onclick={close} role="button" tabindex="-1" onkeydown={(e) => e.key === 'Escape' && close()}></div>
  <aside class="panel">
    <div class="panel-header">
      <h2>Item Detail</h2>
      <button class="close" onclick={close}>✕</button>
    </div>

    <div class="detail-body">
      <div class="item-header">
        <ItemIcon name={$selectedItem.name} mod={$selectedItem.mod} />
        <div>
          <h3>{$selectedItem.displayName}</h3>
          <p class="registry">{$selectedItem.name}</p>
          <p class="mod">{$selectedItem.mod}</p>
        </div>
      </div>

      <div class="stat">
        <span>Total Count</span>
        <strong>{formatCount($selectedItem.count)}</strong>
      </div>

      {#if $selectedItem.enchantments?.length}
        <div class="section">
          <h4>Enchantments</h4>
          {#each $selectedItem.enchantments as ench}
            <span class="ench">{ench.name} {ench.level}</span>
          {/each}
        </div>
      {/if}

      {#if $selectedItem.damage != null && $selectedItem.maxDamage}
        <div class="section">
          <h4>Durability</h4>
          <div class="durability-bar">
            <div class="fill" style="width: {((($selectedItem.maxDamage - $selectedItem.damage) / $selectedItem.maxDamage) * 100)}%"></div>
          </div>
          <p class="durability-text">{$selectedItem.maxDamage - $selectedItem.damage} / {$selectedItem.maxDamage}</p>
        </div>
      {/if}

      <div class="extract-section">
        <h4>Extract</h4>
        <div class="extract-row">
          <input
            type="number"
            placeholder="Amount"
            bind:value={extractAmount}
            min="1"
            max={$selectedItem.count}
          />
          <button class="btn primary" onclick={extractCustom} disabled={extracting}>Take</button>
          <button class="btn secondary" onclick={extractAll} disabled={extracting}>All</button>
        </div>
        {#if message}
          <p class="message">{message}</p>
        {/if}
      </div>
    </div>
  </aside>
{/if}

<style>
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 10;
  }
  .panel {
    position: fixed;
    top: 0;
    right: 0;
    width: 320px;
    height: 100vh;
    background: #24283b;
    border-left: 1px solid #3b4261;
    z-index: 11;
    display: flex;
    flex-direction: column;
    animation: slideIn 0.2s ease;
  }
  @keyframes slideIn {
    from { transform: translateX(100%); }
    to { transform: translateX(0); }
  }
  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #3b4261;
  }
  .panel-header h2 {
    margin: 0;
    font-size: 1rem;
  }
  .close {
    background: none;
    border: none;
    color: #565f89;
    font-size: 1.2rem;
    cursor: pointer;
  }
  .close:hover { color: #c0caf5; }
  .detail-body {
    padding: 1rem;
    overflow-y: auto;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  .item-header {
    display: flex;
    gap: 0.75rem;
    align-items: flex-start;
  }
  .item-header h3 {
    margin: 0;
    font-size: 1rem;
    color: #c0caf5;
  }
  .registry {
    font-size: 0.75rem;
    color: #565f89;
    margin: 0.2rem 0;
  }
  .mod {
    font-size: 0.7rem;
    color: #565f89;
    margin: 0;
  }
  .stat {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem;
    background: #1a1b26;
    border-radius: 6px;
  }
  .stat strong {
    color: #9ece6a;
  }
  .section h4 {
    margin: 0 0 0.4rem;
    font-size: 0.8rem;
    color: #565f89;
    text-transform: uppercase;
  }
  .ench {
    display: inline-block;
    padding: 0.15rem 0.4rem;
    background: #bb9af722;
    border: 1px solid #bb9af755;
    border-radius: 4px;
    color: #bb9af7;
    font-size: 0.75rem;
    margin: 0.15rem;
  }
  .durability-bar {
    height: 6px;
    background: #3b4261;
    border-radius: 3px;
    overflow: hidden;
  }
  .fill {
    height: 100%;
    background: #9ece6a;
    border-radius: 3px;
    transition: width 0.3s;
  }
  .durability-text {
    font-size: 0.75rem;
    color: #565f89;
    margin: 0.25rem 0 0;
  }
  .extract-section {
    margin-top: auto;
    padding-top: 1rem;
    border-top: 1px solid #3b4261;
  }
  .extract-row {
    display: flex;
    gap: 0.5rem;
  }
  .extract-row input {
    flex: 1;
    padding: 0.5rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
  }
  .btn {
    padding: 0.5rem 0.75rem;
    border: none;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
    font-size: 0.85rem;
  }
  .btn.primary {
    background: #9ece6a;
    color: #1a1b26;
  }
  .btn.secondary {
    background: #7aa2f7;
    color: #1a1b26;
  }
  .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .message {
    font-size: 0.8rem;
    color: #9ece6a;
    margin: 0.5rem 0 0;
  }
</style>
