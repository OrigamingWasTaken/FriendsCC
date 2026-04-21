<script lang="ts">
  import { connected, items, status } from "./lib/store";
</script>

<main>
  <header>
    <h1>Storage Terminal</h1>
    <span class="status" class:connected={$connected}>
      {$connected ? "Connected" : "Disconnected"}
    </span>
  </header>
  <p>{$items.length} items, {$status.uniqueTypes} types</p>
</main>

<style>
  :global(body) {
    margin: 0;
    background: #1a1b26;
    color: #c0caf5;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }
  main {
    padding: 1rem;
  }
  header {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem 1rem;
    background: #24283b;
    border-bottom: 1px solid #3b4261;
  }
  h1 {
    margin: 0;
    font-size: 1.2rem;
  }
  .status {
    font-size: 0.8rem;
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    background: #f7768e33;
    color: #f7768e;
  }
  .status.connected {
    background: #9ece6a33;
    color: #9ece6a;
  }
</style>
