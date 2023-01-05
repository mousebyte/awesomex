local awful = require("awful")
local grect = require("gears.geometry").rectangle

local focus_scr = require("awesomex.screen").focus

local client = {}


function client.focus.global_bydirection(dir, c, stacked)
    local sel = c or client.focus

    awful.client.focus.bydirection(dir, sel, stacked)

    if sel == client.focus then
        local scr = sel and sel.screen or awful.screen.focused()
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
            focus_scr(nxt)
            cltbl[target]:emit_signal("request::activate",
                "client.focus.global_bydirection", { raise = true })
        end
    end
end

return setmetatable(client, { __index = function(_, k) return rawget(awful.client, k) end })
