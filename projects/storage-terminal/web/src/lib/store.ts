import { writable } from "svelte/store";
import type { Item, SystemStatus, Config, ActivityEntry } from "./types";

export const items = writable<Item[]>([]);
export const connected = writable(false);
export const status = writable<SystemStatus>({
  connected: false,
  vaults: 0,
  totalSlots: 0,
  usedSlots: 0,
  totalItems: 0,
  uniqueTypes: 0,
  lastScanMs: 0,
  monitors: [],
});
export const config = writable<Config>({
  panels: {},
  outputInv: "",
  scanInterval: 5,
  relayUrl: "",
});
export const activity = writable<ActivityEntry[]>([]);
export const selectedItem = writable<Item | null>(null);
