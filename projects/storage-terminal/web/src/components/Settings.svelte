<script lang="ts">
  import { config, status } from "../lib/store";
  import { send } from "../lib/ws";

  let { open = $bindable(false) }: { open: boolean } = $props();

  let outputInv = $state($config.outputInv);
  let scanInterval = $state($config.scanInterval);

  const PANEL_TYPES = [
    { value: "", label: "None" },
    { value: "recent_activity", label: "Recent Activity" },
    { value: "storage_fill", label: "Storage Usage" },
    { value: "top_items", label: "Top Items" },
    { value: "low_stock", label: "Low Stock" },
    { value: "system_status", label: "System Status" },
  ];

  const allMonitors = $derived($status.monitors ?? []);

  function getPanelForMonitor(monitor: string): string {
    return $config.panels[monitor] ?? "";
  }

  function setPanelType(monitor: string, panelType: string) {
    config.update((c) => {
      const panels = { ...c.panels };
      if (panelType) {
        panels[monitor] = panelType;
      } else {
        delete panels[monitor];
      }
      return { ...c, panels };
    });
  }

  function save() {
    send({
      type: "config_update",
      outputInv,
      scanInterval,
      panels: $config.panels,
    });
    open = false;
  }
</script>

{#if open}
  <div class="overlay" onclick={() => open = false} role="button" tabindex="-1" onkeydown={(e) => e.key === 'Escape' && (open = false)}></div>
  <div class="modal">
    <div class="modal-header">
      <h2>Settings</h2>
      <button class="close" onclick={() => open = false}>✕</button>
    </div>

    <div class="modal-body">
      <label>
        Output Inventory
        <input type="text" bind:value={outputInv} placeholder="minecraft:chest_0" />
      </label>

      <label>
        Scan Interval (seconds)
        <input type="number" bind:value={scanInterval} min="1" max="60" />
      </label>

      <h3>Monitor Panels</h3>
      {#if allMonitors.length === 0}
        <p class="no-monitors">No monitors detected</p>
      {:else}
        {#each allMonitors as monitor}
          <div class="panel-row">
            <span class="monitor-name">{monitor}</span>
            <select value={getPanelForMonitor(monitor)} onchange={(e) => setPanelType(monitor, (e.target as HTMLSelectElement).value)}>
              {#each PANEL_TYPES as pt}
                <option value={pt.value}>{pt.label}</option>
              {/each}
            </select>
          </div>
        {/each}
      {/if}

      <button class="btn save" onclick={save}>Save</button>
    </div>
  </div>
{/if}

<style>
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 20;
  }
  .modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 400px;
    max-height: 80vh;
    background: #24283b;
    border: 1px solid #3b4261;
    border-radius: 12px;
    z-index: 21;
    overflow: hidden;
  }
  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #3b4261;
  }
  .modal-header h2 { margin: 0; font-size: 1rem; }
  .close {
    background: none;
    border: none;
    color: #565f89;
    font-size: 1.2rem;
    cursor: pointer;
  }
  .modal-body {
    padding: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    overflow-y: auto;
  }
  label {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    font-size: 0.85rem;
    color: #565f89;
  }
  input, select {
    padding: 0.5rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
    font-size: 0.85rem;
  }
  h3 {
    margin: 0.5rem 0 0;
    font-size: 0.85rem;
    color: #565f89;
    text-transform: uppercase;
  }
  .no-monitors {
    font-size: 0.8rem;
    color: #565f89;
    font-style: italic;
  }
  .panel-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 0.5rem;
  }
  .monitor-name {
    font-size: 0.8rem;
    color: #c0caf5;
  }
  .btn.save {
    margin-top: 0.5rem;
    padding: 0.5rem;
    background: #9ece6a;
    color: #1a1b26;
    border: none;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
  }
</style>
