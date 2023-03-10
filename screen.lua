-- Basically wraps `base` to add a signal for focused screen changes.
-- The signal is automatically emitted when a client on a different screen is focused,
-- and when a client's screen property changes while it is focused.
-- example: `screen.connect_signal("focused", function(s) do_stuff(s.index) end)`

local base = require("awful.screen")
local gmath = require("gears.math")

local capi = {
    screen = screen,
    client = client
}

local screen = {}

local function get_screen(s)
    return s and capi.screen[s]
end

function screen.focus(s)
    s = get_screen(s)
    if s and s ~= base.focused() then
        base.focus(s)
        capi.screen.emit_signal("_focused", s)
    end
end

function screen.focus_bydirection(dir, s)
    s = get_screen(s or base.focused())
    local target = s:get_next_in_direction(dir)

    if target then
        screen.focus(target)
    end
end

function screen.focus_relative(offset)
    screen.focus(gmath.cycle(capi.screen.count(),
        base.focused().index + offset))
end

capi.screen.connect_signal("_focused", function(s)
    s:emit_signal("focused")
end)

capi.client.connect_signal("focus", function(c)
    screen.focus(c.screen)
end)

capi.client.connect_signal("property::screen", function(c)
    if capi.client.focus == c then screen.focus(c.screen) end
end)

return setmetatable(screen, { __index = function(_, k) return rawget(base, k) end })
