import { type ServerWebSocket } from "bun";
import { join } from "path";

const PORT = parseInt(process.env.PORT || "3001");

type Role = "cc" | "browser";
type WSData = { role: Role };

let ccSocket: ServerWebSocket<WSData> | null = null;
const browserSockets = new Set<ServerWebSocket<WSData>>();

const webDistPath = join(import.meta.dir, "..", "web", "dist");

const server = Bun.serve({
  port: PORT,

  async fetch(req, server) {
    const url = new URL(req.url);

    if (url.pathname === "/ws") {
      const role = (url.searchParams.get("role") as Role) || "browser";
      const upgraded = server.upgrade(req, { data: { role } });
      if (!upgraded) {
        return new Response("WebSocket upgrade failed", { status: 400 });
      }
      return undefined;
    }

    if (url.pathname === "/health") {
      return Response.json({
        status: "ok",
        cc: ccSocket !== null,
        browsers: browserSockets.size,
      });
    }

    let filePath = url.pathname === "/" ? "/index.html" : url.pathname;
    const file = Bun.file(join(webDistPath, filePath));
    if (await file.exists()) {
      return new Response(file);
    }

    const indexFile = Bun.file(join(webDistPath, "index.html"));
    if (await indexFile.exists()) {
      return new Response(indexFile);
    }

    return new Response("Not found", { status: 404 });
  },

  websocket: {
    open(ws: ServerWebSocket<WSData>) {
      if (ws.data.role === "cc") {
        if (ccSocket) {
          ccSocket.close(1000, "replaced");
        }
        ccSocket = ws;
        console.log("[relay] CC connected");
      } else {
        browserSockets.add(ws);
        console.log(`[relay] Browser connected (${browserSockets.size} total)`);
        if (!ccSocket) {
          ws.send(JSON.stringify({ type: "status", connected: false }));
        }
      }
    },

    message(ws: ServerWebSocket<WSData>, message: string | Buffer) {
      const raw = typeof message === "string" ? message : message.toString();

      if (ws.data.role === "cc") {
        for (const browser of browserSockets) {
          browser.send(raw);
        }
      } else {
        if (ccSocket) {
          ccSocket.send(raw);
        } else {
          ws.send(JSON.stringify({ type: "error", message: "Computer not connected" }));
        }
      }
    },

    close(ws: ServerWebSocket<WSData>) {
      if (ws.data.role === "cc") {
        ccSocket = null;
        console.log("[relay] CC disconnected");
        const msg = JSON.stringify({ type: "status", connected: false });
        for (const browser of browserSockets) {
          browser.send(msg);
        }
      } else {
        browserSockets.delete(ws);
        console.log(`[relay] Browser disconnected (${browserSockets.size} total)`);
      }
    },
  },
});

console.log(`[relay] Listening on http://localhost:${server.port}`);
