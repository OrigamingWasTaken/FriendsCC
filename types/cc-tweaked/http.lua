---@meta

---@class httpAPI
http = {}

---@class HTTPResponse
---@field getResponseCode fun(self: HTTPResponse): number
---@field getResponseHeaders fun(self: HTTPResponse): table<string, string>
---@field read fun(self: HTTPResponse, count?: number): string|nil
---@field readLine fun(self: HTTPResponse, withTrailing?: boolean): string|nil
---@field readAll fun(self: HTTPResponse): string|nil
---@field close fun(self: HTTPResponse)

---@class WebSocket
---@field receive fun(self: WebSocket, timeout?: number): string|nil, boolean|nil
---@field send fun(self: WebSocket, message: string, binary?: boolean)
---@field close fun(self: WebSocket)

---Send an async HTTP request. Fires http_success or http_failure events.
---@param url string|{url: string, body?: string, headers?: table, binary?: boolean, method?: string, redirect?: boolean, timeout?: number}
---@param body? string
---@param headers? table<string, string>
---@param binary? boolean
function http.request(url, body, headers, binary) end

---Send a GET request synchronously.
---Yields.
---@param url string|{url: string, headers?: table, binary?: boolean, redirect?: boolean, timeout?: number}
---@param headers? table<string, string>
---@param binary? boolean
---@return HTTPResponse|nil response
---@return string|nil error
---@return HTTPResponse|nil failResponse
function http.get(url, headers, binary) end

---Send a POST request synchronously.
---Yields.
---@param url string|{url: string, body?: string, headers?: table, binary?: boolean, redirect?: boolean, timeout?: number}
---@param body? string
---@param headers? table<string, string>
---@param binary? boolean
---@return HTTPResponse|nil response
---@return string|nil error
---@return HTTPResponse|nil failResponse
function http.post(url, body, headers, binary) end

---Check if a URL is valid and allowed.
---Yields.
---@param url string
---@return boolean valid
---@return string|nil reason
function http.checkURL(url) end

---Open a WebSocket connection.
---Yields.
---@param url string|{url: string, headers?: table, timeout?: number}
---@param headers? table<string, string>
---@return WebSocket|nil websocket
---@return string|nil error
function http.websocket(url, headers) end
