local net = {}

local RPC_TIMEOUT = 5

local function _serialize(data)
    return textutils.serialize(data)
end

local function _unserialize(data)
    if type(data) == "string" then
        return textutils.unserialize(data)
    end
    return data
end

function net.open(side)
    if side then
        rednet.open(side)
    else
        local modem = peripheral.find("modem")
        if modem then
            rednet.open(peripheral.getName(modem))
        else
            error("No modem found", 2)
        end
    end
end

function net.send(recipient, protocol, data)
    return rednet.send(recipient, _serialize(data), protocol)
end

function net.broadcast(protocol, data)
    rednet.broadcast(_serialize(data), protocol)
end

function net.receive(protocol, timeout)
    local sender, raw, proto = rednet.receive(protocol, timeout)
    if sender then
        return sender, _unserialize(raw), proto
    end
    return nil, nil, nil
end

function net.rpc(recipient, method, args, timeout)
    local msg = { type = "rpc_request", method = method, args = args or {} }
    net.send(recipient, "rpc", msg)
    local sender, response = net.receive("rpc", timeout or RPC_TIMEOUT)
    if not sender then
        return nil, "timeout"
    end
    if response and response.type == "rpc_response" then
        if response.error then
            return nil, response.error
        end
        return response.result
    end
    return nil, "invalid response"
end

function net.serve(protocol, handlers)
    while true do
        local sender, msg = net.receive(protocol)
        if sender and msg then
            if msg.type == "rpc_request" and msg.method then
                local handler = handlers[msg.method]
                local response
                if handler then
                    local ok, result = pcall(handler, sender, unpack(msg.args or {}))
                    if ok then
                        response = { type = "rpc_response", result = result }
                    else
                        response = { type = "rpc_response", error = result }
                    end
                else
                    response = { type = "rpc_response", error = "unknown method: " .. msg.method }
                end
                net.send(sender, protocol, response)
            elseif handlers["*"] then
                handlers["*"](sender, msg)
            end
        end
    end
end

return net
