import { items, connected, status, config, activity } from "./store";
import type { ServerMessage, ClientMessage } from "./types";

let socket: WebSocket | null = null;
let backoff = 1000;

function getWsUrl(): string {
  const protocol = location.protocol === "https:" ? "wss:" : "ws:";
  return `${protocol}//${location.host}/ws?role=browser`;
}

function handleMessage(msg: ServerMessage) {
  switch (msg.type) {
    case "inventory":
      items.set(msg.items);
      connected.set(true);
      break;
    case "status":
      status.set({
        connected: msg.connected,
        vaults: msg.vaults ?? 0,
        totalSlots: msg.totalSlots ?? 0,
        usedSlots: msg.usedSlots ?? 0,
        totalItems: msg.totalItems ?? 0,
        uniqueTypes: msg.uniqueTypes ?? 0,
        lastScanMs: msg.lastScanMs ?? 0,
      });
      if (msg.connected !== undefined) {
        connected.set(msg.connected);
      }
      break;
    case "config":
      config.set({
        panels: msg.panels ?? {},
        outputInv: msg.outputInv ?? "",
        scanInterval: msg.scanInterval ?? 5,
        relayUrl: msg.relayUrl ?? "",
      });
      break;
    case "activity":
      activity.update((a) => {
        const updated = [msg.entry, ...a];
        return updated.slice(0, 100);
      });
      break;
    case "extract_result":
      break;
    case "error":
      console.error("[ws] Error:", msg.message);
      break;
  }
}

export function connect() {
  const url = getWsUrl();
  socket = new WebSocket(url);

  socket.onopen = () => {
    console.log("[ws] Connected");
    connected.set(true);
    backoff = 1000;
  };

  socket.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data) as ServerMessage;
      handleMessage(msg);
    } catch (e) {
      console.error("[ws] Parse error:", e);
    }
  };

  socket.onclose = () => {
    console.log("[ws] Disconnected, reconnecting in", backoff, "ms");
    connected.set(false);
    socket = null;
    setTimeout(connect, backoff);
    backoff = Math.min(backoff * 2, 30000);
  };

  socket.onerror = () => {
    socket?.close();
  };
}

export function send(msg: ClientMessage) {
  if (socket && socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify(msg));
  }
}
