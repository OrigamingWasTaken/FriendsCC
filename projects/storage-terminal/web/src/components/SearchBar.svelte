<script lang="ts">
  let { value = $bindable("") }: { value: string } = $props();
  let timeout: ReturnType<typeof setTimeout>;

  function onInput(e: Event) {
    const target = e.target as HTMLInputElement;
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      value = target.value;
    }, 200);
  }

  function clear() {
    value = "";
  }
</script>

<div class="search">
  <input
    type="text"
    placeholder="Search items..."
    value={value}
    oninput={onInput}
  />
  {#if value}
    <button onclick={clear}>✕</button>
  {/if}
</div>

<style>
  .search {
    position: relative;
    display: flex;
    gap: 0.5rem;
  }
  input {
    flex: 1;
    padding: 0.5rem 0.75rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
    font-size: 0.9rem;
    outline: none;
  }
  input:focus {
    border-color: #7aa2f7;
  }
  input::placeholder {
    color: #565f89;
  }
  button {
    background: none;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #565f89;
    padding: 0.5rem;
    cursor: pointer;
  }
  button:hover {
    color: #c0caf5;
    border-color: #7aa2f7;
  }
</style>
