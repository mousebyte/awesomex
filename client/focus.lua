local grect = require("gears.geometry").rectangle

local capi = {
    client = client
}

local screen
do
    screen = setmetatable({}, {
        __index = function(_, k)
            screen = require("awesomex.screen")
            return screen[k]
        end,
        __newindex = error -- Just to be sure in case anything ever does this
    })
end

local client
do
    client = setmetatable({}, {
        __index = function(_, k)
            client = require("awful.client")
            return client[k]
        end,
        __newindex = error -- Just to be sure in case anything ever does this
    })
end

local focus = {}


function focus.global_bydirection(dir, c, stacked)
    local sel = c or capi.client.focus

    client.focus.bydirection(dir, sel, stacked)

    if sel == capi.client.focus then
        local scr = sel and sel.screen or screen.focused()
        local nxt, cltbl = scr, {}

        while #cltbl == 0 do
            nxt = nxt:get_next_in_direction(dir)
            if not nxt then return end
            cltbl = nxt:get_clients(stacked)
        end

        local geomtbl = {}

        for i, cl in ipairs(cltbl) do
            geomtbl[i] = cl:geometry()
        end

        local target = grect.get_in_direction(dir, geomtbl, scr.geometry)

        if target then
            screen.focus(nxt)
            cltbl[target]:emit_signal("request::activate",
                "client.focus.global_bydirection", { raise = true })
        end
    end
end

return setmetatable(focus, { __index = function(_, k) return rawget(client.focus, k) end })
