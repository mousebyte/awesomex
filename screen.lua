-- Basically wraps `awful.screen` to add a signal for focused screen changes.
-- To use it, replace all calls into `awful.screen` in your config with a matching
-- call into `awesome-util.screen`.
-- The signal is automatically emitted when a client on a different screen is focused,
-- and when a client's screen property changes while it is focused.
-- example: `screen.connect_signal("focused", function(s) do_stuff(s.index) end)`

local awful = require("awful")
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
    if s and s ~= awful.screen.focused() then
        awful.screen.focus(s)
        capi.screen.emit_signal("_focused", s)
    end
end

function screen.focus_bydirection(dir, s)
    s = get_screen(s or awful.screen.focused())
    local target = s:get_next_in_direction(dir)

    if target then
        screen.focus(target)
    end
end

function screen.focus_relative(offset)
    screen.focus(gmath.cycle(capi.screen.count(),
        awful.screen.focused().index + offset))
end

capi.screen.connect_signal("_focused", function(s) s:emit_signal("focused") end)

capi.client.connect_signal("focus", function(c)
    screen.focus(c.screen)
end)

capi.client.connect_signal("property::screen", function(c)
    if capi.client.focus == c then screen.focus(c.screen) end
end)

return setmetatable(screen, { __index = function(t, k) return awful.screen[k] end })
