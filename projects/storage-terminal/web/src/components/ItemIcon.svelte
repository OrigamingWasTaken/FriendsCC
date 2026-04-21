<script lang="ts">
  const { name, mod }: { name: string; mod: string } = $props();

  const MOD_COLORS: Record<string, string> = {
    minecraft: "#9ece6a",
    create: "#ff9e64",
    computercraft: "#e0af68",
    ae2: "#7dcfff",
    mekanism: "#9ece6a",
  };

  const letter = $derived((name.split(":")[1] || name)[0]?.toUpperCase() || "?");
  const color = $derived(MOD_COLORS[mod] || "#7aa2f7");
</script>

<div class="icon" style="background: {color}22; border-color: {color}">
  <span style="color: {color}">{letter}</span>
</div>

<style>
  .icon {
    width: 36px;
    height: 36px;
    border-radius: 6px;
    border: 1px solid;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  span {
    font-size: 1rem;
    font-weight: 700;
  }
</style>
