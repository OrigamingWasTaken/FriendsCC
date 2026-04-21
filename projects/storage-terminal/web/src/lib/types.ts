export interface Item {
  key: string;
  name: string;
  displayName: string;
  count: number;
  mod: string;
  enchantments?: { name: string; level: number }[];
  customName?: string;
  damage?: number;
  maxDamage?: number;
  nbt?: string;
  tags?: string[];
}

export interface ActivityEntry {
  action: "add" | "remove" | "extract";
  item: string;
  count: number;
  timestamp: number;
}

export interface SystemStatus {
  connected: boolean;
  vaults: number;
  totalSlots: number;
  usedSlots: number;
  totalItems: number;
  uniqueTypes: number;
  lastScanMs: number;
  monitors?: string[];
}

export interface PanelConfig {
  [monitorName: string]: string;
}

export interface Config {
  panels: PanelConfig;
  outputInv: string;
  scanInterval: number;
  relayUrl: string;
}

export type ServerMessage =
  | { type: "inventory"; items: Item[] }
  | { type: "inventory_delta"; added: Item[]; removed: Item[]; changed: { key: string; count: number }[] }
  | { type: "config"; panels: PanelConfig; outputInv: string; scanInterval: number; relayUrl: string }
  | { type: "activity"; entry: ActivityEntry }
  | { type: "status"; connected: boolean; vaults: number; totalSlots: number; usedSlots: number; totalItems: number; uniqueTypes: number; lastScanMs: number }
  | { type: "extract_result"; itemKey: string; requested: number; extracted: number }
  | { type: "error"; message: string };

export type ClientMessage =
  | { type: "extract"; itemKey: string; count: number }
  | { type: "config_update"; panels?: PanelConfig; outputInv?: string; scanInterval?: number }
  | { type: "refresh" };
